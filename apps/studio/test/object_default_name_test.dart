import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  const path = Path(start: Point(0, 0), segments: [LineSegment(Point(10, 10))]);

  test('shape tool stamps its kind as the object name (ADR-036)', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.activeKind = ToolKind.shape;
    (vm.tool as ShapeTool).kind = ShapeKind.roundedRectangle;
    vm.addPath(path);
    expect(
        vm.session.document.objects.values.single.name, '<Rounded Rectangle>');
  });

  test('pen tool leaves the name null (derived <Path> label)', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.activeKind = ToolKind.pen;
    vm.addPath(path);
    expect(vm.session.document.objects.values.single.name, isNull);
  });
}
