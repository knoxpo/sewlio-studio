import 'dart:math' as math;

import 'point.dart';

/// An immutable 2D affine transform:
///
/// ```text
/// | a  c  tx |   | x |
/// | b  d  ty | · | y |
/// | 0  0  1  |   | 1 |
/// ```
final class Transform2 {
  const Transform2(this.a, this.b, this.c, this.d, this.tx, this.ty);

  final double a, b, c, d, tx, ty;

  static const identity = Transform2(1, 0, 0, 1, 0, 0);

  factory Transform2.translation(double dx, double dy) =>
      Transform2(1, 0, 0, 1, dx, dy);

  factory Transform2.scaling(double sx, [double? sy]) =>
      Transform2(sx, 0, 0, sy ?? sx, 0, 0);

  /// Rotation by [radians], counter-clockwise around the origin.
  factory Transform2.rotation(double radians) {
    final cos = math.cos(radians), sin = math.sin(radians);
    return Transform2(cos, sin, -sin, cos, 0, 0);
  }

  Point apply(Point p) =>
      Point(a * p.x + c * p.y + tx, b * p.x + d * p.y + ty);

  /// Composition: `(this * other)` applies [other] first, then this.
  Transform2 operator *(Transform2 o) => Transform2(
        a * o.a + c * o.b,
        b * o.a + d * o.b,
        a * o.c + c * o.d,
        b * o.c + d * o.d,
        a * o.tx + c * o.ty + tx,
        b * o.tx + d * o.ty + ty,
      );

  double get determinant => a * d - b * c;

  /// Inverse transform. Throws [StateError] if singular.
  Transform2 invert() {
    final det = determinant;
    if (det.abs() <= epsilon) {
      throw StateError('Transform is not invertible (det ≈ 0)');
    }
    final ia = d / det, ib = -b / det, ic = -c / det, id = a / det;
    return Transform2(
        ia, ib, ic, id, -(ia * tx + ic * ty), -(ib * tx + id * ty));
  }

  List<double> toJson() =>
      [for (final v in [a, b, c, d, tx, ty]) roundCoord(v)];

  factory Transform2.fromJson(List<dynamic> json) => Transform2(
        (json[0] as num).toDouble(),
        (json[1] as num).toDouble(),
        (json[2] as num).toDouble(),
        (json[3] as num).toDouble(),
        (json[4] as num).toDouble(),
        (json[5] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      other is Transform2 &&
      other.a == a &&
      other.b == b &&
      other.c == c &&
      other.d == d &&
      other.tx == tx &&
      other.ty == ty;

  @override
  int get hashCode => Object.hash(a, b, c, d, tx, ty);

  @override
  String toString() => 'Transform2($a, $b, $c, $d, $tx, $ty)';
}
