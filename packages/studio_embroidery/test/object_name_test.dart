import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  const object = RunningStitchObject(
    id: Id('a'),
    path: Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]),
    name: '<Rectangle>',
  );

  test('name survives JSON round-trip and is omitted when null', () {
    final decoded = EmbroideryObject.fromJson(object.toJson());
    expect(decoded.name, '<Rectangle>');

    const unnamed = RunningStitchObject(
      id: Id('b'),
      path: Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]),
    );
    expect(unnamed.toJson().containsKey('name'), isFalse);
    expect(EmbroideryObject.fromJson(unnamed.toJson()).name, isNull);
  });

  test('withName renames; other copy paths preserve the name', () {
    final renamed = object.withName('Border');
    expect(renamed.name, 'Border');
    expect(renamed.id, object.id);
    expect((renamed as RunningStitchObject).stitchLength, object.stitchLength);

    expect(object.withPath(object.path).name, '<Rectangle>');
    expect(
        object.withStroke(const StrokeProps(widthMm: 1)).name, '<Rectangle>');
    expect(
        object.transformedBy(Transform2.translation(1, 1)).name, '<Rectangle>');
  });

  test('text object copy paths preserve the name', () {
    const text = TextObject(
      id: Id('t'),
      path: Path(start: Point(0, 0)),
      text: 'hi',
      fontFamily: 'mono',
      name: 'Title',
    );
    expect(text.withPath(const Path(start: Point(5, 5))).name, 'Title');
    expect(text.transformedBy(Transform2.translation(1, 0)).name, 'Title');
    expect(EmbroideryObject.fromJson(text.toJson()).name, 'Title');
  });
}
