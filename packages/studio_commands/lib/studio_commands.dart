/// Commands and the command bus.
///
/// Commands are the only mechanism that may modify a project
/// (ARCH-003). A handler executes the mutation and returns the events
/// describing what happened plus an optional reverse command for undo.
/// The bus publishes those events after successful execution.
library;

import 'package:studio_events/studio_events.dart';

/// Base type for all commands. Subclasses must be immutable.
abstract class Command {
  const Command();
}

/// What a handler produced: events to publish and, if the command is
/// undoable, the command that reverses it.
final class CommandOutcome {
  const CommandOutcome({this.events = const [], this.reverse});

  final List<Event> events;

  /// Dispatching this undoes the executed command. Null = not undoable.
  final Command? reverse;
}

typedef CommandHandler<C extends Command> = CommandOutcome Function(C command);

/// Routes commands to their registered handler and publishes the
/// resulting events on [eventBus].
final class CommandBus {
  CommandBus(this.eventBus);

  final EventBus eventBus;
  final Map<Type, CommandOutcome Function(Command)> _handlers = {};

  /// Registers the handler for command type [C].
  /// Throws [StateError] on duplicate registration.
  void register<C extends Command>(CommandHandler<C> handler) {
    if (_handlers.containsKey(C)) {
      throw StateError('Handler already registered for $C');
    }
    _handlers[C] = (command) => handler(command as C);
  }

  /// Executes [command]: runs its handler, publishes the resulting
  /// events, returns the outcome. Throws [StateError] if no handler is
  /// registered. If the handler throws, nothing is published.
  CommandOutcome dispatch(Command command) {
    final handler = _handlers[command.runtimeType];
    if (handler == null) {
      throw StateError('No handler registered for ${command.runtimeType}');
    }
    final outcome = handler(command);
    outcome.events.forEach(eventBus.publish);
    return outcome;
  }
}
