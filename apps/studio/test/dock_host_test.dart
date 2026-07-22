import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/dock/dock_controller.dart';
import 'package:studio/src/panels/panel_def.dart';

Future<DockController> pumpEditor(WidgetTester tester) async {
  // Widget tests default to Android → touch-sized dock chrome, which
  // makes the tabs overflow into the scrollable tab bar. These tests
  // exercise desktop drag/drop geometry — pin a desktop platform that
  // uses the in-app menu bar (not macOS, whose menus are native).
  debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  final dock = DockController.memory(panelIds: defaultPanelIds);
  await tester.pumpWidget(StudioApp(session: StudioSession(), dock: dock));
  return dock;
}

void main() {
  testWidgets('default dock shows the design tabs; switching tabs works',
      (tester) async {
    await pumpEditor(tester);
    expect(find.byKey(const Key('dock-tab-layers')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-properties')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-hoop')), findsOneWidget);
    // Stitches panel is a domain (Stitch view) panel, not a design one.
    expect(find.byKey(const Key('dock-tab-stitches')), findsNothing);
    // Layers is the default active tab (first registered panel).
    expect(find.byTooltip('Add layer'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('dock-tab-hoop')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('dock-tab-hoop')));
    await tester.pump();
    expect(find.text('Edit Hoop…'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
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
    expect(dock.layout.groups[1].panelIds, [
      for (final id in defaultPanelIds)
        if (id != 'layers') id
    ]);
    // Both groups render their tab bars.
    expect(find.byKey(const Key('dock-tab-layers')), findsOneWidget);
    expect(find.byKey(const Key('dock-splitter-1')), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('dragging a tab onto another tab joins/reorders the group',
      (tester) async {
    final dock = await pumpEditor(tester);
    final target = find.byKey(const Key('dock-tab-layers'));
    final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('dock-tab-properties'))));
    // The drag recognizer claims on the first move and fires
    // onDragStarted on the second (see the split-out test above).
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 10));
    await tester.pump();
    // Hover the left half of the Layers tab → insert before it (both
    // leading tabs are reliably visible in the scrollable tab bar).
    await gesture.moveTo(tester.getTopLeft(target) + const Offset(20, 12));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(dock.layout.groups.single.panelIds, [
      'properties',
      'layers',
      'hoop',
      for (final id in defaultPanelIds)
        if (!{'properties', 'layers', 'hoop'}.contains(id)) id,
    ]);
    debugDefaultTargetPlatformOverride = null;
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
    debugDefaultTargetPlatformOverride = null;
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
    debugDefaultTargetPlatformOverride = null;
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
    debugDefaultTargetPlatformOverride = null;
  });
}
