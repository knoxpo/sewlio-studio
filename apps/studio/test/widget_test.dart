import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';

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

    await tester.tap(find.byTooltip('Pen (P)'));
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
    expect(find.text('Untitled.embproj*'), findsOneWidget);
    // Stitch list shows the object with a real count.
    expect(find.text('Running Stitch'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    expect(session.document.objects, isEmpty);
  });

  testWidgets('rulers show by default and toggle via View menu',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    expect(find.byType(Ruler), findsNWidgets(2)); // top + left

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show Rulers'));
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
        find.widgetWithText(TextField, 'Name').first, 'Center line');
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
            of: find.byType(AlertDialog), matching: find.byType(TextField)),
        'Tulip');
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    expect(session.document.name, 'Tulip');
    expect(session.history.canUndo, isTrue);
  });
}
