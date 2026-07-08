import 'package:barley/barley.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _CounterModel extends BarleyViewModel {
  var count = 0;
  var readyCalls = 0;

  void increment() {
    count++;
    notify();
  }

  @override
  void onReady() => readyCalls++;
}

void main() {
  testWidgets('view rebuilds on notify, onReady fires once, disposes',
      (tester) async {
    late _CounterModel model;
    await tester.pumpWidget(MaterialApp(
      home: BarleyView<_CounterModel>(
        create: () => model = _CounterModel(),
        builder: (context, m) => Text('count ${m.count}'),
      ),
    ));
    await tester.pump();

    expect(find.text('count 0'), findsOneWidget);
    expect(model.readyCalls, 1);

    model.increment();
    await tester.pump();
    expect(find.text('count 1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    expect(model.disposed, isTrue);
    model.notify(); // safe no-op after dispose
  });

  test('runBusy toggles busy and captures errors', () async {
    final model = _CounterModel();
    final states = <bool>[];
    model.addListener(() => states.add(model.isBusy));

    await model.runBusy(() async {});
    expect(states, contains(true));
    expect(model.isBusy, isFalse);
    expect(model.hasError, isFalse);

    await model.runBusy(() async => throw StateError('boom'));
    expect(model.isBusy, isFalse);
    expect(model.error, isA<StateError>());
  });
}
