import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  testWidgets('Escape finishes the in-progress pen path as an open path',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byKey(const Key('tool-Pen')));
    await tester.pump();
    final canvas = tester.getCenter(find.byType(CanvasView));
    // Three anchors, path left open.
    await tester.tapAt(canvas);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(canvas + const Offset(60, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(canvas + const Offset(60, 60));
    await tester.pump(const Duration(milliseconds: 400));
    expect(session.document.objects, isEmpty); // still drawing

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();

    // Escape KEPT the drawn path (open), instead of discarding it.
    final object = session.document.objects.values.single;
    expect(object.path.closed, isFalse);
    expect(object.path.segments, hasLength(2));

    // A single stray anchor is discarded by Escape.
    await tester.tapAt(canvas + const Offset(-100, 0));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(session.document.objects, hasLength(1));
  });

  test('pointer exit clears the painted-cursor position and pen rubber band',
      () {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.activeKind = ToolKind.pen;
    final pen = vm.tool as PenTool;
    pen.tap(const Point(0, 0));
    vm.hover(const Point(10, 10));
    expect(vm.cursor.value, isNotNull);
    expect(pen.preview.single.segments, hasLength(1)); // rubber band

    vm.pointerExited();
    expect(vm.cursor.value, isNull); // painted pen glyph disappears
    expect(pen.preview.single.segments, isEmpty); // rubber band dropped
  });
}
