import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';

void main() {
  Future<void> pumpEditor(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));
  }

  testWidgets('toolbox renders grouped slots incl. hoop, zoom, chips',
      (tester) async {
    await pumpEditor(tester);
    expect(find.byKey(const Key('tool-Move')), findsOneWidget);
    expect(find.byKey(const Key('tool-Hoop')), findsOneWidget);
    expect(
        find.byKey(const Key('tool-Pen')), findsOneWidget); // draw group slot
    expect(
        find.byKey(const Key('tool-View (Pan)')), findsOneWidget); // nav slot
    expect(find.byKey(const Key('fill-chip')), findsOneWidget);
    expect(find.byKey(const Key('stroke-chip')), findsOneWidget);
    expect(find.byKey(const Key('swap-fill-stroke')), findsOneWidget);
  });

  testWidgets('shortcut cycles tools within a group (P: pen → pencil)',
      (tester) async {
    await pumpEditor(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(find.textContaining('Pen:'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(find.textContaining('Pencil:'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump();
    expect(find.textContaining('Pen:'), findsOneWidget);
  });

  testWidgets('Z activates zoom tool; D activates hoop tool', (tester) async {
    await pumpEditor(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.pump();
    expect(find.textContaining('Zoom: click'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pump();
    expect(find.textContaining('Hoop: click'), findsOneWidget);
  });

  testWidgets('X swaps fill and stroke; reset restores defaults',
      (tester) async {
    final session = StudioSession();
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: session));

    await tester.tap(find.byKey(const Key('swap-fill-stroke')));
    await tester.pump();
    // Fill chip now shows the old stroke color (dark).
    final fill = tester.widget<Container>(find
        .descendant(
            of: find.byKey(const Key('fill-chip')),
            matching: find.byType(Container))
        .first);
    expect((fill.decoration! as BoxDecoration).color, const Color(0xFF1C1C1E));

    await tester.tap(find.byKey(const Key('reset-fill-stroke')));
    await tester.pump();
    final reset = tester.widget<Container>(find
        .descendant(
            of: find.byKey(const Key('fill-chip')),
            matching: find.byType(Container))
        .first);
    expect((reset.decoration! as BoxDecoration).color, const Color(0xFFFFFFFF));
  });

  testWidgets('transparent fill shows the none look', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    // Open the picker on the fill chip, pick the transparent swatch,
    // and confirm — this dispatches a transparent fill.
    await tester.tap(find.byKey(const Key('fill-chip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('color-picker-transparent')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('color-picker-select')));
    await tester.pumpAndSettle();

    // The fill circle no longer paints a real colour; it falls back to
    // the field fill (not a black/transparent colour).
    final fill = tester.widget<Container>(find
        .descendant(
            of: find.byKey(const Key('fill-chip')),
            matching: find.byType(Container))
        .first);
    expect((fill.decoration! as BoxDecoration).color,
        isNot(const Color(0xFF000000)));
    expect(
      find.descendant(
          of: find.byKey(const Key('fill-chip')),
          matching: find.byType(CustomPaint)),
      findsWidgets,
    );
  });
}
