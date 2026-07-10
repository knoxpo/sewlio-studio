import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';

void main() {
  const path = Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]);

  test('setStroke restyles the selection undoably and updates defaults', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.addPath(path);
    final id = session.document.objects.keys.single;
    vm.selectRef(DocumentNodeRef(DocumentNodeKind.object, id));

    vm.setStroke((p) => p.copyWith(widthMm: 2.5, cap: 'square'));

    final object = session.document.objectById(id)!;
    expect(object.stroke.widthMm, 2.5);
    expect(object.stroke.cap, 'square');
    // Defaults follow, so the next drawn object matches.
    expect(vm.strokeDefaults.widthMm, 2.5);
    // Undoable (ReplaceObject).
    vm.undo();
    expect(session.document.objectById(id)!.stroke.widthMm, isNot(2.5));
  });

  test('new objects are stamped with the current stroke defaults', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.setStroke((p) => p.copyWith(widthMm: 1.8, join: 'bevel'));
    vm.addPath(path);
    final object = session.document.objects.values.single;
    expect(object.stroke.widthMm, 1.8);
    expect(object.stroke.join, 'bevel');
  });
}
