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

  TextObject sampleText() => const TextObject(
        id: Id('t1'),
        path: Path(start: Point(0, 0)),
        text: 'Hello',
        fontFamily: 'Monoline',
        sizeMm: 10,
      );

  group('ApplyCharAttrs', () {
    test('applies to range; undo restores; redo reapplies', () {
      history.execute(AddObject(sampleText()));
      final before = doc.objects[const Id('t1')] as TextObject;
      expect(before.runs, isEmpty);

      history.execute(
          const ApplyCharAttrs(Id('t1'), 1, 3, CharAttrs(fillHex: '#ff0000')));
      final after = doc.objects[const Id('t1')] as TextObject;
      expect(after.runs, isNotEmpty);
      expect(after.attrsAt(1).fillHex, '#ff0000');
      expect(after.attrsAt(0).fillHex, isNot('#ff0000'));

      history.undo();
      final undone = doc.objects[const Id('t1')] as TextObject;
      expect(undone.runs, isEmpty);
      expect(undone, equals(before));

      history.redo();
      final redone = doc.objects[const Id('t1')] as TextObject;
      expect(redone.attrsAt(1).fillHex, '#ff0000');
    });

    test('no-op when target is not a text object', () {
      const square = Path(
        start: Point(0, 0),
        segments: [LineSegment(Point(10, 0))],
      );
      history.execute(const AddObject(RunningStitchObject(
        id: Id('r1'),
        path: square,
      )));
      final outcome = bus.dispatch(
          const ApplyCharAttrs(Id('r1'), 0, 1, CharAttrs(fillHex: '#0f0')));
      expect(outcome.reverse, isNull);
      expect(history.canUndo, isTrue); // only the AddObject entry
    });
  });

  group('character-style commands round trip', () {
    const style = CharacterStyle('cs-1', 'Heading', CharAttrs(sizeMm: 20));

    test('add', () {
      history.execute(const AddCharacterStyle(style));
      expect(doc.characterStyleById('cs-1'), style);
      history.undo();
      expect(doc.characterStyleById('cs-1'), isNull);
      history.redo();
      expect(doc.characterStyleById('cs-1'), style);
    });

    test('rename', () {
      history.execute(const AddCharacterStyle(style));
      history.execute(const RenameCharacterStyle('cs-1', 'Title'));
      expect(doc.characterStyleById('cs-1')!.name, 'Title');
      history.undo();
      expect(doc.characterStyleById('cs-1')!.name, 'Heading');
    });

    test('update base', () {
      history.execute(const AddCharacterStyle(style));
      history
          .execute(const UpdateCharacterStyle('cs-1', CharAttrs(sizeMm: 30)));
      expect(doc.characterStyleById('cs-1')!.base.sizeMm, 30);
      history.undo();
      expect(doc.characterStyleById('cs-1')!.base.sizeMm, 20);
    });

    test('duplicate', () {
      history.execute(const AddCharacterStyle(style));
      history.execute(const DuplicateCharacterStyle('cs-1', 'cs-2'));
      expect(doc.characterStyles, hasLength(2));
      expect(doc.characterStyleById('cs-2')!.base.sizeMm, 20);
      history.undo();
      expect(doc.characterStyleById('cs-2'), isNull);
      expect(doc.characterStyles, hasLength(1));
    });

    test('delete restores at original index', () {
      const other = CharacterStyle('cs-2', 'Body', CharAttrs());
      history.execute(const AddCharacterStyle(style));
      history.execute(const AddCharacterStyle(other));
      history.execute(const DeleteCharacterStyle('cs-1'));
      expect(doc.characterStyles.map((s) => s.id), ['cs-2']);
      history.undo();
      expect(doc.characterStyles.map((s) => s.id), ['cs-1', 'cs-2']);
    });
  });

  group('transactions', () {
    test('N executes in one transaction = one undo entry', () {
      history.beginTransaction();
      history.execute(const RenameDocument('A'));
      history.execute(const RenameDocument('B'));
      history.execute(const RenameDocument('C'));
      history.endTransaction();
      expect(doc.name, 'C');

      history.undo();
      expect(doc.name, 'Untitled');
      expect(history.canUndo, isFalse);

      history.redo();
      expect(doc.name, 'C');
    });

    test('empty transaction records nothing', () {
      history.beginTransaction();
      history.endTransaction();
      expect(history.canUndo, isFalse);
    });
  });

  group('scrub coalescing', () {
    test('same mergeKey collapses to one undo entry', () {
      history.execute(const RenameDocument('A'), mergeKey: 'name');
      history.execute(const RenameDocument('B'), mergeKey: 'name');
      history.execute(const RenameDocument('C'), mergeKey: 'name');
      expect(doc.name, 'C');

      history.undo();
      expect(doc.name, 'Untitled');
      expect(history.canUndo, isFalse);
    });

    test('different mergeKey does not coalesce', () {
      history.execute(const RenameDocument('A'), mergeKey: 'a');
      history.execute(const RenameDocument('B'), mergeKey: 'b');
      history.undo();
      expect(doc.name, 'A');
      history.undo();
      expect(doc.name, 'Untitled');
    });
  });
}
