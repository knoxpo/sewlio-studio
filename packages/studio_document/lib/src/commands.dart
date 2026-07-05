import 'package:studio_commands/studio_commands.dart';
import 'package:studio_events/studio_events.dart';

import 'document.dart';

/// Renames the document. Undoable.
final class RenameDocument extends Command {
  const RenameDocument(this.name);
  final String name;
}

/// The document was renamed.
final class DocumentRenamed extends Event {
  const DocumentRenamed({required this.from, required this.to});
  final String from;
  final String to;
}

/// Registers handlers for the document commands on [bus], mutating
/// [document]. The composition root calls this once at startup.
void registerDocumentHandlers(CommandBus bus, Document document) {
  bus.register<RenameDocument>((command) {
    final from = document.name;
    document.name = command.name;
    document.revision++;
    return CommandOutcome(
      events: [DocumentRenamed(from: from, to: command.name)],
      reverse: RenameDocument(from),
    );
  });
}
