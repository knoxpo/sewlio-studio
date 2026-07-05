import 'bounds.dart';
import 'point.dart';
import 'transform.dart';

/// A path segment: starts where the previous one ended.
sealed class Segment {
  const Segment();

  Point get end;

  Map<String, dynamic> toJson();

  static Segment fromJson(Map<String, dynamic> json) => switch (json['t']) {
        'line' => LineSegment(Point.fromJson(json['end'] as List)),
        'cubic' => CubicSegment(
            Point.fromJson(json['c1'] as List),
            Point.fromJson(json['c2'] as List),
            Point.fromJson(json['end'] as List),
          ),
        _ => throw FormatException('Unknown segment type: ${json['t']}'),
      };
}

/// Straight line to [end].
final class LineSegment extends Segment {
  const LineSegment(this.end);

  @override
  final Point end;

  @override
  Map<String, dynamic> toJson() => {'t': 'line', 'end': end.toJson()};
}

/// Cubic Bézier with control points [c1], [c2], ending at [end].
final class CubicSegment extends Segment {
  const CubicSegment(this.c1, this.c2, this.end);

  final Point c1;
  final Point c2;
  @override
  final Point end;

  /// Curve point at parameter [t] in [0, 1], from start point [p0].
  Point pointAt(Point p0, double t) {
    final u = 1 - t;
    final a = u * u * u, b = 3 * u * u * t, c = 3 * u * t * t, d = t * t * t;
    return Point(
      a * p0.x + b * c1.x + c * c2.x + d * end.x,
      a * p0.y + b * c1.y + c * c2.y + d * end.y,
    );
  }

  @override
  Map<String, dynamic> toJson() =>
      {'t': 'cubic', 'c1': c1.toJson(), 'c2': c2.toJson(), 'end': end.toJson()};
}

/// An immutable path: a start point followed by segments, optionally
/// closed (implicit line back to [start]).
final class Path {
  const Path(
      {required this.start, this.segments = const [], this.closed = false});

  final Point start;
  final List<Segment> segments;
  final bool closed;

  /// Flattens the path to a polyline. Curves are subdivided until the
  /// control polygon deviates from the chord by less than [tolerance]
  /// (mm). Deterministic: fixed recursion, no randomness.
  List<Point> toPolyline({double tolerance = 0.01}) {
    final points = <Point>[start];
    var current = start;
    for (final segment in segments) {
      switch (segment) {
        case LineSegment(:final end):
          points.add(end);
        case CubicSegment():
          _flattenCubic(current, segment, tolerance, points);
      }
      current = segment.end;
    }
    if (closed && !current.almostEquals(start)) points.add(start);
    return points;
  }

  /// Total polyline length in mm at the given flattening [tolerance].
  double length({double tolerance = 0.01}) {
    final pts = toPolyline(tolerance: tolerance);
    var total = 0.0;
    for (var i = 1; i < pts.length; i++) {
      total += pts[i - 1].distanceTo(pts[i]);
    }
    return total;
  }

  /// Bounding box. Curve bounds use the control-point hull —
  /// conservative but exact for lines.
  // ponytail: hull bbox may overshoot on curvy segments; solve the
  // derivative roots if tight curve bounds ever matter.
  Bounds bounds() {
    final points = <Point>[start];
    for (final segment in segments) {
      switch (segment) {
        case LineSegment(:final end):
          points.add(end);
        case CubicSegment(:final c1, :final c2, :final end):
          points
            ..add(c1)
            ..add(c2)
            ..add(end);
      }
    }
    return Bounds.fromPoints(points);
  }

  /// A copy of this path with [t] applied to every point.
  Path transformed(Transform2 t) => Path(
        start: t.apply(start),
        segments: [
          for (final s in segments)
            switch (s) {
              LineSegment(:final end) => LineSegment(t.apply(end)),
              CubicSegment(:final c1, :final c2, :final end) =>
                CubicSegment(t.apply(c1), t.apply(c2), t.apply(end)),
            }
        ],
        closed: closed,
      );

  Map<String, dynamic> toJson() => {
        'start': start.toJson(),
        'segments': [for (final s in segments) s.toJson()],
        if (closed) 'closed': true,
      };

  factory Path.fromJson(Map<String, dynamic> json) => Path(
        start: Point.fromJson(json['start'] as List),
        segments: [
          for (final s in json['segments'] as List)
            Segment.fromJson(s as Map<String, dynamic>)
        ],
        closed: (json['closed'] as bool?) ?? false,
      );
}

void _flattenCubic(
    Point p0, CubicSegment c, double tolerance, List<Point> out) {
  // Flat enough when both control points sit within tolerance of the
  // chord p0→end (standard flatness test).
  double dist(Point p, Point a, Point b) {
    final ab = b - a;
    final len = ab.length;
    if (len <= epsilon) return p.distanceTo(a);
    final cross = (p.x - a.x) * ab.y - (p.y - a.y) * ab.x;
    return cross.abs() / len;
  }

  void recurse(Point p0, Point c1, Point c2, Point p3, int depth) {
    if (depth >= 24 ||
        (dist(c1, p0, p3) <= tolerance && dist(c2, p0, p3) <= tolerance)) {
      out.add(p3);
      return;
    }
    // de Casteljau split at t = 0.5.
    final p01 = p0.lerp(c1, 0.5);
    final p12 = c1.lerp(c2, 0.5);
    final p23 = c2.lerp(p3, 0.5);
    final p012 = p01.lerp(p12, 0.5);
    final p123 = p12.lerp(p23, 0.5);
    final mid = p012.lerp(p123, 0.5);
    recurse(p0, p01, p012, mid, depth + 1);
    recurse(mid, p123, p23, p3, depth + 1);
  }

  recurse(p0, c.c1, c.c2, c.end, 0);
}
