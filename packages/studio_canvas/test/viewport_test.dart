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
