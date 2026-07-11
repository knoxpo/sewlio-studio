import 'dart:math' as math;

import 'path.dart';
import 'point.dart';

/// Shape constructors. All return closed (except spiral) [Path]s in mm.

/// Axis-aligned rectangle between two corners.
Path rectPath(Point a, Point b) {
  final minX = math.min(a.x, b.x), maxX = math.max(a.x, b.x);
  final minY = math.min(a.y, b.y), maxY = math.max(a.y, b.y);
  return Path(
    start: Point(minX, minY),
    segments: [
      LineSegment(Point(maxX, minY)),
      LineSegment(Point(maxX, maxY)),
      LineSegment(Point(minX, maxY)),
    ],
    closed: true,
  );
}

/// Kappa for approximating a quarter arc with one cubic.
const double _kappa = 0.5522847498307936;

/// Rectangle with rounded corners. [radius] clamps to half the
/// shorter side.
Path roundedRectPath(Point a, Point b, {double radius = 3}) {
  final minX = math.min(a.x, b.x), maxX = math.max(a.x, b.x);
  final minY = math.min(a.y, b.y), maxY = math.max(a.y, b.y);
  final r = radius
      .clamp(0.0, math.min((maxX - minX) / 2, (maxY - minY) / 2))
      .toDouble();
  if (r <= epsilon) return rectPath(a, b);
  final k = r * _kappa;
  return Path(
    start: Point(minX + r, minY),
    segments: [
      LineSegment(Point(maxX - r, minY)),
      CubicSegment(Point(maxX - r + k, minY), Point(maxX, minY + r - k),
          Point(maxX, minY + r)),
      LineSegment(Point(maxX, maxY - r)),
      CubicSegment(Point(maxX, maxY - r + k), Point(maxX - r + k, maxY),
          Point(maxX - r, maxY)),
      LineSegment(Point(minX + r, maxY)),
      CubicSegment(Point(minX + r - k, maxY), Point(minX, maxY - r + k),
          Point(minX, maxY - r)),
      LineSegment(Point(minX, minY + r)),
      CubicSegment(Point(minX, minY + r - k), Point(minX + r - k, minY),
          Point(minX + r, minY)),
    ],
    closed: true,
  );
}

/// Ellipse from four cubic arcs.
Path ellipsePath(Point center, double rx, double ry) {
  final kx = rx * _kappa, ky = ry * _kappa;
  final (cx, cy) = (center.x, center.y);
  return Path(
    start: Point(cx + rx, cy),
    segments: [
      CubicSegment(
          Point(cx + rx, cy + ky), Point(cx + kx, cy + ry), Point(cx, cy + ry)),
      CubicSegment(
          Point(cx - kx, cy + ry), Point(cx - rx, cy + ky), Point(cx - rx, cy)),
      CubicSegment(
          Point(cx - rx, cy - ky), Point(cx - kx, cy - ry), Point(cx, cy - ry)),
      CubicSegment(
          Point(cx + kx, cy - ry), Point(cx + rx, cy - ky), Point(cx + rx, cy)),
    ],
    closed: true,
  );
}

/// Regular polygon ([sides] ≥ 3) with a vertex pointing up by default.
Path regularPolygonPath(Point center, double radius, int sides,
    {double rotation = -math.pi / 2}) {
  if (sides < 3) throw ArgumentError.value(sides, 'sides', 'must be ≥ 3');
  Point vertex(int i) {
    final angle = rotation + 2 * math.pi * i / sides;
    return Point(center.x + radius * math.cos(angle),
        center.y + radius * math.sin(angle));
  }

  return Path(
    start: vertex(0),
    segments: [for (var i = 1; i < sides; i++) LineSegment(vertex(i))],
    closed: true,
  );
}

/// Star with [points] tips alternating outer/inner radius.
Path starPath(Point center, double outerRadius, int points,
    {double innerRatio = 0.5, double rotation = -math.pi / 2}) {
  if (points < 3) throw ArgumentError.value(points, 'points', 'must be ≥ 3');
  final inner = outerRadius * innerRatio;
  Point vertex(int i) {
    final radius = i.isEven ? outerRadius : inner;
    final angle = rotation + math.pi * i / points;
    return Point(center.x + radius * math.cos(angle),
        center.y + radius * math.sin(angle));
  }

  return Path(
    start: vertex(0),
    segments: [for (var i = 1; i < 2 * points; i++) LineSegment(vertex(i))],
    closed: true,
  );
}

/// Archimedean spiral polyline from the center out to [radius].
Path spiralPath(Point center, double radius,
    {double turns = 3, int segmentsPerTurn = 36}) {
  final steps = (turns * segmentsPerTurn).ceil();
  Point at(int i) {
    final t = i / steps;
    final angle = 2 * math.pi * turns * t;
    final r = radius * t;
    return Point(
        center.x + r * math.cos(angle), center.y + r * math.sin(angle));
  }

  return Path(
    start: center,
    segments: [for (var i = 1; i <= steps; i++) LineSegment(at(i))],
  );
}

/// Ramer–Douglas–Peucker polyline simplification (freehand pencil).
List<Point> simplifyPolyline(List<Point> points, {double tolerance = 0.5}) {
  return [
    for (final i in simplifyPolylineIndices(points, tolerance: tolerance))
      points[i]
  ];
}

/// [simplifyPolyline], but returning the kept indices so parallel
/// per-point data (stylus pressure) decimates in lockstep (ADR-038).
List<int> simplifyPolylineIndices(List<Point> points,
    {double tolerance = 0.5}) {
  if (points.length < 3) return [for (var i = 0; i < points.length; i++) i];
  double dist(Point p, Point a, Point b) {
    final ab = b - a;
    final len = ab.length;
    if (len <= epsilon) return p.distanceTo(a);
    return ((p.x - a.x) * ab.y - (p.y - a.y) * ab.x).abs() / len;
  }

  final keep = List<bool>.filled(points.length, false);
  keep[0] = keep[points.length - 1] = true;
  final stack = [(0, points.length - 1)];
  while (stack.isNotEmpty) {
    final (first, last) = stack.removeLast();
    var maxDist = 0.0;
    var index = first;
    for (var i = first + 1; i < last; i++) {
      final d = dist(points[i], points[first], points[last]);
      if (d > maxDist) {
        maxDist = d;
        index = i;
      }
    }
    if (maxDist > tolerance) {
      keep[index] = true;
      stack
        ..add((first, index))
        ..add((index, last));
    }
  }
  return [
    for (var i = 0; i < points.length; i++)
      if (keep[i]) i
  ];
}
