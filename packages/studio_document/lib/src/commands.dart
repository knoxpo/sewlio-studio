import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_events/studio_events.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'document.dart';
import 'guide.dart';
import 'hoop.dart';
import 'hierarchy.dart';

/// Renames the document. Undoable.
final class RenameDocument extends Command {
  const RenameDocument(this.name);
  final String name;
}

/// Adds an object at [index] under [parent] (default layer when null).
final class AddObject extends Command {
  const AddObject(this.object, {this.parent, this.index});
  final EmbroideryObject object;
  final HierarchyParentRef? parent;
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

/// Applies [transform] to all descendant objects from [refs].
final class TransformSelection extends Command {
  const TransformSelection(this.refs, this.transform);
  final List<DocumentNodeRef> refs;
  final Transform2 transform;
}

/// Replaces the object with the same id (parameter edits from the
/// inspector). Undoable — the reverse restores the old object.
final class ReplaceObject extends Command {
  const ReplaceObject(this.object);
  final EmbroideryObject object;
}

/// Applies [patch] to the rune range `[start, end)` of the TextObject
/// with [objectId] (ADR-040). No-op if the object is not a TextObject.
/// Undoable — the reverse restores the prior object.
final class ApplyCharAttrs extends Command {
  const ApplyCharAttrs(this.objectId, this.start, this.end, this.patch);
  final Id objectId;
  final int start;
  final int end;
  final CharAttrs patch;
}

/// Adds a reusable character style (ADR-040). Undoable.
final class AddCharacterStyle extends Command {
  const AddCharacterStyle(this.style, {this.index});
  final CharacterStyle style;
  final int? index;
}

/// Renames the character style with [id]. Undoable.
final class RenameCharacterStyle extends Command {
  const RenameCharacterStyle(this.id, this.name);
  final String id;
  final String name;
}

/// Replaces the base attributes of the character style with [id].
/// Undoable.
final class UpdateCharacterStyle extends Command {
  const UpdateCharacterStyle(this.id, this.base);
  final String id;
  final CharAttrs base;
}

/// Duplicates the character style with [id] under [newId]. Undoable.
final class DuplicateCharacterStyle extends Command {
  const DuplicateCharacterStyle(this.id, this.newId);
  final String id;
  final String newId;
}

/// Removes the character style with [id]. Undoable.
final class DeleteCharacterStyle extends Command {
  const DeleteCharacterStyle(this.id);
  final String id;
}

/// Emitted when [Document.characterStyles] changes.
final class CharacterStylesChanged extends Event {
  const CharacterStylesChanged();
}

/// Replaces the document-wide optical-alignment preset table (undoable).
final class SetOpticalRules extends Command {
  const SetOpticalRules(this.rules);
  final List<OpticalRule> rules;
}

/// Emitted when [Document.opticalRules] changes.
final class OpticalRulesChanged extends Event {
  const OpticalRulesChanged();
}

final class AddLayer extends Command {
  const AddLayer(this.layer, {this.index});
  final LayerNode layer;
  final int? index;
}

final class RenameLayer extends Command {
  const RenameLayer(this.id, this.name);
  final Id id;
  final String name;
}

final class AddGroup extends Command {
  const AddGroup(this.group, {required this.parent, this.index});
  final GroupNode group;
  final HierarchyParentRef parent;
  final int? index;
}

final class RenameGroup extends Command {
  const RenameGroup(this.id, this.name);
  final Id id;
  final String name;
}

final class DeleteNode extends Command {
  const DeleteNode(this.ref);
  final DocumentNodeRef ref;
}

final class DuplicateNode extends Command {
  const DuplicateNode(this.subtree, {this.parent, this.index});
  final DuplicatedSubtree subtree;
  final HierarchyParentRef? parent;
  final int? index;
}

final class MoveNode extends Command {
  const MoveNode(this.ref, {this.parent, this.index});
  final DocumentNodeRef ref;
  final HierarchyParentRef? parent;
  final int? index;
}

final class SetNodeVisible extends Command {
  const SetNodeVisible(this.ref, this.visible);
  final DocumentNodeRef ref;
  final bool visible;
}

final class SetNodeLocked extends Command {
  const SetNodeLocked(this.ref, this.locked);
  final DocumentNodeRef ref;
  final bool locked;
}

final class GroupSelection extends Command {
  const GroupSelection(this.group, this.selection);
  final GroupNode group;
  final List<DocumentNodeRef> selection;
}

final class UngroupGroup extends Command {
  const UngroupGroup(this.groupId);
  final Id groupId;
}

final class SetDocumentSnapshot extends Command {
  const SetDocumentSnapshot(this.snapshot);
  final DocumentSnapshot snapshot;
}

final class DocumentRenamed extends Event {
  const DocumentRenamed({required this.from, required this.to});
  final String from;
  final String to;
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

final class HierarchyChanged extends Event {
  const HierarchyChanged();
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

/// Replaces the hoop + fabric setup. Undoable.
final class UpdateHoop extends Command {
  const UpdateHoop(this.hoop);
  final HoopSettings hoop;
}

final class HoopChanged extends Event {
  const HoopChanged();
}

CommandOutcome _restoreOutcome(
  Document document,
  DocumentSnapshot before, {
  List<Event> events = const [HierarchyChanged()],
}) {
  document.revision++;
  return CommandOutcome(
    events: events,
    reverse: SetDocumentSnapshot(before),
  );
}

/// Registers handlers for the document commands on [bus], mutating
/// [document]. The composition root calls this once at startup.
void registerDocumentHandlers(CommandBus bus, Document document) {
  bus.register<SetDocumentSnapshot>((command) {
    final before = document.snapshot();
    document.restore(command.snapshot);
    return CommandOutcome(
      events: const [HierarchyChanged()],
      reverse: SetDocumentSnapshot(before),
    );
  });

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
    final parent = command.parent ??
        HierarchyParentRef(DocumentNodeKind.layer, document.defaultLayer.id);
    if (document.objects.containsKey(command.object.id)) {
      throw StateError('Duplicate object id ${command.object.id}');
    }
    document.objects[command.object.id] = command.object;
    document.objectStates[command.object.id] = const ObjectNodeState();
    document.insertChild(
      parent,
      HierarchyChildRef(DocumentNodeKind.object, command.object.id),
      index: command.index,
    );
    document.revision++;
    return CommandOutcome(
      events: [ObjectAdded(command.object.id), const HierarchyChanged()],
      reverse: RemoveObject(command.object.id),
    );
  });

  bus.register<RemoveObject>((command) {
    final before = document.snapshot();
    if (!document.objects.containsKey(command.id)) {
      throw StateError('No object with id ${command.id}');
    }
    document.removeNodeCascade(
        DocumentNodeRef(DocumentNodeKind.object, command.id));
    return _restoreOutcome(
      document,
      before,
      events: [ObjectRemoved(command.id), const HierarchyChanged()],
    );
  });

  bus.register<ReplaceObject>((command) {
    final index = document.objects.containsKey(command.object.id) ? 0 : -1;
    if (index < 0) {
      throw StateError('No object with id ${command.object.id}');
    }
    final old = document.objects[command.object.id]!;
    document.objects[command.object.id] = command.object;
    document.revision++;
    return CommandOutcome(
      events: [ObjectReplaced(command.object.id)],
      reverse: ReplaceObject(old),
    );
  });

  bus.register<ApplyCharAttrs>((command) {
    final object = document.objects[command.objectId];
    if (object is! TextObject) {
      // Not a text object: nothing to style, nothing to undo.
      return const CommandOutcome();
    }
    document.objects[command.objectId] =
        object.withRangeAttrs(command.start, command.end, command.patch);
    document.revision++;
    // ponytail: runs only; the UI re-runs text layout to refresh outlines
    // (the font engine lives in studio_tools, which this package cannot use).
    return CommandOutcome(
      events: [ObjectReplaced(command.objectId)],
      reverse: ReplaceObject(object),
    );
  });

  bus.register<AddCharacterStyle>((command) {
    if (document.characterStyleById(command.style.id) != null) {
      throw StateError('Duplicate character style ${command.style.id}');
    }
    final index = command.index ?? document.characterStyles.length;
    document.characterStyles.insert(index, command.style);
    document.revision++;
    return CommandOutcome(
      events: const [CharacterStylesChanged()],
      reverse: DeleteCharacterStyle(command.style.id),
    );
  });

  bus.register<RenameCharacterStyle>((command) {
    final index =
        document.characterStyles.indexWhere((style) => style.id == command.id);
    if (index < 0) throw StateError('No character style ${command.id}');
    final old = document.characterStyles[index];
    document.characterStyles[index] = old.copyWith(name: command.name);
    document.revision++;
    return CommandOutcome(
      events: const [CharacterStylesChanged()],
      reverse: RenameCharacterStyle(command.id, old.name),
    );
  });

  bus.register<UpdateCharacterStyle>((command) {
    final index =
        document.characterStyles.indexWhere((style) => style.id == command.id);
    if (index < 0) throw StateError('No character style ${command.id}');
    final old = document.characterStyles[index];
    document.characterStyles[index] = old.copyWith(base: command.base);
    document.revision++;
    return CommandOutcome(
      events: const [CharacterStylesChanged()],
      reverse: UpdateCharacterStyle(command.id, old.base),
    );
  });

  bus.register<DuplicateCharacterStyle>((command) {
    final index =
        document.characterStyles.indexWhere((style) => style.id == command.id);
    if (index < 0) throw StateError('No character style ${command.id}');
    if (document.characterStyleById(command.newId) != null) {
      throw StateError('Duplicate character style ${command.newId}');
    }
    final source = document.characterStyles[index];
    final copy =
        CharacterStyle(command.newId, '${source.name} copy', source.base);
    document.characterStyles.insert(index + 1, copy);
    document.revision++;
    return CommandOutcome(
      events: const [CharacterStylesChanged()],
      reverse: DeleteCharacterStyle(command.newId),
    );
  });

  bus.register<DeleteCharacterStyle>((command) {
    final index =
        document.characterStyles.indexWhere((style) => style.id == command.id);
    if (index < 0) throw StateError('No character style ${command.id}');
    final removed = document.characterStyles.removeAt(index);
    document.revision++;
    return CommandOutcome(
      events: const [CharacterStylesChanged()],
      reverse: AddCharacterStyle(removed, index: index),
    );
  });

  bus.register<SetOpticalRules>((command) {
    final old = [for (final rule in document.opticalRules) rule];
    document.opticalRules
      ..clear()
      ..addAll(command.rules);
    document.revision++;
    return CommandOutcome(
      events: const [OpticalRulesChanged()],
      reverse: SetOpticalRules(old),
    );
  });

  bus.register<UpdateHoop>((command) {
    final old = document.hoop;
    document.hoop = command.hoop;
    document.revision++;
    return CommandOutcome(
      events: const [HoopChanged()],
      reverse: UpdateHoop(old),
    );
  });

  bus.register<TransformObject>((command) {
    final object = document.objectById(command.id);
    if (object == null) {
      throw StateError('No object with id ${command.id}');
    }
    document.objects[command.id] = object.transformedBy(command.transform);
    document.revision++;
    return CommandOutcome(
      events: [ObjectTransformed(command.id)],
      reverse: TransformObject(command.id, command.transform.invert()),
    );
  });

  bus.register<TransformSelection>((command) {
    final ids = <Id>{};
    for (final ref in command.refs) {
      ids.addAll(document.subtreeObjectIds(ref));
    }
    final before = document.snapshot();
    for (final id in ids) {
      final object = document.objectById(id);
      if (object == null) continue;
      document.objects[id] = object.transformedBy(command.transform);
    }
    return _restoreOutcome(
      document,
      before,
      events: [for (final id in ids) ObjectTransformed(id)],
    );
  });

  bus.register<AddLayer>((command) {
    final index = command.index ?? document.layers.length;
    document.layers.insert(index, command.layer.clone());
    document.revision++;
    return CommandOutcome(
      events: const [HierarchyChanged()],
      reverse:
          DeleteNode(DocumentNodeRef(DocumentNodeKind.layer, command.layer.id)),
    );
  });

  bus.register<RenameLayer>((command) {
    final layer = document.layerById(command.id);
    if (layer == null) throw StateError('No layer with id ${command.id}');
    final old = layer.name;
    layer.name = command.name;
    document.revision++;
    return CommandOutcome(
      events: const [HierarchyChanged()],
      reverse: RenameLayer(command.id, old),
    );
  });

  bus.register<AddGroup>((command) {
    document.groups[command.group.id] = command.group.clone();
    document.insertChild(
      command.parent,
      HierarchyChildRef(DocumentNodeKind.group, command.group.id),
      index: command.index,
    );
    document.revision++;
    return CommandOutcome(
      events: const [HierarchyChanged()],
      reverse:
          DeleteNode(DocumentNodeRef(DocumentNodeKind.group, command.group.id)),
    );
  });

  bus.register<RenameGroup>((command) {
    final group = document.groupById(command.id);
    if (group == null) throw StateError('No group with id ${command.id}');
    final old = group.name;
    group.name = command.name;
    document.revision++;
    return CommandOutcome(
      events: const [HierarchyChanged()],
      reverse: RenameGroup(command.id, old),
    );
  });

  bus.register<DeleteNode>((command) {
    final before = document.snapshot();
    switch (command.ref.kind) {
      case DocumentNodeKind.object:
        if (!document.objects.containsKey(command.ref.id)) {
          throw StateError('No object with id ${command.ref.id}');
        }
      case DocumentNodeKind.group:
        if (!document.groups.containsKey(command.ref.id)) {
          throw StateError('No group with id ${command.ref.id}');
        }
      case DocumentNodeKind.layer:
        if (document.layerById(command.ref.id) == null) {
          throw StateError('No layer with id ${command.ref.id}');
        }
    }
    document.removeNodeCascade(command.ref);
    return _restoreOutcome(document, before);
  });

  bus.register<DuplicateNode>((command) {
    final before = document.snapshot();
    document.objects.addAll(command.subtree.objects);
    document.objectStates.addAll(command.subtree.objectStates);
    document.groups.addAll(command.subtree.groups);
    if (command.subtree.root.kind == DocumentNodeKind.layer) {
      final layer = command.subtree.layer;
      if (layer == null) throw StateError('Layer copy missing');
      document.layers
          .insert(command.index ?? document.layers.length, layer.clone());
    } else {
      final parent = command.parent;
      if (parent == null) throw StateError('Duplicate target parent missing');
      document.insertChild(
        parent,
        HierarchyChildRef(command.subtree.root.kind, command.subtree.root.id),
        index: command.index,
      );
    }
    return _restoreOutcome(document, before);
  });

  bus.register<MoveNode>((command) {
    final before = document.snapshot();
    switch (command.ref.kind) {
      case DocumentNodeKind.layer:
        final index = document.indexOfLayer(command.ref.id);
        if (index < 0) throw StateError('No layer with id ${command.ref.id}');
        final layer = document.layers.removeAt(index);
        document.layers.insert(command.index ?? document.layers.length, layer);
      case DocumentNodeKind.object:
      case DocumentNodeKind.group:
        final parent = command.parent;
        if (parent == null) {
          throw StateError('Node ${command.ref.id} requires a parent');
        }
        if (document.containsNode(
          command.ref,
          parent.asNodeRef,
        )) {
          throw StateError('Cannot move a node into its own descendant');
        }
        final detached = document.detachChild(command.ref);
        if (detached == null) {
          throw StateError('No node ${command.ref.id}');
        }
        document.insertChild(parent, detached, index: command.index);
    }
    return _restoreOutcome(document, before);
  });

  bus.register<SetNodeVisible>((command) {
    final before = document.snapshot();
    switch (command.ref.kind) {
      case DocumentNodeKind.object:
        final object = document.objectById(command.ref.id);
        if (object == null) {
          throw StateError('No object with id ${command.ref.id}');
        }
        document.objectStates[command.ref.id] = document
            .objectState(command.ref.id)
            .copyWith(visible: command.visible);
      case DocumentNodeKind.group:
        final group = document.groupById(command.ref.id);
        if (group == null) {
          throw StateError('No group with id ${command.ref.id}');
        }
        group.visible = command.visible;
      case DocumentNodeKind.layer:
        final layer = document.layerById(command.ref.id);
        if (layer == null) {
          throw StateError('No layer with id ${command.ref.id}');
        }
        layer.visible = command.visible;
    }
    return _restoreOutcome(document, before);
  });

  bus.register<SetNodeLocked>((command) {
    final before = document.snapshot();
    switch (command.ref.kind) {
      case DocumentNodeKind.object:
        final object = document.objectById(command.ref.id);
        if (object == null) {
          throw StateError('No object with id ${command.ref.id}');
        }
        document.objectStates[command.ref.id] = document
            .objectState(command.ref.id)
            .copyWith(locked: command.locked);
      case DocumentNodeKind.group:
        final group = document.groupById(command.ref.id);
        if (group == null) {
          throw StateError('No group with id ${command.ref.id}');
        }
        group.locked = command.locked;
      case DocumentNodeKind.layer:
        final layer = document.layerById(command.ref.id);
        if (layer == null) {
          throw StateError('No layer with id ${command.ref.id}');
        }
        layer.locked = command.locked;
    }
    return _restoreOutcome(document, before);
  });

  bus.register<GroupSelection>((command) {
    if (command.selection.isEmpty) {
      throw StateError('No selection to group');
    }
    final parent = document.parentOf(command.selection.first);
    if (parent == null) {
      throw StateError('Selection has no parent');
    }
    for (final ref in command.selection) {
      if (ref.kind == DocumentNodeKind.layer) {
        throw StateError('Layers cannot be grouped');
      }
      if (document.parentOf(ref) != parent) {
        throw StateError('Cross-parent grouping is not allowed');
      }
    }
    final before = document.snapshot();
    final parentChildren = document.childListFor(parent)!;
    final indexed = <(int, HierarchyChildRef)>[];
    for (final ref in command.selection) {
      final index = document.indexOfChild(parent, ref);
      if (index < 0) throw StateError('Selection child missing');
      indexed.add((index, parentChildren[index]));
    }
    indexed.sort((a, b) => a.$1.compareTo(b.$1));
    final insertIndex = indexed.first.$1;
    final selected = {for (final entry in indexed) entry.$2.id: entry.$2};
    parentChildren.removeWhere((child) => selected.containsKey(child.id));
    document.groups[command.group.id] = command.group.clone();
    document.groups[command.group.id]!.children
      ..clear()
      ..addAll([for (final entry in indexed) entry.$2]);
    parentChildren.insert(
      insertIndex,
      HierarchyChildRef(DocumentNodeKind.group, command.group.id),
    );
    return _restoreOutcome(document, before);
  });

  bus.register<UngroupGroup>((command) {
    final group = document.groupById(command.groupId);
    if (group == null) throw StateError('No group with id ${command.groupId}');
    final before = document.snapshot();
    final parent = document
        .parentOf(DocumentNodeRef(DocumentNodeKind.group, command.groupId));
    if (parent == null) throw StateError('Group has no parent');
    final children = document.childListFor(parent)!;
    final index = document.indexOfChild(
      parent,
      DocumentNodeRef(DocumentNodeKind.group, command.groupId),
    );
    if (index < 0) throw StateError('Group is not attached');
    children.removeAt(index);
    children.insertAll(index, group.children);
    document.groups.remove(command.groupId);
    return _restoreOutcome(document, before);
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
}
