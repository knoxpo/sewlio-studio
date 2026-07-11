import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_design_system/studio_design_system.dart';

void main() {
  setUp(() => studioThemeMode.value = ThemeMode.system);

  testWidgets('mode switcher swaps Design / Stitch Preview / Simulation',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    expect(find.byType(CanvasView), findsOneWidget);

    await tester.tap(find.byKey(const Key('mode-stitchPreview')));
    await tester.pumpAndSettle();
    expect(find.byType(CanvasView), findsNothing);
    expect(find.textContaining('No stitches yet'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mode-simulation')));
    await tester.pumpAndSettle();
    expect(find.text('STITCH SIMULATION'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mode-design')));
    await tester.pumpAndSettle();
    expect(find.byType(CanvasView), findsOneWidget);
  });

  testWidgets('theme selector retints the app immediately', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    studioThemeMode.value = ThemeMode.light;
    await tester.pump();
    expect(AppTokens.isDark, isFalse);
    expect(Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.light);

    studioThemeMode.value = ThemeMode.dark;
    await tester.pump();
    expect(AppTokens.isDark, isTrue);
  });

  testWidgets('header has no Save button; saving stays in the File menu',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    expect(find.widgetWithText(StudioButton, 'Save'), findsNothing);
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
  });
}
