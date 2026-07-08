import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_events/studio_events.dart';
import 'package:test/test.dart';

void main() {
  late Document doc;
  late EventBus events;
  late CommandBus bus;
  late History history;

  setUp(() {
    doc = Document(id: const Id('doc-1'));
    events = EventBus();
    bus = CommandBus(events);
    history = History(bus);
    registerDocumentHandlers(bus, doc);
  });

  test('execute mutates document and publishes event', () {
    final seen = <DocumentRenamed>[];
    events.on<DocumentRenamed>().listen(seen.add);

    history.execute(const RenameDocument('Rose'));

    expect(doc.name, 'Rose');
    expect(doc.revision, 1);
    expect(seen.single.from, 'Untitled');
  });

  test('undo/redo round trip', () {
    history.execute(const RenameDocument('Rose'));
    history.execute(const RenameDocument('Tulip'));

    history.undo();
    expect(doc.name, 'Rose');
    history.undo();
    expect(doc.name, 'Untitled');
    expect(history.canUndo, isFalse);

    history.redo();
    history.redo();
    expect(doc.name, 'Tulip');
    expect(history.canRedo, isFalse);
  });

  test('new edit clears redo', () {
    history.execute(const RenameDocument('Rose'));
    history.undo();
    history.execute(const RenameDocument('Iris'));
    expect(history.canRedo, isFalse);
    expect(doc.name, 'Iris');
  });

  test('undo/redo on empty history are no-ops', () {
    history.undo();
    history.redo();
    expect(doc.name, 'Untitled');
  });

  group('object commands', () {
    const square = Path(
      start: Point(0, 0),
      segments: [LineSegment(Point(10, 0)), LineSegment(Point(10, 10))],
      closed: true,
    );
    const object = RunningStitchObject(id: Id('obj-1'), path: square);

    test('add/remove/transform round trip with undo', () {
      history.execute(const AddObject(object));
      expect(doc.objects, hasLength(1));

      history.execute(
          const TransformObject(Id('obj-1'), Transform2(1, 0, 0, 1, 5, 5)));
      expect(doc.objectById(const Id('obj-1'))!.path.start, const Point(5, 5));

      history.execute(const RemoveObject(Id('obj-1')));
      expect(doc.objects, isEmpty);

      history.undo(); // un-remove
      history.undo(); // un-transform
      expect(doc.objectById(const Id('obj-1'))!.path.start, const Point(0, 0));
      history.undo(); // un-add
      expect(doc.objects, isEmpty);
    });

    test('commands on missing ids throw', () {
      expect(() => history.execute(const RemoveObject(Id('nope'))),
          throwsStateError);
      expect(
          () => history
              .execute(const TransformObject(Id('nope'), Transform2.identity)),
          throwsStateError);
    });
  });

  group('guide commands', () {
    const guide = Guide(
      id: Id('g1'),
      axis: GuideAxis.vertical,
      positionMm: 25,
      name: 'Center',
      colorHex: '#ff6b6b',
    );

    test('add/update/remove round trip with undo', () {
      history.execute(const AddGuide(guide));
      expect(doc.guides, hasLength(1));

      history
          .execute(UpdateGuide(guide.copyWith(name: 'Left', positionMm: 10)));
      expect(doc.guideById(const Id('g1'))!.name, 'Left');

      history.execute(const RemoveGuide(Id('g1')));
      expect(doc.guides, isEmpty);

      history.undo(); // un-remove
      history.undo(); // un-update
      expect(doc.guideById(const Id('g1'))!.name, 'Center');
      history.undo(); // un-add
      expect(doc.guides, isEmpty);
    });

    test('guides persist through .embproj', () {
      doc.guides.add(guide);
      final decoded = decodeProject(encodeProject(doc));
      expect(decoded.guides, hasLength(1));
      expect(decoded.guides.single.name, 'Center');
      expect(decoded.guides.single.colorHex, '#ff6b6b');
      expect(decoded.guides.single.axis, GuideAxis.vertical);
    });
  });

  test('.embproj encode/decode round trips (golden shape)', () {
    doc.name = 'Rose';
    doc.objects.add(const RunningStitchObject(
      id: Id('obj-1'),
      path: Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]),
      stitchLength: 3,
    ));
    final encoded = encodeProject(doc);
    final decoded = decodeProject(encoded);
    expect(decoded.name, 'Rose');
    expect(decoded.id, doc.id);
    expect(decoded.objects, hasLength(1));
    expect(encodeProject(decoded), encoded); // byte-stable

    expect(() => decodeProject('{"version":"999","objects":[]}'),
        throwsFormatException);
  });
}
