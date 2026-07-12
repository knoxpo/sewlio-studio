import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

TextObject _text() {
  const font = MonolineTextFont();
  return TextObject(
    id: const Id('t1'),
    path: const Path(start: Point.zero),
    text: 'hi',
    fontFamily: font.family,
    sizeMm: 5,
    outlines: layoutText('hi', font, origin: Point.zero, sizeMm: 5),
  );
}

KeyDownEvent _key(LogicalKeyboardKey logical, PhysicalKeyboardKey physical) =>
    KeyDownEvent(
        physicalKey: physical, logicalKey: logical, timeStamp: Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('switching workspace mode resets the active tool to Move (select)', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);

    vm.selectTool(ToolKind.pen);
    expect(vm.activeKind, ToolKind.pen);

    // A design tool has no slot in the Stitch toolbox — mode switch
    // drops back to Move so no phantom tool stays active.
    vm.setMode(WorkspaceMode.domain);
    expect(vm.activeKind, ToolKind.select);
  });

  test('double-click enters text editing in design mode only', () async {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.execute(AddObject(_text(), parent: null));
    final center =
        vm.session.document.objectById(const Id('t1'))!.bounds().center;

    // Stitch mode: design content is a read-only outline — double-click
    // must not open the text editor.
    vm.setMode(WorkspaceMode.domain);
    vm.onCanvasDoubleTap(center);
    await pumpEventQueue();
    expect(vm.editingTextId, isNull);
    expect(vm.activeKind, ToolKind.select);

    // Design mode: the same double-click re-enters in-place editing.
    vm.setMode(WorkspaceMode.design);
    vm.onCanvasDoubleTap(center);
    await pumpEventQueue();
    expect(vm.editingTextId, const Id('t1'));
  });

  test('design-tool shortcuts are inert in Stitch mode', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.setMode(WorkspaceMode.domain);
    final node = FocusNode();

    // T (Text) is a design-content tool — ignored in Stitch mode.
    expect(
        vm.onKey(node, _key(LogicalKeyboardKey.keyT, PhysicalKeyboardKey.keyT)),
        KeyEventResult.ignored);
    expect(vm.activeKind, ToolKind.select);

    // Navigation still works everywhere.
    expect(
        vm.onKey(node, _key(LogicalKeyboardKey.keyH, PhysicalKeyboardKey.keyH)),
        KeyEventResult.handled);
    expect(vm.activeKind, ToolKind.pan);
  });
}
