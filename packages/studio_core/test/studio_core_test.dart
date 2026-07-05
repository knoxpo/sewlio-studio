import 'package:studio_core/studio_core.dart';
import 'package:test/test.dart';

void main() {
  group('Id', () {
    test('value equality', () {
      expect(const Id('a'), const Id('a'));
      expect(const Id('a'), isNot(const Id('b')));
      expect(const Id('a').hashCode, const Id('a').hashCode);
    });

    test('sequential generator is deterministic', () {
      Id third(IdGenerator g) {
        g.next();
        g.next();
        return g.next();
      }

      expect(third(SequentialIdGenerator(prefix: 'obj')), const Id('obj-3'));
      expect(third(SequentialIdGenerator(prefix: 'obj')), const Id('obj-3'));
    });
  });

  group('Clock', () {
    test('fixed clock advances manually', () {
      final t0 = DateTime.utc(2026, 1, 1);
      final clock = FixedClock(t0);
      expect(clock.now(), t0);
      clock.advance(const Duration(minutes: 5));
      expect(clock.now(), t0.add(const Duration(minutes: 5)));
    });

    test('system clock returns utc', () {
      expect(const SystemClock().now().isUtc, isTrue);
    });
  });

  group('ServiceRegistry', () {
    test('register and get by type', () {
      final registry = ServiceRegistry();
      final clock = FixedClock(DateTime.utc(2026));
      registry.register<Clock>(clock);
      expect(registry.get<Clock>(), same(clock));
    });

    test('duplicate registration throws', () {
      final registry = ServiceRegistry();
      registry.register<Clock>(const SystemClock());
      expect(() => registry.register<Clock>(const SystemClock()),
          throwsStateError);
    });

    test('missing service throws, maybeGet returns null', () {
      final registry = ServiceRegistry();
      expect(() => registry.get<Clock>(), throwsStateError);
      expect(registry.maybeGet<Clock>(), isNull);
    });
  });
}
