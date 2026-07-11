import 'dart:math' as math;

import 'package:studio_geometry/studio_geometry.dart';

import 'running_stitch.dart';
import 'stitch_ir.dart';

/// Generates a tatami (parallel-row) fill of the region bounded by
/// [boundaries], using the even-odd rule so holes stay unstitched
/// (ADR-042). Rows are spaced [spacing] mm at [angleDeg]; each row is
/// resampled into running stitches, rows connected boustrophedon.
///
/// Deterministic: fixed scan order, no randomness.
List<StitchOp> generateFill(
  List<Path> boundaries, {
  double spacing = 0.4,
  double angleDeg = 0,
  double rowStitchLength = 2.5,
  double tolerance = 0.01,
}) {
  if (spacing <= 0) {
    throw ArgumentError.value(spacing, 'spacing', 'must be > 0 mm');
  }
  final a = angleDeg * math.pi / 180;
  final cosA = math.cos(a), sinA = math.sin(a);
  // Rotate into scan space (scanlines become horizontal).
  Point toScan(Point p) =>
      Point(p.x * cosA + p.y * sinA, -p.x * sinA + p.y * cosA);
  Point fromScan(Point p) =>
      Point(p.x * cosA - p.y * sinA, p.x * sinA + p.y * cosA);

  // Flatten each boundary to a closed polyline in scan space.
  final edges = <(Point, Point)>[];
  var minY = double.infinity, maxY = -double.infinity;
  for (final b in boundaries) {
    final poly = [
      for (final p in b.toPolyline(tolerance: tolerance)) toScan(p)
    ];
    if (poly.length < 2) continue;
    for (var i = 0; i < poly.length; i++) {
      final p1 = poly[i];
      final p2 = poly[(i + 1) % poly.length]; // close the contour
      edges.add((p1, p2));
      minY = math.min(minY, p1.y);
      maxY = math.max(maxY, p1.y);
    }
  }
  if (edges.isEmpty || !minY.isFinite) return const [];

  final ops = <StitchOp>[];
  var rowFlip = false;
  // Sample scanlines at row centers so the first row sits inside the region.
  for (var y = minY + spacing / 2; y < maxY; y += spacing) {
    final xs = <double>[];
    for (final (p1, p2) in edges) {
      final y1 = p1.y, y2 = p2.y;
      // Half-open crossing test avoids double-counting shared vertices.
      if ((y1 <= y && y < y2) || (y2 <= y && y < y1)) {
        final t = (y - y1) / (y2 - y1);
        xs.add(p1.x + t * (p2.x - p1.x));
      }
    }
    if (xs.length < 2) continue;
    xs.sort();
    // Even-odd: fill between crossing pairs (0-1, 2-3, …).
    final spans = <(double, double)>[];
    for (var i = 0; i + 1 < xs.length; i += 2) {
      spans.add((xs[i], xs[i + 1]));
    }
    // Boustrophedon: alternate rows run right→left so travel stays short.
    final ordered = rowFlip ? spans.reversed.toList() : spans;
    for (final (x0, x1) in ordered) {
      final start = fromScan(rowFlip ? Point(x1, y) : Point(x0, y));
      final end = fromScan(rowFlip ? Point(x0, y) : Point(x1, y));
      ops.addAll(generateRunningStitch(
        Path(start: start, segments: [LineSegment(end)]),
        stitchLength: rowStitchLength,
      ));
    }
    rowFlip = !rowFlip;
  }
  return ops;
}
