import 'package:flutter/material.dart';
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
    expect(find.text('Stitch Simulation'), findsOneWidget);
    expect(find.text('Hoop'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('Rectangle tool creates an undoable object; title shows dirty',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byTooltip('Rectangle'));
    await tester.pump();
    expect(session.document.objects, hasLength(1));
    expect(find.text('Untitled.embproj*'), findsOneWidget);
    // Stitch list shows the object with a real count.
    expect(find.text('Running Stitch'), findsOneWidget);

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    expect(session.document.objects, isEmpty);
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
    await tester.enterText(find.byType(TextField), 'Tulip');
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    expect(session.document.name, 'Tulip');
    expect(session.history.canUndo, isTrue);
  });
}
