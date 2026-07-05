import 'dart:math' as math;

/// Comparison tolerance for geometry math, in mm.
const double epsilon = 1e-9;

/// Decimal places kept when serializing coordinates (goldens, files).
const int coordPrecision = 6;

/// Rounds a coordinate to [coordPrecision] decimals for serialization.
/// 1e-6 mm is far below stitch resolution (0.1 mm machine units), so
/// this never affects output while keeping goldens byte-stable.
double roundCoord(double v) {
  final r = double.parse(v.toStringAsFixed(coordPrecision));
  return r == 0 ? 0 : r; // normalize -0.0
}

/// An immutable 2D point/vector in mm.
final class Point {
  const Point(this.x, this.y);

  final double x;
  final double y;

  static const zero = Point(0, 0);

  Point operator +(Point o) => Point(x + o.x, y + o.y);
  Point operator -(Point o) => Point(x - o.x, y - o.y);
  Point operator *(double s) => Point(x * s, y * s);

  double get length => math.sqrt(x * x + y * y);

  double distanceTo(Point o) => (o - this).length;

  /// Point at parameter [t] on the segment from this to [o].
  Point lerp(Point o, double t) =>
      Point(x + (o.x - x) * t, y + (o.y - y) * t);

  bool almostEquals(Point o, {double tolerance = epsilon}) =>
      (x - o.x).abs() <= tolerance && (y - o.y).abs() <= tolerance;

  List<double> toJson() => [roundCoord(x), roundCoord(y)];

  factory Point.fromJson(List<dynamic> json) =>
      Point((json[0] as num).toDouble(), (json[1] as num).toDouble());

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => 'Point($x, $y)';
}
