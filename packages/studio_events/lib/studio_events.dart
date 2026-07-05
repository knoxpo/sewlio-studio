/// Immutable events and the event bus.
///
/// Events describe something that has already happened. They are
/// published only after successful command execution and never mutate
/// state — subscribers react, they don't edit.
library;

import 'dart:async';

/// Base type for all events. Subclasses must be immutable
/// (const-constructible, final fields only).
abstract class Event {
  const Event();
}

/// Publishes events to subscribers.
///
/// Synchronous broadcast: listeners run during [publish], so command →
/// event → UI-model updates stay deterministic and testable without
/// pumping an event loop.
// ponytail: sync broadcast stream — revisit if a listener ever needs to
// publish re-entrantly (sync controllers forbid that).
final class EventBus {
  final _controller = StreamController<Event>.broadcast(sync: true);

  /// All published events.
  Stream<Event> get events => _controller.stream;

  /// Only events of type [E].
  Stream<E> on<E extends Event>() => events.where((e) => e is E).cast<E>();

  void publish(Event event) => _controller.add(event);

  Future<void> dispose() => _controller.close();
}
