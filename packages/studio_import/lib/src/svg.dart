import 'package:studio_geometry/studio_geometry.dart';

/// Millimeters per SVG user unit (CSS px at 96 dpi).
const double mmPerPx = 25.4 / 96;

/// Imports an SVG document's `<path d="…">` outlines as mm-based
/// [Path]s. Supported path commands: M/m, L/l, H/h, V/v, C/c, Z/z —
/// the subset vector editors emit for outlines.
///
/// Normalization: user units are treated as CSS px and scaled to mm.
// ponytail: paths are pulled out with a regex instead of an XML parser,
// so <rect>/<circle>/transforms/styles are ignored. Swap in a real XML
// parser + shape conversion when imports outgrow plain path outlines.
List<Path> importSvg(String svg) {
  final paths = <Path>[];
  for (final match
      in RegExp('<path[^>]*\\sd\\s*=\\s*"([^"]+)"').allMatches(svg)) {
    paths.addAll(parseSvgPathData(match.group(1)!));
  }
  return paths;
}

/// Parses SVG path data into [Path]s (one per subpath), scaled px→mm.
/// Throws [FormatException] on unsupported commands or malformed data.
List<Path> parseSvgPathData(String d) {
  final tokens =
      RegExp(r'[MmLlHhVvCcZz]|-?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?')
          .allMatches(d)
          .map((m) => m.group(0)!)
          .toList();

  final paths = <Path>[];
  var i = 0;
  Point current = Point.zero;
  Point? start;
  var segments = <Segment>[];

  double number() {
    if (i >= tokens.length) throw const FormatException('Unexpected end');
    return double.parse(tokens[i++]) * mmPerPx;
  }

  Point pair() => Point(number(), number());

  void flush({required bool closed}) {
    if (start != null && (segments.isNotEmpty || closed)) {
      paths.add(Path(start: start, segments: segments, closed: closed));
    }
    segments = [];
  }

  bool nextIsNumber() =>
      i < tokens.length && !RegExp('[A-Za-z]').hasMatch(tokens[i]);

  while (i < tokens.length) {
    final command = tokens[i++];
    final relative = command.toLowerCase() == command;
    switch (command.toUpperCase()) {
      case 'M':
        flush(closed: false);
        var p = pair();
        if (relative && start != null) p = current + p;
        start = current = p;
        // Extra coordinate pairs after M are implicit linetos.
        while (nextIsNumber()) {
          var q = pair();
          if (relative) q = current + q;
          segments.add(LineSegment(q));
          current = q;
        }
      case 'L':
        do {
          var p = pair();
          if (relative) p = current + p;
          segments.add(LineSegment(p));
          current = p;
        } while (nextIsNumber());
      case 'H':
        do {
          final x = number();
          final p = Point(relative ? current.x + x : x, current.y);
          segments.add(LineSegment(p));
          current = p;
        } while (nextIsNumber());
      case 'V':
        do {
          final y = number();
          final p = Point(current.x, relative ? current.y + y : y);
          segments.add(LineSegment(p));
          current = p;
        } while (nextIsNumber());
      case 'C':
        do {
          var c1 = pair(), c2 = pair(), end = pair();
          if (relative) {
            c1 = current + c1;
            c2 = current + c2;
            end = current + end;
          }
          segments.add(CubicSegment(c1, c2, end));
          current = end;
        } while (nextIsNumber());
      case 'Z':
        flush(closed: true);
        if (start != null) current = start;
        start = current;
      default:
        throw FormatException('Unsupported SVG path command: $command');
    }
  }
  flush(closed: false);
  return paths;
}
