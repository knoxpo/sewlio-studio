import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Zoom tool: click zooms in about the point; with the modifier held
/// (the canvas passes it as [outModifier]) it zooms out.
final class ZoomTool extends Tool {
  ZoomTool({required this.onZoom});

  /// [magnify] > 1 zooms in; the view model applies it about [world].
  final void Function(Point world, double magnify) onZoom;

  /// Set by the view model from the current keyboard modifiers.
  bool outModifier = false;

  @override
  void tap(Point world) => onZoom(world, outModifier ? 0.8 : 1.25);

  @override
  String? get status => 'Zoom: click to zoom in, ⌥-click to zoom out';
}
