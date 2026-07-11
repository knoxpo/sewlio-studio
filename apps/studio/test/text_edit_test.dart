import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

void main() {
  testWidgets('text tool click on committed text re-enters editing',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    // Commit "hi" at the canvas center.
    await tester.tap(find.byKey(const Key('tool-Text')));
    await tester.pump();
    final center = tester.getCenter(find.byType(CanvasView));
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(session.document.objects, hasLength(1));

    // Click the committed text with the text tool (a beat later, so it
    // does not register as a double-click): editing resumes with the
    // existing buffer instead of opening a new insertion point.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(center + const Offset(10, -4));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('type on canvas'), findsOneWidget);

    // Caret sits at the end; arrows + delete edit at the caret:
    // hi → h|i (left) → hx|i (type x) → |hxi (home) → xi (delete).
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // Same single object, edited in place (one ReplaceObject).
    expect(session.document.objects, hasLength(1));
    final object = session.document.objects.values.single as TextObject;
    expect(object.text, 'xi');
  });
}
