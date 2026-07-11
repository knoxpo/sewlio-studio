import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';

void main() {
  testWidgets('app chrome stays below the system status bar inset',
      (tester) async {
    tester.view.physicalSize = const Size(1000, 760);
    tester.view.devicePixelRatio = 1;
    // Simulate an iPad/Android status bar (top) + home indicator
    // (bottom).
    tester.view.padding = const FakeViewPadding(top: 47, bottom: 20);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(StudioApp(session: StudioSession()));

    // First app chrome row (header with the brand) starts below the
    // status bar instead of underneath it.
    final headerTop = tester.getTopLeft(find.text('Sewlio Studio').first).dy;
    expect(headerTop, greaterThanOrEqualTo(47));
  });
}
