import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/dock/dock_controller.dart';
import 'package:studio/src/panels/panel_def.dart';

Future<DockController> pumpEditor(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  final dock = DockController.memory(panelIds: defaultPanelIds);
  await tester.pumpWidget(StudioApp(session: StudioSession(), dock: dock));
  return dock;
}

void main() {
  testWidgets('default dock shows the three tabs; switching tabs works',
      (tester) async {
    await pumpEditor(tester);
    expect(find.byKey(const Key('dock-tab-stitches')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-layers')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-properties')), findsOneWidget);
    // Stitches is the default active tab (summary footer visible).
    expect(find.text('Stitch Count'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dock-tab-layers')));
    await tester.pump();
    expect(find.byTooltip('Add layer'), findsOneWidget);
  });

  testWidgets('dragging a tab to a gap splits it into its own group',
      (tester) async {
    final dock = await pumpEditor(tester);
    final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('dock-tab-layers'))));
    // Gap zones mount once the drag is in flight — nudge twice (the
    // recognizer claims on the first move, fires onDragStarted on the
    // second).
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byKey(const Key('dock-gap-0'))));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(dock.layout.groups, hasLength(2));
    expect(dock.layout.groups[0].panelIds, ['layers']);
    expect(dock.layout.groups[1].panelIds, ['stitches', 'properties']);
    // Both groups render their tab bars.
    expect(find.byKey(const Key('dock-tab-layers')), findsOneWidget);
    expect(find.byKey(const Key('dock-splitter-1')), findsOneWidget);
  });

  testWidgets('dragging a tab onto another tab joins/reorders the group',
      (tester) async {
    final dock = await pumpEditor(tester);
    final target = find.byKey(const Key('dock-tab-properties'));
    final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('dock-tab-stitches'))));
    await tester.pump();
    // Hover the right half of the Properties tab → insert after it.
    await gesture.moveTo(tester.getCenter(target) + const Offset(30, 0));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(dock.layout.groups.single.panelIds,
        ['layers', 'properties', 'stitches']);
  });

  testWidgets('splitter drag resizes the pair and survives collapse toggle',
      (tester) async {
    final dock = await pumpEditor(tester);
    dock.splitOut('layers', groupIndex: 0);
    await tester.pump();
    final before =
        tester.getSize(find.byKey(const Key('dock-panel-layers'))).height;
    await tester.drag(
        find.byKey(const Key('dock-splitter-1')), const Offset(0, 120));
    await tester.pump();
    final after =
        tester.getSize(find.byKey(const Key('dock-panel-layers'))).height;
    expect(after, greaterThan(before + 100));

    // Collapse: only the tab bar remains for the collapsed group.
    await tester.tap(find.byKey(const Key('dock-collapse-0')));
    await tester.pump();
    expect(dock.layout.groups[0].collapsed, isTrue);
    expect(find.byKey(const Key('dock-panel-layers')), findsNothing);
    await tester.tap(find.byKey(const Key('dock-collapse-0')));
    await tester.pump();
    expect(find.byKey(const Key('dock-panel-layers')), findsOneWidget);
  });

  testWidgets('width handle resizes the dock within bounds', (tester) async {
    final dock = await pumpEditor(tester);
    await tester.drag(
        find.byKey(const Key('dock-width-handle')), const Offset(-100, 0));
    await tester.pump();
    expect(dock.layout.width, 400);
    await tester.drag(
        find.byKey(const Key('dock-width-handle')), const Offset(-500, 0));
    await tester.pump();
    expect(dock.layout.width, 480); // clamped to maxWidth
  });

  testWidgets('Panels menu toggles panels and resets the workspace',
      (tester) async {
    final dock = await pumpEditor(tester);
    await tester.tap(find.text('Panels'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Properties'));
    await tester.pumpAndSettle();
    expect(dock.isVisible('properties'), isFalse);
    expect(find.byKey(const Key('dock-tab-properties')), findsNothing);

    dock.splitOut('layers', groupIndex: 0);
    await tester.pump();
    await tester.tap(find.text('Panels'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Reset Workspace'));
    await tester.pumpAndSettle();
    expect(dock.layout.groups.single.panelIds, defaultPanelIds);
    expect(dock.isVisible('properties'), isTrue);
  });
}
