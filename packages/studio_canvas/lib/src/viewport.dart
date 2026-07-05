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

  static const double minZoom = 0.5;
  static const double maxZoom = 100;

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
}
