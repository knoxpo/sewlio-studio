import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';

void main() {
  test('drawing into a reopened project never collides with stored ids', () {
    const path =
        Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]);
    // Save a project containing obj-1..obj-3, then reopen it.
    final original = StudioSession();
    final vm1 = WorkspaceViewModel(session: original);
    for (var i = 0; i < 3; i++) {
      vm1.addPath(path.transformed(Transform2.translation(i * 20, 0)));
    }
    final saved = encodeProject(original.document);

    final reopened = StudioSession(document: decodeProject(saved));
    final vm2 = WorkspaceViewModel(session: reopened);
    // The fresh session's id generator restarts at obj-1 — this used
    // to throw 'Duplicate object id obj-1'.
    vm2.addPath(path.transformed(Transform2.translation(80, 0)));
    vm2.addPath(path.transformed(Transform2.translation(100, 0)));

    expect(reopened.document.objects, hasLength(5));
    expect(reopened.document.objects.keys.toSet(), hasLength(5));
  });
}
