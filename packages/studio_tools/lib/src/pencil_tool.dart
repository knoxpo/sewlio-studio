import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Freehand drawing: drag, release, and the sampled trace is
/// RDP-simplified into a path. Stylus pressure is sampled per point
/// (from [Tool.pointerPressure]) and handed to [onCreate] so the shell
/// can turn it into a width profile (ADR-038).
final class PencilTool extends Tool {
  PencilTool({required this.onCreate, this.toleranceMm = 0.5});

  /// [pressures] parallels the path nodes (start + segment ends),
  /// normalized 0–1; null when no pressure varied (mouse, touch).
  final void Function(Path path, {List<double>? pressures}) onCreate;

  /// Simplification tolerance — larger = smoother, fewer nodes.
  /// Adjustable from the tool options bar.
  double toleranceMm;

  final List<Point> _trace = [];
  final List<double> _pressures = [];

  @override
  bool dragStart(Point world) {
    _trace
      ..clear()
      ..add(world);
    _pressures
      ..clear()
      ..add(pointerPressure);
    return true;
  }

  @override
  void dragUpdate(Point world) {
    if (world.distanceTo(_trace.last) < 0.2) return; // ignore jitter
    _trace.add(world);
    _pressures.add(pointerPressure);
    notifyListeners();
  }

  @override
  void dragEnd() {
    final kept = simplifyPolylineIndices(_trace, tolerance: toleranceMm);
    final simplified = [for (final i in kept) _trace[i]];
    final pressures = [for (final i in kept) _pressures[i]];
    cancel();
    if (simplified.length < 2) return;
    final varied = pressures.any((p) => p != pressures.first);
    onCreate(
      Path(
        start: simplified.first,
        segments: [for (final p in simplified.skip(1)) LineSegment(p)],
      ),
      pressures: varied ? pressures : null,
    );
  }

  @override
  void cancel() {
    _trace.clear();
    _pressures.clear();
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

  /// Live pressure samples paralleling the preview trace, for
  /// variable-width preview rendering; null while uniform.
  List<double>? get previewPressures {
    if (_trace.length < 2) return null;
    return _pressures.any((p) => p != _pressures.first) ? _pressures : null;
  }

  @override
  String? get status => 'Pencil: drag to draw freehand';
}
