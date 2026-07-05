import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Freehand drawing: drag, release, and the sampled trace is
/// RDP-simplified into a path.
final class PencilTool extends Tool {
  PencilTool({required this.onCreate, this.toleranceMm = 0.5});

  final void Function(Path path) onCreate;

  /// Simplification tolerance — larger = smoother, fewer nodes.
  final double toleranceMm;

  final List<Point> _trace = [];

  @override
  bool dragStart(Point world) {
    _trace
      ..clear()
      ..add(world);
    return true;
  }

  @override
  void dragUpdate(Point world) {
    if (world.distanceTo(_trace.last) < 0.2) return; // ignore jitter
    _trace.add(world);
    notifyListeners();
  }

  @override
  void dragEnd() {
    final simplified = simplifyPolyline(_trace, tolerance: toleranceMm);
    cancel();
    if (simplified.length < 2) return;
    onCreate(Path(
      start: simplified.first,
      segments: [for (final p in simplified.skip(1)) LineSegment(p)],
    ));
  }

  @override
  void cancel() {
    _trace.clear();
    notifyListeners();
  }

  @override
  List<Path> get preview {
    if (_trace.length < 2) return const [];
    return [
      Path(start: _trace.first, segments: [
        for (final p in _trace.skip(1)) LineSegment(p),
      ]),
    ];
  }

  @override
  String? get status => 'Pencil: drag to draw freehand';
}
