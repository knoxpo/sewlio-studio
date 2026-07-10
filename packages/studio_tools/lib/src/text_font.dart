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
}

// ----------------------------------------------------------------- layout

double textLineWidthMm(String line, TextFont font, double sizeMm,
    {double trackingMm = 0}) {
  var width = 0.0;
  for (final rune in line.runes) {
    width += font.advanceMm(rune, sizeMm) + trackingMm;
  }
  return width;
}

/// Splits [text] into visual lines: explicit '\n' breaks always;
/// [frameWidthMm] adds greedy word wrapping (area text).
List<String> wrapText(
  String text,
  TextFont font, {
  required double sizeMm,
  double trackingMm = 0,
  double? frameWidthMm,
}) {
  final paragraphs = text.split('\n');
  if (frameWidthMm == null) return paragraphs;
  double width(String line) =>
      textLineWidthMm(line, font, sizeMm, trackingMm: trackingMm);
  final lines = <String>[];
  for (final paragraph in paragraphs) {
    var line = '';
    for (final word in paragraph.split(' ')) {
      final candidate = line.isEmpty ? word : '$line $word';
      if (width(candidate) <= frameWidthMm || line.isEmpty) {
        line = candidate;
      } else {
        lines.add(line);
        line = word;
      }
    }
    lines.add(line);
  }
  return lines;
}

double _lineOffsetX(String line, TextFont font, MonoTextAlign align,
    double sizeMm, double trackingMm, double? frameWidthMm) {
  final width = textLineWidthMm(line, font, sizeMm, trackingMm: trackingMm);
  final field = frameWidthMm ?? 0;
  return switch (align) {
    MonoTextAlign.left => 0,
    MonoTextAlign.center => (field - width) / 2,
    MonoTextAlign.right => field - width,
  };
}

/// Lays [text] out as stitchable paths. [origin] is the first
/// baseline's left (or the frame's left for area text); '\n' starts a
/// new line; [lineHeight] is the baseline distance as a multiple of
/// [sizeMm].
List<Path> layoutText(
  String text,
  TextFont font, {
  required Point origin,
  double sizeMm = 10,
  double trackingMm = 0,
  double lineHeight = 1.4,
  MonoTextAlign align = MonoTextAlign.left,
  double? frameWidthMm,
}) {
  final paths = <Path>[];
  final lines = wrapText(text, font,
      sizeMm: sizeMm, trackingMm: trackingMm, frameWidthMm: frameWidthMm);
  for (final (index, line) in lines.indexed) {
    final baselineY = origin.y + index * lineHeight * sizeMm;
    var penX = origin.x +
        _lineOffsetX(line, font, align, sizeMm, trackingMm, frameWidthMm);
    for (final rune in line.runes) {
      paths.addAll(font.glyphPaths(rune, Point(penX, baselineY), sizeMm));
      penX += font.advanceMm(rune, sizeMm) + trackingMm;
    }
  }
  return paths;
}

/// One laid-out glyph's slice of a [layoutText] result: the character,
/// its 0-based position in layout order, and how many outline paths it
/// contributed. Glyph-level inspection (Stitches panel) partitions a
/// TextObject's cached outlines with these counts — the document keeps
/// one editable text object; this grouping is derived, never stored.
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
}) {
  final groups = <GlyphGroup>[];
  final lines = wrapText(text, font,
      sizeMm: sizeMm, trackingMm: trackingMm, frameWidthMm: frameWidthMm);
  var index = 0;
  for (final line in lines) {
    for (final rune in line.runes) {
      groups.add((
        char: String.fromCharCode(rune),
        index: index++,
        outlineCount: font.glyphPaths(rune, Point.zero, sizeMm).length,
      ));
    }
  }
  return groups;
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
}) {
  final lines = wrapText(text, font,
      sizeMm: sizeMm, trackingMm: trackingMm, frameWidthMm: frameWidthMm);
  final last = lines.last;
  final baselineY = origin.y + (lines.length - 1) * lineHeight * sizeMm;
  final x = origin.x +
      _lineOffsetX(last, font, align, sizeMm, trackingMm, frameWidthMm) +
      textLineWidthMm(last, font, sizeMm, trackingMm: trackingMm);
  return Point(x, baselineY);
}
