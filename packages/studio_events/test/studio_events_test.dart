import 'package:studio_events/studio_events.dart';
import 'package:test/test.dart';

final class _Ping extends Event {
  const _Ping(this.n);
  final int n;
}

final class _Pong extends Event {
  const _Pong();
}

void main() {
  test('publish delivers synchronously to subscribers', () {
    final bus = EventBus();
    final seen = <Event>[];
    bus.events.listen(seen.add);

    bus.publish(const _Ping(1));
    bus.publish(const _Pong());

    expect(seen, hasLength(2));
    expect((seen.first as _Ping).n, 1);
  });

  test('on<E>() filters by event type', () {
    final bus = EventBus();
    final pings = <_Ping>[];
    bus.on<_Ping>().listen(pings.add);

    bus.publish(const _Pong());
    bus.publish(const _Ping(7));

    expect(pings.map((p) => p.n), [7]);
  });
}
