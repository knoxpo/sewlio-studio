import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace/project_type.dart';
import 'package:studio/src/workspace/project_type_registry.dart';
import 'package:studio/src/workspace_view_model.dart';

void main() {
  test('embroidery contributes domain and simulation overlay sets', () {
    final module = moduleFor(ProjectType.embroidery);
    expect(module.domainOverlays, hasLength(10));
    expect(module.simulationOverlays, hasLength(8));
  });

  test('activeOverlays respects defaults and toggles', () {
    final vm = WorkspaceViewModel(session: StudioSession());
    final domain = moduleFor(ProjectType.embroidery).domainOverlays;
    final heatmap = domain.singleWhere((o) => o.id == 'density-heatmap');

    // Heatmap defaults hidden; everything else visible.
    final active = vm.activeOverlays(WorkspaceMode.domain);
    expect(active.map((o) => o.id), isNot(contains('density-heatmap')));
    expect(active, hasLength(domain.length - 1));

    vm.toggleOverlay(WorkspaceMode.domain, heatmap);
    expect(vm.activeOverlays(WorkspaceMode.domain).map((o) => o.id),
        contains('density-heatmap'));

    vm.toggleOverlay(WorkspaceMode.domain, domain.first);
    expect(vm.activeOverlays(WorkspaceMode.domain).map((o) => o.id),
        isNot(contains(domain.first.id)));

    // Design mode contributes no overlays.
    expect(vm.activeOverlays(WorkspaceMode.design), isEmpty);
    vm.dispose();
  });
}
