import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_events/studio_events.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'document.dart';
import 'guide.dart';

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

/// Adds an object at [index] (end when null). Undoable.
final class AddObject extends Command {
  const AddObject(this.object, {this.index});
  final EmbroideryObject object;
  final int? index;
}

/// Removes the object with [id]. Undoable.
final class RemoveObject extends Command {
  const RemoveObject(this.id);
  final Id id;
}

/// Applies [transform] to the object's geometry. Undoable via the
/// inverse transform.
final class TransformObject extends Command {
  const TransformObject(this.id, this.transform);
  final Id id;
  final Transform2 transform;
}

/// Replaces the object with the same id (parameter edits from the
/// inspector). Undoable — the reverse restores the old object.
final class ReplaceObject extends Command {
  const ReplaceObject(this.object);
  final EmbroideryObject object;
}

final class ObjectReplaced extends Event {
  const ObjectReplaced(this.id);
  final Id id;
}

final class ObjectAdded extends Event {
  const ObjectAdded(this.id);
  final Id id;
}

final class ObjectRemoved extends Event {
  const ObjectRemoved(this.id);
  final Id id;
}

final class ObjectTransformed extends Event {
  const ObjectTransformed(this.id);
  final Id id;
}

/// Adds a ruler guide. Undoable.
final class AddGuide extends Command {
  const AddGuide(this.guide);
  final Guide guide;
}

/// Removes the guide with [id]. Undoable.
final class RemoveGuide extends Command {
  const RemoveGuide(this.id);
  final Id id;
}

/// Replaces the guide with the same id (rename, recolor, move).
/// Undoable.
final class UpdateGuide extends Command {
  const UpdateGuide(this.guide);
  final Guide guide;
}

final class GuidesChanged extends Event {
  const GuidesChanged();
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

  bus.register<AddObject>((command) {
    final index = command.index ?? document.objects.length;
    document.objects.insert(index, command.object);
    document.revision++;
    return CommandOutcome(
      events: [ObjectAdded(command.object.id)],
      reverse: RemoveObject(command.object.id),
    );
  });

  bus.register<RemoveObject>((command) {
    final index =
        document.objects.indexWhere((object) => object.id == command.id);
    if (index < 0) {
      throw StateError('No object with id ${command.id}');
    }
    final object = document.objects.removeAt(index);
    document.revision++;
    return CommandOutcome(
      events: [ObjectRemoved(command.id)],
      reverse: AddObject(object, index: index),
    );
  });

  bus.register<ReplaceObject>((command) {
    final index =
        document.objects.indexWhere((object) => object.id == command.object.id);
    if (index < 0) {
      throw StateError('No object with id ${command.object.id}');
    }
    final old = document.objects[index];
    document.objects[index] = command.object;
    document.revision++;
    return CommandOutcome(
      events: [ObjectReplaced(command.object.id)],
      reverse: ReplaceObject(old),
    );
  });

  bus.register<AddGuide>((command) {
    document.guides.add(command.guide);
    document.revision++;
    return CommandOutcome(
      events: const [GuidesChanged()],
      reverse: RemoveGuide(command.guide.id),
    );
  });

  bus.register<RemoveGuide>((command) {
    final index = document.guides.indexWhere((guide) => guide.id == command.id);
    if (index < 0) {
      throw StateError('No guide with id ${command.id}');
    }
    final guide = document.guides.removeAt(index);
    document.revision++;
    return CommandOutcome(
      events: const [GuidesChanged()],
      reverse: AddGuide(guide),
    );
  });

  bus.register<UpdateGuide>((command) {
    final index =
        document.guides.indexWhere((guide) => guide.id == command.guide.id);
    if (index < 0) {
      throw StateError('No guide with id ${command.guide.id}');
    }
    final old = document.guides[index];
    document.guides[index] = command.guide;
    document.revision++;
    return CommandOutcome(
      events: const [GuidesChanged()],
      reverse: UpdateGuide(old),
    );
  });

  bus.register<TransformObject>((command) {
    final index =
        document.objects.indexWhere((object) => object.id == command.id);
    if (index < 0) {
      throw StateError('No object with id ${command.id}');
    }
    final object = document.objects[index];
    document.objects[index] =
        object.withPath(object.path.transformed(command.transform));
    document.revision++;
    return CommandOutcome(
      events: [ObjectTransformed(command.id)],
      reverse: TransformObject(command.id, command.transform.invert()),
    );
  });
}
