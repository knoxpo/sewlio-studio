import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';

void main() {
  testWidgets('view toggles drive the canvas: stitches, outlines, holes',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    CanvasView canvas() => tester.widget<CanvasView>(find.byType(CanvasView));

    // Defaults: stitches + outlines on, needle holes off.
    expect(canvas().stitches, isNotNull);
    expect(canvas().showOutlines, isTrue);
    expect(canvas().showNeedleHoles, isFalse);

    // Toolbar buttons toggle (view state only — no document change).
    await tester.tap(find.byTooltip('Show stitches (S)'));
    await tester.pump();
    expect(canvas().stitches, isNull);

    await tester.tap(find.byTooltip('Show outlines (O)'));
    await tester.pump();
    expect(canvas().showOutlines, isFalse);

    // Keyboard shortcuts flip them too.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pump();
    expect(canvas().showNeedleHoles, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pump();
    expect(canvas().stitches, isNotNull);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyO);
    await tester.pump();
    expect(canvas().showOutlines, isTrue);

    // Modifier chords must NOT trigger view toggles (⌘S = save).
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pump();
    expect(canvas().stitches, isNotNull); // unchanged
  });
}
