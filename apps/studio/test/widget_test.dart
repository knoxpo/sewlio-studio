import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_document/studio_document.dart';

void main() {
  testWidgets('shell renders menu, toolbar, panels, canvas placeholder',
      (tester) async {
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    expect(find.text('File'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Layers'), findsOneWidget);
    expect(find.text('Inspector'), findsOneWidget);
    expect(find.byType(CanvasView), findsOneWidget);
    expect(find.byKey(const Key('doc-title')), findsOneWidget);
  });

  testWidgets('Add square toolbar button creates an undoable object',
      (tester) async {
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byTooltip('Add square'));
    await tester.pump();
    expect(session.document.objects, hasLength(1));

    await tester.tap(find.byTooltip('Undo'));
    await tester.pump();
    expect(session.document.objects, isEmpty);
  });

  testWidgets('commands drive title; toolbar undo/redo follow history',
      (tester) async {
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    // Undo disabled at start.
    final undoButton = find.widgetWithIcon(IconButton, Icons.undo);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);

    // Mutate through the command path, as tools/menu do.
    session.history.execute(const RenameDocument('Rose'));
    await tester.pump();
    expect(find.text('Rose'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNotNull);

    // Undo via toolbar restores the old name.
    await tester.tap(undoButton);
    await tester.pump();
    expect(find.text('Untitled'), findsOneWidget);
    expect(tester.widget<IconButton>(undoButton).onPressed, isNull);
  });

  testWidgets('File > Rename dialog executes RenameDocument', (tester) async {
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
