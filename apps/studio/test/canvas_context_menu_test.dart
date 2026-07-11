import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));
  }

  testWidgets('touch long-press opens the canvas context menu', (tester) async {
    await pumpApp(tester);
    final c = tester.getCenter(find.byType(CanvasView));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.touch);
    await gesture.down(c);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Zoom to Fit'), findsOneWidget);
  });

  testWidgets('stylus long-press does not open the menu (it draws)',
      (tester) async {
    await pumpApp(tester);
    final c = tester.getCenter(find.byType(CanvasView));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await gesture.down(c);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Zoom to Fit'), findsNothing);
  });
}
