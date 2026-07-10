import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: SizedBox(width: 200, child: child))),
    );

void main() {
  Future<void> submit(WidgetTester tester, String text) async {
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), text);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
  }

  testWidgets('Enter parses, clamps, and canonicalizes', (tester) async {
    // Stateful host mirrors the real pattern: commit updates the
    // external value, which the field re-syncs to on blur.
    var value = 10.0;
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => StudioNumberField(
        value: value,
        onSubmitted: (v) => setState(() => value = v),
      ),
    )));

    await submit(tester, '5.678');
    expect(value, closeTo(5.678, 1e-9));
    await tester.pump();
    expect(find.text('5.68'), findsOneWidget);
  });

  testWidgets('clamps to min and max', (tester) async {
    double? committed;
    await tester.pumpWidget(_host(StudioNumberField(
      value: 10,
      min: 5,
      max: 20,
      onSubmitted: (v) => committed = v,
    )));

    await submit(tester, '100');
    expect(committed, 20);

    await submit(tester, '1');
    expect(committed, 5);
  });

  testWidgets('integer mode rounds', (tester) async {
    var value = 3.0;
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => StudioNumberField(
        value: value,
        integer: true,
        onSubmitted: (v) => setState(() => value = v),
      ),
    )));

    await submit(tester, '4.7');
    expect(value, 5);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('external value change updates text when unfocused',
      (tester) async {
    await tester.pumpWidget(_host(StudioNumberField(
      value: 1,
      onSubmitted: (_) {},
    )));
    expect(find.text('1.00'), findsOneWidget);

    await tester.pumpWidget(_host(StudioNumberField(
      value: 2.5,
      onSubmitted: (_) {},
    )));
    await tester.pump();
    expect(find.text('2.50'), findsOneWidget);
  });

  testWidgets('external value change never clobbers typing', (tester) async {
    await tester.pumpWidget(_host(StudioNumberField(
      value: 1,
      onSubmitted: (_) {},
    )));
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), '9.9');

    await tester.pumpWidget(_host(StudioNumberField(
      value: 3,
      onSubmitted: (_) {},
    )));
    await tester.pump();
    expect(find.text('9.9'), findsOneWidget);
  });

  testWidgets('Escape reverts and unfocuses', (tester) async {
    double? committed;
    await tester.pumpWidget(_host(StudioNumberField(
      value: 7,
      onSubmitted: (v) => committed = v,
    )));
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), '42');

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(committed, isNull);
    expect(find.text('7.00'), findsOneWidget);
  });

  testWidgets('steppers nudge and clamp', (tester) async {
    final commits = <double>[];
    await tester.pumpWidget(_host(StudioNumberField(
      value: 3,
      min: 3,
      integer: true,
      steppers: true,
      onSubmitted: commits.add,
    )));

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(commits, [3]); // clamped at min

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(commits, [3, 4]);
  });

  testWidgets('null onSubmitted disables the field', (tester) async {
    await tester.pumpWidget(_host(const StudioNumberField(
      value: 1,
      onSubmitted: null,
    )));
    await tester.tap(find.byType(StudioTextField), warnIfMissed: false);
    await tester.pump();
    expect(
        tester.widget<EditableText>(find.byType(EditableText)).readOnly, true);
  });
}
