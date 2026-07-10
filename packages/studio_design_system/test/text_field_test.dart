import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: SizedBox(width: 200, child: child))),
    );

void main() {
  testWidgets('typing fires onChanged, Enter fires onSubmitted',
      (tester) async {
    final changes = <String>[];
    String? submitted;
    await tester.pumpWidget(_host(StudioTextField(
      onChanged: changes.add,
      onSubmitted: (v) => submitted = v,
    )));

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'hello');
    expect(changes, contains('hello'));

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(submitted, 'hello');
  });

  testWidgets('prefix and suffix slots render inside the field',
      (tester) async {
    await tester.pumpWidget(_host(const StudioTextField(
      prefix: Icon(Icons.search, size: 12),
      suffix: Text('mm'),
    )));
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text('mm'), findsOneWidget);
  });

  testWidgets('hint shows when empty, hides when text entered', (tester) async {
    await tester.pumpWidget(_host(const StudioTextField(hint: 'Name')));
    expect(find.text('Name'), findsOneWidget);

    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'x');
    await tester.pump();
    expect(find.text('Name'), findsNothing);
  });

  testWidgets('label renders above the field', (tester) async {
    await tester.pumpWidget(_host(const StudioTextField(label: 'Width')));
    expect(find.text('Width'), findsOneWidget);
  });

  testWidgets('disabled field cannot gain focus', (tester) async {
    final node = FocusNode();
    await tester.pumpWidget(_host(StudioTextField(
      focusNode: node,
      enabled: false,
    )));
    await tester.tap(find.byType(StudioTextField), warnIfMissed: false);
    await tester.pump();
    expect(node.hasFocus, isFalse);
  });

  testWidgets('external controller round-trips', (tester) async {
    final controller = TextEditingController(text: 'seed');
    addTearDown(controller.dispose);
    await tester.pumpWidget(_host(StudioTextField(controller: controller)));
    expect(find.text('seed'), findsOneWidget);

    controller.text = 'updated';
    await tester.pump();
    expect(find.text('updated'), findsOneWidget);
  });
}
