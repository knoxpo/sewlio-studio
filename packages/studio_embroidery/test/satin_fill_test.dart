import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

Path _closed(List<Point> pts) => Path(
      start: pts.first,
      segments: [for (final p in pts.skip(1)) LineSegment(p)],
      closed: true,
    );

void main() {
  group('generateSatin', () {
    test('zig-zags across a horizontal centerline at ±width/2', () {
      final ops = generateSatin(
        Path(
            start: const Point(0, 0),
            segments: [LineSegment(const Point(10, 0))]),
        width: 4,
        density: 1,
      );
      expect(ops.length, greaterThan(8));
      // Normal of a horizontal line is vertical → points alternate y=±2.
      for (var i = 0; i < ops.length; i++) {
        expect(ops[i].position.y.abs(), closeTo(2, 1e-6));
        expect(ops[i].position.y > 0, i.isEven);
      }
      // x marches from 0 to 10.
      expect(ops.first.position.x, closeTo(0, 1e-6));
      expect(ops.last.position.x, closeTo(10, 1e-6));
    });

    test('deterministic', () {
      Path p() => Path(
          start: const Point(0, 0), segments: [LineSegment(const Point(8, 3))]);
      expect(generateSatin(p(), width: 3, density: 0.5),
          generateSatin(p(), width: 3, density: 0.5));
    });
  });

  group('generateFill', () {
    test('fills a square with rows', () {
      final square = _closed(const [
        Point(0, 0),
        Point(10, 0),
        Point(10, 10),
        Point(0, 10),
      ]);
      final ops = generateFill([square], spacing: 2);
      expect(ops, isNotEmpty);
      // Every stitch sits inside the square.
      for (final op in ops) {
        expect(op.position.x, inInclusiveRange(-1e-6, 10 + 1e-6));
        expect(op.position.y, inInclusiveRange(-1e-6, 10 + 1e-6));
      }
    });

    test('even-odd leaves a hole unstitched', () {
      final outer = _closed(const [
        Point(0, 0),
        Point(10, 0),
        Point(10, 10),
        Point(0, 10),
      ]);
      final hole = _closed(const [
        Point(3, 3),
        Point(7, 3),
        Point(7, 7),
        Point(3, 7),
      ]);
      final ops = generateFill([outer, hole], spacing: 1, rowStitchLength: 0.5);
      // No needle point lands strictly inside the hole (2 < x,y < 8 core).
      for (final op in ops) {
        final inHole = op.position.x > 3.2 &&
            op.position.x < 6.8 &&
            op.position.y > 3.2 &&
            op.position.y < 6.8;
        expect(inHole, isFalse, reason: 'stitch inside hole at ${op.position}');
      }
    });

    test('deterministic', () {
      final sq = _closed(const [
        Point(0, 0),
        Point(6, 0),
        Point(6, 6),
        Point(0, 6),
      ]);
      expect(generateFill([sq], spacing: 1), generateFill([sq], spacing: 1));
    });
  });

  test('FillObject.holes JSON round-trips; legacy loads empty', () {
    final fill = FillObject(
      id: Id('f1'),
      path: _closed(const [Point(0, 0), Point(4, 0), Point(4, 4), Point(0, 4)]),
      holes: [
        _closed(const [Point(1, 1), Point(2, 1), Point(2, 2), Point(1, 2)])
      ],
    );
    final back = EmbroideryObject.fromJson(fill.toJson()) as FillObject;
    expect(back.holes.length, 1);
    expect(back.renderPaths.length, 2);

    final legacy = Map<String, dynamic>.from(fill.toJson())..remove('holes');
    final loaded = EmbroideryObject.fromJson(legacy) as FillObject;
    expect(loaded.holes, isEmpty);
  });
}
