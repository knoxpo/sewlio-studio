import 'dart:typed_data';

import 'package:studio_geometry/studio_geometry.dart';

import 'text_font.dart';

/// A system font parsed from TrueType bytes (`.ttf`, first face of a
/// `.ttc`). Glyph outlines come from the `glyf` table; quadratic
/// contours are emitted as exact cubic Béziers.
///
/// [sizeMm] is the em size (like point size in design apps).
// ponytail: TrueType `glyf` outlines only — CFF/`.otf`, kerning pairs,
// and OpenType shaping (ligatures, scripts) wait for a real shaping
// engine (HarfBuzz). Composite glyphs and cmap formats 4/12 are enough
// for Latin system fonts.
final class TtfTextFont implements TextFont {
  TtfTextFont._(this._data, this._tables, this.family, this.styleName,
      this._unitsPerEm, this._longLoca, this._numGlyphs, this._hMetricCount);

  final ByteData _data;
  final Map<String, (int, int)> _tables; // tag -> (offset, length)

  /// Typographic family (nameID 1) — the grouping key for style
  /// variants ('Arial', not 'Arial Bold').
  @override
  final String family;

  /// Face subfamily (nameID 2): 'Regular', 'Bold', 'Italic', …
  final String styleName;
  final int _unitsPerEm;
  final bool _longLoca;
  final int _numGlyphs;
  final int _hMetricCount;

  final Map<int, int> _glyphIndexCache = {};

  /// Parses [bytes]; returns null when the file is not TrueType-glyf
  /// (e.g. CFF-based `.otf`) or is malformed. [faceIndex] selects a
  /// face inside a `.ttc` collection (ignored for single-face files).
  static TtfTextFont? tryParse(Uint8List bytes, {int faceIndex = 0}) {
    try {
      final data = ByteData.sublistView(bytes);
      var offset = 0;
      final version = data.getUint32(0);
      if (version == 0x74746366 /* 'ttcf' */) {
        if (faceIndex >= data.getUint32(8)) return null;
        offset = data.getUint32(12 + faceIndex * 4);
      } else if (faceIndex > 0) {
        return null; // Single-face file has no further faces.
      }
      final sfnt = data.getUint32(offset);
      if (sfnt != 0x00010000 && sfnt != 0x74727565 /* 'true' */) {
        return null; // 'OTTO' (CFF) and friends unsupported.
      }
      final numTables = data.getUint16(offset + 4);
      final tables = <String, (int, int)>{};
      for (var i = 0; i < numTables; i++) {
        final record = offset + 12 + i * 16;
        final tag = String.fromCharCodes(bytes, record, record + 4);
        tables[tag] = (data.getUint32(record + 8), data.getUint32(record + 12));
      }
      final head = tables['head']?.$1;
      final maxp = tables['maxp']?.$1;
      final hhea = tables['hhea']?.$1;
      if (head == null ||
          maxp == null ||
          hhea == null ||
          !tables.containsKey('glyf') ||
          !tables.containsKey('loca') ||
          !tables.containsKey('cmap') ||
          !tables.containsKey('hmtx')) {
        return null;
      }
      return TtfTextFont._(
        data,
        tables,
        _readName(data, bytes, tables['name'], const [1, 4]) ?? 'Unknown',
        _readName(data, bytes, tables['name'], const [2]) ?? 'Regular',
        data.getUint16(head + 18),
        data.getInt16(head + 50) == 1,
        data.getUint16(maxp + 4),
        data.getUint16(hhea + 34),
      );
    } catch (_) {
      return null;
    }
  }

  /// Number of faces in [bytes]: >1 for `.ttc` collections, 1 for
  /// plain `.ttf`, 0 when unreadable.
  static int faceCount(Uint8List bytes) {
    try {
      final data = ByteData.sublistView(bytes);
      return data.getUint32(0) == 0x74746366 /* 'ttcf' */
          ? data.getUint32(8)
          : 1;
    } catch (_) {
      return 0;
    }
  }

  /// First non-empty name-table entry among [wantedIds], in order
  /// (family = [1, 4] fallback, subfamily = [2]). Prefers English
  /// entries — style grouping matches on 'Bold'/'Italic', so a
  /// localized subfamily ('Negreta') must not win over 'Bold'.
  static String? _readName(
      ByteData data, Uint8List bytes, (int, int)? name, List<int> wantedIds) {
    if (name == null) return null;
    final base = name.$1;
    final count = data.getUint16(base + 2);
    final strings = base + data.getUint16(base + 4);
    for (final wantedId in wantedIds) {
      String? best;
      var bestScore = -1;
      for (var i = 0; i < count; i++) {
        final r = base + 6 + i * 12;
        final platform = data.getUint16(r);
        final language = data.getUint16(r + 4);
        final nameId = data.getUint16(r + 6);
        if (nameId != wantedId) continue;
        final length = data.getUint16(r + 8);
        final start = strings + data.getUint16(r + 10);
        final score = switch (platform) {
          3 when language == 0x409 => 4, // Windows en-US
          3 => 2,
          0 => 3, // Unicode (no language)
          1 when language == 0 => 1, // Mac English
          _ => 0,
        };
        if (score <= bestScore) continue;
        final value = platform == 1
            ? String.fromCharCodes(bytes, start, start + length)
            : String.fromCharCodes([
                for (var j = 0; j < length; j += 2) data.getUint16(start + j),
              ]);
        if (value.isEmpty) continue;
        best = value;
        bestScore = score;
      }
      if (best != null) return best;
    }
    return null;
  }

  // ------------------------------------------------------------- metrics

  double _scale(double sizeMm) => sizeMm / _unitsPerEm;

  // ponytail: `glyf`-only parser has no shaping/variation tables wired
  // up, so it reports no variation/feature support until a shaping
  // engine lands. Family-level style variants (Bold/Italic faces) are
  // grouped by the app's FontLibrary; a single face knows only its own
  // subfamily name.
  @override
  List<String> get styleNames => [styleName];

  @override
  List<({String tag, double min, double def, double max})> variationAxes() =>
      const [];

  @override
  List<String> availableFeatures() => const [];

  @override
  bool supportsFeature(String tag) => false;

  @override
  bool supports(int rune) => _glyphIndex(rune) != 0;

  @override
  double advanceMm(int rune, double sizeMm) {
    final glyph = _glyphIndex(rune);
    final (hmtx, _) = _tables['hmtx']!;
    final index = glyph < _hMetricCount ? glyph : _hMetricCount - 1;
    return _data.getUint16(hmtx + index * 4) * _scale(sizeMm);
  }

  @override
  List<Path> glyphPaths(int rune, Point origin, double sizeMm) {
    final contours = _contours(_glyphIndex(rune), 0);
    final scale = _scale(sizeMm);
    Point map(_Pt p) => Point(origin.x + p.x * scale, origin.y - p.y * scale);
    final paths = <Path>[];
    for (final contour in contours) {
      if (contour.length < 2) continue;
      final segments = <Segment>[];
      final start = map(contour.first.$1);
      var current = start;
      for (final (onPoint, control) in contour.skip(1)) {
        final end = map(onPoint);
        if (control == null) {
          segments.add(LineSegment(end));
        } else {
          // Quadratic → exact cubic elevation.
          final q = map(control);
          segments.add(CubicSegment(
            Point(current.x + 2 / 3 * (q.x - current.x),
                current.y + 2 / 3 * (q.y - current.y)),
            Point(end.x + 2 / 3 * (q.x - end.x), end.y + 2 / 3 * (q.y - end.y)),
            end,
          ));
        }
        current = end;
      }
      paths.add(Path(start: start, segments: segments, closed: true));
    }
    return paths;
  }

  // ---------------------------------------------------------------- cmap

  int _glyphIndex(int rune) => _glyphIndexCache[rune] ??= _lookupGlyph(rune);

  int _lookupGlyph(int rune) {
    final (cmap, _) = _tables['cmap']!;
    final subtableCount = _data.getUint16(cmap + 2);
    var best = 0;
    var bestScore = -1;
    for (var i = 0; i < subtableCount; i++) {
      final r = cmap + 4 + i * 8;
      final platform = _data.getUint16(r);
      final encoding = _data.getUint16(r + 2);
      final offset = cmap + _data.getUint32(r + 4);
      final format = _data.getUint16(offset);
      final score = switch ((platform, encoding, format)) {
        (3, 10, 12) => 4,
        (0, _, 12) => 3,
        (3, 1, 4) => 2,
        (0, _, 4) => 1,
        _ => -1,
      };
      if (score > bestScore) {
        best = offset;
        bestScore = score;
      }
    }
    if (bestScore < 0) return 0;
    final format = _data.getUint16(best);
    return format == 12 ? _cmap12(best, rune) : _cmap4(best, rune);
  }

  int _cmap4(int table, int rune) {
    if (rune > 0xFFFF) return 0;
    final segCount = _data.getUint16(table + 6) ~/ 2;
    final ends = table + 14;
    final starts = ends + segCount * 2 + 2;
    final deltas = starts + segCount * 2;
    final rangeOffsets = deltas + segCount * 2;
    for (var seg = 0; seg < segCount; seg++) {
      if (_data.getUint16(ends + seg * 2) < rune) continue;
      final startCode = _data.getUint16(starts + seg * 2);
      if (startCode > rune) return 0;
      final rangeOffset = _data.getUint16(rangeOffsets + seg * 2);
      if (rangeOffset == 0) {
        return (rune + _data.getInt16(deltas + seg * 2)) & 0xFFFF;
      }
      final glyphAt =
          rangeOffsets + seg * 2 + rangeOffset + (rune - startCode) * 2;
      final glyph = _data.getUint16(glyphAt);
      return glyph == 0
          ? 0
          : (glyph + _data.getInt16(deltas + seg * 2)) & 0xFFFF;
    }
    return 0;
  }

  int _cmap12(int table, int rune) {
    final groups = _data.getUint32(table + 12);
    for (var i = 0; i < groups; i++) {
      final g = table + 16 + i * 12;
      final start = _data.getUint32(g);
      final end = _data.getUint32(g + 4);
      if (rune < start) return 0;
      if (rune <= end) return _data.getUint32(g + 8) + (rune - start);
    }
    return 0;
  }

  // ---------------------------------------------------------------- glyf

  /// Contours as lists of (onCurvePoint, precedingQuadControl?) — the
  /// first entry is the contour start (control always null there).
  List<List<(_Pt, _Pt?)>> _contours(int glyph, int depth) {
    if (glyph <= 0 || glyph >= _numGlyphs || depth > 4) return const [];
    final (loca, _) = _tables['loca']!;
    final (glyf, _) = _tables['glyf']!;
    final int start, end;
    if (_longLoca) {
      start = _data.getUint32(loca + glyph * 4);
      end = _data.getUint32(loca + glyph * 4 + 4);
    } else {
      start = _data.getUint16(loca + glyph * 2) * 2;
      end = _data.getUint16(loca + glyph * 2 + 2) * 2;
    }
    if (end <= start) return const []; // Empty glyph (e.g. space).
    final g = glyf + start;
    final contourCount = _data.getInt16(g);
    return contourCount >= 0
        ? _simpleGlyph(g, contourCount)
        : _compositeGlyph(g, depth);
  }

  List<List<(_Pt, _Pt?)>> _simpleGlyph(int g, int contourCount) {
    final endPts = [
      for (var i = 0; i < contourCount; i++) _data.getUint16(g + 10 + i * 2),
    ];
    final pointCount = endPts.isEmpty ? 0 : endPts.last + 1;
    var p = g + 10 + contourCount * 2;
    p += 2 + _data.getUint16(p); // Skip instructions.

    // Flags with repeat expansion.
    final flags = Uint8List(pointCount);
    for (var i = 0; i < pointCount;) {
      final flag = _data.getUint8(p++);
      flags[i++] = flag;
      if (flag & 8 != 0) {
        var repeat = _data.getUint8(p++);
        while (repeat-- > 0 && i < pointCount) {
          flags[i++] = flag;
        }
      }
    }
    // Coordinates (deltas).
    final xs = List<double>.filled(pointCount, 0);
    var x = 0;
    for (var i = 0; i < pointCount; i++) {
      final flag = flags[i];
      if (flag & 2 != 0) {
        final d = _data.getUint8(p++);
        x += flag & 16 != 0 ? d : -d;
      } else if (flag & 16 == 0) {
        x += _data.getInt16(p);
        p += 2;
      }
      xs[i] = x.toDouble();
    }
    final ys = List<double>.filled(pointCount, 0);
    var y = 0;
    for (var i = 0; i < pointCount; i++) {
      final flag = flags[i];
      if (flag & 4 != 0) {
        final d = _data.getUint8(p++);
        y += flag & 32 != 0 ? d : -d;
      } else if (flag & 32 == 0) {
        y += _data.getInt16(p);
        p += 2;
      }
      ys[i] = y.toDouble();
    }

    // TrueType quadratic contours → (on-curve, control) sequences with
    // implied on-curve midpoints between consecutive off-curve points.
    final contours = <List<(_Pt, _Pt?)>>[];
    var first = 0;
    for (final last in endPts) {
      final n = last - first + 1;
      if (n < 2) {
        first = last + 1;
        continue;
      }
      _Pt at(int i) {
        final j = first + i % n;
        return _Pt(xs[j], ys[j], flags[j] & 1 != 0);
      }

      // Rotate so the contour starts on-curve (or a synthesized
      // midpoint when the contour is all control points).
      var startIndex = 0;
      while (startIndex < n && !at(startIndex).onCurve) {
        startIndex++;
      }
      final all = <_Pt>[];
      if (startIndex == n) {
        all.add(_Pt.mid(at(0), at(1)));
        startIndex = 0;
      } else {
        all.add(at(startIndex));
      }
      for (var i = 1; i <= n; i++) {
        all.add(at(startIndex + i));
      }

      final contour = <(_Pt, _Pt?)>[(all.first, null)];
      _Pt? control;
      for (var i = 1; i < all.length; i++) {
        final point = all[i];
        if (point.onCurve) {
          contour.add((point, control));
          control = null;
        } else {
          if (control != null) {
            contour.add((_Pt.mid(control, point), control));
          }
          control = point;
        }
      }
      if (control != null) contour.add((all.first, control));
      contours.add(contour);
      first = last + 1;
    }
    return contours;
  }

  List<List<(_Pt, _Pt?)>> _compositeGlyph(int g, int depth) {
    final contours = <List<(_Pt, _Pt?)>>[];
    var p = g + 10;
    while (true) {
      final flags = _data.getUint16(p);
      final glyphIndex = _data.getUint16(p + 2);
      p += 4;
      final double dx, dy;
      if (flags & 1 != 0) {
        dx = _data.getInt16(p).toDouble();
        dy = _data.getInt16(p + 2).toDouble();
        p += 4;
      } else {
        dx = _data.getInt8(p).toDouble();
        dy = _data.getInt8(p + 1).toDouble();
        p += 2;
      }
      double a = 1, b = 0, c = 0, d = 1;
      if (flags & 8 != 0) {
        a = d = _f2dot14(p);
        p += 2;
      } else if (flags & 0x40 != 0) {
        a = _f2dot14(p);
        d = _f2dot14(p + 2);
        p += 4;
      } else if (flags & 0x80 != 0) {
        a = _f2dot14(p);
        b = _f2dot14(p + 2);
        c = _f2dot14(p + 4);
        d = _f2dot14(p + 6);
        p += 8;
      }
      for (final contour in _contours(glyphIndex, depth + 1)) {
        contours.add([
          for (final (point, control) in contour)
            (
              point.transform(a, b, c, d, dx, dy),
              control?.transform(a, b, c, d, dx, dy),
            ),
        ]);
      }
      if (flags & 0x20 == 0) break; // MORE_COMPONENTS
    }
    return contours;
  }

  double _f2dot14(int offset) => _data.getInt16(offset) / 16384;
}

final class _Pt {
  const _Pt(this.x, this.y, [this.onCurve = true]);

  final double x;
  final double y;
  final bool onCurve;

  static _Pt mid(_Pt a, _Pt b) => _Pt((a.x + b.x) / 2, (a.y + b.y) / 2);

  _Pt transform(double a, double b, double c, double d, double dx, double dy) =>
      _Pt(a * x + c * y + dx, b * x + d * y + dy, onCurve);
}
