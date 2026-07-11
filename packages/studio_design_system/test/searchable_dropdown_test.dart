import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: SizedBox(width: 200, child: child))),
    );

const _items = <(String, String)>[
  ('a', 'Apple'),
  ('b', 'Banana'),
  ('c', 'Cherry'),
  ('d', 'Blueberry'),
];

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byType(StudioSearchableDropdown<String>));
    await tester.pumpAndSettle();
  }

  testWidgets('typing filters the list', (tester) async {
    // value null so the trigger shows no label (a selected label would
    // otherwise also match find.text below).
    await tester.pumpWidget(_host(StudioSearchableDropdown<String>(
      value: null,
      items: _items,
      onChanged: (_) {},
    )));
    await open(tester);

    // All labels visible before typing.
    expect(find.text('Banana'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'berry');
    await tester.pump();

    // Substring match keeps Blueberry, drops Apple/Banana/Cherry.
    expect(find.text('Blueberry'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Banana'), findsNothing);
  });

  testWidgets('ArrowDown + Enter selects the highlighted item', (tester) async {
    String? picked;
    await tester.pumpWidget(_host(StudioSearchableDropdown<String>(
      value: 'a',
      items: _items,
      onChanged: (v) => picked = v,
    )));
    await open(tester);

    // Highlight starts on the current value (Apple, index 0).
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown); // -> Banana
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(picked, 'b');
  });

  testWidgets('Escape closes without changing the value', (tester) async {
    var changed = false;
    await tester.pumpWidget(_host(StudioSearchableDropdown<String>(
      value: 'a',
      items: _items,
      onChanged: (_) => changed = true,
    )));
    await open(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(changed, isFalse);
    // Popover closed: the search box is gone.
    expect(find.byType(EditableText), findsNothing);
  });
}
