import 'dart:math' as math;

import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';

/// Horizontal alignment of laid-out text (about the origin for point
/// text, within the frame for area text).
enum MonoTextAlign { left, center, right }

/// A vector font the Text tool can lay out: per-rune advances and
/// outline/stroke paths. Implementations: the built-in monoline stroke
/// font and parsed TrueType files ([TtfTextFont]).
abstract interface class TextFont {
  /// Display name shown in the font dropdown.
  String get family;

  /// Whether [rune] has a real glyph (unsupported runes still advance).
  bool supports(int rune);

  /// Pen advance for [rune] at [sizeMm], excluding tracking.
  double advanceMm(int rune, double sizeMm);

  /// Glyph geometry for [rune] with the baseline-left pen position at
  /// [origin]. Monoline returns open strokes; TTF returns closed
  /// outlines — both stitch as running-stitch paths.
  List<Path> glyphPaths(int rune, Point origin, double sizeMm);

  // --------------------------------------------------------- capabilities
  //
  // Honest capability queries so the character panel can enable/disable
  // typography controls per font. Fonts that expose nothing return the
  // empty/false answers below.

  /// Selectable weight/italic styles (e.g. 'Regular', 'Bold', 'Italic').
  List<String> get styleNames;

  /// Variable-font axes as (tag, min, default, max) tuples; empty when
  /// the font is not variable.
  List<({String tag, double min, double def, double max})> variationAxes();

  /// OpenType feature tags the font carries (e.g. 'liga', 'smcp').
  List<String> availableFeatures();

  /// Whether [tag] is an OpenType feature this font supports.
  bool supportsFeature(String tag);
}

// ----------------------------------------------------------------- layout
//
// Run-aware layout (ADR-040): every layout entry point takes an optional
// `attrsOf(runeOffset)` that resolves the fully-merged attributes (object
// defaults ⊕ style run) at an ABSOLUTE rune offset into the full `text`.
// When null, behavior is identical to the pre-run pipeline. Absolute rune
// offsets are threaded through wrapping so `attrsOf` always sees the right
// index even after '\n' splits and word breaks drop characters.

/// One laid-out character: its absolute rune offset into the full text
/// and its rune value.
typedef _Glyph = (int offset, int rune);

/// A visual line after wrapping: its starting absolute rune offset (used
/// for caret placement on empty lines) and its glyphs.
typedef _Line = ({int startOffset, List<_Glyph> glyphs});

/// Caret/hit-test metrics for one visual line: the baseline Y, and per
/// boundary the absolute rune offset and pen X. [offsets]/[xs] have one
/// entry per rune plus a trailing entry for the line-end caret.
typedef TextLineMetrics = ({
  double baselineY,
  double startX,
  List<int> offsets,
  List<double> xs,
});

List<_Glyph> _glyphsOf(String text) {
  final out = <_Glyph>[];
  var i = 0;
  for (final rune in text.runes) {
    out.add((i++, rune));
  }
  return out;
}

double _runeSize(CharAttrs Function(int)? attrsOf, int offset, double sizeMm) =>
    attrsOf == null ? sizeMm : (attrsOf(offset).sizeMm ?? sizeMm);

double _runeTracking(
        CharAttrs Function(int)? attrsOf, int offset, double trackingMm) =>
    attrsOf == null ? trackingMm : (attrsOf(offset).trackingMm ?? trackingMm);

double _glyphsWidth(List<_Glyph> glyphs, TextFont font, double sizeMm,
    double trackingMm, CharAttrs Function(int)? attrsOf) {
  var width = 0.0;
  for (final (offset, rune) in glyphs) {
    width += font.advanceMm(rune, _runeSize(attrsOf, offset, sizeMm)) +
        _runeTracking(attrsOf, offset, trackingMm);
  }
  return width;
}

/// Splits [text] into wrapped visual lines carrying absolute rune
/// offsets: explicit '\n' breaks always; [frameWidthMm] adds greedy word
/// wrapping (area text). Mirrors the original String-based wrap exactly.
List<_Line> _wrapLines(
  String text,
  TextFont font, {
  required double sizeMm,
  required double trackingMm,
  double? frameWidthMm,
  CharAttrs Function(int)? attrsOf,
}) {
  final paragraphs = <_Line>[];
  var para = <_Glyph>[];
  var paraStart = 0;
  for (final g in _glyphsOf(text)) {
    if (g.$2 == 0x0A /* \n */) {
      paragraphs.add((startOffset: paraStart, glyphs: para));
      para = [];
      paraStart = g.$1 + 1;
    } else {
      para.add(g);
    }
  }
  paragraphs.add((startOffset: paraStart, glyphs: para));
  if (frameWidthMm == null) return paragraphs;

  final lines = <_Line>[];
  for (final paragraph in paragraphs) {
    // Split at spaces exactly like `String.split(' ')`: consecutive
    // spaces yield empty words; `spaces[i]` is the separator that
    // followed `words[i]`.
    final words = <List<_Glyph>>[];
    final spaces = <_Glyph>[];
    var word = <_Glyph>[];
    for (final g in paragraph.glyphs) {
      if (g.$2 == 0x20 /* space */) {
        words.add(word);
        spaces.add(g);
        word = [];
      } else {
        word.add(g);
      }
    }
    words.add(word);

    var line = <_Glyph>[];
    var lineStart = paragraph.startOffset;
    for (var i = 0; i < words.length; i++) {
      final candidate =
          line.isEmpty ? [...words[i]] : [...line, spaces[i - 1], ...words[i]];
      if (_glyphsWidth(candidate, font, sizeMm, trackingMm, attrsOf) <=
              frameWidthMm ||
          line.isEmpty) {
        if (line.isEmpty && words[i].isNotEmpty) {
          lineStart = words[i].first.$1;
        }
        line = candidate;
      } else {
        lines.add((startOffset: lineStart, glyphs: line));
        line = [...words[i]];
        lineStart = words[i].isEmpty ? spaces[i - 1].$1 + 1 : words[i].first.$1;
      }
    }
    lines.add((startOffset: lineStart, glyphs: line));
  }
  return lines;
}

double textLineWidthMm(String line, TextFont font, double sizeMm,
        {double trackingMm = 0, CharAttrs Function(int runeOffset)? attrsOf}) =>
    _glyphsWidth(_glyphsOf(line), font, sizeMm, trackingMm, attrsOf);

/// Splits [text] into visual lines: explicit '\n' breaks always;
/// [frameWidthMm] adds greedy word wrapping (area text). [attrsOf], when
/// given, resolves per-rune size/tracking so wrap widths honor runs.
List<String> wrapText(
  String text,
  TextFont font, {
  required double sizeMm,
  double trackingMm = 0,
  double? frameWidthMm,
  CharAttrs Function(int runeOffset)? attrsOf,
}) =>
    [
      for (final line in _wrapLines(text, font,
          sizeMm: sizeMm,
          trackingMm: trackingMm,
          frameWidthMm: frameWidthMm,
          attrsOf: attrsOf))
        String.fromCharCodes([for (final (_, rune) in line.glyphs) rune]),
    ];

double _lineOffsetX(
    _Line line,
    TextFont font,
    MonoTextAlign align,
    double sizeMm,
    double trackingMm,
    double? frameWidthMm,
    CharAttrs Function(int)? attrsOf) {
  final width = _glyphsWidth(line.glyphs, font, sizeMm, trackingMm, attrsOf);
  final field = frameWidthMm ?? 0;
  return switch (align) {
    MonoTextAlign.left => 0,
    MonoTextAlign.center => (field - width) / 2,
    MonoTextAlign.right => field - width,
  };
}

// ponytail: Transform2 has no shear factory; build the 2x3 shear matrix
// directly (x' = x + xy·y). Upgrade to a named factory if geometry grows
// one.
Transform2 _shear(double xy) => Transform2(1, 0, xy, 1, 0, 0);

/// Per-glyph affine from [attrs], applied about the glyph baseline origin
/// ([px], [py]); null when [attrs] requests no glyph-level transform (the
/// common case — keeps output byte-identical to the untransformed path).
/// Composition order: scale, then skew, then rotate, then baseline shift
/// (negative Y is up, matching the file's Y-down world).
Transform2? _glyphTransform(CharAttrs attrs, double px, double py) {
  final shift = attrs.baselineShiftMm ?? 0;
  final hScale = attrs.hScale ?? 1.0;
  final vScale = attrs.vScale ?? 1.0;
  final skew = attrs.skewDeg ?? 0;
  final rotation = attrs.rotationDeg ?? 0;
  if (shift == 0 &&
      hScale == 1.0 &&
      vScale == 1.0 &&
      skew == 0 &&
      rotation == 0) {
    return null;
  }
  var m = Transform2.identity;
  if (rotation != 0) m = m * Transform2.rotation(rotation * math.pi / 180);
  if (skew != 0) m = m * _shear(math.tan(skew * math.pi / 180));
  if (hScale != 1.0 || vScale != 1.0) {
    m = m * Transform2.scaling(hScale, vScale);
  }
  // Translate the glyph origin to 0, apply m, translate back and lift by
  // the baseline shift (up = -Y).
  return Transform2.translation(px, py - shift) *
      m *
      Transform2.translation(-px, -py);
}

/// Lays [text] out as stitchable paths. [origin] is the first
/// baseline's left (or the frame's left for area text); '\n' starts a
/// new line; [lineHeight] is the baseline distance as a multiple of
/// [sizeMm]. When [attrsOf] is given, each rune's size/tracking and a
/// per-glyph affine (baseline shift, scale, skew, rotation) come from its
/// resolved attributes.
List<Path> layoutText(
  String text,
  TextFont font, {
  required Point origin,
  double sizeMm = 10,
  double trackingMm = 0,
  double lineHeight = 1.4,
  MonoTextAlign align = MonoTextAlign.left,
  double? frameWidthMm,
  CharAttrs Function(int runeOffset)? attrsOf,
}) {
  final paths = <Path>[];
  final lines = _wrapLines(text, font,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      frameWidthMm: frameWidthMm,
      attrsOf: attrsOf);
  for (final (index, line) in lines.indexed) {
    final baselineY = origin.y + index * lineHeight * sizeMm;
    var penX = origin.x +
        _lineOffsetX(
            line, font, align, sizeMm, trackingMm, frameWidthMm, attrsOf);
    for (final (offset, rune) in line.glyphs) {
      final size = _runeSize(attrsOf, offset, sizeMm);
      final glyphPaths = font.glyphPaths(rune, Point(penX, baselineY), size);
      if (attrsOf == null) {
        paths.addAll(glyphPaths);
      } else {
        final t = _glyphTransform(attrsOf(offset), penX, baselineY);
        paths.addAll(t == null
            ? glyphPaths
            : [for (final p in glyphPaths) p.transformed(t)]);
      }
      penX += font.advanceMm(rune, size) +
          _runeTracking(attrsOf, offset, trackingMm);
    }
  }
  return paths;
}

/// One laid-out glyph's slice of a [layoutText] result: the character,
/// its ABSOLUTE rune offset into the full text (repeats/newlines keep
/// glyphs distinguishable), and how many outline paths it contributed.
/// Glyph-level inspection (Stitches panel) partitions a TextObject's
/// cached outlines with these counts — the document keeps one editable
/// text object; this grouping is derived, never stored.
typedef GlyphGroup = ({String char, int index, int outlineCount});

/// Per-glyph outline grouping matching [layoutText]'s concatenation
/// order exactly (same wrapping, same rune order). Zero-outline glyphs
/// (spaces, unsupported runes) are included so indexes stay aligned
/// with the visible text; callers may skip them for display.
List<GlyphGroup> glyphOutlineGroups(
  String text,
  TextFont font, {
  double sizeMm = 10,
  double trackingMm = 0,
  double? frameWidthMm,
  CharAttrs Function(int runeOffset)? attrsOf,
}) {
  final groups = <GlyphGroup>[];
  final lines = _wrapLines(text, font,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      frameWidthMm: frameWidthMm,
      attrsOf: attrsOf);
  for (final line in lines) {
    for (final (offset, rune) in line.glyphs) {
      groups.add((
        char: String.fromCharCode(rune),
        index: offset,
        outlineCount: font
            .glyphPaths(rune, Point.zero, _runeSize(attrsOf, offset, sizeMm))
            .length,
      ));
    }
  }
  return groups;
}

/// Per-line caret/hit-test metrics under the same layout parameters as
/// [layoutText] — the single source the Text tool uses for caret
/// placement, pointer hit-testing, and selection highlighting.
List<TextLineMetrics> layoutLineMetrics(
  String text,
  TextFont font, {
  required Point origin,
  double sizeMm = 10,
  double trackingMm = 0,
  double lineHeight = 1.4,
  MonoTextAlign align = MonoTextAlign.left,
  double? frameWidthMm,
  CharAttrs Function(int runeOffset)? attrsOf,
}) {
  final lines = _wrapLines(text, font,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      frameWidthMm: frameWidthMm,
      attrsOf: attrsOf);
  final out = <TextLineMetrics>[];
  for (final (index, line) in lines.indexed) {
    final baselineY = origin.y + index * lineHeight * sizeMm;
    final startX = origin.x +
        _lineOffsetX(
            line, font, align, sizeMm, trackingMm, frameWidthMm, attrsOf);
    final offsets = <int>[];
    final xs = <double>[];
    var penX = startX;
    for (final (offset, rune) in line.glyphs) {
      offsets.add(offset);
      xs.add(penX);
      penX += font.advanceMm(rune, _runeSize(attrsOf, offset, sizeMm)) +
          _runeTracking(attrsOf, offset, trackingMm);
    }
    // Trailing line-end caret boundary.
    offsets
        .add(line.glyphs.isEmpty ? line.startOffset : line.glyphs.last.$1 + 1);
    xs.add(penX);
    out.add((baselineY: baselineY, startX: startX, offsets: offsets, xs: xs));
  }
  return out;
}

/// Caret position (baseline point after the last character) under the
/// same layout parameters as [layoutText].
Point layoutCaret(
  String text,
  TextFont font, {
  required Point origin,
  double sizeMm = 10,
  double trackingMm = 0,
  double lineHeight = 1.4,
  MonoTextAlign align = MonoTextAlign.left,
  double? frameWidthMm,
  CharAttrs Function(int runeOffset)? attrsOf,
}) {
  final lines = _wrapLines(text, font,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      frameWidthMm: frameWidthMm,
      attrsOf: attrsOf);
  final last = lines.last;
  final baselineY = origin.y + (lines.length - 1) * lineHeight * sizeMm;
  final x = origin.x +
      _lineOffsetX(
          last, font, align, sizeMm, trackingMm, frameWidthMm, attrsOf) +
      _glyphsWidth(last.glyphs, font, sizeMm, trackingMm, attrsOf);
  return Point(x, baselineY);
}
