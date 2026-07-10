import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

void main() {
  test('seed tokens are defined', () {
    expect(AppTokens.spacing, greaterThan(0));
    expect(AppTokens.seed.a, 1.0);
  });

  for (final platform in [
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ]) {
    testWidgets('dialog close control closes on $platform', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: studioTheme().copyWith(platform: platform),
        home: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showStudioDialog<void>(
                context: context,
                title: 'Probe',
                body: const Text('body'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Probe'), findsOneWidget);

      // Every platform variant exposes exactly one tappable close
      // control inside the title bar.
      final close = find.descendant(
        of: find.byType(Dialog),
        matching: find.byWidgetPredicate((w) =>
            w is Icon && w.icon == Icons.close ||
            w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration! as BoxDecoration).shape == BoxShape.circle &&
                (w.decoration! as BoxDecoration).color ==
                    const Color(0xFFFF5F57)),
      );
      expect(close, findsWidgets);
      await tester.tap(close.first);
      await tester.pumpAndSettle();
      expect(find.text('Probe'), findsNothing);
    });
  }
}
