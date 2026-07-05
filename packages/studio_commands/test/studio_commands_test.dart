import 'package:studio_commands/studio_commands.dart';
import 'package:studio_events/studio_events.dart';
import 'package:test/test.dart';

final class _SetValue extends Command {
  const _SetValue(this.value);
  final int value;
}

final class _ValueChanged extends Event {
  const _ValueChanged(this.from, this.to);
  final int from;
  final int to;
}

void main() {
  late EventBus events;
  late CommandBus bus;
  late List<Event> published;
  var state = 0;

  setUp(() {
    events = EventBus();
    bus = CommandBus(events);
    published = [];
    events.events.listen(published.add);
    state = 0;
    bus.register<_SetValue>((cmd) {
      final old = state;
      state = cmd.value;
      return CommandOutcome(
        events: [_ValueChanged(old, cmd.value)],
        reverse: _SetValue(old),
      );
    });
  });

  test('dispatch runs handler, publishes events, returns reverse', () {
    final outcome = bus.dispatch(const _SetValue(42));

    expect(state, 42);
    expect(published.single, isA<_ValueChanged>());
    expect((outcome.reverse! as _SetValue).value, 0);

    bus.dispatch(outcome.reverse!);
    expect(state, 0);
  });

  test('unregistered command throws, duplicate registration throws', () {
    expect(() => bus.dispatch(const _Unknown()), throwsStateError);
    expect(
      () => bus.register<_SetValue>((c) => const CommandOutcome()),
      throwsStateError,
    );
  });

  test('handler failure publishes nothing', () {
    bus.register<_Unknown>((c) => throw ArgumentError('bad'));
    expect(() => bus.dispatch(const _Unknown()), throwsArgumentError);
    expect(published, isEmpty);
  });
}

final class _Unknown extends Command {
  const _Unknown();
}
