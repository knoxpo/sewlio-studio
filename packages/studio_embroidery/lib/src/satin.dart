import 'dart:math' as math;

import 'package:studio_geometry/studio_geometry.dart';

import 'stitch_ir.dart';

/// Generates a satin column along [path]'s centerline (ADR-042): a
/// zig-zag of needle points alternating `±width/2` across the local
/// perpendicular, stepping ~[density] mm along the path.
///
/// Deterministic: same path + params → same ops. The last column lands
/// on the path end.
List<StitchOp> generateSatin(
  Path path, {
  double width = 3.0,
  double density = 0.4,
  double tolerance = 0.01,
}) {
  if (width <= 0) {
    throw ArgumentError.value(width, 'width', 'must be > 0 mm');
  }
  if (density <= 0) {
    throw ArgumentError.value(density, 'density', 'must be > 0 mm');
  }
  final centers = _resample(path.toPolyline(tolerance: tolerance), density);
  if (centers.length < 2) return const [];

  final half = width / 2;
  final ops = <StitchOp>[];
  for (var i = 0; i < centers.length; i++) {
    final n = _normalAt(centers, i);
    final side = i.isEven ? 1.0 : -1.0;
    ops.add(StitchOp.stitch(
      Point(centers[i].x + n.x * half * side, centers[i].y + n.y * half * side),
    ));
  }
  return ops;
}

/// Resamples [polyline] into points spaced ~[step] mm, always including
/// the first and last vertex.
List<Point> _resample(List<Point> polyline, double step) {
  if (polyline.length < 2) return polyline;
  final out = <Point>[polyline.first];
  var carried = 0.0;
  var last = polyline.first;
  for (var i = 1; i < polyline.length; i++) {
    var target = polyline[i];
    var span = last.distanceTo(target);
    var from = last;
    while (carried + span >= step && span > 0) {
      final t = (step - carried) / span;
      final p = from.lerp(target, t);
      out.add(p);
      span -= step - carried;
      carried = 0;
      from = p;
    }
    carried += span;
    last = target;
  }
  if (!out.last.almostEquals(polyline.last, tolerance: 1e-9)) {
    out.add(polyline.last);
  }
  return out;
}

/// Unit normal (perpendicular to the tangent) at sample [i], from the
/// central difference of neighbouring points.
Point _normalAt(List<Point> pts, int i) {
  final a = pts[math.max(0, i - 1)];
  final b = pts[math.min(pts.length - 1, i + 1)];
  final dx = b.x - a.x, dy = b.y - a.y;
  final len = math.sqrt(dx * dx + dy * dy);
  if (len == 0) return const Point(0, 1);
  // Perpendicular to the tangent (dx,dy) is (-dy,dx), normalized.
  return Point(-dy / len, dx / len);
}
