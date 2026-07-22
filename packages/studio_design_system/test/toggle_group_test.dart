import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('tapping a segment reports its value', (tester) async {
    final taps = <String>[];
    await tester.pumpWidget(_host(StudioToggleGroup<String>(
      items: const [
        StudioToggleItem(value: 'left', icon: Icons.format_align_left),
        StudioToggleItem(
            value: 'center', icon: Icons.format_align_center, active: true),
        StudioToggleItem(value: 'right', icon: Icons.format_align_right),
      ],
      onToggled: taps.add,
    )));

    await tester.tap(find.byIcon(Icons.format_align_right));
    await tester.pump();
    expect(taps, ['right']);
  });

  testWidgets('indeterminate renders distinctly and resolves on tap',
      (tester) async {
    final taps = <String>[];
    await tester.pumpWidget(_host(StudioToggleGroup<String>(
      items: const [
        StudioToggleItem(value: 'bold', icon: Icons.format_bold, active: null),
        StudioToggleItem(
            value: 'italic', icon: Icons.format_italic, active: false),
      ],
      onToggled: taps.add,
    )));

    // The mixed-state indicator marks the indeterminate segment.
    expect(find.byKey(const ValueKey('studio-toggle-indeterminate')),
        findsOneWidget);

    await tester.tap(find.byIcon(Icons.format_bold));
    await tester.pump();
    expect(taps, ['bold']);
  });
}
