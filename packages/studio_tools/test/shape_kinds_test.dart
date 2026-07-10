import 'package:flutter_test/flutter_test.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  test('every shape kind drags out a non-degenerate path', () {
    for (final kind in ShapeKind.values) {
      final created = <Path>[];
      final tool = ShapeTool(onCreate: created.add)..kind = kind;
      tool.dragStart(const Point(10, 10));
      tool.dragUpdate(const Point(50, 35));
      tool.dragEnd();
      expect(created, hasLength(1), reason: kind.name);
      final path = created.single;
      expect(path.segments.length, greaterThanOrEqualTo(2), reason: kind.name);
      final b = path.bounds();
      expect(b.width > 0 || b.height > 0, isTrue, reason: kind.name);
    }
  });
}
