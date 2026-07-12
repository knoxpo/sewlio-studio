import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/dock/dock_controller.dart';
import 'package:studio/src/panels/panel_registry.dart';
import 'package:studio/src/workspace_view_model.dart';

void main() {
  DockGroupMatch groupOf(DockController dock, String id) {
    for (final g in dock.layout.groups) {
      if (g.panelIds.contains(id)) return (found: true, activeId: g.activeId);
    }
    return (found: false, activeId: null);
  }

  test('activating the Text tool reveals the Character tab (ADR-044)', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    final dock = DockController.memory(
        panelIds: defaultPanelIds, rows: designPanelRows);
    vm.onRevealPanel = dock.selectTab;

    // 'character' shares a row with 'properties' (the default active tab).
    expect(groupOf(dock, 'character').activeId, isNot('character'));
    vm.selectTool(ToolKind.text);
    expect(groupOf(dock, 'character').activeId, 'character');
  });

  test('a user-hidden panel stays hidden on tool activation', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    final dock = DockController.memory(
        panelIds: defaultPanelIds, rows: designPanelRows);
    vm.onRevealPanel = dock.selectTab;

    dock.togglePanel('character'); // user closes the panel
    expect(dock.isVisible('character'), isFalse);
    vm.selectTool(ToolKind.text);
    expect(dock.isVisible('character'), isFalse,
        reason: 'reveal never un-hides — user customisation wins');
  });
}

typedef DockGroupMatch = ({bool found, String? activeId});
