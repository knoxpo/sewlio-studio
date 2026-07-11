import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/dock/dock_host.dart';
import 'package:studio/src/form_factor.dart';
import 'package:studio/src/toolbox.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size,
      {TargetPlatform platform = TargetPlatform.macOS}) async {
    // Widget tests default to TargetPlatform.android, which counts as
    // a touch platform — pin the platform per test instead.
    debugDefaultTargetPlatformOverride = platform;
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));
  }

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('breakpoints match platform-requirements §14', () {
    expect(formFactorFor(1280), FormFactor.desktop);
    expect(formFactorFor(1200), FormFactor.desktop);
    expect(formFactorFor(1100), FormFactor.tabletLandscape);
    expect(formFactorFor(900), FormFactor.tabletLandscape);
    expect(formFactorFor(820), FormFactor.tabletPortrait);
  });

  testWidgets('desktop width: docked rail and dock, no toggle', (tester) async {
    await pumpAt(tester, const Size(1600, 1000));
    expect(find.byType(ToolboxRail), findsOneWidget);
    expect(find.byType(DockHost), findsOneWidget);
    expect(find.byKey(const Key('toggle-dock')), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('tablet landscape: dock collapses behind the toggle',
      (tester) async {
    await pumpAt(tester, const Size(1000, 760));
    expect(find.byType(DockHost), findsOneWidget);
    await tester.tap(find.byKey(const Key('toggle-dock')));
    await tester.pump();
    expect(find.byType(DockHost), findsNothing);
    await tester.tap(find.byKey(const Key('toggle-dock')));
    await tester.pump();
    expect(find.byType(DockHost), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('tablet portrait: floating toolbox over a full-bleed canvas',
      (tester) async {
    await pumpAt(tester, const Size(800, 1100));
    final rail = tester.widget<ToolboxRail>(find.byType(ToolboxRail));
    expect(rail.floating, isTrue);
    expect(find.byKey(const Key('toggle-dock')), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('touch mode gives tool buttons ≥48dp targets', (tester) async {
    await pumpAt(tester, const Size(1000, 760), platform: TargetPlatform.iOS);
    final size = tester.getSize(find.byKey(const Key('tool-Pencil')));
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('desktop keeps compact tool buttons', (tester) async {
    await pumpAt(tester, const Size(1600, 1000));
    final size = tester.getSize(find.byKey(const Key('tool-Pencil')));
    expect(size.width, lessThan(48));
    debugDefaultTargetPlatformOverride = null;
  });
}
