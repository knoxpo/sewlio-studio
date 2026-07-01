import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

// Skeleton test: verifies the app package and design system resolve and render.
// It deliberately does NOT pump StudioApp, because that calls into the Rust engine
// (appVersion) which needs the compiled es_ffi dylib — exercised by the manual
// `flutter run` / integration-test path, not unit `flutter test`.
void main() {
  testWidgets('design tokens drive a themed widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorSchemeSeed: AppTokens.seed, useMaterial3: true),
        home: const Scaffold(body: Center(child: Text('Sewlio Studio'))),
      ),
    );
    expect(find.text('Sewlio Studio'), findsOneWidget);
  });
}
