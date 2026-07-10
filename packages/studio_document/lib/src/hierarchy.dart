import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import 'guide.dart';

enum DocumentNodeKind { object, group, layer }

final class DocumentNodeRef {
  const DocumentNodeRef(this.kind, this.id);

  final DocumentNodeKind kind;
  final Id id;

  @override
  bool operator ==(Object other) =>
      other is DocumentNodeRef && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

final class HierarchyChildRef {
  const HierarchyChildRef(this.kind, this.id)
      : assert(kind != DocumentNodeKind.layer);

  final DocumentNodeKind kind;
  final Id id;

  DocumentNodeRef get asNodeRef => DocumentNodeRef(kind, id);

  HierarchyChildRef copyWith({DocumentNodeKind? kind, Id? id}) =>
      HierarchyChildRef(kind ?? this.kind, id ?? this.id);

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'id': id.value,
      };

  static HierarchyChildRef fromJson(Map<String, dynamic> json) =>
      HierarchyChildRef(
        DocumentNodeKind.values.byName(json['kind'] as String),
        Id(json['id'] as String),
      );
}

final class HierarchyParentRef {
  const HierarchyParentRef(this.kind, this.id)
      : assert(kind != DocumentNodeKind.object);

  final DocumentNodeKind kind;
  final Id id;

  DocumentNodeRef get asNodeRef => DocumentNodeRef(kind, id);

  @override
  bool operator ==(Object other) =>
      other is HierarchyParentRef && other.kind == kind && other.id == id;

  @override
  int get hashCode => Object.hash(kind, id);
}

final class ObjectNodeState {
  const ObjectNodeState({this.visible = true, this.locked = false});

  final bool visible;
  final bool locked;

  ObjectNodeState copyWith({bool? visible, bool? locked}) => ObjectNodeState(
        visible: visible ?? this.visible,
        locked: locked ?? this.locked,
      );

  Map<String, dynamic> toJson() => {
        'visible': visible,
        'locked': locked,
      };

  static ObjectNodeState fromJson(Map<String, dynamic> json) => ObjectNodeState(
        visible: json['visible'] as bool? ?? true,
        locked: json['locked'] as bool? ?? false,
      );
}

final class LayerNode {
  LayerNode({
    required this.id,
    required this.name,
    this.visible = true,
    this.locked = false,
    List<HierarchyChildRef>? children,
  }) : children = children ?? [];

  final Id id;
  String name;
  bool visible;
  bool locked;
  final List<HierarchyChildRef> children;

  LayerNode clone() => LayerNode(
        id: id,
        name: name,
        visible: visible,
        locked: locked,
        children: [for (final child in children) child.copyWith()],
      );

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'name': name,
        'visible': visible,
        'locked': locked,
        'children': [for (final child in children) child.toJson()],
      };

  static LayerNode fromJson(Map<String, dynamic> json) => LayerNode(
        id: Id(json['id'] as String),
        name: json['name'] as String,
        visible: json['visible'] as bool? ?? true,
        locked: json['locked'] as bool? ?? false,
        children: [
          for (final child in (json['children'] as List?) ?? const [])
            HierarchyChildRef.fromJson(child as Map<String, dynamic>)
        ],
      );
}

final class GroupNode {
  GroupNode({
    required this.id,
    required this.name,
    this.visible = true,
    this.locked = false,
    List<HierarchyChildRef>? children,
  }) : children = children ?? [];

  final Id id;
  String name;
  bool visible;
  bool locked;
  final List<HierarchyChildRef> children;

  GroupNode clone() => GroupNode(
        id: id,
        name: name,
        visible: visible,
        locked: locked,
        children: [for (final child in children) child.copyWith()],
      );

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'name': name,
        'visible': visible,
        'locked': locked,
        'children': [for (final child in children) child.toJson()],
      };

  static GroupNode fromJson(Map<String, dynamic> json) => GroupNode(
        id: Id(json['id'] as String),
        name: json['name'] as String,
        visible: json['visible'] as bool? ?? true,
        locked: json['locked'] as bool? ?? false,
        children: [
          for (final child in (json['children'] as List?) ?? const [])
            HierarchyChildRef.fromJson(child as Map<String, dynamic>)
        ],
      );
}

final class DocumentSnapshot {
  DocumentSnapshot({
    required this.name,
    required this.revision,
    required this.objects,
    required this.objectStates,
    required this.layers,
    required this.groups,
    required this.guides,
  });

  final String name;
  final int revision;
  final Map<Id, EmbroideryObject> objects;
  final Map<Id, ObjectNodeState> objectStates;
  final List<LayerNode> layers;
  final Map<Id, GroupNode> groups;
  final List<Guide> guides;
}

final class DuplicatedSubtree {
  DuplicatedSubtree({
    required this.root,
    required this.objects,
    required this.objectStates,
    required this.groups,
    this.layer,
  });

  final DocumentNodeRef root;
  final LayerNode? layer;
  final Map<Id, EmbroideryObject> objects;
  final Map<Id, ObjectNodeState> objectStates;
  final Map<Id, GroupNode> groups;
}
