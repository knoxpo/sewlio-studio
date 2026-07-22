import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'guide.dart';
import 'hoop.dart';
import 'hierarchy.dart';
import 'units.dart';

/// Root of the in-memory project document.
///
/// Mutable, but only command handlers may mutate it — everything else
/// reads.
final class Document {
  Document({
    required this.id,
    this.name = 'Untitled',
    this.hoop = const HoopSettings(),
    this.units = ProjectUnits.mm,
    this.colorProfile = ColorProfile.srgb,
  }) {
    layers.add(LayerNode(id: defaultLayerId, name: 'Layer 1'));
  }

  final Id id;
  String name;

  final Map<Id, EmbroideryObject> objects = {};
  final Map<Id, ObjectNodeState> objectStates = {};
  final List<LayerNode> layers = [];
  final Map<Id, GroupNode> groups = {};

  /// Ruler guides.
  final List<Guide> guides = [];

  /// Reusable character styles (ADR-040); text runs reference these by
  /// id. Mutated only via character-style commands.
  final List<CharacterStyle> characterStyles = [];

  CharacterStyle? characterStyleById(String id) {
    for (final style in characterStyles) {
      if (style.id == id) return style;
    }
    return null;
  }

  /// Document-wide optical-alignment preset table (ADR-040). Mutated only
  /// via the SetOpticalRules command.
  final List<OpticalRule> opticalRules = [];

  /// Hoop + fabric setup. Mutated only via the UpdateHoop command.
  HoopSettings hoop;

  /// Display units for dimensions; geometry is always stored in mm.
  ProjectUnits units;

  /// Working color space (metadata; no conversion pipeline yet).
  ColorProfile colorProfile;

  /// Incremented by handlers on every mutation. Lets observers cheaply
  /// detect "document changed" without diffing.
  int revision = 0;

  Id get defaultLayerId => Id('${id.value}:layer-1');

  LayerNode get defaultLayer => layers.first;

  Guide? guideById(Id id) {
    for (final guide in guides) {
      if (guide.id == id) return guide;
    }
    return null;
  }

  EmbroideryObject? objectById(Id id) => objects[id];

  LayerNode? layerById(Id id) {
    for (final layer in layers) {
      if (layer.id == id) return layer;
    }
    return null;
  }

  GroupNode? groupById(Id id) => groups[id];

  ObjectNodeState objectState(Id id) =>
      objectStates[id] ?? const ObjectNodeState();

  DocumentSnapshot snapshot() => DocumentSnapshot(
        name: name,
        revision: revision,
        objects: Map<Id, EmbroideryObject>.from(objects),
        objectStates: {
          for (final entry in objectStates.entries)
            entry.key: entry.value.copyWith(),
        },
        layers: [for (final layer in layers) layer.clone()],
        groups: {
          for (final entry in groups.entries) entry.key: entry.value.clone()
        },
        guides: [for (final guide in guides) guide],
        characterStyles: [for (final style in characterStyles) style],
        opticalRules: [for (final rule in opticalRules) rule],
      );

  void restore(DocumentSnapshot snapshot) {
    name = snapshot.name;
    revision = snapshot.revision;
    objects
      ..clear()
      ..addAll(snapshot.objects);
    objectStates
      ..clear()
      ..addAll(snapshot.objectStates);
    layers
      ..clear()
      ..addAll([for (final layer in snapshot.layers) layer.clone()]);
    groups
      ..clear()
      ..addAll({
        for (final entry in snapshot.groups.entries)
          entry.key: entry.value.clone()
      });
    guides
      ..clear()
      ..addAll(snapshot.guides);
    characterStyles
      ..clear()
      ..addAll(snapshot.characterStyles);
    opticalRules
      ..clear()
      ..addAll(snapshot.opticalRules);
  }

  List<EmbroideryObject> flattenObjects() {
    final out = <EmbroideryObject>[];
    for (final layer in layers) {
      _collectObjects(layer.children, out, visibleOnly: false);
    }
    return out;
  }

  List<EmbroideryObject> flattenVisibleObjects() {
    final out = <EmbroideryObject>[];
    for (final layer in layers) {
      if (!layer.visible) continue;
      _collectObjects(layer.children, out, visibleOnly: true);
    }
    return out;
  }

  List<HierarchyChildRef> flattenedChildren() {
    final out = <HierarchyChildRef>[];
    for (final layer in layers) {
      out.addAll(layer.children);
    }
    return out;
  }

  void _collectObjects(
    List<HierarchyChildRef> children,
    List<EmbroideryObject> out, {
    required bool visibleOnly,
  }) {
    for (final child in children) {
      switch (child.kind) {
        case DocumentNodeKind.object:
          if (!visibleOnly || isObjectVisible(child.id)) {
            final object = objects[child.id];
            if (object != null) out.add(object);
          }
        case DocumentNodeKind.group:
          final group = groups[child.id];
          if (group == null) continue;
          if (visibleOnly && !group.visible) continue;
          _collectObjects(group.children, out, visibleOnly: visibleOnly);
        case DocumentNodeKind.layer:
          break;
      }
    }
  }

  HierarchyParentRef? parentOf(DocumentNodeRef ref) {
    for (final layer in layers) {
      if (_containsChild(layer.children, ref)) {
        return HierarchyParentRef(DocumentNodeKind.layer, layer.id);
      }
    }
    for (final group in groups.values) {
      if (_containsChild(group.children, ref)) {
        return HierarchyParentRef(DocumentNodeKind.group, group.id);
      }
    }
    return null;
  }

  bool _containsChild(List<HierarchyChildRef> children, DocumentNodeRef ref) {
    for (final child in children) {
      if (child.kind == ref.kind && child.id == ref.id) return true;
    }
    return false;
  }

  List<HierarchyChildRef> childrenOf(HierarchyParentRef parent) =>
      switch (parent.kind) {
        DocumentNodeKind.layer => layerById(parent.id)?.children ?? const [],
        DocumentNodeKind.group => groupById(parent.id)?.children ?? const [],
        DocumentNodeKind.object => const [],
      };

  List<Id> subtreeObjectIds(DocumentNodeRef ref) {
    return switch (ref.kind) {
      DocumentNodeKind.object =>
        objects.containsKey(ref.id) ? [ref.id] : const [],
      DocumentNodeKind.group => _subtreeChildObjectIds(
          groupById(ref.id)?.children ?? const [],
        ),
      DocumentNodeKind.layer => _subtreeChildObjectIds(
          layerById(ref.id)?.children ?? const [],
        ),
    };
  }

  List<Id> _subtreeChildObjectIds(List<HierarchyChildRef> children) {
    final ids = <Id>[];
    for (final child in children) {
      switch (child.kind) {
        case DocumentNodeKind.object:
          ids.add(child.id);
        case DocumentNodeKind.group:
          final group = groups[child.id];
          if (group != null) ids.addAll(_subtreeChildObjectIds(group.children));
        case DocumentNodeKind.layer:
          break;
      }
    }
    return ids;
  }

  bool containsNode(DocumentNodeRef ancestor, DocumentNodeRef target) {
    if (ancestor == target) return true;
    for (final childId in switch (ancestor.kind) {
      DocumentNodeKind.object => const <DocumentNodeRef>[],
      DocumentNodeKind.group => [
          for (final child in groupById(ancestor.id)?.children ?? const [])
            child.asNodeRef,
        ],
      DocumentNodeKind.layer => [
          for (final child in layerById(ancestor.id)?.children ?? const [])
            child.asNodeRef,
        ],
    }) {
      if (containsNode(childId, target)) return true;
    }
    return false;
  }

  bool isObjectVisible(Id id) {
    if (!objectState(id).visible) return false;
    var parent = parentOf(DocumentNodeRef(DocumentNodeKind.object, id));
    while (parent != null) {
      switch (parent.kind) {
        case DocumentNodeKind.layer:
          final layer = layerById(parent.id);
          if (layer == null || !layer.visible) return false;
        case DocumentNodeKind.group:
          final group = groupById(parent.id);
          if (group == null || !group.visible) return false;
        case DocumentNodeKind.object:
          break;
      }
      parent = parentOf(parent.asNodeRef);
    }
    return true;
  }

  bool isObjectLocked(Id id) {
    if (objectState(id).locked) return true;
    var parent = parentOf(DocumentNodeRef(DocumentNodeKind.object, id));
    while (parent != null) {
      switch (parent.kind) {
        case DocumentNodeKind.layer:
          final layer = layerById(parent.id);
          if (layer?.locked ?? false) return true;
        case DocumentNodeKind.group:
          final group = groupById(parent.id);
          if (group?.locked ?? false) return true;
        case DocumentNodeKind.object:
          break;
      }
      parent = parentOf(parent.asNodeRef);
    }
    return false;
  }

  bool isNodeVisible(DocumentNodeRef ref) => switch (ref.kind) {
        DocumentNodeKind.object => isObjectVisible(ref.id),
        DocumentNodeKind.group => _containerVisible(ref),
        DocumentNodeKind.layer => layerById(ref.id)?.visible ?? false,
      };

  bool _containerVisible(DocumentNodeRef ref) {
    var current = ref;
    while (true) {
      switch (current.kind) {
        case DocumentNodeKind.group:
          final group = groupById(current.id);
          if (group == null || !group.visible) return false;
        case DocumentNodeKind.layer:
          final layer = layerById(current.id);
          if (layer == null || !layer.visible) return false;
        case DocumentNodeKind.object:
          break;
      }
      final parent = parentOf(current);
      if (parent == null) return true;
      current = parent.asNodeRef;
    }
  }

  bool isNodeLocked(DocumentNodeRef ref) => switch (ref.kind) {
        DocumentNodeKind.object => isObjectLocked(ref.id),
        DocumentNodeKind.group => _containerLocked(ref),
        DocumentNodeKind.layer => layerById(ref.id)?.locked ?? false,
      };

  bool _containerLocked(DocumentNodeRef ref) {
    var current = ref;
    while (true) {
      switch (current.kind) {
        case DocumentNodeKind.group:
          final group = groupById(current.id);
          if (group?.locked ?? false) return true;
        case DocumentNodeKind.layer:
          final layer = layerById(current.id);
          if (layer?.locked ?? false) return true;
        case DocumentNodeKind.object:
          break;
      }
      final parent = parentOf(current);
      if (parent == null) return false;
      current = parent.asNodeRef;
    }
  }

  List<HierarchyChildRef>? childListFor(HierarchyParentRef parent) =>
      switch (parent.kind) {
        DocumentNodeKind.layer => layerById(parent.id)?.children,
        DocumentNodeKind.group => groupById(parent.id)?.children,
        DocumentNodeKind.object => null,
      };

  int indexOfChild(HierarchyParentRef parent, DocumentNodeRef ref) {
    final children = childListFor(parent);
    if (children == null) return -1;
    return children
        .indexWhere((child) => child.kind == ref.kind && child.id == ref.id);
  }

  HierarchyChildRef? detachChild(DocumentNodeRef ref) {
    final parent = parentOf(ref);
    if (parent == null) return null;
    final children = childListFor(parent);
    if (children == null) return null;
    final index = indexOfChild(parent, ref);
    if (index < 0) return null;
    return children.removeAt(index);
  }

  void insertChild(
    HierarchyParentRef parent,
    HierarchyChildRef child, {
    int? index,
  }) {
    final children = childListFor(parent);
    if (children == null) {
      throw StateError('Invalid parent ${parent.kind}:${parent.id}');
    }
    children.insert(index ?? children.length, child);
  }

  int indexOfLayer(Id id) => layers.indexWhere((layer) => layer.id == id);

  void removeNodeCascade(DocumentNodeRef ref) {
    switch (ref.kind) {
      case DocumentNodeKind.object:
        detachChild(ref);
        objects.remove(ref.id);
        objectStates.remove(ref.id);
      case DocumentNodeKind.group:
        final group = groups[ref.id];
        if (group == null) return;
        for (final child in List<HierarchyChildRef>.of(group.children)) {
          removeNodeCascade(child.asNodeRef);
        }
        detachChild(ref);
        groups.remove(ref.id);
      case DocumentNodeKind.layer:
        final layer = layerById(ref.id);
        if (layer == null) return;
        for (final child in List<HierarchyChildRef>.of(layer.children)) {
          removeNodeCascade(child.asNodeRef);
        }
        layers.removeWhere((entry) => entry.id == ref.id);
    }
  }

  DuplicatedSubtree duplicateSubtree(
    DocumentNodeRef ref,
    Id Function() nextId,
  ) {
    return switch (ref.kind) {
      DocumentNodeKind.object => _duplicateObject(ref.id, nextId),
      DocumentNodeKind.group => _duplicateGroup(ref.id, nextId),
      DocumentNodeKind.layer => _duplicateLayer(ref.id, nextId),
    };
  }

  DuplicatedSubtree _duplicateObject(Id id, Id Function() nextId) {
    final source = objectById(id);
    if (source == null) {
      throw StateError('No object with id $id');
    }
    final duplicateId = nextId();
    // Clone via the object's own serialization so every kind (incl.
    // future ones) duplicates without this file knowing about it.
    final duplicate =
        EmbroideryObject.fromJson(source.toJson()..['id'] = duplicateId.value);
    return DuplicatedSubtree(
      root: DocumentNodeRef(DocumentNodeKind.object, duplicateId),
      objects: {duplicateId: duplicate},
      objectStates: {duplicateId: objectState(id).copyWith()},
      groups: const {},
    );
  }

  DuplicatedSubtree _duplicateGroup(Id id, Id Function() nextId) {
    final source = groupById(id);
    if (source == null) {
      throw StateError('No group with id $id');
    }
    final newGroupId = nextId();
    final groupCopies = <Id, GroupNode>{};
    final objectCopies = <Id, EmbroideryObject>{};
    final stateCopies = <Id, ObjectNodeState>{};
    List<HierarchyChildRef> copyChildren(List<HierarchyChildRef> children) {
      final copied = <HierarchyChildRef>[];
      for (final child in children) {
        switch (child.kind) {
          case DocumentNodeKind.object:
            final duplicated = _duplicateObject(child.id, nextId);
            objectCopies.addAll(duplicated.objects);
            stateCopies.addAll(duplicated.objectStates);
            copied.add(
                HierarchyChildRef(DocumentNodeKind.object, duplicated.root.id));
          case DocumentNodeKind.group:
            final duplicated = _duplicateGroup(child.id, nextId);
            groupCopies.addAll(duplicated.groups);
            objectCopies.addAll(duplicated.objects);
            stateCopies.addAll(duplicated.objectStates);
            copied.add(
                HierarchyChildRef(DocumentNodeKind.group, duplicated.root.id));
          case DocumentNodeKind.layer:
            break;
        }
      }
      return copied;
    }

    final clone = GroupNode(
      id: newGroupId,
      name: '${source.name} copy',
      visible: source.visible,
      locked: source.locked,
      children: copyChildren(source.children),
    );
    groupCopies[newGroupId] = clone;
    return DuplicatedSubtree(
      root: DocumentNodeRef(DocumentNodeKind.group, newGroupId),
      objects: objectCopies,
      objectStates: stateCopies,
      groups: groupCopies,
    );
  }

  DuplicatedSubtree _duplicateLayer(Id id, Id Function() nextId) {
    final source = layerById(id);
    if (source == null) {
      throw StateError('No layer with id $id');
    }
    final newLayerId = nextId();
    final groupCopies = <Id, GroupNode>{};
    final objectCopies = <Id, EmbroideryObject>{};
    final stateCopies = <Id, ObjectNodeState>{};
    final copiedChildren = <HierarchyChildRef>[];
    for (final child in source.children) {
      final duplicated = duplicateSubtree(child.asNodeRef, nextId);
      groupCopies.addAll(duplicated.groups);
      objectCopies.addAll(duplicated.objects);
      stateCopies.addAll(duplicated.objectStates);
      copiedChildren
          .add(HierarchyChildRef(duplicated.root.kind, duplicated.root.id));
    }
    final layer = LayerNode(
      id: newLayerId,
      name: '${source.name} copy',
      visible: source.visible,
      locked: source.locked,
      children: copiedChildren,
    );
    return DuplicatedSubtree(
      root: DocumentNodeRef(DocumentNodeKind.layer, newLayerId),
      layer: layer,
      objects: objectCopies,
      objectStates: stateCopies,
      groups: groupCopies,
    );
  }

  g.Bounds? selectionBounds(Iterable<DocumentNodeRef> refs) {
    g.Bounds? bounds;
    for (final ref in refs) {
      for (final objectId in subtreeObjectIds(ref).toSet()) {
        final object = objectById(objectId);
        if (object == null || !isObjectVisible(objectId)) continue;
        bounds =
            bounds == null ? object.bounds() : bounds.union(object.bounds());
      }
    }
    return bounds;
  }
}
