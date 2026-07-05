import 'package:studio_commands/studio_commands.dart';

class _Entry {
  _Entry(this.forward, this.reverse);
  final Command forward;
  final Command reverse;
}

/// Undo/redo history on top of a [CommandBus].
///
/// Execute commands through [execute] instead of dispatching directly;
/// any command whose handler returns a reverse command becomes undoable.
/// Non-undoable commands execute but clear nothing.
final class History {
  History(this._bus, {this.limit = 1000});

  final CommandBus _bus;

  /// Max undo entries kept; oldest drop off first.
  final int limit;

  final List<_Entry> _undo = [];
  final List<_Entry> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// Dispatches [command]; records it for undo if its handler returned
  /// a reverse command. A new edit clears the redo stack.
  CommandOutcome execute(Command command) {
    final outcome = _bus.dispatch(command);
    final reverse = outcome.reverse;
    if (reverse != null) {
      _undo.add(_Entry(command, reverse));
      if (_undo.length > limit) _undo.removeAt(0);
      _redo.clear();
    }
    return outcome;
  }

  /// Undoes the most recent undoable command. No-op when empty.
  void undo() {
    if (_undo.isEmpty) return;
    final entry = _undo.removeLast();
    _bus.dispatch(entry.reverse);
    _redo.add(entry);
  }

  /// Re-executes the most recently undone command. No-op when empty.
  void redo() {
    if (_redo.isEmpty) return;
    final entry = _redo.removeLast();
    _bus.dispatch(entry.forward);
    _undo.add(entry);
  }
}
