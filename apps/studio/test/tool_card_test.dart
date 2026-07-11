import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';

void main() {
  testWidgets(
      'hovering a tool shows the learning card; Learn More opens '
      'full docs; leaving hides the card', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Hover the Pen button; the card appears after the show delay.
    await gesture.moveTo(tester.getCenter(find.byKey(const Key('tool-Pen'))));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('Pen Tool'), findsOneWidget);
    expect(find.text('Click to place the first point.'), findsOneWidget);
    expect(find.text('Learn More'), findsOneWidget);

    // Learn More opens the full documentation dialog.
    await tester.tap(find.text('Learn More'));
    await tester.pumpAndSettle();
    expect(find.text('Pen Tool  [P]'), findsOneWidget);
    expect(find.text('Quick start'), findsOneWidget);
    expect(find.text('Modifier keys'), findsOneWidget);
    await tester.tapAt(const Offset(10, 990)); // dismiss dialog barrier
    await tester.pumpAndSettle();

    // Hover again, then leave: the card disappears after the delay.
    await gesture.moveTo(tester.getCenter(find.byKey(const Key('tool-Pen'))));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.text('Pen Tool'), findsOneWidget);
    await gesture.moveTo(const Offset(800, 500));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Pen Tool'), findsNothing);
  });
}
