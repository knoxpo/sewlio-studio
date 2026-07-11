import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  const lineA = Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]);
  const lineB =
      Path(start: Point(20, 20), segments: [LineSegment(Point(25, 20))]);

  test('joins objects with trim + jump between them', () {
    final seq = digitizeObjects(const [
      RunningStitchObject(id: Id('a'), path: lineA),
      RunningStitchObject(id: Id('b'), path: lineB),
    ]);
    final kinds = seq.ops.map((op) => op.kind).toList();
    final trimIndex = kinds.indexOf(StitchKind.trim);
    expect(trimIndex, greaterThan(0));
    expect(kinds[trimIndex + 1], StitchKind.jump);
    expect(seq.ops[trimIndex + 1].position, const Point(20, 20));
    expect(seq.threads, hasLength(1));
  });

  test('satin and fill now digitize (ADR-042), joined with trim + jump', () {
    final skipped = <EmbroideryObject>[];
    final seq = digitizeObjects(const [
      RunningStitchObject(id: Id('a'), path: lineA),
      SatinObject(id: Id('s'), path: lineB),
    ], skipped: skipped);
    // Both objects have generators now — nothing is skipped, and they are
    // joined with a trim + jump.
    expect(skipped, isEmpty);
    expect(seq.ops.map((op) => op.kind), contains(StitchKind.trim));
  });
}
