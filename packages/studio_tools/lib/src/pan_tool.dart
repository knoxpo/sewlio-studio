import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Claims nothing — every drag pans the canvas, taps do nothing.
/// (The canvas shows the closed-hand cursor itself while panning.)
final class PanTool extends Tool {
  @override
  ToolCursor cursorAt(Point world) => ToolCursor.grab;
}
