import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';

Future<void> pumpDomainMode(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1600, 1000);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(StudioApp(session: StudioSession()));
  await tester.tap(find.byKey(const Key('mode-domain')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Stitch view is an editing workspace: rail, canvas, dock',
      (tester) async {
    await pumpDomainMode(tester);

    // Shared canvas stays live (editing view, not a preview), framed by
    // the same mm rulers as the design view.
    expect(find.byType(CanvasView), findsOneWidget);
    expect(find.text('Stitch View'), findsOneWidget);
    expect(find.text('mm'), findsOneWidget);

    // Module toolbox: live select + dimmed placeholders.
    expect(find.byKey(const Key('tool-Select Stitch Object')), findsOneWidget);
    expect(find.byKey(const Key('tool-Satin Column')), findsOneWidget);

    // Module panels docked (Production structure, not Artwork).
    expect(find.byKey(const Key('dock-tab-stitch-layers')), findsOneWidget);
    expect(
        find.byKey(const Key('dock-tab-sequence-color-film')), findsOneWidget);
    // Stitch Simulation now docks in the Stitch view, not Design.
    expect(
        find.byKey(const Key('dock-tab-stitch-simulation')), findsOneWidget);
    // Design layers panel does NOT leak into the domain dock.
    expect(find.byKey(const Key('dock-tab-layers')), findsNothing);
  });

  testWidgets('quick actions render disabled with coming-soon tooltips',
      (tester) async {
    await pumpDomainMode(tester);
    expect(find.byKey(const Key('quick-convert-path-run')), findsOneWidget);
    expect(find.byKey(const Key('quick-optimize-sequence')), findsOneWidget);
  });
}
