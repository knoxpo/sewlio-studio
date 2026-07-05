/// A time source. Inject instead of calling `DateTime.now()` so time is
/// controllable in tests and replay.
abstract interface class Clock {
  DateTime now();
}

/// Wall-clock time.
final class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now().toUtc();
}

/// A clock frozen at a fixed instant, advanced manually. For tests.
final class FixedClock implements Clock {
  FixedClock(this._now);

  DateTime _now;

  @override
  DateTime now() => _now;

  void advance(Duration d) => _now = _now.add(d);
}
