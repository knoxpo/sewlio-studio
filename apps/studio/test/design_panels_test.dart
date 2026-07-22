import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/panels/preview_panels.dart';

void main() {
  testWidgets('hoop and stitch simulation live in the dock, not the bottom',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    // No bottom strip anymore; thread bar moved to the Stitch view.
    expect(find.byType(SimulationSection), findsNothing);
    expect(find.text('Colorway 1'), findsNothing);

    // Hoop panel: docked, opens Document Setup.
    await tester.ensureVisible(find.byKey(const Key('dock-tab-hoop')));
    await tester.tap(find.byKey(const Key('dock-tab-hoop')));
    await tester.pump();
    expect(find.text('Edit Hoop…'), findsOneWidget);
    await tester.tap(find.text('Edit Hoop…'));
    await tester.pumpAndSettle();
    expect(find.text('Document Setup'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Stitch Simulation panel: docked on demand.
    await tester
        .ensureVisible(find.byKey(const Key('dock-tab-stitch-simulation')));
    await tester.tap(find.byKey(const Key('dock-tab-stitch-simulation')));
    await tester.pump();
    expect(find.byType(SimulationSection), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
