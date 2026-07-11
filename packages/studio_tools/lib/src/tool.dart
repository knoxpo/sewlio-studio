import 'package:flutter/foundation.dart';
import 'package:studio_geometry/studio_geometry.dart';

/// Semantic cursor a tool wants shown. The canvas maps these to
/// platform [SystemMouseCursors]; tools stay headless-testable.
enum ToolCursor {
  basic,
  crosshair,
  text,
  move,
  grab,
  grabbing,
  zoomIn,
  zoomOut,
  resizeNWSE,
  resizeNESW,
  resizeNS,
  resizeEW,
  rotate,

  /// Pen family: the canvas hides the system cursor and paints a pen
  /// glyph with a state badge (Affinity-style) at the pointer.
  pen, // start a new path
  penAdd, // next click adds a point
  penMinus, // click removes the hovered anchor
  penClose, // click closes the path on its first point
}

/// A canvas tool: receives gestures in world mm, mutates only via
/// commands, and exposes live preview geometry for the canvas overlay.
/// Notifies listeners when its preview/status changes.
abstract class Tool extends ChangeNotifier {
  /// Normalized stylus pressure (0–1) for the current drag sample, set
  /// by the shell before [dragStart]/[dragUpdate]; 1.0 for devices
  /// without pressure. A field rather than a parameter so the ~10
  /// tools that ignore pressure keep their signatures.
  double pointerPressure = 1.0;

  /// Single tap/click.
  void tap(Point world) {}

  /// Double tap/click (pen finishes its path here).
  void doubleTap(Point world) {}

  /// Pointer moved without dragging (rubber-band previews).
  void hover(Point world) {}

  /// The pointer left the canvas: drop hover-derived preview state
  /// (rubber bands; painted cursors follow the shell's cleared hover).
  void hoverExit() {}

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

  /// Cursor for the pointer at [world] — context-sensitive per tool
  /// (handles, nodes, drag state). Drawing tools default to crosshair.
  ToolCursor cursorAt(Point world) => ToolCursor.crosshair;
}
