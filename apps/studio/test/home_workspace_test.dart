import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/recents.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {RecentsStore? recents}) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(recents: recents));
    await tester.pump();
  }

  testWidgets('startup lands on Home: no document, no editor', (tester) async {
    await pumpApp(tester);

    expect(find.byKey(const Key('home-tab')), findsOneWidget);
    expect(find.byKey(const Key('home-new-project')), findsOneWidget);
    expect(find.text('No recent projects yet'), findsOneWidget);
    // Never show an empty editor: no document tab, no canvas.
    expect(find.byKey(const Key('doc-title')), findsNothing);
    expect(find.byType(CanvasView), findsNothing);
  });

  testWidgets(
      'New Project: 3 panes, validation, template, live preview, create',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const Key('home-new-project')));
    await tester.pump();

    // Three panes: templates | configuration | preview.
    expect(find.text('Templates'), findsOneWidget);
    expect(find.byKey(const Key('new-project-name')), findsOneWidget);
    expect(find.byType(CanvasView), findsOneWidget); // live preview

    // Empty name blocks creation.
    await tester.enterText(find.byKey(const Key('new-project-name')), '');
    await tester.pump();
    expect(find.byKey(const Key('new-project-error')), findsOneWidget);
    await tester.tap(find.byKey(const Key('new-project-create')));
    await tester.pump();
    expect(find.byKey(const Key('doc-title')), findsNothing); // still blocked

    // Template selection updates the hoop fields.
    await tester.tap(find.byKey(const Key('template-Cap Front')));
    await tester.pump();
    expect(find.text('130'), findsOneWidget); // width field
    expect(find.text('60'), findsOneWidget); // height field
    expect(find.textContaining('Preview — 130 × 60 mm'), findsOneWidget);

    // Valid name → create lands in the editor with the configured hoop.
    await tester.enterText(find.byKey(const Key('new-project-name')), 'Tulip');
    await tester.pump();
    expect(find.byKey(const Key('new-project-error')), findsNothing);
    await tester.tap(find.byKey(const Key('new-project-create')));
    await tester.pumpAndSettle();

    expect(find.text('Tulip.swl'), findsOneWidget);
    expect(find.byType(CanvasView), findsOneWidget); // the editor canvas
  });

  testWidgets('units selector converts hoop fields and lands on the document',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('home-new-project')));
    await tester.pumpAndSettle();

    // 100 mm → switch to centimeters → field reads 10, same hoop.
    await tester.tap(find.byKey(const Key('new-project-units')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Centimeters'));
    await tester.pumpAndSettle();
    expect(find.text('10'), findsNWidgets(2)); // width + height fields
    expect(find.text('Width (cm)'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('new-project-name')), 'Rose');
    await tester.pump();
    await tester.tap(find.byKey(const Key('new-project-create')));
    await tester.pumpAndSettle();

    final canvas = tester.widget<CanvasView>(find.byType(CanvasView));
    expect(canvas.document.units, ProjectUnits.cm);
    expect(canvas.document.hoop.widthMm, closeTo(100, 0.01));
  });

  testWidgets('recent card opens the project; missing file offers removal',
      (tester) async {
    final temp = Directory.systemTemp.createTempSync('home');
    addTearDown(() => temp.deleteSync(recursive: true));
    final projectPath = '${temp.path}/rose.swl';
    File(projectPath).writeAsStringSync(
        encodeProject(Document(id: const Id('rose'), name: 'Rose')));

    final recents = RecentsStore.memory()
      ..record(RecentProject(
        name: 'Rose',
        path: projectPath,
        hoopWidthMm: 100,
        hoopHeightMm: 100,
        lastOpened: DateTime(2026, 7, 10),
      ))
      ..record(RecentProject(
        name: 'Ghost',
        path: '${temp.path}/gone.swl',
        hoopWidthMm: 100,
        hoopHeightMm: 100,
        lastOpened: DateTime(2026, 7, 10),
      ));
    await pumpApp(tester, recents: recents);

    // Missing file → dialog, removal never touches disk.
    await tester.tap(find.text('Ghost'));
    await tester.pumpAndSettle();
    expect(find.text('Project Missing'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Ghost'), findsNothing);
    expect(recents.entries, hasLength(1));

    // Existing file opens into the editor. Real file IO needs the
    // real async zone, hence runAsync.
    await tester.runAsync(() async {
      await tester.tap(find.text('Rose'));
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
    expect(find.text('Rose.swl'), findsOneWidget);
    expect(find.byType(CanvasView), findsOneWidget);
  });
}
