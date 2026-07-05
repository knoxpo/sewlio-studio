import 'package:studio_geometry/studio_geometry.dart';

/// Built-in single-stroke (monoline) vector font for the Text tool.
///
/// Glyphs are polyline strokes on a 4-wide × 6-tall grid (y up,
/// baseline at 0). Monoline lettering stitches directly as running
/// stitch — no fill needed.
// ponytail: A–Z, 0–9 and basic punctuation only — swap for TTF glyph
// outlines + satin lettering when typography matters.
const double _capHeight = 6;
const double _advance = 5.5;

/// Strokes per character; each stroke is a list of (x, y) grid points.
const Map<String, List<List<(double, double)>>> _glyphs = {
  'A': [
    [(0, 0), (2, 6), (4, 0)],
    [(1, 2.5), (3, 2.5)],
  ],
  'B': [
    [(0, 0), (0, 6), (3, 6), (4, 5), (4, 4), (3, 3), (0, 3)],
    [(3, 3), (4, 2), (4, 1), (3, 0), (0, 0)],
  ],
  'C': [
    [(4, 5), (3, 6), (1, 6), (0, 5), (0, 1), (1, 0), (3, 0), (4, 1)],
  ],
  'D': [
    [(0, 0), (0, 6), (2, 6), (4, 4), (4, 2), (2, 0), (0, 0)],
  ],
  'E': [
    [(4, 6), (0, 6), (0, 0), (4, 0)],
    [(0, 3), (3, 3)],
  ],
  'F': [
    [(4, 6), (0, 6), (0, 0)],
    [(0, 3), (3, 3)],
  ],
  'G': [
    [
      (4, 5),
      (3, 6),
      (1, 6),
      (0, 5),
      (0, 1),
      (1, 0),
      (3, 0),
      (4, 1),
      (4, 3),
      (2, 3)
    ],
  ],
  'H': [
    [(0, 0), (0, 6)],
    [(4, 0), (4, 6)],
    [(0, 3), (4, 3)],
  ],
  'I': [
    [(1, 6), (3, 6)],
    [(2, 6), (2, 0)],
    [(1, 0), (3, 0)],
  ],
  'J': [
    [(4, 6), (4, 1), (3, 0), (1, 0), (0, 1)],
  ],
  'K': [
    [(0, 0), (0, 6)],
    [(4, 6), (0, 3), (4, 0)],
  ],
  'L': [
    [(0, 6), (0, 0), (4, 0)],
  ],
  'M': [
    [(0, 0), (0, 6), (2, 3), (4, 6), (4, 0)],
  ],
  'N': [
    [(0, 0), (0, 6), (4, 0), (4, 6)],
  ],
  'O': [
    [(1, 0), (0, 1), (0, 5), (1, 6), (3, 6), (4, 5), (4, 1), (3, 0), (1, 0)],
  ],
  'P': [
    [(0, 0), (0, 6), (3, 6), (4, 5), (4, 4), (3, 3), (0, 3)],
  ],
  'Q': [
    [(1, 0), (0, 1), (0, 5), (1, 6), (3, 6), (4, 5), (4, 1), (3, 0), (1, 0)],
    [(2.5, 1.5), (4.5, -0.5)],
  ],
  'R': [
    [(0, 0), (0, 6), (3, 6), (4, 5), (4, 4), (3, 3), (0, 3)],
    [(2, 3), (4, 0)],
  ],
  'S': [
    [
      (4, 5),
      (3, 6),
      (1, 6),
      (0, 5),
      (0, 4),
      (1, 3),
      (3, 3),
      (4, 2),
      (4, 1),
      (3, 0),
      (1, 0),
      (0, 1)
    ],
  ],
  'T': [
    [(0, 6), (4, 6)],
    [(2, 6), (2, 0)],
  ],
  'U': [
    [(0, 6), (0, 1), (1, 0), (3, 0), (4, 1), (4, 6)],
  ],
  'V': [
    [(0, 6), (2, 0), (4, 6)],
  ],
  'W': [
    [(0, 6), (1, 0), (2, 4), (3, 0), (4, 6)],
  ],
  'X': [
    [(0, 0), (4, 6)],
    [(0, 6), (4, 0)],
  ],
  'Y': [
    [(0, 6), (2, 3), (4, 6)],
    [(2, 3), (2, 0)],
  ],
  'Z': [
    [(0, 6), (4, 6), (0, 0), (4, 0)],
  ],
  '0': [
    [(1, 0), (0, 1), (0, 5), (1, 6), (3, 6), (4, 5), (4, 1), (3, 0), (1, 0)],
    [(1, 1), (3, 5)],
  ],
  '1': [
    [(1, 5), (2, 6), (2, 0)],
    [(1, 0), (3, 0)],
  ],
  '2': [
    [(0, 5), (1, 6), (3, 6), (4, 5), (4, 4), (0, 1), (0, 0), (4, 0)],
  ],
  '3': [
    [(0, 5), (1, 6), (3, 6), (4, 5), (4, 4), (3, 3), (1.5, 3)],
    [(3, 3), (4, 2), (4, 1), (3, 0), (1, 0), (0, 1)],
  ],
  '4': [
    [(3, 0), (3, 6), (0, 2), (4, 2)],
  ],
  '5': [
    [
      (4, 6),
      (0, 6),
      (0, 3.5),
      (3, 3.5),
      (4, 2.5),
      (4, 1),
      (3, 0),
      (1, 0),
      (0, 1)
    ],
  ],
  '6': [
    [
      (4, 5),
      (3, 6),
      (1, 6),
      (0, 5),
      (0, 1),
      (1, 0),
      (3, 0),
      (4, 1),
      (4, 2),
      (3, 3),
      (0, 3)
    ],
  ],
  '7': [
    [(0, 6), (4, 6), (1, 0)],
  ],
  '8': [
    [
      (1, 3),
      (0, 4),
      (0, 5),
      (1, 6),
      (3, 6),
      (4, 5),
      (4, 4),
      (3, 3),
      (1, 3),
      (0, 2),
      (0, 1),
      (1, 0),
      (3, 0),
      (4, 1),
      (4, 2),
      (3, 3)
    ],
  ],
  '9': [
    [
      (4, 3),
      (1, 3),
      (0, 4),
      (0, 5),
      (1, 6),
      (3, 6),
      (4, 5),
      (4, 1),
      (3, 0),
      (1, 0),
      (0, 1)
    ],
  ],
  '-': [
    [(1, 3), (3, 3)],
  ],
  '.': [
    [(1.8, 0), (2.2, 0)],
  ],
  ' ': [],
};

/// Converts [text] to stitchable monoline paths (one per pen stroke).
/// [origin] is the baseline left; [sizeMm] is the capital height.
/// Unsupported characters are skipped (lowercase maps to uppercase).
List<Path> textToPaths(String text,
    {required Point origin, double sizeMm = 10}) {
  final scale = sizeMm / _capHeight;
  final paths = <Path>[];
  var penX = origin.x;
  for (final rune in text.toUpperCase().runes) {
    final strokes = _glyphs[String.fromCharCode(rune)];
    if (strokes != null) {
      for (final stroke in strokes) {
        if (stroke.length < 2) continue;
        Point map((double, double) p) =>
            Point(penX + p.$1 * scale, origin.y - p.$2 * scale);
        paths.add(Path(
          start: map(stroke.first),
          segments: [for (final p in stroke.skip(1)) LineSegment(map(p))],
        ));
      }
    }
    penX += _advance * scale;
  }
  return paths;
}
