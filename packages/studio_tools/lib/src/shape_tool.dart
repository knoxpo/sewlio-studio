import 'dart:math' as math;

import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

enum ShapeKind {
  rectangle,
  square,
  roundedRectangle,
  circle,
  ellipse,
  triangle,
  pentagon,
  hexagon,
  polygon, // uses [ShapeTool.sides]
  star,
  spiral,
}

/// Drag out a shape; the committed path goes through [onCreate]
/// (which dispatches AddObject).
final class ShapeTool extends Tool {
  ShapeTool({required this.onCreate});

  final void Function(Path path) onCreate;

  ShapeKind kind = ShapeKind.rectangle;

  /// Sides for [ShapeKind.polygon] (heptagon, octagon, …).
  int sides = 7;

  /// Tips for [ShapeKind.star].
  int starPoints = 5;
  double starInnerRatio = 0.5;
  double cornerRadiusMm = 3;
  double spiralTurns = 3;

  Point? _anchor;
  Path? _preview;

  Path _build(Point a, Point b) {
    switch (kind) {
      case ShapeKind.rectangle:
        return rectPath(a, b);
      case ShapeKind.square:
        final side = math.max((b.x - a.x).abs(), (b.y - a.y).abs());
        return rectPath(
            a,
            Point(a.x + side * (b.x < a.x ? -1 : 1),
                a.y + side * (b.y < a.y ? -1 : 1)));
      case ShapeKind.roundedRectangle:
        return roundedRectPath(a, b, radius: cornerRadiusMm);
      case ShapeKind.circle:
        return ellipsePath(a, a.distanceTo(b), a.distanceTo(b));
      case ShapeKind.ellipse:
        return ellipsePath(
            a.lerp(b, 0.5), (b.x - a.x).abs() / 2, (b.y - a.y).abs() / 2);
      case ShapeKind.triangle:
        return regularPolygonPath(a, a.distanceTo(b), 3);
      case ShapeKind.pentagon:
        return regularPolygonPath(a, a.distanceTo(b), 5);
      case ShapeKind.hexagon:
        return regularPolygonPath(a, a.distanceTo(b), 6);
      case ShapeKind.polygon:
        return regularPolygonPath(a, a.distanceTo(b), sides);
      case ShapeKind.star:
        return starPath(a, a.distanceTo(b), starPoints,
            innerRatio: starInnerRatio);
      case ShapeKind.spiral:
        return spiralPath(a, a.distanceTo(b), turns: spiralTurns);
    }
  }

  @override
  bool dragStart(Point world) {
    _anchor = world;
    _preview = null;
    return true;
  }

  @override
  void dragUpdate(Point world) {
    final anchor = _anchor;
    if (anchor == null) return;
    if (anchor.distanceTo(world) <= epsilon) return;
    _preview = _build(anchor, world);
    notifyListeners();
  }

  @override
  void dragEnd() {
    final path = _preview;
    cancel();
    if (path != null) onCreate(path);
  }

  @override
  void cancel() {
    _anchor = null;
    _preview = null;
    notifyListeners();
  }

  @override
  List<Path> get preview => [if (_preview != null) _preview!];

  @override
  String? get status => 'Shape: ${kind.name} — drag on canvas';
}
