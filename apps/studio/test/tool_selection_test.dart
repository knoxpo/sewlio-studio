import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';

void main() {
  testWidgets(
      'pen commit selects the new object and shows anchors, not the '
      'transform box; the box appears when switching to Select',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    CanvasView canvas() => tester.widget<CanvasView>(find.byType(CanvasView));

    await tester.tap(find.byKey(const Key('tool-Pen')));
    await tester.pump();
    final center = tester.getCenter(find.byType(CanvasView));
    await tester.tapAt(center);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(center + const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(center + const Offset(80, 60));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(center + const Offset(80, 60));
    await tester.pump(const Duration(milliseconds: 400));
    expect(session.document.objects, hasLength(1));

    // Committed object is selected; pen shows its anchor points, no
    // transform bounding box.
    expect(canvas().markers, isNotEmpty);
    expect(canvas().selectionBounds, isNull);
    expect(canvas().selectedIds, isEmpty);

    // Select tool: transform box appears for the same selection.
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.pump();
    expect(canvas().selectionBounds, isNotNull);
    expect(canvas().selectedIds, hasLength(1));
    expect(canvas().markers, isEmpty);

    // Delete removes the selected element.
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();
    expect(session.document.objects, isEmpty);
    expect(canvas().selectionBounds, isNull);
  });
}
