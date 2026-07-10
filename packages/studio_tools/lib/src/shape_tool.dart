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
  diamond,
  trapezoid,
  pentagon,
  hexagon,
  polygon, // uses [ShapeTool.sides]
  star,
  squareStar,
  arrow,
  pie,
  segment,
  crescent,
  cog,
  heart,
  teardrop,
  cloud,
  spiral,
}
// ponytail: no donut — it needs a multi-contour shape object; add it
// when ShapeTool can emit composite geometry.

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
      case ShapeKind.diamond:
        return regularPolygonPath(a, a.distanceTo(b), 4);
      case ShapeKind.trapezoid:
        return _trapezoid(a, b);
      case ShapeKind.squareStar:
        return starPath(a, a.distanceTo(b), 4, innerRatio: 0.4);
      case ShapeKind.arrow:
        return _arrow(a, b);
      case ShapeKind.pie:
        return _pie(a, a.distanceTo(b), sweep: 3 * math.pi / 2);
      case ShapeKind.segment:
        return _segment(a, a.distanceTo(b));
      case ShapeKind.crescent:
        return _crescent(a, a.distanceTo(b));
      case ShapeKind.cog:
        return _cog(a, a.distanceTo(b));
      case ShapeKind.heart:
        return _heart(a, a.distanceTo(b));
      case ShapeKind.teardrop:
        return _teardrop(a, a.distanceTo(b));
      case ShapeKind.cloud:
        return _cloud(a, b);
    }
  }

  // ------------------------------------------------------ shape builders

  /// Rect from drag with the top edge inset 25% per side.
  static Path _trapezoid(Point a, Point b) {
    final inset = (b.x - a.x) * 0.25;
    return Path(
        start: Point(a.x, b.y),
        segments: [
          LineSegment(Point(b.x, b.y)),
          LineSegment(Point(b.x - inset, a.y)),
          LineSegment(Point(a.x + inset, a.y)),
        ],
        closed: true);
  }

  /// Right-pointing arrow filling the drag rect.
  static Path _arrow(Point a, Point b) {
    final midY = (a.y + b.y) / 2;
    final headX = a.x + (b.x - a.x) * 0.6;
    final shaft = (b.y - a.y) * 0.25;
    return Path(
        start: Point(a.x, midY - shaft),
        segments: [
          LineSegment(Point(headX, midY - shaft)),
          LineSegment(Point(headX, a.y)),
          LineSegment(Point(b.x, midY)),
          LineSegment(Point(headX, b.y)),
          LineSegment(Point(headX, midY + shaft)),
          LineSegment(Point(a.x, midY + shaft)),
        ],
        closed: true);
  }

  /// Cubic approximation of a circular arc around [c], split ≤90°/leg.
  static List<Segment> _arc(Point c, double r, double from, double sweep) {
    final segments = <Segment>[];
    final legs = (sweep.abs() / (math.pi / 2)).ceil().clamp(1, 8);
    final step = sweep / legs;
    var angle = from;
    for (var i = 0; i < legs; i++) {
      final k = 4 / 3 * math.tan(step / 4);
      Point at(double t) => Point(c.x + r * math.cos(t), c.y + r * math.sin(t));
      final p0 = at(angle);
      final p1 = at(angle + step);
      segments.add(CubicSegment(
        Point(p0.x - r * k * math.sin(angle), p0.y + r * k * math.cos(angle)),
        Point(p1.x + r * k * math.sin(angle + step),
            p1.y - r * k * math.cos(angle + step)),
        p1,
      ));
      angle += step;
    }
    return segments;
  }

  static Path _pie(Point c, double r, {required double sweep}) {
    final start = Point(c.x + r, c.y);
    return Path(
      start: c,
      segments: [LineSegment(start), ..._arc(c, r, 0, sweep)],
      closed: true,
    );
  }

  static Path _segment(Point c, double r) => Path(
        start: Point(c.x - r, c.y),
        segments: _arc(c, r, math.pi, math.pi),
        closed: true,
      );

  static Path _crescent(Point c, double r) => Path(
        start: Point(c.x, c.y - r),
        segments: [
          ..._arc(c, r, -math.pi / 2, math.pi),
          // Inner arc back up, bulging the same way (moon).
          ..._arc(Point(c.x - r * 0.6, c.y), r * 1.1, math.asin(r / (r * 1.1)),
              -2 * math.asin(r / (r * 1.1))),
        ],
        closed: true,
      );

  static Path _cog(Point c, double r, {int teeth = 8}) {
    final inner = r * 0.75;
    final points = <Point>[];
    final step = math.pi / teeth; // half tooth
    for (var i = 0; i < teeth * 2; i++) {
      final radius = i.isEven ? r : inner;
      final a0 = i * step + step * 0.15;
      final a1 = (i + 1) * step - step * 0.15;
      points
        ..add(Point(c.x + radius * math.cos(a0), c.y + radius * math.sin(a0)))
        ..add(Point(c.x + radius * math.cos(a1), c.y + radius * math.sin(a1)));
    }
    return Path(
      start: points.first,
      segments: [for (final p in points.skip(1)) LineSegment(p)],
      closed: true,
    );
  }

  static Path _heart(Point c, double r) {
    final top = Point(c.x, c.y - r * 0.35);
    final bottom = Point(c.x, c.y + r);
    return Path(
        start: top,
        segments: [
          CubicSegment(Point(c.x - r * 0.1, c.y - r * 0.9),
              Point(c.x - r, c.y - r * 0.9), Point(c.x - r, c.y - r * 0.25)),
          CubicSegment(Point(c.x - r, c.y + r * 0.35),
              Point(c.x - r * 0.35, c.y + r * 0.55), bottom),
          CubicSegment(Point(c.x + r * 0.35, c.y + r * 0.55),
              Point(c.x + r, c.y + r * 0.35), Point(c.x + r, c.y - r * 0.25)),
          CubicSegment(Point(c.x + r, c.y - r * 0.9),
              Point(c.x + r * 0.1, c.y - r * 0.9), top),
        ],
        closed: true);
  }

  static Path _teardrop(Point c, double r) {
    final tip = Point(c.x, c.y - r * 1.4);
    return Path(
        start: tip,
        segments: [
          CubicSegment(Point(c.x + r * 0.9, c.y - r * 0.5),
              Point(c.x + r, c.y + r * 0.45), Point(c.x, c.y + r * 0.8)),
          CubicSegment(Point(c.x - r, c.y + r * 0.45),
              Point(c.x - r * 0.9, c.y - r * 0.5), tip),
        ],
        closed: true);
  }

  /// Bumpy ellipse: arcs bulging outward around the drag rect.
  static Path _cloud(Point a, Point b) {
    const bumps = 7;
    final c = a.lerp(b, 0.5);
    final rx = (b.x - a.x).abs() / 2;
    final ry = (b.y - a.y).abs() / 2;
    if (rx <= 0 || ry <= 0) return Path(start: a);
    Point at(int i) {
      final t = 2 * math.pi * i / bumps;
      return Point(c.x + rx * math.cos(t), c.y + ry * math.sin(t));
    }

    final start = at(0);
    final segments = <Segment>[];
    for (var i = 0; i < bumps; i++) {
      final p0 = at(i);
      final p1 = at(i + 1);
      final mid = p0.lerp(p1, 0.5);
      final len = p0.distanceTo(p1);
      // Push the bump outward from the center.
      final d = mid - c;
      final dLen = d.length;
      final out = dLen <= epsilon
          ? Point.zero
          : Point(d.x / dLen * len * 0.45, d.y / dLen * len * 0.45);
      segments.add(CubicSegment(
        Point(p0.x + out.x, p0.y + out.y),
        Point(p1.x + out.x, p1.y + out.y),
        p1,
      ));
    }
    return Path(start: start, segments: segments, closed: true);
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
