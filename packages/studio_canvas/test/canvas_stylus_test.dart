import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

void main() {
  late ViewportController viewport;
  late List<String> log;
  List<double?> pressures = [];

  Future<void> pumpCanvas(WidgetTester tester, {bool claimDrag = true}) async {
    viewport = ViewportController();
    log = [];
    pressures = [];
    await tester.pumpWidget(MaterialApp(
      home: CanvasView(
        document: Document(id: const Id('doc')),
        viewport: viewport,
        onTapWorld: (world, {required toggle, required extend}) =>
            log.add('tap'),
        onDragStartWorld: (world,
            {required toggle, required extend, double? pressure}) {
          log.add('start');
          pressures.add(pressure);
          return claimDrag;
        },
        onDragUpdateWorld: (world, {double? pressure}) {
          log.add('update');
          pressures.add(pressure);
        },
        onDragEndWorld: () => log.add('end'),
      ),
    ));
  }

  testWidgets('stylus drag goes to the tool with pressure', (tester) async {
    await pumpCanvas(tester);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await gesture.down(const Offset(100, 100));
    await gesture.moveTo(const Offset(140, 100));
    await gesture.moveTo(const Offset(160, 100));
    await gesture.up();
    await tester.pump();
    expect(log, ['start', 'update', 'update', 'end']);
    expect(pressures, everyElement(isNotNull));
    expect(viewport.pan, Offset.zero); // tool claimed it — no panning
  });

  testWidgets('stylus tap fires tap, not drag', (tester) async {
    await pumpCanvas(tester);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await gesture.down(const Offset(100, 100));
    await gesture.up();
    await tester.pump();
    expect(log, ['tap']);
  });

  testWidgets('unclaimed stylus drag pans the canvas', (tester) async {
    await pumpCanvas(tester, claimDrag: false);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await gesture.down(const Offset(100, 100));
    await gesture.moveTo(const Offset(150, 100));
    await gesture.up();
    await tester.pump();
    expect(log, ['start']);
    expect(viewport.pan.dx, greaterThan(0));
  });

  testWidgets('palm touches are rejected while the stylus draws',
      (tester) async {
    await pumpCanvas(tester);
    final stylus = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await stylus.down(const Offset(100, 100));
    await stylus.moveTo(const Offset(140, 100));

    // Palm lands and slides mid-stroke.
    final palm = await tester.createGesture(kind: PointerDeviceKind.touch);
    await palm.down(const Offset(300, 300));
    await palm.moveTo(const Offset(360, 340));

    await stylus.moveTo(const Offset(160, 100));
    await stylus.up();

    // Palm keeps moving after the stylus lifted — still rejected.
    await palm.moveTo(const Offset(400, 380));
    await palm.up();
    await tester.pump();

    expect(log, ['start', 'update', 'update', 'end']);
    expect(viewport.pan, Offset.zero);
  });

  testWidgets('touch pan still works when no stylus is down', (tester) async {
    await pumpCanvas(tester, claimDrag: false);
    final touch = await tester.createGesture(kind: PointerDeviceKind.touch);
    await touch.down(const Offset(100, 100));
    await touch.moveTo(const Offset(160, 100));
    await touch.moveTo(const Offset(200, 100));
    await touch.up();
    await tester.pump();
    expect(viewport.pan.dx, greaterThan(0));
  });

  testWidgets('stylus positions arrive in world coordinates', (tester) async {
    await pumpCanvas(tester);
    g.Point? startWorld;
    await tester.pumpWidget(MaterialApp(
      home: CanvasView(
        document: Document(id: const Id('doc')),
        viewport: viewport,
        onDragStartWorld: (world,
            {required toggle, required extend, double? pressure}) {
          startWorld = world;
          return true;
        },
      ),
    ));
    final gesture = await tester.createGesture(kind: PointerDeviceKind.stylus);
    await gesture.down(const Offset(100, 50));
    await gesture.moveTo(const Offset(200, 50));
    await gesture.up();
    expect(startWorld, isNotNull);
    expect(
        startWorld!.almostEquals(viewport.screenToWorld(
          const Offset(100, 50),
        )),
        isTrue);
  });
}
