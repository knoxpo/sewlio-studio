import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';

void main() {
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
}
