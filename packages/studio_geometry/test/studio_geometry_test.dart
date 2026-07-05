import 'dart:convert';
import 'dart:math' as math;

import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  group('Point', () {
    test('arithmetic and distance', () {
      expect(const Point(1, 2) + const Point(3, 4), const Point(4, 6));
      expect(const Point(3, 4).length, 5);
      expect(const Point(0, 0).distanceTo(const Point(3, 4)), 5);
      expect(const Point(0, 0).lerp(const Point(10, 20), 0.5),
          const Point(5, 10));
    });

    test('roundCoord normalizes for serialization', () {
      expect(roundCoord(1.0000001), 1.0);
      expect(roundCoord(-0.0000001), 0); // no -0.0
      expect(const Point(1.23456789, 2).toJson(), [1.234568, 2.0]);
    });
  });

  group('Path', () {
    test('polyline of line segments and length', () {
      const path = Path(
        start: Point(0, 0),
        segments: [LineSegment(Point(10, 0)), LineSegment(Point(10, 10))],
      );
      expect(path.toPolyline(),
          [const Point(0, 0), const Point(10, 0), const Point(10, 10)]);
      expect(path.length(), closeTo(20, epsilon));
    });

    test('closed path appends start', () {
      const square = Path(
        start: Point(0, 0),
        segments: [
          LineSegment(Point(10, 0)),
          LineSegment(Point(10, 10)),
          LineSegment(Point(0, 10)),
        ],
        closed: true,
      );
      expect(square.toPolyline().last, const Point(0, 0));
      expect(square.length(), closeTo(40, epsilon));
    });

    test('cubic flattening approximates a quarter circle', () {
      // Cubic approximation of a unit quarter arc, radius 10.
      const k = 5.522847498; // 10 * 0.5522847498
      const arc = Path(
        start: Point(10, 0),
        segments: [CubicSegment(Point(10, k), Point(k, 10), Point(0, 10))],
      );
      final len = arc.length(tolerance: 0.001);
      expect(len, closeTo(2 * math.pi * 10 / 4, 0.01));
      // Every flattened point stays close to radius 10.
      for (final p in arc.toPolyline(tolerance: 0.001)) {
        expect(p.length, closeTo(10, 0.01));
      }
    });

    test('bounds unions lines and curve hulls', () {
      const path = Path(
        start: Point(0, 0),
        segments: [
          LineSegment(Point(10, 5)),
          CubicSegment(Point(12, 8), Point(15, -2), Point(20, 3)),
        ],
      );
      expect(path.bounds(), const Bounds(0, -2, 20, 8));
    });

    test('json round trip is stable (golden)', () {
      const path = Path(
        start: Point(0, 0),
        segments: [
          LineSegment(Point(10.123456789, 0)),
          CubicSegment(Point(1, 2), Point(3, 4), Point(5, 6)),
        ],
        closed: true,
      );
      final encoded = jsonEncode(path.toJson());
      // Golden: byte-stable serialization (risk R2 determinism policy).
      expect(
        encoded,
        '{"start":[0.0,0.0],"segments":[{"t":"line","end":[10.123457,0.0]},'
        '{"t":"cubic","c1":[1.0,2.0],"c2":[3.0,4.0],"end":[5.0,6.0]}],'
        '"closed":true}',
      );
      final decoded =
          Path.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
      expect(jsonEncode(decoded.toJson()), encoded);
    });
  });

  group('Transform2', () {
    test('translate, scale, rotate', () {
      expect(Transform2.translation(3, 4).apply(const Point(1, 1)),
          const Point(4, 5));
      expect(Transform2.scaling(2).apply(const Point(3, 4)),
          const Point(6, 8));
      final rotated =
          Transform2.rotation(math.pi / 2).apply(const Point(1, 0));
      expect(rotated.almostEquals(const Point(0, 1)), isTrue);
    });

    test('composition applies right-to-left', () {
      final t = Transform2.translation(10, 0) * Transform2.scaling(2);
      expect(t.apply(const Point(1, 1)), const Point(12, 2));
    });

    test('inverse round trips', () {
      final t = Transform2.translation(3, -7) *
          Transform2.rotation(0.7) *
          Transform2.scaling(2, 3);
      final p = const Point(5, 9);
      expect(t.invert().apply(t.apply(p)).almostEquals(p, tolerance: 1e-9),
          isTrue);
      expect(() => Transform2.scaling(0).invert(), throwsStateError);
    });
  });
}
