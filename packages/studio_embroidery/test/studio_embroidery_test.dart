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
