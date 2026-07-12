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

void main() {
  test('editing text hides the committed object and syncs the tool', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.execute(AddObject(_text(), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));

    // Not editing yet.
    expect(vm.editingTextId, isNull);

    // Enter in-place editing (double-click path).
    final tool = vm.tools[ToolKind.text]! as TextTool;
    tool.editExisting(
        vm.session.document.objectById(const Id('t1')) as TextObject,
        const MonolineTextFont());
    expect(vm.editingTextId, const Id('t1'),
        reason: 'edited object is hidden from the vector pass');

    // A panel size change mirrors onto the live tool so the preview
    // updates immediately (no old+new ghost).
    vm.applyCharAttrs(const CharAttrs(sizeMm: 20));
    expect(tool.sizeMm, 20);
  });
}
