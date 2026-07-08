import 'package:flutter/widgets.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

/// Maps world space (mm, y down) to screen space (logical px).
/// Pure view state — not part of the document, so mutating it directly
/// is fine and not a command.
final class ViewportController extends ChangeNotifier {
  ViewportController({this.zoom = 4, this.pan = Offset.zero});

  /// Logical pixels per millimeter.
  double zoom;

  /// Screen position of the world origin.
  Offset pan;

  /// Current canvas size in logical pixels, recorded by [CanvasView]
  /// on every layout. Needed for fit/center operations.
  Size? viewSize;

  static const double minZoom = 0.5;
  static const double maxZoom = 100;

  /// Zoom at which the percentage readout shows 100%.
  static const double baseZoom = 4;

  double get percent => zoom / baseZoom * 100;

  Offset worldToScreen(g.Point p) =>
      Offset(p.x * zoom + pan.dx, p.y * zoom + pan.dy);

  g.Point screenToWorld(Offset o) =>
      g.Point((o.dx - pan.dx) / zoom, (o.dy - pan.dy) / zoom);

  void panBy(Offset delta) {
    pan += delta;
    notifyListeners();
  }

  /// Zooms by [factor], keeping the world point under [focal] fixed.
  void zoomAt(Offset focal, double factor) {
    final next = (zoom * factor).clamp(minZoom, maxZoom);
    final world = screenToWorld(focal);
    zoom = next;
    pan = focal - Offset(world.x * zoom, world.y * zoom);
    notifyListeners();
  }

  /// Sets the zoom to [percent] (of [baseZoom]), keeping the view
  /// center fixed.
  void setPercent(double percent) {
    final size = viewSize;
    final focal =
        size == null ? Offset.zero : Offset(size.width / 2, size.height / 2);
    zoomAt(focal, (percent / 100 * baseZoom) / zoom);
  }

  /// Fits [bounds] (mm) into the current view, centered, with
  /// [paddingPx] breathing room. No-op before the first layout.
  void fitBounds(g.Bounds bounds, {double paddingPx = 40}) {
    final size = viewSize;
    if (size == null || size.isEmpty) return;
    final availableW = size.width - 2 * paddingPx;
    final availableH = size.height - 2 * paddingPx;
    if (availableW <= 0 || availableH <= 0) return;
    final fit = bounds.width <= 0 || bounds.height <= 0
        ? baseZoom
        : [availableW / bounds.width, availableH / bounds.height]
            .reduce((a, b) => a < b ? a : b);
    zoom = fit.clamp(minZoom, maxZoom);
    final center = bounds.center;
    pan = Offset(
        size.width / 2 - center.x * zoom, size.height / 2 - center.y * zoom);
    notifyListeners();
  }
}
