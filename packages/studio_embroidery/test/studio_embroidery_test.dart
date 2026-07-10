import 'dart:convert';

import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  group('running stitch generator', () {
    test('straight line resamples evenly and hits the end', () {
      const line =
          Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]);
      final ops = generateRunningStitch(line, stitchLength: 2.5);

      expect(ops.map((o) => o.position.x), [0.0, 2.5, 5.0, 7.5, 10.0]);
      expect(ops.every((o) => o.kind == StitchKind.stitch), isTrue);
    });

    test('is deterministic', () {
      const k = 5.522847498;
      const arc = Path(
        start: Point(10, 0),
        segments: [CubicSegment(Point(10, k), Point(k, 10), Point(0, 10))],
      );
      final a = generateRunningStitch(arc);
      final b = generateRunningStitch(arc);
      expect(a, b);
      expect(a.last.position.almostEquals(const Point(0, 10)), isTrue);
      // Consecutive stitches never exceed the requested length (within
      // flattening slack).
      for (var i = 1; i < a.length; i++) {
        expect(a[i - 1].position.distanceTo(a[i].position),
            lessThanOrEqualTo(2.5 + 0.05));
      }
    });

    test('pins a stitch on every sharp corner', () {
      // 10 mm square, 4 mm stitches: pure arc-length resampling would
      // cut every corner; corner pinning must land on all four.
      const square = Path(
        start: Point(0, 0),
        segments: [
          LineSegment(Point(10, 0)),
          LineSegment(Point(10, 10)),
          LineSegment(Point(0, 10)),
        ],
        closed: true,
      );
      final ops = generateRunningStitch(square, stitchLength: 4);
      for (final corner in const [
        Point(10, 0),
        Point(10, 10),
        Point(0, 10),
      ]) {
        expect(
          ops.any((o) => o.position.almostEquals(corner, tolerance: 1e-6)),
          isTrue,
          reason: 'no stitch on corner $corner',
        );
      }
    });

    test('curves stay round: small circle gets ~30°-spaced stitches', () {
      // r = 2 mm circle (circumference ~12.6 mm). Pure 2.5 mm
      // resampling gives ~5 points (a pentagon); curvature pinning
      // must keep at least one stitch per ~10° of turn.
      const k = 2 * 0.5522847498;
      const circle = Path(
        start: Point(2, 0),
        segments: [
          CubicSegment(Point(2, k), Point(k, 2), Point(0, 2)),
          CubicSegment(Point(-k, 2), Point(-2, k), Point(-2, 0)),
          CubicSegment(Point(-2, -k), Point(-k, -2), Point(0, -2)),
          CubicSegment(Point(k, -2), Point(2, -k), Point(2, 0)),
        ],
        closed: true,
      );
      final ops = generateRunningStitch(circle, stitchLength: 2.5);
      expect(ops.length, greaterThanOrEqualTo(30));
      // Every stitch stays close to the circle: no chord midpoint may
      // sag more than ~0.03 mm inside the radius.
      for (var i = 1; i < ops.length; i++) {
        final a = ops[i - 1].position, b = ops[i].position;
        final mid = Point((a.x + b.x) / 2, (a.y + b.y) / 2);
        final r = mid.distanceTo(const Point(0, 0));
        expect(r, greaterThan(2 - 0.03), reason: 'chord sag at $i');
      }
    });

    test('gentle large-radius curves stay within the sag budget', () {
      // Quarter arc, r = 15 mm: per-stitch turn (~9.5°) stays under the
      // curve threshold, so only the sag bound keeps chords from
      // cutting visibly inside the drawn outline.
      const r = 15.0;
      const k = r * 0.5522847498;
      const arc = Path(
        start: Point(r, 0),
        segments: [CubicSegment(Point(r, k), Point(k, r), Point(0, r))],
      );
      final ops = generateRunningStitch(arc, stitchLength: 2.5);
      for (var i = 1; i < ops.length; i++) {
        final a = ops[i - 1].position, b = ops[i].position;
        final mid = Point((a.x + b.x) / 2, (a.y + b.y) / 2);
        expect(mid.distanceTo(const Point(0, 0)), greaterThan(r - 0.05),
            reason: 'chord sag at $i');
      }
    });

    test('transforms preserve outline-to-stitch alignment', () {
      // Scale + rotate + translate an arc; stitches generated from the
      // transformed path must still hug it (same sag budget).
      const k = 2 * 0.5522847498;
      const arc = Path(
        start: Point(2, 0),
        segments: [CubicSegment(Point(2, k), Point(k, 2), Point(0, 2))],
      );
      final t = Transform2.translation(30, -12) *
          Transform2.rotation(0.7) *
          Transform2.scaling(3);
      final moved = arc.transformed(t);
      final ops = generateRunningStitch(moved);
      final dense = moved.toPolyline(tolerance: 0.001);
      double segDist(Point p, Point a, Point b) {
        final vx = b.x - a.x, vy = b.y - a.y;
        final wx = p.x - a.x, wy = p.y - a.y;
        final c1 = vx * wx + vy * wy;
        if (c1 <= 0) return p.distanceTo(a);
        final c2 = vx * vx + vy * vy;
        if (c2 <= c1) return p.distanceTo(b);
        final s = c1 / c2;
        return p.distanceTo(Point(a.x + s * vx, a.y + s * vy));
      }

      for (final p in dense) {
        var best = double.infinity;
        for (var i = 1; i < ops.length; i++) {
          final d = segDist(p, ops[i - 1].position, ops[i].position);
          if (d < best) best = d;
        }
        expect(best, lessThan(0.05), reason: 'outline exposed at $p');
      }
    });

    test('rejects non-positive stitch length', () {
      const line =
          Path(start: Point(0, 0), segments: [LineSegment(Point(1, 0))]);
      expect(() => generateRunningStitch(line, stitchLength: 0),
          throwsArgumentError);
    });

    test('dispatch: running works, satin/fill are skeletons', () {
      const path =
          Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]);
      expect(
        generateStitches(const RunningStitchObject(id: Id('o1'), path: path)),
        isNotEmpty,
      );
      expect(
          () => generateStitches(const SatinObject(id: Id('o2'), path: path)),
          throwsUnimplementedError);
      expect(() => generateStitches(const FillObject(id: Id('o3'), path: path)),
          throwsUnimplementedError);
    });
  });

  group('Stitch IR', () {
    test('json round trip with version gate (golden)', () {
      const seq = StitchSequence(
        threads: [Thread('#ff0000', name: 'red')],
        ops: [
          StitchOp.stitch(Point(0, 0)),
          StitchOp.jump(Point(5, 5)),
          StitchOp(StitchKind.trim, Point(5, 5)),
        ],
      );
      final encoded = jsonEncode(seq.toJson());
      expect(
        encoded,
        '{"version":"1","threads":[{"color":"#ff0000","name":"red"}],'
        '"ops":[{"k":"stitch","p":[0.0,0.0]},{"k":"jump","p":[5.0,5.0]},'
        '{"k":"trim","p":[5.0,5.0]}]}',
      );
      final decoded =
          StitchSequence.fromJson(jsonDecode(encoded) as Map<String, dynamic>);
      expect(decoded.stitchCount, 1);
      expect(jsonEncode(decoded.toJson()), encoded);

      expect(
        () => StitchSequence.fromJson(
            {'version': '999', 'threads': [], 'ops': []}),
        throwsFormatException,
      );
    });
  });
}
