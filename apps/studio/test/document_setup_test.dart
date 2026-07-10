import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_design_system/studio_design_system.dart';

void main() {
  testWidgets('Document Setup edits hoop size/shape/fabric, undoable',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Document Setup…'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(StudioTextField, 'Width (mm)'), '130');
    await tester.enterText(
        find.widgetWithText(StudioTextField, 'Height (mm)'), '180');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    final hoop = session.document.hoop;
    expect(hoop.widthMm, 130);
    expect(hoop.heightMm, 180);

    // Undoable — one command for the whole dialog.
    expect(session.history.canUndo, isTrue);
    session.history.undo();
    expect(session.document.hoop.widthMm, 100);
  });

  testWidgets('Document Setup floats: undimmed and draggable by title bar',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Document Setup…'));
    await tester.pumpAndSettle();

    final title = find.text('Document Setup');
    final before = tester.getTopLeft(title);
    await tester.drag(title, const Offset(120, 60));
    await tester.pumpAndSettle();
    final after = tester.getTopLeft(title);
    expect(after.dx - before.dx, closeTo(120, 1));
    expect(after.dy - before.dy, closeTo(60, 1));
  });
}
