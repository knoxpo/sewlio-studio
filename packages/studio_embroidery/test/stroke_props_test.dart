import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  const path = Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]);

  test('stroke props round-trip through object JSON', () {
    const object = RunningStitchObject(
      id: Id('s1'),
      path: path,
      stroke: StrokeProps(
          widthMm: 1.2, cap: 'square', join: 'bevel', colorHex: '#d7263d'),
    );
    final decoded = EmbroideryObject.fromJson(object.toJson());
    expect(decoded.stroke.widthMm, 1.2);
    expect(decoded.stroke.cap, 'square');
    expect(decoded.stroke.join, 'bevel');
    expect(decoded.stroke.colorHex, '#d7263d');
  });

  test('default stroke stays out of JSON; old files decode to defaults', () {
    const object = RunningStitchObject(id: Id('s2'), path: path);
    final json = object.toJson();
    expect(json.containsKey('stroke'), isFalse);
    expect(EmbroideryObject.fromJson(json).stroke.isDefault, isTrue);
  });

  test('withStroke keeps type, id, geometry, and params', () {
    const object =
        RunningStitchObject(id: Id('s3'), path: path, stitchLength: 3);
    final restyled =
        object.withStroke(const StrokeProps(widthMm: 2, cap: 'butt'));
    expect(restyled, isA<RunningStitchObject>());
    expect(restyled.id, object.id);
    expect(restyled.path.segments, hasLength(1));
    expect((restyled as RunningStitchObject).stitchLength, 3);
    expect(restyled.stroke.widthMm, 2);
  });

  test('withPath and transformedBy preserve stroke', () {
    const object = RunningStitchObject(
        id: Id('s4'), path: path, stroke: StrokeProps(widthMm: 2));
    expect(object.withPath(path).stroke.widthMm, 2);
    expect(
        object.transformedBy(Transform2.translation(1, 1)).stroke.widthMm, 2);
  });
}
