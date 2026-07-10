import 'dart:math' as math;

import 'package:studio_core/studio_core.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Pen drawing modes (Affinity-style mode strip in the options bar):
/// `pen` places straight segments (Bézier handle dragging later);
/// `smart` fits a smooth curve through the clicked points
/// (Catmull-Rom → cubics); `polygon` always commits a closed shape;
/// `line` commits after two points.
enum PenMode { pen, smart, polygon, line }

/// Click to place anchor points. Double-click commits an open path;
/// clicking back on the first point closes and commits. Holding
/// Shift/Ctrl constrains the next point to 45° increments from the
/// previous one (the view model feeds [constrainAngles] from the
/// keyboard).
final class PenTool extends Tool {
  PenTool(
      {required this.onCreate, this.onReplace, this.closeToleranceMm = 1.5});

  final void Function(Path path) onCreate;

  /// Continuation edits (pen activated with a path selected) commit
  /// here: replace the object's geometry, same id (single undo step).
  final void Function(Id id, Path path)? onReplace;

  final double closeToleranceMm;

  PenMode mode = PenMode.pen;

  /// Set while continuing a selected path: commit replaces it.
  Id? _editingId;

  /// Loads an existing open polyline for continuation: its anchors
  /// appear selected/editable and new clicks extend the path.
  void editExisting(Id id, List<Point> points) {
    if (points.length < 2) return;
    _points
      ..clear()
      ..addAll(points);
    _editingId = id;
    notifyListeners();
  }

  /// Set per-event from keyboard modifiers (Shift/Ctrl on all OSes).
  bool constrainAngles = false;

  final List<Point> _points = [];
  Point? _hover;

  /// Snaps [world] to the nearest 45° ray from the last point.
  Point _constrained(Point world) {
    if (!constrainAngles || _points.isEmpty) return world;
    final last = _points.last;
    final dx = world.x - last.x, dy = world.y - last.y;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length <= epsilon) return world;
    final step = math.pi / 4;
    final angle = (math.atan2(dy, dx) / step).round() * step;
    return Point(
        last.x + length * math.cos(angle), last.y + length * math.sin(angle));
  }

  @override
  void tap(Point world) {
    if (_points.length >= 2 &&
        world.distanceTo(_points.first) <= closeToleranceMm) {
      _commit(closed: true);
      return;
    }
    _points.add(_constrained(world));
    if (mode == PenMode.line && _points.length == 2) {
      _commit(closed: false);
      return;
    }
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
    _hover = _constrained(world);
    if (_points.isNotEmpty) notifyListeners();
  }

  void _commit({required bool closed}) {
    // Polygon mode always produces a closed shape.
    final close = closed || (mode == PenMode.polygon && _points.length >= 3);
    final path = Path(
      start: _points.first,
      segments: mode == PenMode.smart
          ? _smoothSegments(_points)
          : [for (final p in _points.skip(1)) LineSegment(p)],
      closed: close,
    );
    final editing = _editingId;
    cancel();
    editing == null || onReplace == null
        ? onCreate(path)
        : onReplace!(editing, path);
  }

  /// Catmull-Rom spline through the anchors, emitted as exact cubics —
  /// the Smart mode curve fit.
  static List<Segment> _smoothSegments(List<Point> pts) {
    if (pts.length < 3) {
      return [for (final p in pts.skip(1)) LineSegment(p)];
    }
    Point at(int i) => pts[i.clamp(0, pts.length - 1)];
    return [
      for (var i = 0; i < pts.length - 1; i++)
        CubicSegment(
          Point(
            at(i).x + (at(i + 1).x - at(i - 1).x) / 6,
            at(i).y + (at(i + 1).y - at(i - 1).y) / 6,
          ),
          Point(
            at(i + 1).x - (at(i + 2).x - at(i).x) / 6,
            at(i + 1).y - (at(i + 2).y - at(i).y) / 6,
          ),
          at(i + 1),
        ),
    ];
  }

  @override
  void cancel() {
    _points.clear();
    _hover = null;
    _editingId = null;
    notifyListeners();
  }

  @override
  List<Path> get preview {
    if (_points.isEmpty) return const [];
    final anchors = [..._points, if (_hover != null) _hover!];
    return [
      Path(
        start: anchors.first,
        segments: mode == PenMode.smart
            ? _smoothSegments(anchors)
            : [for (final p in anchors.skip(1)) LineSegment(p)],
      ),
    ];
  }

  @override
  List<Point> get markers => List.unmodifiable(_points);

  @override
  String? get status => _points.isEmpty
      ? switch (mode) {
          PenMode.line => 'Pen (line): click two points for one segment',
          PenMode.polygon =>
            'Pen (polygon): click corners — double-click closes the shape',
          PenMode.smart =>
            'Pen (smart): click points — a smooth curve is fitted through them',
          PenMode.pen => 'Pen: click to place points — hold Shift/Ctrl for 45°',
        }
      : _editingId != null
          ? 'Pen: editing selected path (${_points.length} points) — '
              'double-click to apply'
          : 'Pen: ${_points.length} point(s) — double-click to finish, '
              'click start to close';
}
