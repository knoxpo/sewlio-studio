import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';

Path _square() => Path(
      start: const Point(0, 0),
      segments: const [
        LineSegment(Point(10, 0)),
        LineSegment(Point(10, 10)),
        LineSegment(Point(0, 10)),
      ],
      closed: true,
    );

void main() {
  test('new shapes are filled by default', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.addPath(_square());
    final obj = vm.session.document.objects.values.first;
    expect(obj.stroke.fillHex, isNotNull, reason: 'useFill defaults on');
  });

  test('picking a fill color enables fill on the selection', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.addPath(_square());
    final id = vm.session.document.objects.keys.first;
    vm.selectRef(DocumentNodeRef(DocumentNodeKind.object, id));
    vm.setFillColor('#ff0000');
    expect(vm.session.document.objectById(id)!.stroke.fillHex, '#ff0000');
  });
}
