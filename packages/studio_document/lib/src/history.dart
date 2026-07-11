import 'package:studio_commands/studio_commands.dart';

/// One undo entry. Usually a single command, but a transaction or a
/// coalesced scrub collects several — undo replays [reverses] in reverse
/// order, redo replays [forwards] in order.
class _Entry {
  _Entry(this.forwards, this.reverses, {this.mergeKey});
  final List<Command> forwards;
  final List<Command> reverses;
  final String? mergeKey;
}

/// Undo/redo history on top of a [CommandBus].
///
/// Execute commands through [execute] instead of dispatching directly;
/// any command whose handler returns a reverse command becomes undoable.
/// Non-undoable commands execute but clear nothing.
///
/// Multiple executes collapse into one undo entry when wrapped in
/// [beginTransaction]/[endTransaction], or when they share a `mergeKey`
/// (e.g. scrubbing a numeric field).
final class History {
  History(this._bus, {this.limit = 1000});

  final CommandBus _bus;

  /// Max undo entries kept; oldest drop off first.
  final int limit;

  final List<_Entry> _undo = [];
  final List<_Entry> _redo = [];

  /// Open transaction; executes accumulate here until [endTransaction].
  _Entry? _txn;

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  /// Opens a transaction: every undoable [execute] until [endTransaction]
  /// collapses into a single undo entry. Optional [mergeKey] merges this
  /// transaction into the previous entry when they share the key.
  void beginTransaction([String? mergeKey]) {
    if (_txn != null) throw StateError('Transaction already open');
    _txn = _Entry([], [], mergeKey: mergeKey);
  }

  /// Closes the current transaction, recording one undo entry for all its
  /// sub-commands. No entry is recorded if nothing undoable ran.
  void endTransaction() {
    final txn = _txn;
    if (txn == null) throw StateError('No transaction open');
    _txn = null;
    if (txn.reverses.isEmpty) return;
    _record(txn);
  }

  /// Dispatches [command]; records it for undo if its handler returned a
  /// reverse command. A new edit clears the redo stack.
  ///
  /// Inside a transaction the command is folded into the open entry.
  /// Otherwise, when [mergeKey] matches the most recent entry's key, the
  /// command is appended to it (coalescing) instead of starting a new one.
  CommandOutcome execute(Command command, {String? mergeKey}) {
    final outcome = _bus.dispatch(command);
    final reverse = outcome.reverse;
    if (reverse == null) return outcome;
    if (_txn != null) {
      _txn!.forwards.add(command);
      _txn!.reverses.add(reverse);
      return outcome;
    }
    if (mergeKey != null &&
        _undo.isNotEmpty &&
        _undo.last.mergeKey == mergeKey) {
      _undo.last.forwards.add(command);
      _undo.last.reverses.add(reverse);
      _redo.clear();
      return outcome;
    }
    _record(_Entry([command], [reverse], mergeKey: mergeKey));
    return outcome;
  }

  void _record(_Entry entry) {
    _undo.add(entry);
    if (_undo.length > limit) _undo.removeAt(0);
    _redo.clear();
  }

  /// Undoes the most recent undoable entry. No-op when empty.
  void undo() {
    if (_undo.isEmpty) return;
    final entry = _undo.removeLast();
    for (final reverse in entry.reverses.reversed) {
      _bus.dispatch(reverse);
    }
    _redo.add(entry);
  }

  /// Re-executes the most recently undone entry. No-op when empty.
  void redo() {
    if (_redo.isEmpty) return;
    final entry = _redo.removeLast();
    for (final forward in entry.forwards) {
      _bus.dispatch(forward);
    }
    _undo.add(entry);
  }
}
