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
    )..pxPerMm = 10; // realistic zoom: handle hit radius = 0.6 mm
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

  test('corner handle resizes the selection about the opposite corner', () {
    tool.tap(const Point(15, 15)); // square bounds (10,10)-(20,20)

    // Drag the SE handle from (20,20) to (30,30): 2× about NW (10,10).
    expect(tool.dragStart(const Point(20, 20)), isTrue);
    tool.dragUpdate(const Point(30, 30));
    tool.dragEnd();

    final b = document.objectById(const Id('obj-1'))!.bounds();
    expect(b.minX, closeTo(10, 1e-9));
    expect(b.minY, closeTo(10, 1e-9));
    expect(b.maxX, closeTo(30, 1e-9));
    expect(b.maxY, closeTo(30, 1e-9));

    history.undo();
    expect(document.objectById(const Id('obj-1'))!.bounds().maxX,
        closeTo(20, 1e-9));
  });

  test('edge handle scales one axis; Shift makes corner scaling uniform', () {
    tool.tap(const Point(15, 15));

    // East edge handle (20,15) → (25,15): only width doubles... 1.5×.
    expect(tool.dragStart(const Point(20, 15)), isTrue);
    tool.dragUpdate(const Point(25, 15));
    tool.dragEnd();
    var b = document.objectById(const Id('obj-1'))!.bounds();
    expect(b.maxX, closeTo(25, 1e-9));
    expect(b.maxY, closeTo(20, 1e-9)); // height untouched
    history.undo();

    // SE corner with Shift: x drags to 2×, y only 1.2× → uniform 2×.
    tool.uniformModifier = true;
    expect(tool.dragStart(const Point(20, 20)), isTrue);
    tool.dragUpdate(const Point(30, 22));
    tool.dragEnd();
    b = document.objectById(const Id('obj-1'))!.bounds();
    expect(b.maxX, closeTo(30, 1e-9));
    expect(b.maxY, closeTo(30, 1e-9));
  });

  test('Alt scales from the selection center', () {
    tool.tap(const Point(15, 15));
    tool.centerModifier = true;

    // SE (20,20) → (25,25): 2× about the center (15,15).
    expect(tool.dragStart(const Point(20, 20)), isTrue);
    tool.dragUpdate(const Point(25, 25));
    tool.dragEnd();
    final b = document.objectById(const Id('obj-1'))!.bounds();
    expect(b.minX, closeTo(5, 1e-9));
    expect(b.maxX, closeTo(25, 1e-9));
  });

  test('rotation grip rotates about the center; Shift snaps to 15°', () {
    tool.tap(const Point(15, 15));

    // Grip sits above top-center: (15, 10 - 22/pxPerMm) = (15, 7.8).
    expect(tool.dragStart(const Point(15, 7.8)), isTrue);
    // Drag to the right of the center → 90° clockwise-ish; with Shift
    // and a slightly-off angle it snaps to exactly 90°.
    tool.uniformModifier = true;
    tool.dragUpdate(const Point(43, 16)); // ~92° from the grip vector
    tool.dragEnd();

    final b = document.objectById(const Id('obj-1'))!.bounds();
    // 90° rotation of a square about its center: bounds unchanged.
    expect(b.minX, closeTo(10, 1e-6));
    expect(b.minY, closeTo(10, 1e-6));
    expect(b.maxX, closeTo(20, 1e-6));
    expect(b.maxY, closeTo(20, 1e-6));
    // But the path's start corner moved to a different corner.
    final start = document.objectById(const Id('obj-1'))!.path.start;
    expect(start.distanceTo(const Point(10, 10)), greaterThan(1));
  });

  test('cursorAt reflects handles, selected objects, and empty canvas', () {
    expect(tool.cursorAt(const Point(50, 50)), ToolCursor.basic);
    tool.tap(const Point(15, 15));
    // Inside the selection: open hand; closed hand while dragging.
    expect(tool.cursorAt(const Point(15, 15)), ToolCursor.grab);
    tool.dragStart(const Point(15, 15));
    expect(tool.cursorAt(const Point(16, 16)), ToolCursor.grabbing);
    tool.dragEnd();
    expect(tool.cursorAt(const Point(20, 20)), ToolCursor.resizeNWSE);
    expect(tool.cursorAt(const Point(20, 10)), ToolCursor.resizeNESW);
    expect(tool.cursorAt(const Point(15, 20)), ToolCursor.resizeNS);
    expect(tool.cursorAt(const Point(10, 15)), ToolCursor.resizeEW);
    expect(tool.cursorAt(const Point(15, 7.8)), ToolCursor.rotate);
  });

  test('empty drag becomes marquee; zero-size marquee dispatches nothing', () {
    expect(tool.dragStart(const Point(50, 50)), isTrue);
    tool.dragEnd();
    expect(tool.selection.selected, isNull);

    tool.tap(const Point(15, 15));
    expect(tool.dragStart(const Point(15, 15)), isTrue);
    tool.dragEnd(); // no movement
    expect(history.canUndo, isTrue); // only the AddObject from setUp
    history.undo();
    expect(history.canUndo, isFalse);
  });

  group('restrictToBase (Stitch mode)', () {
    // A second object on a stitch layer, so the base guard is per-object.
    const stitchLayerId = Id('sl');
    const stitchSquare = Path(
      start: Point(40, 40),
      segments: [
        LineSegment(Point(50, 40)),
        LineSegment(Point(50, 50)),
        LineSegment(Point(40, 50)),
      ],
      closed: true,
    );

    setUp(() {
      history.execute(AddLayer(
          LayerNode(id: stitchLayerId, name: 'Stitches', kind: LayerKind.stitch)));
      history.execute(const AddObject(
        RunningStitchObject(id: Id('obj-2'), path: stitchSquare),
        parent: HierarchyParentRef(DocumentNodeKind.layer, stitchLayerId),
      ));
      tool.restrictToBase = true;
    });

    test('design-layer (base) object stays selectable but cannot move', () {
      // Selectable: tap still hits it.
      tool.tap(const Point(15, 15));
      expect(tool.selection.selected, const Id('obj-1'));
      // No transform grips for a base object.
      expect(tool.handleAt(const Point(20, 20)), isNull);
      // Drag on it does not move it (falls through to marquee).
      final undosBefore = history.canUndo;
      expect(tool.dragStart(const Point(15, 15)), isTrue);
      tool.dragUpdate(const Point(25, 25));
      tool.dragEnd();
      expect(document.objectById(const Id('obj-1'))!.path.start,
          const Point(10, 10));
      expect(history.canUndo, undosBefore); // no new TransformSelection
    });

    test('stitch-layer object still moves under restrictToBase', () {
      tool.tap(const Point(45, 45));
      expect(tool.selection.selected, const Id('obj-2'));
      expect(tool.handleAt(const Point(50, 50)), isNotNull);
      expect(tool.dragStart(const Point(45, 45)), isTrue);
      tool.dragUpdate(const Point(48, 45));
      tool.dragEnd();
      expect(document.objectById(const Id('obj-2'))!.path.start,
          const Point(43, 40));
    });
  });
}
