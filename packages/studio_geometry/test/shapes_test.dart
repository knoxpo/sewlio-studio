import 'dart:math' as math;

import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  test('rect from any corner pair, closed', () {
    final r = rectPath(const Point(10, 10), const Point(0, 0));
    expect(r.closed, isTrue);
    expect(r.bounds(), const Bounds(0, 0, 10, 10));
    expect(r.length(), closeTo(40, 1e-9));
  });

  test('rounded rect clamps radius and stays in bounds', () {
    final r =
        roundedRectPath(const Point(0, 0), const Point(20, 10), radius: 50);
    final b = r.bounds();
    expect(b.width, closeTo(20, 1e-9));
    expect(b.height, closeTo(10, 1e-9));
    // Zero radius degrades to a plain rect.
    expect(
        roundedRectPath(const Point(0, 0), const Point(4, 4), radius: 0)
            .segments
            .whereType<CubicSegment>(),
        isEmpty);
  });

  test('ellipse approximates circumference', () {
    final circle = ellipsePath(const Point(0, 0), 10, 10);
    expect(circle.length(tolerance: 0.001), closeTo(2 * math.pi * 10, 0.05));
    for (final p in circle.toPolyline(tolerance: 0.001)) {
      expect(p.length, closeTo(10, 0.02));
    }
  });

  test('regular polygon has n equal sides', () {
    final hex = regularPolygonPath(const Point(0, 0), 10, 6);
    final pts = hex.toPolyline();
    expect(pts.length, 7); // 6 vertices + closing point
    final side = pts[0].distanceTo(pts[1]);
    for (var i = 1; i < 6; i++) {
      expect(pts[i].distanceTo(pts[i + 1]), closeTo(side, 1e-9));
    }
    expect(() => regularPolygonPath(const Point(0, 0), 10, 2),
        throwsArgumentError);
  });

  test('star alternates radii', () {
    final star = starPath(const Point(0, 0), 10, 5, innerRatio: 0.4);
    final pts = star.toPolyline();
    expect(pts.length, 11); // 10 vertices + close
    expect(pts[0].length, closeTo(10, 1e-9));
    expect(pts[1].length, closeTo(4, 1e-9));
  });

  test('spiral starts at center, ends at radius', () {
    final s = spiralPath(const Point(5, 5), 10, turns: 2);
    final pts = s.toPolyline();
    expect(pts.first, const Point(5, 5));
    expect(pts.last.distanceTo(const Point(5, 5)), closeTo(10, 1e-9));
    expect(s.closed, isFalse);
  });

  test('simplifyPolyline drops collinear points, keeps corners', () {
    final points = [
      for (var x = 0.0; x <= 10; x += 0.5) Point(x, 0),
      for (var y = 0.5; y <= 10; y += 0.5) Point(10, y),
    ];
    final simplified = simplifyPolyline(points, tolerance: 0.1);
    expect(simplified, [
      const Point(0, 0),
      const Point(10, 0),
      const Point(10, 10),
    ]);
  });

  test(
      'simplifyPolylineIndices keeps endpoints and maps back to the '
      'same points', () {
    final points = [
      for (var x = 0.0; x <= 10; x += 0.5) Point(x, 0),
      for (var y = 0.5; y <= 10; y += 0.5) Point(10, y),
    ];
    final kept = simplifyPolylineIndices(points, tolerance: 0.1);
    expect(kept.first, 0);
    expect(kept.last, points.length - 1);
    expect([for (final i in kept) points[i]],
        simplifyPolyline(points, tolerance: 0.1));
  });

  test('simplifyPolylineIndices on short input returns all indices', () {
    expect(
      simplifyPolylineIndices(const [Point(0, 0), Point(1, 1)]),
      [0, 1],
    );
  });
}
