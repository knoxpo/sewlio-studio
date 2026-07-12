import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

Widget _host(Widget child) => MaterialApp(
      theme: studioTheme(),
      home: Scaffold(body: Center(child: child)),
    );

/// Opens the picker; [result] holds the resolved hex once a footer
/// button is tapped ([result.value] stays null until then).
class _Holder {
  String? value;
  bool done = false;
}

Future<_Holder> _open(WidgetTester tester, String initialHex) async {
  final holder = _Holder();
  await tester.pumpWidget(_host(Builder(builder: (context) {
    return TextButton(
      onPressed: () async {
        holder.value = await showStudioColorPicker(
          context: context,
          initialHex: initialHex,
        );
        holder.done = true;
      },
      child: const Text('open'),
    );
  })));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return holder;
}

void main() {
  testWidgets('Select returns the initial hex unchanged', (tester) async {
    final holder = await _open(tester, '#3e8bff');
    await tester.tap(find.byKey(const Key('color-picker-select')));
    await tester.pumpAndSettle();
    expect(holder.done, isTrue);
    expect(holder.value, '#3e8bff');
  });

  testWidgets('transparent swatch selects studioTransparent', (tester) async {
    final holder = await _open(tester, '#3e8bff');
    await tester.tap(find.byKey(const Key('color-picker-transparent')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('color-picker-select')));
    await tester.pumpAndSettle();
    expect(holder.value, studioTransparent);
  });

  testWidgets('opacity < 100% yields an 8-digit hex', (tester) async {
    // 8-digit input with alpha 80 round-trips through Select unchanged.
    final holder = await _open(tester, '#3e8bff80');
    await tester.tap(find.byKey(const Key('color-picker-select')));
    await tester.pumpAndSettle();
    expect(holder.value, '#3e8bff80');
    expect(holder.value!.length, 9); // '#' + 8 hex digits.
  });

  testWidgets('fully opaque input returns a 6-digit hex', (tester) async {
    final holder = await _open(tester, '#ffffff');
    await tester.tap(find.byKey(const Key('color-picker-select')));
    await tester.pumpAndSettle();
    expect(holder.value, '#ffffff');
    expect(holder.value!.length, 7);
  });

  testWidgets('Cancel returns null', (tester) async {
    final holder = await _open(tester, '#3e8bff');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(holder.done, isTrue);
    expect(holder.value, isNull);
  });
}
