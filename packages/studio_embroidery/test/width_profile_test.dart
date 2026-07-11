import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  const path = Path(start: Point(0, 0), segments: [
    LineSegment(Point(10, 0)),
    LineSegment(Point(10, 10)),
  ]);

  test('widthProfile round-trips through JSON (ADR-038)', () {
    const object = RunningStitchObject(
      id: Id('w1'),
      path: path,
      widthProfile: [0.2, 0.5, 0.4],
    );
    final decoded =
        EmbroideryObject.fromJson(object.toJson()) as RunningStitchObject;
    expect(decoded.widthProfile, [0.2, 0.5, 0.4]);
  });

  test('null profile stays out of JSON; old files load unchanged', () {
    const object = RunningStitchObject(id: Id('w2'), path: path);
    final json = object.toJson();
    expect(json.containsKey('widthProfile'), isFalse);
    final decoded = EmbroideryObject.fromJson(json) as RunningStitchObject;
    expect(decoded.widthProfile, isNull);
  });

  test(
      'withPath keeps the profile when node count matches, drops it '
      'otherwise', () {
    const object = RunningStitchObject(
      id: Id('w3'),
      path: path,
      widthProfile: [0.2, 0.5, 0.4],
    );
    // Transform: same node count.
    final moved = object.withPath(path.transformed(
      Transform2.translation(5, 5),
    ));
    expect(moved.widthProfile, [0.2, 0.5, 0.4]);
    // Node edit: different node count.
    const edited = Path(
      start: Point(0, 0),
      segments: [LineSegment(Point(10, 10))],
    );
    expect(object.withPath(edited).widthProfile, isNull);
  });
}
