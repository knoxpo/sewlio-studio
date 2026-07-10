import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_events/studio_events.dart';
import 'package:studio_geometry/studio_geometry.dart';
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

  group('hierarchy object commands', () {
    const square = Path(
      start: Point(0, 0),
      segments: [LineSegment(Point(10, 0)), LineSegment(Point(10, 10))],
      closed: true,
    );
    const object = RunningStitchObject(id: Id('obj-1'), path: square);

    test('add/remove/transform round trip with undo', () {
      history.execute(const AddObject(object));
      expect(doc.objects, hasLength(1));
      expect(doc.defaultLayer.children.single.id, const Id('obj-1'));

      history.execute(
          const TransformObject(Id('obj-1'), Transform2(1, 0, 0, 1, 5, 5)));
      expect(doc.objectById(const Id('obj-1'))!.path.start, const Point(5, 5));

      history.execute(const RemoveObject(Id('obj-1')));
      expect(doc.objects, isEmpty);

      history.undo();
      history.undo();
      expect(doc.objectById(const Id('obj-1'))!.path.start, const Point(0, 0));
      history.undo();
      expect(doc.objects, isEmpty);
    });

    test('group/ungroup with nested groups', () {
      history.execute(const AddObject(RunningStitchObject(
        id: Id('a'),
        path: Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]),
      )));
      history.execute(const AddObject(RunningStitchObject(
        id: Id('b'),
        path: Path(start: Point(10, 0), segments: [LineSegment(Point(15, 0))]),
      )));

      history.execute(GroupSelection(
        GroupNode(id: const Id('g1'), name: 'Group 1'),
        const [
          DocumentNodeRef(DocumentNodeKind.object, Id('a')),
          DocumentNodeRef(DocumentNodeKind.object, Id('b')),
        ],
      ));
      expect(doc.defaultLayer.children.single.id, const Id('g1'));
      expect(doc.groupById(const Id('g1'))!.children, hasLength(2));

      history.execute(GroupSelection(
        GroupNode(id: const Id('g2'), name: 'Group 2'),
        const [DocumentNodeRef(DocumentNodeKind.group, Id('g1'))],
      ));
      expect(doc.defaultLayer.children.single.id, const Id('g2'));
      expect(doc.groupById(const Id('g2'))!.children.single.id, const Id('g1'));

      history.execute(const UngroupGroup(Id('g2')));
      expect(doc.defaultLayer.children.single.id, const Id('g1'));
      expect(doc.groups.containsKey(const Id('g2')), isFalse);
    });

    test('duplicate subtree creates fresh ids', () {
      history.execute(const AddObject(RunningStitchObject(
        id: Id('a'),
        path: Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]),
      )));
      history.execute(GroupSelection(
        GroupNode(id: const Id('g1'), name: 'Group 1'),
        const [DocumentNodeRef(DocumentNodeKind.object, Id('a'))],
      ));

      final subtree = doc.duplicateSubtree(
        const DocumentNodeRef(DocumentNodeKind.group, Id('g1')),
        () => Id('copy-${doc.objects.length + doc.groups.length}'),
      );
      history.execute(DuplicateNode(
        subtree,
        parent: HierarchyParentRef(DocumentNodeKind.layer, doc.defaultLayer.id),
        index: 1,
      ));

      expect(doc.defaultLayer.children, hasLength(2));
      expect(doc.defaultLayer.children.last.id, isNot(const Id('g1')));
      expect(doc.groups, hasLength(2));
      expect(doc.objects, hasLength(2));
    });

    test('effective visibility and locking inherit from ancestors', () {
      history.execute(const AddObject(RunningStitchObject(
        id: Id('a'),
        path: Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]),
      )));
      history.execute(GroupSelection(
        GroupNode(id: const Id('g1'), name: 'Group 1'),
        const [DocumentNodeRef(DocumentNodeKind.object, Id('a'))],
      ));

      history.execute(const SetNodeVisible(
          DocumentNodeRef(DocumentNodeKind.group, Id('g1')), false));
      history.execute(const SetNodeLocked(
          DocumentNodeRef(DocumentNodeKind.group, Id('g1')), true));

      expect(doc.isObjectVisible(const Id('a')), isFalse);
      expect(doc.isObjectLocked(const Id('a')), isTrue);
      expect(doc.flattenVisibleObjects(), isEmpty);
    });

    test('batch transform over mixed selection applies once to descendants',
        () {
      history.execute(const AddObject(RunningStitchObject(
        id: Id('a'),
        path: Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]),
      )));
      history.execute(const AddObject(RunningStitchObject(
        id: Id('b'),
        path: Path(start: Point(10, 0), segments: [LineSegment(Point(15, 0))]),
      )));
      history.execute(GroupSelection(
        GroupNode(id: const Id('g1'), name: 'Group 1'),
        const [
          DocumentNodeRef(DocumentNodeKind.object, Id('a')),
          DocumentNodeRef(DocumentNodeKind.object, Id('b')),
        ],
      ));

      history.execute(const TransformSelection(
        [DocumentNodeRef(DocumentNodeKind.group, Id('g1'))],
        Transform2(1, 0, 0, 1, 3, 2),
      ));

      expect(doc.objectById(const Id('a'))!.path.start, const Point(3, 2));
      expect(doc.objectById(const Id('b'))!.path.start, const Point(13, 2));
    });

    test('move rejects cycles', () {
      history.execute(const AddObject(RunningStitchObject(
        id: Id('a'),
        path: Path(start: Point(0, 0), segments: [LineSegment(Point(5, 0))]),
      )));
      history.execute(GroupSelection(
        GroupNode(id: const Id('g1'), name: 'Group 1'),
        const [DocumentNodeRef(DocumentNodeKind.object, Id('a'))],
      ));
      history.execute(GroupSelection(
        GroupNode(id: const Id('g2'), name: 'Group 2'),
        const [DocumentNodeRef(DocumentNodeKind.group, Id('g1'))],
      ));

      expect(
        () => history.execute(const MoveNode(
          DocumentNodeRef(DocumentNodeKind.group, Id('g2')),
          parent: HierarchyParentRef(DocumentNodeKind.group, Id('g1')),
        )),
        throwsStateError,
      );
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

      history.undo();
      history.undo();
      expect(doc.guideById(const Id('g1'))!.name, 'Center');
      history.undo();
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

  test('.embproj v2 encode/decode round trips and v1 is rejected', () {
    doc.name = 'Rose';
    history.execute(const AddObject(RunningStitchObject(
      id: Id('obj-1'),
      path: Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]),
      stitchLength: 3,
    )));
    history.execute(GroupSelection(
      GroupNode(id: const Id('g1'), name: 'Group 1'),
      const [DocumentNodeRef(DocumentNodeKind.object, Id('obj-1'))],
    ));
    final encoded = encodeProject(doc);
    final decoded = decodeProject(encoded);
    expect(decoded.name, 'Rose');
    expect(decoded.id, doc.id);
    expect(decoded.objects, hasLength(1));
    expect(decoded.groups, hasLength(1));
    expect(decoded.layers, hasLength(1));
    expect(encodeProject(decoded), encoded);

    expect(
        () => decodeProject(
            '{"version":"1","objects":[],"layers":[],"groups":{}}'),
        throwsFormatException);
  });
}
