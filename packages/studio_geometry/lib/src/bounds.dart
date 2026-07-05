import 'point.dart';

/// An immutable axis-aligned bounding box in mm.
final class Bounds {
  const Bounds(this.minX, this.minY, this.maxX, this.maxY);

  final double minX, minY, maxX, maxY;

  factory Bounds.fromPoints(Iterable<Point> points) {
    final it = points.iterator;
    if (!it.moveNext()) {
      throw ArgumentError('Bounds.fromPoints needs at least one point');
    }
    var minX = it.current.x, minY = it.current.y;
    var maxX = minX, maxY = minY;
    while (it.moveNext()) {
      final p = it.current;
      if (p.x < minX) minX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.x > maxX) maxX = p.x;
      if (p.y > maxY) maxY = p.y;
    }
    return Bounds(minX, minY, maxX, maxY);
  }

  double get width => maxX - minX;
  double get height => maxY - minY;
  Point get center => Point((minX + maxX) / 2, (minY + maxY) / 2);

  Bounds union(Bounds o) => Bounds(
        minX < o.minX ? minX : o.minX,
        minY < o.minY ? minY : o.minY,
        maxX > o.maxX ? maxX : o.maxX,
        maxY > o.maxY ? maxY : o.maxY,
      );

  bool contains(Point p) =>
      p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY;

  @override
  bool operator ==(Object other) =>
      other is Bounds &&
      other.minX == minX &&
      other.minY == minY &&
      other.maxX == maxX &&
      other.maxY == maxY;

  @override
  int get hashCode => Object.hash(minX, minY, maxX, maxY);

  @override
  String toString() => 'Bounds($minX, $minY, $maxX, $maxY)';
}
