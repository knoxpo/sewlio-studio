import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio/src/tool_options.dart';

void main() {
  final barButton = find.descendant(
      of: find.byType(ToolOptionsBar), matching: find.text('Edit Hoop…'));

  Future<StudioSession> pumpWithHoopTool(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));
    await tester.tap(find.byIcon(TablerIcons.frame));
    await tester.pumpAndSettle();
    return session;
  }

  testWidgets('Hoop tool: canvas click opens Document Setup', (tester) async {
    await pumpWithHoopTool(tester);
    await tester.tap(find.byType(CanvasView));
    await tester.pumpAndSettle();
    expect(find.text('Document Setup'), findsOneWidget);
  });

  testWidgets('Hoop tool options bar edits the hoop inline, undoable',
      (tester) async {
    final session = await pumpWithHoopTool(tester);

    // Options bar came from the contribution: size fields + dialog button.
    expect(find.text('Width '), findsOneWidget);
    expect(barButton, findsOneWidget);

    // Width is the first field in the bar.
    await tester.enterText(
        find
            .descendant(
                of: find.byType(ToolOptionsBar),
                matching: find.byType(EditableText))
            .first,
        '130');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(session.document.hoop.widthMm, 130);
    expect(session.history.canUndo, isTrue);
    session.history.undo();
    expect(session.document.hoop.widthMm, 100);
  });

  testWidgets('Hoop tool options bar opens Document Setup', (tester) async {
    await pumpWithHoopTool(tester);
    await tester.tap(barButton);
    await tester.pumpAndSettle();
    expect(find.text('Document Setup'), findsOneWidget);
  });
}
