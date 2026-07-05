/// Assistant hooks: natural-language input → proposed Commands.
///
/// The assistant only *proposes* — the caller decides whether to
/// execute the commands (via History), keeping AI on the same
/// public command path as every other mutation source (ARCH-014).
library;

import 'package:studio_commands/studio_commands.dart';

/// Turns user input into proposed commands. Returns empty when the
/// hook doesn't understand the input.
typedef AssistantHook = List<Command> Function(String input);

// ponytail: ordered rule hooks, no model — swap a hook for an
// LLM-backed one behind the same interface when AI lands (Phase 3).

/// Registry of assistant hooks, consulted in registration order.
final class Assistant {
  final List<AssistantHook> _hooks = [];

  void register(AssistantHook hook) => _hooks.add(hook);

  /// Commands proposed by the first hook that understands [input];
  /// empty when none do.
  List<Command> propose(String input) {
    for (final hook in _hooks) {
      final commands = hook(input);
      if (commands.isNotEmpty) return commands;
    }
    return const [];
  }
}
