import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/app_view_model.dart';
import 'package:studio/src/recents.dart';
import 'package:studio/src/workspace/project_type.dart';
import 'package:studio/src/workspace/project_type_registry.dart';
import 'package:studio/src/workspace_view_model.dart';

void main() {
  test('design mode shares the app dock; other modes get their own', () {
    final app = AppViewModel(recents: RecentsStore.memory());
    expect(app.dockFor(WorkspaceMode.design, ProjectType.embroidery),
        same(app.dock));
    final domain = app.dockFor(WorkspaceMode.domain, ProjectType.embroidery);
    final sim = app.dockFor(WorkspaceMode.simulation, ProjectType.embroidery);
    expect(domain, isNot(same(app.dock)));
    expect(sim, isNot(same(domain)));
    // Lazy controllers are cached, not rebuilt per call.
    expect(app.dockFor(WorkspaceMode.domain, ProjectType.embroidery),
        same(domain));
  });

  test('design dock defaults to three stacked tab rows', () {
    final app = AppViewModel(recents: RecentsStore.memory());
    expect(
      [for (final g in app.dock.layout.groups) g.panelIds],
      [
        [
          'properties',
          'color',
          'fill',
          'stroke',
          'character',
          'align-arrange',
          'paragraph'
        ],
        ['layers', 'assets-reference', 'path-operations'],
        ['hoop', 'transform', 'stitch-simulation'],
      ],
    );
    // First tab of each row is active.
    expect([for (final g in app.dock.layout.groups) g.activeId],
        ['properties', 'layers', 'hoop']);
  });

  test('domain dock panels resolve from the active module (ARCH-038)', () {
    final app = AppViewModel(recents: RecentsStore.memory());
    final domain = app.dockFor(WorkspaceMode.domain, ProjectType.embroidery);
    expect(domain.panelIds,
        [for (final p in moduleFor(ProjectType.embroidery).domainPanels) p.id]);
  });
}
