import 'package:flutter_test/flutter_test.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_events/studio_events.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  late Document document;
  late History history;
  late SelectTool tool;

  const square = Path(
    start: Point(10, 10),
    segments: [
      LineSegment(Point(20, 10)),
      LineSegment(Point(20, 20)),
      LineSegment(Point(10, 20)),
    ],
    closed: true,
  );

  setUp(() {
    document = Document(id: const Id('doc-1'));
    final bus = CommandBus(EventBus());
    history = History(bus);
    registerDocumentHandlers(bus, document);
    history.execute(
        const AddObject(RunningStitchObject(id: Id('obj-1'), path: square)));
    tool = SelectTool(
      document: document,
      history: history,
      selection: SelectionController(),
    );
  });

  test('tap selects topmost hit, tap on empty clears', () {
    tool.tap(const Point(15, 15));
    expect(tool.selection.selected, const Id('obj-1'));
    tool.tap(const Point(50, 50));
    expect(tool.selection.selected, isNull);
  });

  test('drag moves selection via one undoable TransformObject', () {
    tool.tap(const Point(15, 15));

    expect(tool.dragStart(const Point(15, 15)), isTrue);
    tool.dragUpdate(const Point(18, 15));
    tool.dragUpdate(const Point(20, 17));
    tool.dragEnd();

    final moved = document.objectById(const Id('obj-1'))!;
    expect(moved.path.start, const Point(15, 12));

    history.undo();
    expect(document.objectById(const Id('obj-1'))!.path.start,
        const Point(10, 10));
  });

  test('drag off-selection is not claimed; empty drag dispatches nothing', () {
    expect(tool.dragStart(const Point(50, 50)), isFalse);

    tool.tap(const Point(15, 15));
    expect(tool.dragStart(const Point(15, 15)), isTrue);
    tool.dragEnd(); // no movement
    expect(history.canUndo, isTrue); // only the AddObject from setUp
    history.undo();
    expect(history.canUndo, isFalse);
  });
}
