import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: child)),
    );

Container _swatch(WidgetTester tester) => tester.widget<Container>(
      find.byKey(const ValueKey('studio-color-swatch')),
    );

void main() {
  testWidgets('renders the given hex color and is tappable', (tester) async {
    await tester.pumpWidget(_host(StudioColorSwatch(
      color: '#3e8bff',
      onChanged: (_) {},
    )));

    final decoration = _swatch(tester).decoration as BoxDecoration;
    expect(decoration.color, const Color(0xFF3E8BFF));

    // Tappable via InkWell (picker dialog itself not exercised here).
    expect(find.byType(InkWell), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    await tester.pump();
  });

  testWidgets('unset color renders the none slash', (tester) async {
    await tester.pumpWidget(_host(StudioColorSwatch(
      color: null,
      onChanged: (_) {},
    )));

    final swatch = _swatch(tester);
    // Field-fill background stands in for "no color".
    expect((swatch.decoration as BoxDecoration).color, isNotNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('transparent sentinel renders the none slash', (tester) async {
    await tester.pumpWidget(_host(StudioColorSwatch(
      color: studioTransparent,
      onChanged: (_) {},
    )));

    // Same "none" look as null: field background + the slash paint.
    expect((_swatch(tester).decoration as BoxDecoration).color, isNotNull);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('partial-alpha 8-digit color renders without throwing',
      (tester) async {
    await tester.pumpWidget(_host(StudioColorSwatch(
      color: '#3e8bff80',
      onChanged: (_) {},
    )));

    // Checkerboard + colour overlay; no exception thrown.
    expect(_swatch(tester), isNotNull);
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
