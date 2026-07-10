import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: SizedBox(width: 200, child: child))),
    );

void main() {
  group('StudioSwitch', () {
    testWidgets('tap toggles', (tester) async {
      bool? toggled;
      await tester.pumpWidget(_host(StudioSwitch(
        value: false,
        onChanged: (v) => toggled = v,
      )));
      await tester.tap(find.byType(StudioSwitch));
      expect(toggled, isTrue);
    });

    testWidgets('label row is fully tappable', (tester) async {
      bool? toggled;
      await tester.pumpWidget(_host(StudioSwitch(
        value: true,
        label: 'Visible',
        onChanged: (v) => toggled = v,
      )));
      await tester.tap(find.text('Visible'));
      expect(toggled, isFalse);
    });

    testWidgets('Space toggles when focused', (tester) async {
      bool? toggled;
      await tester.pumpWidget(_host(StudioSwitch(
        value: false,
        onChanged: (v) => toggled = v,
      )));
      tester
          .state<State>(find.byType(StudioSwitch))
          .context
          .visitChildElements((_) {});
      final focus =
          Focus.of(tester.element(find.byType(GestureDetector).first));
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(toggled, isTrue);
    });

    testWidgets('disabled switch ignores taps', (tester) async {
      await tester.pumpWidget(_host(const StudioSwitch(value: false)));
      await tester.tap(find.byType(StudioSwitch));
      // No callback — nothing to assert beyond not crashing.
    });
  });

  group('StudioSlider', () {
    testWidgets('drag emits clamped in-range values', (tester) async {
      final values = <double>[];
      await tester.pumpWidget(_host(StudioSlider(
        value: 0.5,
        onChanged: values.add,
      )));
      await tester.drag(find.byType(StudioSlider), const Offset(60, 0));
      expect(values, isNotEmpty);
      for (final v in values) {
        expect(v, inInclusiveRange(0, 1));
      }
    });

    testWidgets('tap seeks to position', (tester) async {
      final values = <double>[];
      await tester.pumpWidget(_host(StudioSlider(
        value: 0,
        onChanged: values.add,
      )));
      final rect = tester.getRect(find.byType(StudioSlider));
      await tester.tapAt(rect.centerRight - const Offset(5, 0));
      expect(values.single, greaterThan(0.8));
    });

    testWidgets('custom range maps correctly', (tester) async {
      final values = <double>[];
      await tester.pumpWidget(_host(StudioSlider(
        value: 50,
        min: 0,
        max: 100,
        onChanged: values.add,
      )));
      final rect = tester.getRect(find.byType(StudioSlider));
      await tester.tapAt(rect.center);
      expect(values.single, closeTo(50, 5));
    });

    testWidgets('null onChanged ignores interaction', (tester) async {
      await tester.pumpWidget(_host(const StudioSlider(value: 0.5)));
      await tester.drag(find.byType(StudioSlider), const Offset(40, 0));
      // No callback — nothing to assert beyond not crashing.
    });
  });
}
