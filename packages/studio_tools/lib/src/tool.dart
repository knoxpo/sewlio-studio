import 'package:flutter/foundation.dart';
import 'package:studio_geometry/studio_geometry.dart';

/// A canvas tool: receives gestures in world mm, mutates only via
/// commands, and exposes live preview geometry for the canvas overlay.
/// Notifies listeners when its preview/status changes.
abstract class Tool extends ChangeNotifier {
  /// Single tap/click.
  void tap(Point world) {}

  /// Double tap/click (pen finishes its path here).
  void doubleTap(Point world) {}

  /// Pointer moved without dragging (rubber-band previews).
  void hover(Point world) {}

  /// Returns true to claim the drag; otherwise the canvas pans.
  bool dragStart(Point world) => false;

  void dragUpdate(Point world) {}

  void dragEnd() {}

  /// Abort any in-progress interaction (tool switch, Escape).
  void cancel() {}

  /// Live overlay geometry drawn by the canvas.
  List<Path> get preview => const [];

  /// Anchor markers drawn by the canvas (node editing).
  List<Point> get markers => const [];

  /// One-line hint for the status bar.
  String? get status => null;
}
