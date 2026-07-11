import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/object_panel.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';

void main() {
  testWidgets('workspace renders chrome: menus, panels, canvas, status bar',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    expect(find.text('File'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Stitches'), findsWidgets); // tab + list header
    expect(find.text('Layers'), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
    expect(find.byType(CanvasView), findsOneWidget);
    expect(find.byKey(const Key('doc-title')), findsOneWidget);
    expect(find.text('STITCH SIMULATION'), findsOneWidget);
    expect(find.text('HOOP'), findsOneWidget);
    expect(find.textContaining('Select:'), findsOneWidget); // status bar
  });

  testWidgets('Pen tool draws an undoable path; title shows dirty',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byKey(const Key('tool-Pen')));
    await tester.pump();

    final canvas = tester.getCenter(find.byType(CanvasView));
    await tester.tapAt(canvas);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(canvas + const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 400));
    // Double tap finishes the path.
    await tester.tapAt(canvas + const Offset(80, 60));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(canvas + const Offset(80, 60));
    // Flush the double-tap recognizer's countdown timer.
    await tester.pump(const Duration(milliseconds: 400));

    expect(session.document.objects, hasLength(1));
    expect(find.text('Untitled.swl*'), findsOneWidget);
    // Stitch list shows the object with a real count.
    expect(find.text('Running Stitch'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'Undo'));
    await tester.pumpAndSettle();
    expect(session.document.objects, isEmpty);
  });

  testWidgets('properties tab hosts object properties panel', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byKey(const Key('tool-Pen')));
    await tester.pump();

    final canvas = tester.getCenter(find.byType(CanvasView));
    await tester.tapAt(canvas);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(canvas + const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(canvas + const Offset(80, 60));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(canvas + const Offset(80, 60));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Running Stitch'));
    await tester.pump();
    // The tab bar scrolls horizontally — the Properties tab may sit
    // past the dock edge under touch-sized chrome.
    await tester.ensureVisible(find.byKey(const Key('dock-tab-properties')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('dock-tab-properties')));
    await tester.pump();

    expect(find.text('Object Properties'), findsOneWidget);
    expect(find.text('Transform'), findsOneWidget);
    // Scoped: the header's domain-mode segment is also labeled 'Stitch'.
    expect(
        find.descendant(
            of: find.byType(ObjectPropertiesPanel),
            matching: find.text('Stitch')),
        findsOneWidget);
  });

  testWidgets('layers tab shows hierarchy and hidden groups drop from stitches',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    session.history.execute(const AddObject(RunningStitchObject(
      id: Id('a'),
      path: Path(start: Point(0, 0), segments: [LineSegment(Point(20, 0))]),
    )));
    session.history.execute(const AddObject(RunningStitchObject(
      id: Id('b'),
      path: Path(start: Point(30, 0), segments: [LineSegment(Point(50, 0))]),
    )));
    session.history.execute(GroupSelection(
      GroupNode(id: const Id('g1'), name: 'Group 1'),
      const [
        DocumentNodeRef(DocumentNodeKind.object, Id('a')),
        DocumentNodeRef(DocumentNodeKind.object, Id('b')),
      ],
    ));

    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.text('Layers'));
    await tester.pump();
    expect(find.text('Layer 1'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right).first);
    await tester.pump();
    expect(find.text('Group 1'), findsOneWidget);

    await tester.tap(find.text('Group 1'));
    await tester.pump();
    // Scrollable tab bar: bring overflowing tabs into view first.
    await tester.ensureVisible(find.byKey(const Key('dock-tab-properties')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('dock-tab-properties')));
    await tester.pump();
    expect(find.text('Group Properties'), findsOneWidget);

    await tester.tap(find.byType(StudioSwitch).first);
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('dock-tab-stitches')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('dock-tab-stitches')));
    await tester.pump();
    expect(find.text('Running Stitch'), findsNothing);
  });

  testWidgets('rulers show by default and toggle via View menu',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    expect(find.byType(Ruler), findsNWidgets(2)); // top + left

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rulers'));
    await tester.pumpAndSettle();
    expect(find.byType(Ruler), findsNothing);
  });

  testWidgets('tapping a ruler adds a named guide via dialog', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    // Tap the top ruler (vertical guide).
    final ruler = find.byType(Ruler).first;
    await tester.tapAt(tester.getCenter(ruler));
    await tester.pumpAndSettle();
    expect(find.text('Add Guide'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(StudioTextField, 'Name').first, 'Center line');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(session.document.guides, hasLength(1));
    expect(session.document.guides.single.name, 'Center line');
    expect(session.history.canUndo, isTrue);
  });

  testWidgets('single-key shortcuts switch tools, Esc cancels', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(find.textContaining('Pen:'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
    await tester.pump();
    expect(find.textContaining('Measure:'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.pump();
    expect(find.textContaining('Select:'), findsOneWidget);
  });

  testWidgets('Text tool types in place on the canvas; Enter commits',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byKey(const Key('tool-Text')));
    await tester.pump();
    // Rich typography toolbar appears for the Text tool.
    expect(find.text('Tracking '), findsOneWidget);
    expect(find.byTooltip('Align Center'), findsOneWidget);

    // Click canvas → insertion point, no dialog.
    await tester.tapAt(tester.getCenter(find.byType(CanvasView)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(Dialog), findsNothing);
    expect(find.textContaining('type on canvas'), findsOneWidget);

    // Type "HI" — tool-shortcut keys must go into the buffer, not
    // switch tools.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.pump();
    expect(session.document.objects, isEmpty); // still previewing

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    // ONE editable text object (ADR-028), not per-stroke paths.
    expect(session.document.objects, hasLength(1));
    final object = session.document.objects.values.single;
    expect(object, isA<TextObject>());
    expect((object as TextObject).text, 'hi'); // raw input retained
    expect(object.renderPaths, hasLength(6)); // cached outline strokes
    expect(find.textContaining('click for point text'), findsOneWidget);
  });

  testWidgets('File > Rename dialog executes RenameDocument', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename…'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.descendant(
            of: find.byType(Dialog), matching: find.byType(StudioTextField)),
        'Tulip');
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    expect(session.document.name, 'Tulip');
    expect(session.history.canUndo, isTrue);
  });
}
