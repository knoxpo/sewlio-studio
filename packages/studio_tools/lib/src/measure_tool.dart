import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Drag to measure a distance; the length shows in the status bar.
/// Never touches the document.
final class MeasureTool extends Tool {
  Point? _from;
  Point? _to;

  @override
  bool dragStart(Point world) {
    _from = world;
    _to = world;
    notifyListeners();
    return true;
  }

  @override
  void dragUpdate(Point world) {
    _to = world;
    notifyListeners();
  }

  @override
  void dragEnd() {
    // Keep the measurement on screen until the next drag or cancel.
    notifyListeners();
  }

  @override
  void cancel() {
    _from = null;
    _to = null;
    notifyListeners();
  }

  @override
  List<Path> get preview {
    final (from, to) = (_from, _to);
    if (from == null || to == null) return const [];
    return [
      Path(start: from, segments: [LineSegment(to)])
    ];
  }

  @override
  String? get status {
    final (from, to) = (_from, _to);
    if (from == null || to == null) return 'Measure: drag on canvas';
    return 'Measure: ${from.distanceTo(to).toStringAsFixed(2)} mm '
        '(Δx ${(to.x - from.x).toStringAsFixed(2)}, '
        'Δy ${(to.y - from.y).toStringAsFixed(2)})';
  }
}
