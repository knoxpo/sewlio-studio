import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  const path = Path(
      start: Point(0, 0),
      segments: [LineSegment(Point(10, 0)), LineSegment(Point(20, 5))]);

  test('activating the pen with an open path selected loads it for editing',
      () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.addPath(path);
    final id = session.document.objects.keys.single;
    vm.selectRef(DocumentNodeRef(DocumentNodeKind.object, id));

    vm.selectTool(ToolKind.pen);
    final pen = vm.tool as PenTool;
    expect(pen.markers, hasLength(3)); // anchors loaded, editable

    pen.tap(const Point(30, 0));
    pen.doubleTap(const Point(30, 0));
    // Same object, extended geometry, one undo step.
    expect(session.document.objects.keys.single, id);
    expect(session.document.objectById(id)!.path.segments, hasLength(3));
    vm.undo();
    expect(session.document.objectById(id)!.path.segments, hasLength(2));
  });

  test('Use fill stamps and removes fill on the selection', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.addPath(path);
    final id = session.document.objects.keys.single;
    vm.selectRef(DocumentNodeRef(DocumentNodeKind.object, id));

    vm.setUseFill(true);
    expect(session.document.objectById(id)!.stroke.fillHex, vm.fillColorHex);
    vm.setUseFill(false);
    expect(session.document.objectById(id)!.stroke.fillHex, isNull);

    // New objects follow the toggle.
    vm.setUseFill(true);
    vm.selectRef(null);
    vm.addPath(path.transformed(Transform2.translation(40, 0)));
    final other = session.document.objects.values.firstWhere((o) => o.id != id);
    expect(other.stroke.fillHex, vm.fillColorHex);
  });
}
