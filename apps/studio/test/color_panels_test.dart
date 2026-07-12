import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/panels/color_panel.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_design_system/studio_design_system.dart';
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

Future<void> _pump(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(360, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
      MaterialApp(theme: studioTheme(), home: Scaffold(body: child)));
  await tester.pump();
}

void main() {
  WorkspaceViewModel buildVm() {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.addPath(_square());
    vm.selectRef(DocumentNodeRef(
        DocumentNodeKind.object, vm.session.document.objects.keys.first));
    return vm;
  }

  testWidgets('Fill panel embeds the inline colour editor', (tester) async {
    await _pump(tester, FillPanelContent(model: buildVm()));
    expect(find.byType(StudioColorEditor), findsOneWidget);
  });

  testWidgets('Stroke panel: inline editor + icon cap/join toggles',
      (tester) async {
    final vm = buildVm();
    await _pump(tester, StrokePanelContent(model: vm));
    expect(find.byType(StudioColorEditor), findsOneWidget);
    // Cap + Join are icon toggle groups (two groups).
    expect(find.byType(StudioToggleGroup<String>), findsNWidgets(2));

    // Tapping the 'square' cap icon updates the stroke.
    await tester.tap(find.byIcon(Icons.crop_square));
    await tester.pump();
    final id = vm.session.document.objects.keys.first;
    expect(vm.session.document.objectById(id)!.stroke.cap, 'square');
  });
}
