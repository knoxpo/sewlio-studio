import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';

void main() {
  testWidgets('simulation mode shows the transport bar and panels',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));
    await tester.tap(find.byKey(const Key('mode-simulation')));
    await tester.pumpAndSettle();

    // Transport controls.
    for (final key in const [
      'sim-play',
      'sim-stop',
      'sim-step-back',
      'sim-step-forward',
      'sim-scrub',
      'sim-speed',
      'sim-jump-color',
      'sim-jump-trim',
      'sim-jump-object',
      'sim-loop',
      'sim-show-needle',
      'sim-show-travel',
      'sim-show-machine-path',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }

    // Module simulation panels dock; design panels stay out.
    expect(find.byKey(const Key('dock-tab-timeline')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-runtime-stats')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-warnings')), findsOneWidget);
    expect(find.byKey(const Key('dock-tab-layers')), findsNothing);
  });
}
