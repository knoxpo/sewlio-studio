import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Click to place anchor points. Double-click commits an open path;
/// clicking back on the first point closes and commits.
final class PenTool extends Tool {
  PenTool({required this.onCreate, this.closeToleranceMm = 1.5});

  final void Function(Path path) onCreate;
  final double closeToleranceMm;

  final List<Point> _points = [];
  Point? _hover;

  @override
  void tap(Point world) {
    if (_points.length >= 2 &&
        world.distanceTo(_points.first) <= closeToleranceMm) {
      _commit(closed: true);
      return;
    }
    _points.add(world);
    notifyListeners();
  }

  @override
  void doubleTap(Point world) {
    // A double-tap suppresses the single tap, so this point isn't in
    // the list yet — place it, then finish.
    if (_points.isEmpty || _points.last.distanceTo(world) > closeToleranceMm) {
      _points.add(world);
    }
    if (_points.length >= 2) {
      _commit(closed: false);
    } else {
      cancel();
    }
  }

  @override
  void hover(Point world) {
    _hover = world;
    if (_points.isNotEmpty) notifyListeners();
  }

  void _commit({required bool closed}) {
    final path = Path(
      start: _points.first,
      segments: [for (final p in _points.skip(1)) LineSegment(p)],
      closed: closed,
    );
    cancel();
    onCreate(path);
  }

  @override
  void cancel() {
    _points.clear();
    _hover = null;
    notifyListeners();
  }

  @override
  List<Path> get preview {
    if (_points.isEmpty) return const [];
    return [
      Path(start: _points.first, segments: [
        for (final p in _points.skip(1)) LineSegment(p),
        if (_hover != null) LineSegment(_hover!),
      ]),
    ];
  }

  @override
  List<Point> get markers => List.unmodifiable(_points);

  @override
  String? get status => _points.isEmpty
      ? 'Pen: click to place points'
      : 'Pen: ${_points.length} point(s) — double-click to finish, '
          'click start to close';
}
