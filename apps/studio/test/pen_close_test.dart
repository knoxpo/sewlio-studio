import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';

void main() {
  testWidgets(
      'rapid pen clicks survive; closing on the start point keeps the shape',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byTooltip('Pen (P)'));
    await tester.pump();
    final c = tester.getCenter(find.byType(CanvasView));
    // Realistic drawing pace (~150ms/click) — the old
    // DoubleTapGestureRecognizer used to swallow pairs of these.
    for (final offset in [
      Offset.zero,
      const Offset(60, 0),
      const Offset(60, 60),
      const Offset(0, 60),
    ]) {
      await tester.tapAt(c + offset);
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tapAt(c); // close on the start point
    await tester.pump(const Duration(milliseconds: 400));

    final object = session.document.objects.values.single;
    expect(object.path.closed, isTrue);
    expect(object.path.segments, hasLength(3)); // all corners kept
    expect(object.bounds().width, greaterThan(1));
  });
}
