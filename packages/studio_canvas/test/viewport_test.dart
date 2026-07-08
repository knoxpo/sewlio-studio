import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

void main() {
  test('world/screen round trip', () {
    final viewport = ViewportController(zoom: 4, pan: const Offset(100, 50));
    const world = g.Point(10, -5);
    final screen = viewport.worldToScreen(world);
    expect(screen, const Offset(140, 30));
    expect(viewport.screenToWorld(screen).almostEquals(world), isTrue);
  });

  test('panBy shifts and notifies', () {
    final viewport = ViewportController();
    var notified = 0;
    viewport.addListener(() => notified++);
    viewport.panBy(const Offset(10, 20));
    expect(viewport.pan, const Offset(10, 20));
    expect(notified, 1);
  });

  test('fitBounds centers and fits with padding', () {
    final viewport = ViewportController()
      ..viewSize = const Size(880, 480); // 800×400 after 40 px padding
    const hoop = g.Bounds(-50, -50, 50, 50); // 100 mm square
    viewport.fitBounds(hoop);

    expect(viewport.zoom, closeTo(4, 1e-9)); // 400 px / 100 mm
    // Hoop center lands on the view center.
    final center = viewport.worldToScreen(g.Point.zero);
    expect(center, const Offset(440, 240));
    expect(viewport.percent, closeTo(100, 1e-9));

    // No view size yet → no-op.
    final fresh = ViewportController();
    final before = (fresh.zoom, fresh.pan);
    fresh.fitBounds(hoop);
    expect((fresh.zoom, fresh.pan), before);
  });

  test('setPercent zooms about the view center', () {
    final viewport = ViewportController()
      ..viewSize = const Size(800, 600)
      ..pan = const Offset(400, 300); // origin centered
    viewport.setPercent(200);
    expect(viewport.percent, closeTo(200, 1e-9));
    expect(
        viewport
            .screenToWorld(const Offset(400, 300))
            .almostEquals(g.Point.zero),
        isTrue);
  });

  test('zoomAt keeps the focal world point fixed and clamps', () {
    final viewport = ViewportController(zoom: 4);
    const focal = Offset(200, 100);
    final before = viewport.screenToWorld(focal);
    viewport.zoomAt(focal, 2);
    expect(viewport.zoom, 8);
    expect(viewport.screenToWorld(focal).almostEquals(before), isTrue);

    viewport.zoomAt(focal, 1000);
    expect(viewport.zoom, ViewportController.maxZoom);
    viewport.zoomAt(focal, 1e-9);
    expect(viewport.zoom, ViewportController.minZoom);
  });
}
