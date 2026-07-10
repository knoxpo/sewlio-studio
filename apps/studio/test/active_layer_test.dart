import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';

void main() {
  const path = Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]);

  test('new objects land on the selected layer, not the default (ADR-028)', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    session.history
        .execute(AddLayer(LayerNode(id: const Id('L2'), name: 'Layer 2')));

    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.layer, Id('L2')));
    vm.addPath(path);

    expect(session.document.layerById(const Id('L2'))!.children, hasLength(1));
    expect(session.document.defaultLayer.children, isEmpty);
  });

  test('active layer follows the selected object’s ancestor layer', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    session.history
        .execute(AddLayer(LayerNode(id: const Id('L2'), name: 'Layer 2')));

    // Draw on layer 2, then keep drawing with the new object selected:
    // creations must stay on layer 2.
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.layer, Id('L2')));
    vm.addPath(path);
    final docLayer2 = session.document.layerById(const Id('L2'))!;
    final objectId = docLayer2.children.single.id;
    vm.selectRef(DocumentNodeRef(DocumentNodeKind.object, objectId));

    vm.addPath(path.transformed(Transform2.translation(20, 0)));
    expect(session.document.layerById(const Id('L2'))!.children, hasLength(2));
    expect(session.document.defaultLayer.children, isEmpty);
  });

  test('no selection falls back to the default layer', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.addPath(path);
    expect(session.document.defaultLayer.children, hasLength(1));
  });
}
