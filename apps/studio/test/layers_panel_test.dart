import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/panels/layers_panel.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';

Future<StudioSession> pumpLayers(WidgetTester tester,
    {StudioSession? session}) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  final s = session ?? StudioSession();
  await tester.pumpWidget(StudioApp(session: s));
  await tester.tap(find.byKey(const Key('dock-tab-layers')));
  await tester.pump();
  return s;
}

/// Session with two objects grouped inside Layer 1 plus a second layer.
StudioSession richSession() {
  final session = StudioSession();
  session.history.execute(const AddObject(RunningStitchObject(
    id: Id('a'),
    path: Path(start: Point(0, 0), segments: [LineSegment(Point(20, 0))]),
  )));
  session.history.execute(const AddObject(RunningStitchObject(
    id: Id('b'),
    path: Path(start: Point(30, 0), segments: [LineSegment(Point(50, 0))]),
  )));
  session.history
      .execute(AddLayer(LayerNode(id: const Id('l2'), name: 'Layer 2')));
  return session;
}

/// The inline rename editor (excludes the panel's search field).
Finder renameField() => find.byWidgetPredicate(
    (w) => w is TextField && (w.key?.toString().contains('rename-') ?? false));

/// A row label inside the Layers panel. Scoped: once a node is
/// selected, the always-visible Properties panel shows the same name
/// in its editable field, so a bare text finder is ambiguous.
Finder layerLabel(String name) => find.descendant(
    of: find.byType(LayersPanelContent), matching: find.text(name));

void main() {
  testWidgets('clicking the selected layer label starts rename; Enter commits',
      (tester) async {
    final session = await pumpLayers(tester);
    expect(find.text('Layer 1'), findsOneWidget);

    // First click selects; clicking the selected label starts editing.
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    expect(renameField(), findsNothing);
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    expect(renameField(), findsOneWidget);
    await tester.enterText(renameField(), 'Background');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(renameField(), findsNothing);
    expect(layerLabel('Background'), findsOneWidget);
    expect(session.document.layers.single.name, 'Background');

    // Undoable: rename went through the command bus.
    session.history.undo();
    await tester.pump();
    expect(session.document.layers.single.name, 'Layer 1');
  });

  testWidgets('Escape cancels an in-flight rename', (tester) async {
    final session = await pumpLayers(tester);
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    await tester.enterText(renameField(), 'Nope');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(renameField(), findsNothing);
    expect(session.document.layers.single.name, 'Layer 1');
  });

  testWidgets('F2 renames the primary selection', (tester) async {
    await pumpLayers(tester);
    // Select the layer (also focuses the panel), then F2.
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.f2);
    await tester.pump();
    expect(renameField(), findsOneWidget);
  });

  testWidgets('drop on the top quarter of a layer row inserts before it',
      (tester) async {
    final session = await pumpLayers(tester, session: richSession());
    expect([for (final l in session.document.layers) l.name],
        ['Layer 1', 'Layer 2']);
    final source = find.text('Layer 2');
    final target = find.text('Layer 1');
    final gesture = await tester.startGesture(tester.getCenter(source));
    await tester.pump();
    final targetRect = tester.getRect(target);
    // Top quarter of the target ROW: the label sits vertically centred
    // in a taller thumbnail row, so aim a few px above the text.
    await gesture.moveTo(Offset(targetRect.center.dx, targetRect.top - 5));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect([for (final l in session.document.layers) l.name],
        ['Layer 2', 'Layer 1']);
  });

  testWidgets('selection made elsewhere auto-expands its collapsed ancestors',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = richSession();
    // Nest both objects in a group inside Layer 1.
    session.history.execute(GroupSelection(
      GroupNode(id: const Id('g1'), name: 'Group 1'),
      const [
        DocumentNodeRef(DocumentNodeKind.object, Id('a')),
        DocumentNodeRef(DocumentNodeKind.object, Id('b')),
      ],
    ));
    await tester.pumpWidget(StudioApp(session: session));

    // Select the nested object from the Stitch view's Stitch Objects
    // panel (Layers closed) — selection is shared across modes.
    await tester.tap(find.byKey(const Key('mode-domain')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Running Stitch').first);
    await tester.pump();

    // Back in design, opening Layers reveals the selection: ancestors
    // auto-expanded.
    await tester.tap(find.byKey(const Key('mode-design')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dock-tab-layers')));
    await tester.pump();
    expect(find.text('Group 1'), findsOneWidget);
    expect(find.text('<Path>'), findsNWidgets(2));
  });

  testWidgets('search filters the tree, expands matches, and clears',
      (tester) async {
    final session = richSession();
    session.history.execute(GroupSelection(
      GroupNode(id: const Id('g1'), name: 'Petals'),
      const [
        DocumentNodeRef(DocumentNodeKind.object, Id('a')),
        DocumentNodeRef(DocumentNodeKind.object, Id('b')),
      ],
    ));
    await pumpLayers(tester, session: session);
    // Collapsed by default: nested rows hidden.
    expect(find.text('Petals'), findsNothing);

    // Case-insensitive partial match on the group name: its layer stays,
    // the group shows (auto-expanded path), Layer 2 filters out.
    await tester.enterText(find.byKey(const Key('layers-search')), 'peta');
    await tester.pump();
    expect(find.text('Petals'), findsOneWidget);
    expect(find.text('Layer 1'), findsOneWidget);
    expect(find.text('Layer 2'), findsNothing);
    // Matched container reveals its subtree (design-origin labels).
    expect(find.text('<Path>'), findsNWidgets(2));

    // Object-label match filters down to the matching branch.
    await tester.enterText(find.byKey(const Key('layers-search')), 'path');
    await tester.pump();
    expect(find.text('<Path>'), findsNWidgets(2));
    expect(find.text('Layer 2'), findsNothing);

    // Clear restores the normal (collapsed) tree.
    await tester.tap(find.byKey(const Key('layers-search-clear')));
    await tester.pump();
    expect(find.text('Layer 2'), findsOneWidget);
    expect(find.text('Petals'), findsNothing);
  });

  testWidgets('bottom toolbar expands/collapses all and selects parent',
      (tester) async {
    final session = richSession();
    session.history.execute(GroupSelection(
      GroupNode(id: const Id('g1'), name: 'Group 1'),
      const [
        DocumentNodeRef(DocumentNodeKind.object, Id('a')),
        DocumentNodeRef(DocumentNodeKind.object, Id('b')),
      ],
    ));
    await pumpLayers(tester, session: session);

    await tester.tap(find.byTooltip('Expand all'));
    await tester.pump();
    expect(find.text('Group 1'), findsOneWidget);
    expect(find.text('<Path>'), findsNWidgets(2));

    // Select a nested object, then walk up the hierarchy.
    await tester.tap(find.text('<Path>').first);
    await tester.pump();
    await tester.tap(find.byTooltip('Select parent'));
    await tester.pump();
    // Parent group is now the primary selection → Ungroup enabled.
    await tester.tap(find.byTooltip('Select parent'));
    await tester.pump();
    // Now the layer is selected; its parent is null → button disabled.

    await tester.tap(find.byTooltip('Collapse all'));
    await tester.pump();
    expect(find.text('Group 1'), findsNothing);
  });

  testWidgets('objects rename via the selected-label click (ADR-036)',
      (tester) async {
    final session = await pumpLayers(tester, session: richSession());
    await tester.tap(find.byTooltip('Expand all'));
    await tester.pump();

    // Select the object, then click its label to edit.
    await tester.tap(find.text('<Path>').first);
    await tester.pump();
    await tester.tap(find.text('<Path>').first);
    await tester.pump();
    expect(renameField(), findsOneWidget);
    await tester.enterText(renameField(), 'Outline');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(find.text('Outline'), findsOneWidget);
    expect(session.document.objectById(const Id('a'))!.name, 'Outline');
    // Undoable: rename went through ReplaceObject.
    session.history.undo();
    await tester.pump();
    expect(session.document.objectById(const Id('a'))!.name, isNull);
  });

  testWidgets('stitch entries reorder by drag (execution order)',
      (tester) async {
    final session = richSession();
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: session));
    // Stitch Objects panel lives in the Stitch view (default active tab).
    await tester.tap(find.byKey(const Key('mode-domain')));
    await tester.pumpAndSettle();
    expect(find.text('Running Stitch'), findsNWidgets(2));
    List<Id> order() => [
          for (final o in session.document.flattenVisibleObjects()) o.id,
        ];
    expect(order(), [const Id('a'), const Id('b')]);

    // Drag row 2 above row 1 (drop on the target's top half).
    final rows = find.text('Running Stitch');
    final gesture = await tester.startGesture(tester.getCenter(rows.last));
    await gesture.moveBy(const Offset(0, -5));
    await tester.pump();
    final target = tester.getRect(rows.first);
    await gesture.moveTo(Offset(target.center.dx, target.top - 3));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    expect(order(), [const Id('b'), const Id('a')]);
  });

  testWidgets('tool shortcuts are inert while a text field has focus',
      (tester) async {
    await pumpLayers(tester);
    expect(find.textContaining('Select:'), findsOneWidget); // status bar

    // Open the rename editor, then hit single-key tool shortcuts.
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    expect(renameField(), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP); // pen
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS); // show stitches
    await tester.pump();
    // Still the Select tool, rename still in progress.
    expect(find.textContaining('Select:'), findsOneWidget);
    expect(renameField(), findsOneWidget);

    // Same for the search field.
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.tap(find.byKey(const Key('layers-search')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(find.textContaining('Select:'), findsOneWidget);

    // Outside any field the shortcut works again: clicking the selected
    // label re-opens rename, Esc leaves it (focus returns to the panel).
    await tester.tap(layerLabel('Layer 1'));
    await tester.pump();
    expect(renameField(), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(find.textContaining('Pen:'), findsOneWidget);
  });

  testWidgets('context menu locks a node', (tester) async {
    final session = await pumpLayers(tester);
    final layerRect = tester.getRect(find.text('Layer 1'));
    await tester.tapAt(layerRect.center, buttons: kSecondaryMouseButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lock'));
    await tester.pumpAndSettle();
    expect(session.document.layers.single.locked, isTrue);
  });

  testWidgets('drop in the middle of a layer row nests an object into it',
      (tester) async {
    final session = await pumpLayers(tester, session: richSession());
    // Expand Layer 1 so its object rows are visible.
    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pump();
    expect(find.text('<Path>'), findsNWidgets(2));

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('<Path>').first));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Layer 2')));
    await tester.pump();
    await gesture.up();
    await tester.pump();
    final layer2 = session.document.layerById(const Id('l2'))!;
    expect(layer2.children, hasLength(1));
    expect(layer2.children.single.kind, DocumentNodeKind.object);
  });
}
