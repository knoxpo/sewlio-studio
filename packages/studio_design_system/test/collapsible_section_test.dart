import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('toggling the header shows and hides the child', (tester) async {
    await tester.pumpWidget(_host(const StudioCollapsibleSection(
      title: 'Typography',
      child: Text('body'),
    )));

    expect(find.text('body'), findsOneWidget);

    await tester.tap(find.text('TYPOGRAPHY'));
    await tester.pump();
    expect(find.text('body'), findsNothing);

    await tester.tap(find.text('TYPOGRAPHY'));
    await tester.pump();
    expect(find.text('body'), findsOneWidget);
  });

  testWidgets('controlled expanded is respected', (tester) async {
    var expanded = false;
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => StudioCollapsibleSection(
        title: 'Advanced',
        expanded: expanded,
        onExpandedChanged: (v) => setState(() => expanded = v),
        child: const Text('body'),
      ),
    )));

    // Controlled + collapsed: child hidden.
    expect(find.text('body'), findsNothing);

    await tester.tap(find.text('ADVANCED'));
    await tester.pump();

    // Header toggle drove the external flag, which reopened the section.
    expect(expanded, isTrue);
    expect(find.text('body'), findsOneWidget);
  });
}
