import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

TextObject _sample() => TextObject(
      id: const Id('t1'),
      path: const Path(start: Point(10, 20)),
      text: 'Hi',
      fontFamily: 'Monoline',
      sizeMm: 12,
      trackingMm: 0.5,
      lineHeight: 1.2,
      alignment: 'center',
      frameWidthMm: 40,
      outlines: const [
        Path(start: Point(10, 20), segments: [LineSegment(Point(15, 20))]),
        Path(start: Point(20, 20), segments: [LineSegment(Point(25, 14))]),
      ],
    );

void main() {
  test('text object serializes round trip (ADR-028)', () {
    final decoded = EmbroideryObject.fromJson(_sample().toJson());
    expect(decoded, isA<TextObject>());
    final text = decoded as TextObject;
    expect(text.text, 'Hi');
    expect(text.fontFamily, 'Monoline');
    expect(text.alignment, 'center');
    expect(text.frameWidthMm, 40);
    expect(text.outlines, hasLength(2));
    expect(text.anchor, const Point(10, 20));
  });

  test('renderPaths/bounds come from outlines; base objects unchanged', () {
    final text = _sample();
    expect(text.renderPaths, same(text.outlines));
    expect(text.bounds().minX, 10);
    expect(text.bounds().maxX, 25);

    const running = RunningStitchObject(
        id: Id('r'),
        path: Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]));
    expect(running.renderPaths, [running.path]);
  });

  test('transformedBy moves anchor and every outline', () {
    final moved = _sample().transformedBy(Transform2.translation(5, -5));
    expect(moved.anchor, const Point(15, 15));
    expect(moved.outlines.first.start, const Point(15, 15));
    expect(moved.outlines.last.start, const Point(25, 15));
    expect(moved.text, 'Hi'); // design intent untouched
  });

  test('withPath (drag translation) shifts outlines by the delta', () {
    final moved = _sample().withPath(const Path(start: Point(0, 20)));
    expect(moved.outlines.first.start, const Point(0, 20));
  });

  test('stitch generation joins contours with trim + jump', () {
    final ops = generateStitches(_sample());
    expect(ops.where((o) => o.kind == StitchKind.trim), hasLength(1));
    expect(ops.where((o) => o.kind == StitchKind.jump), hasLength(1));
    expect(ops.first.kind, StitchKind.stitch);
  });
}
