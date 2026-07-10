import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Align(alignment: Alignment.topLeft, child: child)),
    );

const _items = [(1, 'One'), (2, 'Two'), (3, 'Three')];

void main() {
  testWidgets('tap opens menu, tap item selects and closes', (tester) async {
    int? selected;
    await tester.pumpWidget(_host(StudioDropdown<int>(
      value: 1,
      items: _items,
      onChanged: (v) => selected = v,
      width: 120,
    )));
    expect(find.text('Two'), findsNothing);

    await tester.tap(find.byType(StudioDropdown<int>));
    await tester.pump();
    expect(find.text('Two'), findsOneWidget);

    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(selected, 2);
    expect(find.text('Two'), findsNothing);
  });

  testWidgets('tap outside closes without selection', (tester) async {
    int? selected;
    await tester.pumpWidget(_host(StudioDropdown<int>(
      value: 1,
      items: _items,
      onChanged: (v) => selected = v,
      width: 120,
    )));
    await tester.tap(find.byType(StudioDropdown<int>));
    await tester.pump();
    expect(find.text('Three'), findsOneWidget);

    await tester.tapAt(const Offset(400, 400));
    await tester.pump();
    expect(find.text('Three'), findsNothing);
    expect(selected, isNull);
  });

  testWidgets(
      'keyboard: Enter opens, ArrowDown+Enter selects next, Escape closes',
      (tester) async {
    int? selected;
    await tester.pumpWidget(_host(StudioDropdown<int>(
      value: 1,
      items: _items,
      onChanged: (v) => selected = v,
      width: 120,
    )));

    await tester.tap(find.byType(StudioDropdown<int>)); // focus + open
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(find.text('Two'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter); // reopen
    await tester.pump();
    expect(find.text('Two'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(selected, 2);
    expect(find.text('Three'), findsNothing);
  });

  testWidgets('menu hugs trigger width instead of filling the screen',
      (tester) async {
    await tester.pumpWidget(_host(StudioDropdown<int>(
      value: 1,
      items: _items,
      onChanged: (_) {},
      width: 120,
    )));
    await tester.tap(find.byType(StudioDropdown<int>));
    await tester.pump();

    // Menu row width tracks the trigger, not the overlay's full width.
    final row = tester.getSize(find.widgetWithText(GestureDetector, 'Two'));
    expect(row.width, closeTo(120, 10));
  });

  testWidgets('hint shown when value is null', (tester) async {
    await tester.pumpWidget(_host(StudioDropdown<int>(
      value: null,
      items: _items,
      onChanged: (_) {},
      hint: 'Pick one',
      width: 120,
    )));
    expect(find.text('Pick one'), findsOneWidget);
  });
}
