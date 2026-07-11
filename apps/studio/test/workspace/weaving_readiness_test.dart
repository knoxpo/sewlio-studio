import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/app_shell.dart';
import 'package:studio/src/app_view_model.dart';
import 'package:studio/src/recents.dart';
import 'package:studio/src/workspace/project_type.dart';
import 'package:studio_document/studio_document.dart';

/// ARCH-038 acceptance: a second domain renders in the shared shell
/// purely from registry data — no shell code knows about weaving.
void main() {
  testWidgets('weaving project resolves Weaving domain view from registry',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    late AppViewModel app;
    await tester.pumpWidget(MaterialApp(
      home: AppShell(create: () {
        app = AppViewModel(recents: RecentsStore.memory());
        return app;
      }),
    ));
    await app.createProject(
      name: 'Blanket',
      hoop: const HoopSettings(),
      type: ProjectType.weaving,
    );
    await tester.pumpAndSettle();

    // Mode switcher shows the resolved domain label.
    expect(find.text('Weaving'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mode-domain')));
    await tester.pumpAndSettle();

    expect(find.text('Weaving View'), findsOneWidget);
    expect(find.byKey(const Key('tool-Pick Editor')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-warp-setup')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-weft-sequence')), findsOneWidget);
    // No embroidery contributions leak in.
    expect(find.byKey(const Key('dock-tab-stitch-objects')), findsNothing);
  });

  test('weaving is a planned module, kept out of New Project', () async {
    final app = AppViewModel(recents: RecentsStore.memory());
    final tab = await app.createProject(
        name: 'Default', hoop: const HoopSettings());
    expect(tab.vm.projectType, ProjectType.embroidery);
  });
}
