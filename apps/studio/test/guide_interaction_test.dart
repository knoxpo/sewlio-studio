import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

void main() {
  late StudioSession session;

  Future<ViewportController> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));
    await tester.pump(); // post-frame fitCanvas
    return tester.widget<CanvasView>(find.byType(CanvasView)).viewport;
  }

  Guide addGuide(GuideAxis axis, double mm) {
    final guide = Guide(id: Id('g-$axis-$mm'), axis: axis, positionMm: mm);
    session.history.execute(AddGuide(guide));
    return guide;
  }

  testWidgets('dragging a guide on the canvas moves it (undoable)',
      (tester) async {
    final viewport = await pumpApp(tester);
    final guide = addGuide(GuideAxis.vertical, 50);
    await tester.pump();

    final canvasOrigin = tester.getTopLeft(find.byType(CanvasView));
    final start = canvasOrigin +
        Offset(viewport.worldToScreen(const g.Point(50, 0)).dx, 300);
    await tester.dragFrom(start, const Offset(40, 0));
    await tester.pump();

    final moved = session.document.guideById(guide.id)!;
    expect(moved.positionMm, greaterThan(50));

    session.history.undo();
    expect(session.document.guideById(guide.id)!.positionMm, 50);
  });

  testWidgets('dragging a guide off the canvas removes it', (tester) async {
    final viewport = await pumpApp(tester);
    final guide = addGuide(GuideAxis.vertical, 50);
    await tester.pump();

    final canvasBox = tester.getRect(find.byType(CanvasView));
    final start = canvasBox.topLeft +
        Offset(viewport.worldToScreen(const g.Point(50, 0)).dx, 300);
    // Pull far left, past the canvas edge.
    await tester.dragFrom(start, Offset(-start.dx - 100, 0));
    await tester.pump();

    expect(session.document.guideById(guide.id), isNull);
    session.history.undo();
    expect(session.document.guideById(guide.id), isNotNull);
  });

  testWidgets('pulling from the top ruler creates a horizontal guide',
      (tester) async {
    await pumpApp(tester);
    expect(session.document.guides, isEmpty);

    // Top ruler strip sits directly above the canvas.
    final canvasTop = tester.getTopLeft(find.byType(CanvasView));
    final rulerPoint = Offset(canvasTop.dx + 300, canvasTop.dy - 10);
    await tester.timedDragFrom(
        rulerPoint, const Offset(0, 200), const Duration(milliseconds: 300));
    await tester.pump();

    expect(session.document.guides, hasLength(1));
    expect(session.document.guides.single.axis, GuideAxis.horizontal);
  });

  testWidgets('releasing back inside the ruler cancels the pull',
      (tester) async {
    await pumpApp(tester);
    final canvasTop = tester.getTopLeft(find.byType(CanvasView));
    final rulerPoint = Offset(canvasTop.dx + 300, canvasTop.dy - 10);
    // Wiggle inside the strip only — never crosses into the canvas.
    await tester.timedDragFrom(
        rulerPoint, const Offset(30, 0), const Duration(milliseconds: 200));
    await tester.pump();
    expect(session.document.guides, isEmpty);
  });

  testWidgets('pulling from the left ruler creates a vertical guide',
      (tester) async {
    await pumpApp(tester);
    final canvasLeft = tester.getTopLeft(find.byType(CanvasView));
    final rulerPoint = Offset(canvasLeft.dx - 10, canvasLeft.dy + 300);
    await tester.timedDragFrom(
        rulerPoint, const Offset(200, 0), const Duration(milliseconds: 300));
    await tester.pump();

    expect(session.document.guides, hasLength(1));
    expect(session.document.guides.single.axis, GuideAxis.vertical);
  });
}
