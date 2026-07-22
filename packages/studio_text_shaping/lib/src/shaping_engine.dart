// High-level HarfBuzz shaping + glyph-outline extraction (ADR-041).
//
// Returns positioned glyph outlines as studio_geometry [Path]s in mm, so
// the embroidery stitch pipeline consumes shaped text the same way it
// consumes any vector contour. Falls back gracefully: [ShapingEngine.tryLoad]
// returns null when the native library is absent (web, or desktop without
// libharfbuzz bundled), and callers use the pure Dart glyf parser instead.
//
// ponytail: the draw-callback path is exercised only when a real
// libharfbuzz is present; the gated smoke test covers it there, and the
// fallback (engine == null) is unit-tested everywhere.
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'harfbuzz_ffi.dart';

/// One shaped glyph: its font glyph id, horizontal advance in mm, and
/// outline contours in mm (y-down, positioned at the run origin).
final class ShapedGlyph {
  ShapedGlyph({
    required this.glyphId,
    required this.cluster,
    required this.advanceMm,
    required this.outlines,
  });

  final int glyphId;

  /// Source character (rune) offset this glyph came from (HarfBuzz cluster).
  final int cluster;
  final double advanceMm;
  final List<Path> outlines;
}

/// A variable-font axis descriptor.
typedef AxisInfo = ({String tag, double min, double def, double max});

// Active outline builder for the synchronous draw callbacks. Shaping is
// single-threaded and draw runs entirely within one hb_font_draw_glyph
// call, so a single top-level pointer is safe and avoids user_data
// marshaling.
_GlyphOutlineBuilder? _active;

class _GlyphOutlineBuilder {
  final List<Path> paths = [];
  final List<Segment> _segments = [];
  double _startX = 0, _startY = 0;
  double _curX = 0, _curY = 0;
  bool _open = false;

  void moveTo(double x, double y) {
    _flush();
    _startX = _curX = x;
    _startY = _curY = y;
    _open = true;
  }

  void lineTo(double x, double y) {
    _segments.add(LineSegment(Point(x, y)));
    _curX = x;
    _curY = y;
  }

  void quadTo(double cx, double cy, double x, double y) {
    // Elevate quadratic to cubic (exact), matching the glyf parser.
    final c1 =
        Point(_curX + 2 / 3 * (cx - _curX), _curY + 2 / 3 * (cy - _curY));
    final c2 = Point(x + 2 / 3 * (cx - x), y + 2 / 3 * (cy - y));
    _segments.add(CubicSegment(c1, c2, Point(x, y)));
    _curX = x;
    _curY = y;
  }

  void cubicTo(
      double c1x, double c1y, double c2x, double c2y, double x, double y) {
    _segments.add(CubicSegment(Point(c1x, c1y), Point(c2x, c2y), Point(x, y)));
    _curX = x;
    _curY = y;
  }

  void close() {
    _flush();
  }

  void _flush() {
    if (_open && _segments.isNotEmpty) {
      paths.add(Path(
          start: Point(_startX, _startY),
          segments: List.of(_segments),
          closed: true));
    }
    _segments.clear();
    _open = false;
  }

  List<Path> finish() {
    _flush();
    return paths;
  }
}

// --- draw callbacks (font-unit coordinates, y-up) ---
void _moveTo(Pointer<HbDrawFuncs> _, Pointer<Void> __, Pointer<HbDrawState> ___,
        double x, double y, Pointer<Void> ____) =>
    _active?.moveTo(x, y);
void _lineTo(Pointer<HbDrawFuncs> _, Pointer<Void> __, Pointer<HbDrawState> ___,
        double x, double y, Pointer<Void> ____) =>
    _active?.lineTo(x, y);
void _quadTo(Pointer<HbDrawFuncs> _, Pointer<Void> __, Pointer<HbDrawState> ___,
        double cx, double cy, double x, double y, Pointer<Void> ____) =>
    _active?.quadTo(cx, cy, x, y);
void _cubicTo(
        Pointer<HbDrawFuncs> _,
        Pointer<Void> __,
        Pointer<HbDrawState> ___,
        double c1x,
        double c1y,
        double c2x,
        double c2y,
        double x,
        double y,
        Pointer<Void> ____) =>
    _active?.cubicTo(c1x, c1y, c2x, c2y, x, y);
void _close(Pointer<HbDrawFuncs> _, Pointer<Void> __, Pointer<HbDrawState> ___,
        Pointer<Void> ____) =>
    _active?.close();

/// HarfBuzz-backed shaper. Construct via [tryLoad]; a null result means
/// shaping is unavailable and the caller must fall back.
final class ShapingEngine {
  ShapingEngine._(this._hb, this._drawFuncs, this._keepAlive);

  final HarfBuzzLib _hb;
  final Pointer<HbDrawFuncs> _drawFuncs;
  // Keep NativeCallables alive for the engine's lifetime.
  // ignore: unused_field
  final List<Object> _keepAlive;

  bool get available => true;

  /// Loads HarfBuzz and wires the draw callbacks, or returns null.
  static ShapingEngine? tryLoad() {
    final hb = openHarfBuzz();
    if (hb == null) return null;
    try {
      final funcs = hb.drawFuncsCreate();
      if (funcs == nullptr) return null;
      final moveCb = NativeCallable<HbMoveToNative>.isolateLocal(_moveTo)
        ..keepIsolateAlive = false;
      final lineCb = NativeCallable<HbLineToNative>.isolateLocal(_lineTo)
        ..keepIsolateAlive = false;
      final quadCb = NativeCallable<HbQuadToNative>.isolateLocal(_quadTo)
        ..keepIsolateAlive = false;
      final cubicCb = NativeCallable<HbCubicToNative>.isolateLocal(_cubicTo)
        ..keepIsolateAlive = false;
      final closeCb = NativeCallable<HbCloseNative>.isolateLocal(_close)
        ..keepIsolateAlive = false;
      hb.setMoveTo(funcs, moveCb.nativeFunction, nullptr, nullptr);
      hb.setLineTo(funcs, lineCb.nativeFunction, nullptr, nullptr);
      hb.setQuadTo(funcs, quadCb.nativeFunction, nullptr, nullptr);
      hb.setCubicTo(funcs, cubicCb.nativeFunction, nullptr, nullptr);
      hb.setClose(funcs, closeCb.nativeFunction, nullptr, nullptr);
      return ShapingEngine._(
          hb, funcs, [moveCb, lineCb, quadCb, cubicCb, closeCb]);
    } on Object {
      return null;
    }
  }

  /// Shapes [text] with [fontBytes] at [sizeMm], applying variable-font
  /// [axes] and OpenType [features]. Returns positioned glyphs whose
  /// outlines are in mm (y-down), laid along the baseline from x=0.
  List<ShapedGlyph> shape(
    Uint8List fontBytes,
    String text, {
    double sizeMm = 10,
    Map<String, double> axes = const {},
    Map<String, int> features = const {},
    String? language,
    String? script,
  }) {
    return _withFace(fontBytes, (face, upem) {
      final font = _hb.fontCreate(face);
      final blobs = <Pointer<NativeType>>[];
      try {
        _applyAxes(font, axes, blobs);
        final buffer = _hb.bufferCreate();
        final textPtr = text.toNativeUtf8();
        blobs.add(textPtr.cast());
        _hb.bufferAddUtf8(buffer, textPtr, -1, 0, -1);
        _hb.bufferGuess(buffer);
        final featPtr = _buildFeatures(features, blobs);
        _hb.shape(font, buffer, featPtr, features.length);

        final countPtr = calloc<Uint32>();
        blobs.add(countPtr);
        final infos = _hb.bufferGetInfos(buffer, countPtr);
        final positions = _hb.bufferGetPositions(buffer, countPtr);
        final count = countPtr.value;
        final mmPerUnit = sizeMm / upem;

        final glyphs = <ShapedGlyph>[];
        var penX = 0.0;
        for (var i = 0; i < count; i++) {
          final info = infos[i];
          final pos = positions[i];
          final outlines = _drawGlyph(font, info.codepoint);
          final ox = penX + pos.xOffset * mmPerUnit;
          final oy = pos.yOffset * mmPerUnit;
          // Font units are y-up; flip to y-down and place at pen.
          final placed = [
            for (final p in outlines)
              p.transformed(Transform2(mmPerUnit, 0, 0, -mmPerUnit, ox, oy))
          ];
          glyphs.add(ShapedGlyph(
            glyphId: info.codepoint,
            cluster: info.cluster,
            advanceMm: pos.xAdvance * mmPerUnit,
            outlines: placed,
          ));
          penX += pos.xAdvance * mmPerUnit;
        }
        _hb.bufferDestroy(buffer.cast());
        return glyphs;
      } finally {
        _hb.fontDestroy(font.cast());
        for (final b in blobs) {
          calloc.free(b);
        }
      }
    });
  }

  /// Variable-font axes of [fontBytes] (empty for static fonts).
  List<AxisInfo> variationAxes(Uint8List fontBytes) {
    return _withFace(fontBytes, (face, _) {
      final countPtr = calloc<Uint32>();
      try {
        final total = _hb.varAxisInfos(face, 0, countPtr, nullptr);
        if (total == 0) return const <AxisInfo>[];
        final arr = calloc<HbOtVarAxisInfo>(total);
        countPtr.value = total;
        _hb.varAxisInfos(face, 0, countPtr, arr);
        final out = <AxisInfo>[];
        for (var i = 0; i < countPtr.value; i++) {
          final a = arr[i];
          out.add((
            tag: tagString(a.tag),
            min: a.minValue,
            def: a.defaultValue,
            max: a.maxValue,
          ));
        }
        calloc.free(arr);
        return out;
      } finally {
        calloc.free(countPtr);
      }
    });
  }

  /// GSUB+GPOS feature tags available in [fontBytes].
  List<String> availableFeatures(Uint8List fontBytes) {
    return _withFace(fontBytes, (face, _) {
      final tags = <String>{};
      for (final table in ['GSUB', 'GPOS']) {
        tags.addAll(_tableFeatures(face, table));
      }
      final list = tags.toList()..sort();
      return list;
    });
  }

  List<String> _tableFeatures(Pointer<HbFace> face, String table) {
    final countPtr = calloc<Uint32>();
    try {
      final total = _hb.featureTags(face, hbTag(table), 0, countPtr, nullptr);
      if (total == 0) return const [];
      final arr = calloc<Uint32>(total);
      countPtr.value = total;
      _hb.featureTags(face, hbTag(table), 0, countPtr, arr);
      final out = <String>[];
      for (var i = 0; i < countPtr.value; i++) {
        out.add(tagString(arr[i]));
      }
      calloc.free(arr);
      return out;
    } finally {
      calloc.free(countPtr);
    }
  }

  List<Path> _drawGlyph(Pointer<HbFont> font, int glyphId) {
    final builder = _GlyphOutlineBuilder();
    _active = builder;
    try {
      _hb.fontDrawGlyph(font, glyphId, _drawFuncs, nullptr);
    } finally {
      _active = null;
    }
    return builder.finish();
  }

  void _applyAxes(Pointer<HbFont> font, Map<String, double> axes,
      List<Pointer<NativeType>> blobs) {
    if (axes.isEmpty) return;
    final arr = calloc<HbVariation>(axes.length);
    blobs.add(arr);
    var i = 0;
    for (final e in axes.entries) {
      arr[i].tag = hbTag(e.key);
      arr[i].value = e.value;
      i++;
    }
    _hb.fontSetVariations(font, arr, axes.length);
  }

  Pointer<HbFeature> _buildFeatures(
      Map<String, int> features, List<Pointer<NativeType>> blobs) {
    if (features.isEmpty) return nullptr;
    final arr = calloc<HbFeature>(features.length);
    blobs.add(arr);
    var i = 0;
    for (final e in features.entries) {
      arr[i].tag = hbTag(e.key);
      arr[i].value = e.value;
      arr[i].start = 0;
      arr[i].end = 0xffffffff;
      i++;
    }
    return arr;
  }

  T _withFace<T>(
      Uint8List fontBytes, T Function(Pointer<HbFace> face, int upem) body) {
    final data = calloc<Uint8>(fontBytes.length);
    data.asTypedList(fontBytes.length).setAll(0, fontBytes);
    // HB_MEMORY_MODE_DUPLICATE = 0 → HarfBuzz copies; we free `data` after.
    final blob = _hb.blobCreate(data, fontBytes.length, 0, nullptr, nullptr);
    final face = _hb.faceCreate(blob, 0);
    final upem = _hb.faceUpem(face);
    try {
      return body(face, upem == 0 ? 1000 : upem);
    } finally {
      _hb.faceDestroy(face.cast());
      _hb.blobDestroy(blob.cast());
      calloc.free(data);
    }
  }
}
