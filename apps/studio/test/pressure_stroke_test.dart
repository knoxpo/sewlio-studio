import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

/// Full loop (ADR-038): stylus drag with the pencil tool → committed
/// RunningStitchObject carries a width profile → undo removes it.
void main() {
  testWidgets('stylus pencil stroke commits a width profile; undo works',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byKey(const Key('tool-Pencil')));
    await tester.pump();

    // TestGesture reports constant pressure — dispatch raw stylus
    // events with a varying pressure profile instead.
    final c = tester.getCenter(find.byType(CanvasView));
    PointerEvent stylusEvent(
      PointerEvent Function({
        int pointer,
        PointerDeviceKind kind,
        Offset position,
        double pressure,
        double pressureMin,
        double pressureMax,
      }) make,
      Offset position,
      double pressure,
    ) =>
        make(
          pointer: 42,
          kind: PointerDeviceKind.stylus,
          position: position,
          pressure: pressure,
          pressureMin: 0,
          pressureMax: 1,
        );

    tester.binding
        .handlePointerEvent(stylusEvent(PointerDownEvent.new, c, 0.2));
    var last = c;
    for (var i = 1; i <= 6; i++) {
      last = c + Offset(i * 20.0, 0);
      tester.binding.handlePointerEvent(
          stylusEvent(PointerMoveEvent.new, last, 0.2 + i * 0.1));
      await tester.pump();
    }
    tester.binding.handlePointerEvent(stylusEvent(PointerUpEvent.new, last, 0));
    await tester.pump();

    final object =
        session.document.objects.values.single as RunningStitchObject;
    expect(object.widthProfile, isNotNull);
    expect(object.widthProfile!.length, object.path.segments.length + 1);
    // Light start, heavier end.
    expect(object.widthProfile!.first, lessThan(object.widthProfile!.last));

    session.history.undo();
    expect(session.document.objects, isEmpty);
  });
}
