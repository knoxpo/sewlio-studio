/// Document model skeleton and undo/redo history.
///
/// The document is only ever mutated by command handlers (ARCH-003/005).
/// [History] wraps a [CommandBus] and records reverse commands so any
/// undoable command gets undo/redo for free.
library;

export 'src/commands.dart';
export 'src/document.dart';
export 'src/history.dart';
export 'src/project_io.dart';
