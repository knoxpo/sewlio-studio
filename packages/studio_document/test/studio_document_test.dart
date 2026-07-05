import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_events/studio_events.dart';
import 'package:test/test.dart';

final class RenameDocument extends Command {
  const RenameDocument(this.name);
  final String name;
}

final class DocumentRenamed extends Event {
  const DocumentRenamed(this.from, this.to);
  final String from;
  final String to;
}

void main() {
  late Document doc;
  late EventBus events;
  late CommandBus bus;
  late History history;

  setUp(() {
    doc = Document(id: const Id('doc-1'));
    events = EventBus();
    bus = CommandBus(events);
    history = History(bus);
    bus.register<RenameDocument>((cmd) {
      final old = doc.name;
      doc.name = cmd.name;
      doc.revision++;
      return CommandOutcome(
        events: [DocumentRenamed(old, cmd.name)],
        reverse: RenameDocument(old),
      );
    });
  });

  test('execute mutates document and publishes event', () {
    final seen = <DocumentRenamed>[];
    events.on<DocumentRenamed>().listen(seen.add);

    history.execute(const RenameDocument('Rose'));

    expect(doc.name, 'Rose');
    expect(doc.revision, 1);
    expect(seen.single.from, 'Untitled');
  });

  test('undo/redo round trip', () {
    history.execute(const RenameDocument('Rose'));
    history.execute(const RenameDocument('Tulip'));

    history.undo();
    expect(doc.name, 'Rose');
    history.undo();
    expect(doc.name, 'Untitled');
    expect(history.canUndo, isFalse);

    history.redo();
    history.redo();
    expect(doc.name, 'Tulip');
    expect(history.canRedo, isFalse);
  });

  test('new edit clears redo', () {
    history.execute(const RenameDocument('Rose'));
    history.undo();
    history.execute(const RenameDocument('Iris'));
    expect(history.canRedo, isFalse);
    expect(doc.name, 'Iris');
  });

  test('undo/redo on empty history are no-ops', () {
    history.undo();
    history.redo();
    expect(doc.name, 'Untitled');
  });
}
