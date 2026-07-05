/// An opaque, immutable identifier for a document entity.
final class Id {
  const Id(this.value);

  final String value;

  @override
  bool operator ==(Object other) => other is Id && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Produces ids. Inject one so id assignment is deterministic in tests
/// and replayable in command logs.
abstract interface class IdGenerator {
  Id next();
}

/// Monotonic counter-based generator: `prefix-1`, `prefix-2`, ...
///
/// Deterministic by construction — the same call sequence yields the
/// same ids. Uniqueness holds per generator instance, which is per
/// document, matching where ids must be unique.
// ponytail: counter ids, not UUIDs — switch to UUIDv7 if ids ever need
// global uniqueness across documents/devices.
final class SequentialIdGenerator implements IdGenerator {
  SequentialIdGenerator({this.prefix = 'id'});

  final String prefix;
  int _next = 1;

  @override
  Id next() => Id('$prefix-${_next++}');
}
