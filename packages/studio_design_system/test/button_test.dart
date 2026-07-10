import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('tap fires onPressed', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(_host(StudioButton(
      label: 'Save',
      onPressed: () => pressed++,
    )));
    await tester.tap(find.text('Save'));
    expect(pressed, 1);
  });

  testWidgets('disabled button ignores taps and focus', (tester) async {
    await tester.pumpWidget(_host(const StudioButton(label: 'Save')));
    await tester.tap(find.text('Save'));
    final focus = Focus.of(tester.element(find.text('Save')));
    expect(focus.canRequestFocus, isFalse);
  });

  testWidgets('Enter activates when focused', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(_host(StudioButton(
      label: 'Apply',
      onPressed: () => pressed++,
    )));
    Focus.of(tester.element(find.text('Apply'))).requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pressed, 1);
  });

  testWidgets('icon renders before label', (tester) async {
    await tester.pumpWidget(_host(StudioButton(
      label: 'Play',
      icon: Icons.play_arrow,
      onPressed: () {},
    )));
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('variants paint distinct fills', (tester) async {
    Color fillOf(String label) {
      final container = tester.widget<Container>(find
          .ancestor(
            of: find.text(label),
            matching: find.byType(Container),
          )
          .first);
      return (container.decoration! as BoxDecoration).color!;
    }

    await tester.pumpWidget(_host(Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StudioButton(
            label: 'P', variant: StudioButtonVariant.primary, onPressed: () {}),
        StudioButton(
            label: 'S',
            variant: StudioButtonVariant.secondary,
            onPressed: () {}),
        StudioButton(
            label: 'G', variant: StudioButtonVariant.ghost, onPressed: () {}),
        StudioButton(
            label: 'D', variant: StudioButtonVariant.danger, onPressed: () {}),
      ],
    )));

    expect(fillOf('P'), AppTokens.primary);
    expect(fillOf('S'), AppTokens.surfaceHigh);
    expect(fillOf('G'), Colors.transparent);
    expect(fillOf('D'), Colors.transparent);
  });

  testWidgets('expand stretches to parent width', (tester) async {
    await tester.pumpWidget(_host(SizedBox(
      width: 300,
      child: StudioButton(label: 'Wide', expand: true, onPressed: () {}),
    )));
    expect(tester.getSize(find.byType(StudioButton)).width, 300);
  });
}
