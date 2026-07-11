import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import 'context_menu.dart';
import 'object_visuals.dart';

/// Where a dragged node lands relative to the hovered row.
enum _DropZone { before, after, into }

/// Layers panel: document hierarchy tree with selection, visibility,
/// lock, drag-drop rearrange, and inline rename (double-click / F2 /
/// context menu). Stateless-props; hosted by the dock via the registry.
class LayersPanelContent extends StatefulWidget {
  const LayersPanelContent({
    super.key,
    required this.document,
    required this.selectedRefs,
    required this.primarySelection,
    required this.onSelect,
    required this.onCommand,
    required this.onCreateLayer,
    required this.onCreateGroup,
    required this.onUngroup,
    required this.onDelete,
    required this.onDuplicate,
    required this.onMoveNode,
  });

  final Document document;
  final List<DocumentNodeRef> selectedRefs;
  final DocumentNodeRef? primarySelection;
  final void Function(DocumentNodeRef? ref, {bool toggle, bool extend})
      onSelect;
  final void Function(Command command) onCommand;
  final VoidCallback onCreateLayer;
  final VoidCallback onCreateGroup;
  final VoidCallback onUngroup;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final void Function(DocumentNodeRef ref,
      {HierarchyParentRef? parent, int? index}) onMoveNode;

  @override
  State<LayersPanelContent> createState() => _LayersPanelContentState();
}

class _LayersPanelContentState extends State<LayersPanelContent> {
  final _expanded = <Id>{};
  final _focusNode = FocusNode(debugLabel: 'layers-panel');
  final _renameFocus = FocusNode(debugLabel: 'layers-rename');
  final _renameController = TextEditingController();
  final _searchController = TextEditingController();
  var _query = '';

  DocumentNodeRef? _hovered;
  DocumentNodeRef? _renaming;
  DocumentNodeRef? _dropTarget;
  _DropZone? _dropZone;

  /// Ancestors of the current selection, refreshed each build.
  var _ancestors = <Id>{};

  bool get _toggle =>
      HardwareKeyboard.instance.isMetaPressed ||
      HardwareKeyboard.instance.isControlPressed;

  bool get _extend => HardwareKeyboard.instance.isShiftPressed;

  /// Node ids that contain the current selection (every ancestor of
  /// every selected ref) — drives the parent-of-selection indicators.
  Set<Id> _selectionAncestors() {
    final ancestors = <Id>{};
    for (final ref in widget.selectedRefs) {
      var parent = widget.document.parentOf(ref);
      while (parent != null) {
        if (!ancestors.add(parent.id)) break; // shared ancestry: done
        parent =
            widget.document.parentOf(DocumentNodeRef(parent.kind, parent.id));
      }
    }
    return ancestors;
  }

  @override
  void initState() {
    super.initState();
    _revealSelection();
  }

  @override
  void didUpdateWidget(covariant LayersPanelContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-expand collapsed ancestors so the selection is visible —
    // only when the selection changes, so a manual collapse afterwards
    // is respected until the user selects something else.
    if (widget.primarySelection != oldWidget.primarySelection) {
      _revealSelection();
    }
  }

  void _revealSelection() {
    if (widget.primarySelection == null) return;
    _expanded.addAll(_selectionAncestors());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _renameFocus.dispose();
    _renameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- search

  bool get _filtering => _query.isNotEmpty;

  bool _matchText(String label) =>
      _filtering && label.toLowerCase().contains(_query.toLowerCase());

  /// Design-object label (ADR-036): the user's name, else the design
  /// origin — never the stitch kind (that vocabulary belongs to the
  /// Stitches panel).
  static String _objectLabel(EmbroideryObject object) =>
      object.name ?? (object is TextObject ? '<Text>' : '<Path>');

  /// Whether any node in this subtree matches the search query.
  bool _childMatches(HierarchyChildRef child) {
    switch (child.kind) {
      case DocumentNodeKind.object:
        final object = widget.document.objectById(child.id);
        return object != null && _matchText(_objectLabel(object));
      case DocumentNodeKind.group:
        final group = widget.document.groupById(child.id);
        if (group == null) return false;
        return _matchText(group.name) || group.children.any(_childMatches);
      case DocumentNodeKind.layer:
        return false;
    }
  }

  // -------------------------------------------------- expand / navigate

  Set<Id> _allContainerIds() {
    final ids = <Id>{};
    void walkChildren(List<HierarchyChildRef> children) {
      for (final child in children) {
        if (child.kind != DocumentNodeKind.group) continue;
        final group = widget.document.groupById(child.id);
        if (group == null) continue;
        ids.add(group.id);
        walkChildren(group.children);
      }
    }

    for (final layer in widget.document.layers) {
      ids.add(layer.id);
      walkChildren(layer.children);
    }
    return ids;
  }

  void _selectParent() {
    final primary = widget.primarySelection;
    if (primary == null) return;
    final parent = widget.document.parentOf(primary);
    if (parent == null) return;
    widget.onSelect(DocumentNodeRef(parent.kind, parent.id));
  }

  // ------------------------------------------------------------- rename

  bool _canRename(DocumentNodeRef ref) => true;

  String? _nameOf(DocumentNodeRef ref) => switch (ref.kind) {
        DocumentNodeKind.layer => widget.document.layerById(ref.id)?.name,
        DocumentNodeKind.group => widget.document.groupById(ref.id)?.name,
        DocumentNodeKind.object => switch (widget.document.objectById(ref.id)) {
            final o? => _objectLabel(o),
            _ => null,
          },
      };

  void _startRename(DocumentNodeRef ref) {
    if (!_canRename(ref)) return;
    final name = _nameOf(ref);
    if (name == null) return;
    setState(() {
      _renaming = ref;
      _renameController
        ..text = name
        ..selection = TextSelection(baseOffset: 0, extentOffset: name.length);
    });
    // autofocus loses when the panel's focus node already holds focus —
    // claim it explicitly once the field is mounted, so typed characters
    // land in the field (and shortcut handlers see a text field focused).
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _renameFocus.requestFocus());
  }

  void _commitRename() {
    final ref = _renaming;
    if (ref == null) return;
    final name = _renameController.text.trim();
    if (name.isNotEmpty && name != _nameOf(ref)) {
      switch (ref.kind) {
        case DocumentNodeKind.layer:
          widget.onCommand(RenameLayer(ref.id, name));
        case DocumentNodeKind.group:
          widget.onCommand(RenameGroup(ref.id, name));
        case DocumentNodeKind.object:
          // ADR-036: rename = replace with a named copy (undoable).
          final object = widget.document.objectById(ref.id);
          if (object != null) {
            widget.onCommand(ReplaceObject(object.withName(name)));
          }
      }
    }
    setState(() => _renaming = null);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.f2) {
      final primary = widget.primarySelection;
      if (primary != null && _canRename(primary)) {
        _startRename(primary);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// (visible, locked) of any node kind.
  (bool, bool) _stateOf(DocumentNodeRef ref) => switch (ref.kind) {
        DocumentNodeKind.layer => switch (widget.document.layerById(ref.id)) {
            final l? => (l.visible, l.locked),
            _ => (true, false),
          },
        DocumentNodeKind.group => switch (widget.document.groupById(ref.id)) {
            final g? => (g.visible, g.locked),
            _ => (true, false),
          },
        DocumentNodeKind.object => switch (
              widget.document.objectState(ref.id)) {
            final s => (s.visible, s.locked),
          },
      };

  /// Container children (empty for objects).
  List<HierarchyChildRef> _childrenOf(DocumentNodeRef ref) =>
      switch (ref.kind) {
        DocumentNodeKind.layer =>
          widget.document.layerById(ref.id)?.children ?? const [],
        DocumentNodeKind.group =>
          widget.document.groupById(ref.id)?.children ?? const [],
        DocumentNodeKind.object => const [],
      };

  Future<void> _showContextMenu(
      DocumentNodeRef ref, Offset globalPosition) async {
    final (visible, locked) = _stateOf(ref);
    final hasChildren = _childrenOf(ref).isNotEmpty;
    final isExpanded = _expanded.contains(ref.id);
    final hasParent = widget.document.parentOf(ref) != null;
    final action = await showStudioMenu<String>(
      context: context,
      position: globalPosition,
      entries: [
        StudioMenuEntry('Rename', 'rename',
            icon: Icons.drive_file_rename_outline),
        StudioMenuEntry('Duplicate', 'duplicate', icon: Icons.copy),
        StudioMenuEntry('Delete', 'delete', icon: Icons.delete_outline),
        const StudioMenuEntry.divider(),
        StudioMenuEntry('Group Selection', 'group',
            icon: Icons.folder_open, enabled: widget.selectedRefs.isNotEmpty),
        StudioMenuEntry('Ungroup', 'ungroup',
            icon: Icons.folder_off_outlined,
            enabled: ref.kind == DocumentNodeKind.group),
        StudioMenuEntry('Move to Layer…', 'movetolayer',
            icon: Icons.drive_file_move_outline,
            enabled: ref.kind != DocumentNodeKind.layer),
        const StudioMenuEntry.divider(),
        StudioMenuEntry(isExpanded ? 'Collapse' : 'Expand', 'expand',
            icon: isExpanded ? Icons.unfold_less : Icons.unfold_more,
            enabled: hasChildren),
        StudioMenuEntry('Select Parent', 'parent',
            icon: Icons.north_east, enabled: hasParent),
        const StudioMenuEntry.divider(),
        StudioMenuEntry(locked ? 'Unlock' : 'Lock', 'lock',
            icon: locked ? Icons.lock_open_outlined : Icons.lock_outline),
        StudioMenuEntry(visible ? 'Hide' : 'Show', 'hide',
            icon: visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
      ],
    );
    switch (action) {
      case 'rename':
        _startRename(ref);
      case 'duplicate':
        widget.onDuplicate();
      case 'delete':
        widget.onDelete();
      case 'group':
        widget.onCreateGroup();
      case 'ungroup':
        widget.onUngroup();
      case 'movetolayer':
        await _showMoveToLayerMenu(ref, globalPosition);
      case 'expand':
        _toggleExpanded(ref.id);
      case 'parent':
        _selectParent();
      case 'lock':
        widget.onCommand(SetNodeLocked(ref, !locked));
      case 'hide':
        widget.onCommand(SetNodeVisible(ref, !visible));
    }
  }

  /// Second-level picker for Move to Layer: lists every layer; picking
  /// one reparents the node there (appended at the end).
  Future<void> _showMoveToLayerMenu(
      DocumentNodeRef ref, Offset globalPosition) async {
    if (!mounted) return;
    final target = await showStudioMenu<Id>(
      context: context,
      position: globalPosition,
      entries: [
        for (final layer in widget.document.layers)
          StudioMenuEntry(layer.name, layer.id, icon: Icons.layers_outlined),
      ],
    );
    if (target == null) return;
    widget.onMoveNode(ref,
        parent: HierarchyParentRef(DocumentNodeKind.layer, target));
  }

  // -------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    _ancestors = _selectionAncestors();
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Column(
        children: [
          _searchBar(),
          Expanded(
            child: ListView(
              children: [
                for (final layer in widget.document.layers)
                  _layerRow(layer, depth: 0),
              ],
            ),
          ),
          _bottomToolbar(),
        ],
      ),
    );
  }

  /// Real-time hierarchy filter (Illustrator-style Search All).
  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      child: SizedBox(
        height: 24,
        child: TextField(
          key: const Key('layers-search'),
          controller: _searchController,
          onChanged: (value) => setState(() => _query = value.trim()),
          style: TextStyle(color: AppTokens.textPrimary, fontSize: 12),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppTokens.field,
            hintText: 'Search layers',
            hintStyle: TextStyle(color: AppTokens.textMuted, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
            prefixIcon:
                Icon(Icons.search, size: 14, color: AppTokens.textMuted),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 28, minHeight: 24),
            suffixIcon: _query.isEmpty
                ? null
                : InkWell(
                    key: const Key('layers-search-clear'),
                    onTap: () => setState(() {
                      _searchController.clear();
                      _query = '';
                    }),
                    child:
                        Icon(Icons.close, size: 13, color: AppTokens.textMuted),
                  ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 24, minHeight: 24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  /// Layer operations, Illustrator-style at the panel's bottom edge:
  /// create/structure actions left, tree/navigation middle, destructive
  /// right. Context-aware — irrelevant actions disable.
  Widget _bottomToolbar() {
    final primary = widget.primarySelection;
    final hasParent =
        primary != null && widget.document.parentOf(primary) != null;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: Row(
        children: [
          StudioIconButton(
            icon: Icons.layers_outlined,
            tooltip: 'Add layer',
            size: 15,
            onPressed: widget.onCreateLayer,
          ),
          StudioIconButton(
            icon: Icons.folder_open,
            tooltip: 'Group selection',
            size: 15,
            onPressed:
                widget.selectedRefs.isEmpty ? null : widget.onCreateGroup,
          ),
          StudioIconButton(
            icon: Icons.folder_off_outlined,
            tooltip: 'Ungroup',
            size: 15,
            onPressed: primary?.kind == DocumentNodeKind.group
                ? widget.onUngroup
                : null,
          ),
          const Spacer(),
          StudioIconButton(
            icon: Icons.unfold_more,
            tooltip: 'Expand all',
            size: 15,
            onPressed: () =>
                setState(() => _expanded.addAll(_allContainerIds())),
          ),
          StudioIconButton(
            icon: Icons.unfold_less,
            tooltip: 'Collapse all',
            size: 15,
            onPressed: () => setState(_expanded.clear),
          ),
          StudioIconButton(
            icon: Icons.north_east,
            tooltip: 'Select parent',
            size: 15,
            onPressed: hasParent ? _selectParent : null,
          ),
          const Spacer(),
          StudioIconButton(
            icon: Icons.copy,
            tooltip: 'Duplicate',
            size: 15,
            onPressed: primary == null ? null : widget.onDuplicate,
          ),
          StudioIconButton(
            icon: Icons.delete_outline,
            tooltip: 'Delete',
            size: 15,
            onPressed: primary == null ? null : widget.onDelete,
          ),
        ],
      ),
    );
  }

  Widget _layerRow(LayerNode layer, {required int depth}) {
    final ref = DocumentNodeRef(DocumentNodeKind.layer, layer.id);
    // Search filter: a layer stays visible when it matches or holds a
    // match; matched containers show their whole subtree.
    final selfMatch = _matchText(layer.name);
    final holdsMatch = _filtering && layer.children.any(_childMatches);
    if (_filtering && !selfMatch && !holdsMatch) {
      return const SizedBox.shrink();
    }
    final expanded = _filtering || _expanded.contains(layer.id);
    final canExpand = layer.children.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _treeRow(
          ref: ref,
          depth: depth,
          label: layer.name,
          visible: layer.visible,
          locked: layer.locked,
          expanded: expanded,
          canExpand: canExpand,
          onExpand: canExpand ? () => _toggleExpanded(layer.id) : null,
          thumbObjects: _descendantObjects(layer.children),
          highlighted: selfMatch,
        ),
        if (expanded)
          for (final child in layer.children)
            _childRow(child,
                depth: depth + 1,
                parent: HierarchyParentRef(DocumentNodeKind.layer, layer.id),
                ancestorMatched: selfMatch),
      ],
    );
  }

  /// Every object under a container, depth-first — feeds the composite
  /// layer/group thumbnails.
  List<EmbroideryObject> _descendantObjects(List<HierarchyChildRef> children) {
    final out = <EmbroideryObject>[];
    for (final child in children) {
      switch (child.kind) {
        case DocumentNodeKind.object:
          final object = widget.document.objectById(child.id);
          if (object != null) out.add(object);
        case DocumentNodeKind.group:
          final group = widget.document.groupById(child.id);
          if (group != null) out.addAll(_descendantObjects(group.children));
        case DocumentNodeKind.layer:
          break;
      }
    }
    return out;
  }

  void _toggleExpanded(Id id) {
    setState(() {
      _expanded.contains(id) ? _expanded.remove(id) : _expanded.add(id);
    });
  }

  Widget _childRow(
    HierarchyChildRef child, {
    required int depth,
    required HierarchyParentRef parent,
    bool ancestorMatched = false,
  }) {
    return switch (child.kind) {
      DocumentNodeKind.object => _objectRow(
          widget.document.objectById(child.id)!,
          depth: depth,
          parent: parent,
          ancestorMatched: ancestorMatched),
      DocumentNodeKind.group => _groupRow(widget.document.groupById(child.id)!,
          depth: depth, parent: parent, ancestorMatched: ancestorMatched),
      DocumentNodeKind.layer => const SizedBox.shrink(),
    };
  }

  Widget _groupRow(
    GroupNode group, {
    required int depth,
    required HierarchyParentRef parent,
    bool ancestorMatched = false,
  }) {
    final ref = DocumentNodeRef(DocumentNodeKind.group, group.id);
    final selfMatch = _matchText(group.name);
    final holdsMatch = _filtering && group.children.any(_childMatches);
    if (_filtering && !ancestorMatched && !selfMatch && !holdsMatch) {
      return const SizedBox.shrink();
    }
    final expanded = _filtering || _expanded.contains(group.id);
    final canExpand = group.children.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _treeRow(
          ref: ref,
          depth: depth,
          label: group.name,
          visible: group.visible,
          locked: group.locked,
          expanded: expanded,
          canExpand: canExpand,
          onExpand: canExpand ? () => _toggleExpanded(group.id) : null,
          thumbObjects: _descendantObjects(group.children),
          highlighted: selfMatch,
        ),
        if (expanded)
          for (final child in group.children)
            _childRow(child,
                depth: depth + 1,
                parent: HierarchyParentRef(DocumentNodeKind.group, group.id),
                ancestorMatched: ancestorMatched || selfMatch),
      ],
    );
  }

  Widget _objectRow(
    EmbroideryObject object, {
    required int depth,
    required HierarchyParentRef parent,
    bool ancestorMatched = false,
  }) {
    final ref = DocumentNodeRef(DocumentNodeKind.object, object.id);
    final label = _objectLabel(object);
    final selfMatch = _matchText(label);
    if (_filtering && !ancestorMatched && !selfMatch) {
      return const SizedBox.shrink();
    }
    final state = widget.document.objectState(object.id);
    return _treeRow(
      ref: ref,
      depth: depth,
      label: label,
      visible: state.visible,
      locked: state.locked,
      expanded: false,
      canExpand: false,
      onExpand: null,
      thumbObjects: [object],
      highlighted: selfMatch,
    );
  }

  // ---------------------------------------------------------- drag-drop

  /// Zone from the pointer's vertical position within the row: top
  /// quarter inserts before, bottom quarter after, middle nests into
  /// (containers only — objects and layer-on-layer resolve to after).
  _DropZone _zoneFor(
      DocumentNodeRef target, DocumentNodeRef dragged, double fraction) {
    final canNest = target.kind != DocumentNodeKind.object &&
        dragged.kind != DocumentNodeKind.layer;
    if (fraction < 0.25) return _DropZone.before;
    if (fraction > 0.75 || !canNest) return _DropZone.after;
    return _DropZone.into;
  }

  bool _canDrop(DocumentNodeRef dragged, DocumentNodeRef target) {
    if (dragged == target) return false;
    if (widget.document.containsNode(dragged, target)) return false;
    // Layers are top-level only: they reorder against other layers.
    if (dragged.kind == DocumentNodeKind.layer &&
        target.kind != DocumentNodeKind.layer) {
      return false;
    }
    return true;
  }

  void _acceptDrop(DocumentNodeRef dragged, DocumentNodeRef target) {
    final zone = _dropZone ?? _DropZone.after;
    setState(() {
      _dropTarget = null;
      _dropZone = null;
    });
    if (target.kind == DocumentNodeKind.layer) {
      if (dragged.kind == DocumentNodeKind.layer) {
        final index = widget.document.indexOfLayer(target.id);
        widget.onMoveNode(dragged,
            index: zone == _DropZone.before ? index : index + 1);
      } else {
        // Non-layers can only live inside a layer — any zone nests.
        widget.onMoveNode(dragged,
            parent: HierarchyParentRef(DocumentNodeKind.layer, target.id));
      }
      return;
    }
    if (zone == _DropZone.into && target.kind == DocumentNodeKind.group) {
      widget.onMoveNode(dragged,
          parent: HierarchyParentRef(DocumentNodeKind.group, target.id));
      return;
    }
    final parent = widget.document.parentOf(target);
    if (parent == null) return;
    final index = widget.document.indexOfChild(parent, target);
    widget.onMoveNode(dragged,
        parent: parent, index: zone == _DropZone.before ? index : index + 1);
  }

  // ------------------------------------------------------------ tree row

  Widget _treeRow({
    required DocumentNodeRef ref,
    required int depth,
    required String label,
    required bool visible,
    required bool locked,
    required bool expanded,
    required bool canExpand,
    required VoidCallback? onExpand,
    required List<EmbroideryObject> thumbObjects,
    bool highlighted = false,
  }) {
    final selected = widget.selectedRefs.contains(ref);
    // Parent of the current selection: indicated, not fully selected.
    final holdsSelection = !selected && _ancestors.contains(ref.id);
    final hovered = _hovered == ref;
    final renaming = _renaming == ref;
    final dropHere = _dropTarget == ref ? _dropZone : null;
    BuildContext? rowContext;
    return DragTarget<DocumentNodeRef>(
      onWillAcceptWithDetails: (details) => _canDrop(details.data, ref),
      onMove: (details) {
        final box = rowContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final fraction =
            (box.globalToLocal(details.offset).dy / box.size.height)
                .clamp(0.0, 1.0);
        final zone = _zoneFor(ref, details.data, fraction);
        if (_dropTarget != ref || _dropZone != zone) {
          setState(() {
            _dropTarget = ref;
            _dropZone = zone;
          });
        }
      },
      onLeave: (_) => setState(() {
        _dropTarget = null;
        _dropZone = null;
      }),
      onAcceptWithDetails: (details) => _acceptDrop(details.data, ref),
      builder: (context, _, __) {
        rowContext = context;
        return Draggable<DocumentNodeRef>(
          data: ref,
          // Pointer-anchored so onMove's offset is the pointer position
          // (the before/after/into zone math relies on it).
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: AppTokens.surfaceHigh,
              child: Text(label),
            ),
          ),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = ref),
            onExit: (_) => setState(() {
              if (_hovered == ref) _hovered = null;
            }),
            child: GestureDetector(
              onSecondaryTapDown: (details) {
                // Standard convention: right-click selects first.
                if (!widget.selectedRefs.contains(ref)) {
                  widget.onSelect(ref);
                }
                _showContextMenu(ref, details.globalPosition);
              },
              child: InkWell(
                onTap: () {
                  _focusNode.requestFocus();
                  widget.onSelect(ref, toggle: _toggle, extend: _extend);
                },
                child: Opacity(
                  opacity: visible ? 1 : 0.45,
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 6.0 + depth * 16, right: 6, top: 4, bottom: 4),
                    decoration: BoxDecoration(
                      color: dropHere == _DropZone.into
                          ? AppTokens.primary.withValues(alpha: 0.12)
                          : selected
                              ? AppTokens.surfaceHigh
                              : hovered
                                  ? AppTokens.surfaceHigh.withValues(alpha: 0.5)
                                  : null,
                      // Constant-width borders: selection accent left,
                      // drop-indicator lines top/bottom — no layout shift.
                      border: Border(
                        left: BorderSide(
                          width: 2,
                          color: selected
                              ? AppTokens.primary
                              : holdsSelection
                                  ? AppTokens.primary.withValues(alpha: 0.4)
                                  : Colors.transparent,
                        ),
                        top: BorderSide(
                          width: 2,
                          color: dropHere == _DropZone.before
                              ? AppTokens.primary
                              : Colors.transparent,
                        ),
                        bottom: BorderSide(
                          width: 2,
                          color: dropHere == _DropZone.after
                              ? AppTokens.primary
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          child: canExpand
                              ? InkWell(
                                  onTap: onExpand,
                                  child: Icon(
                                    expanded
                                        ? Icons.expand_more
                                        : Icons.chevron_right,
                                    size: 14,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // Composite geometry preview for every node;
                        // empty containers fall back to their kind icon
                        // inside the same thumbnail frame.
                        NodeThumbnail(
                          objects: thumbObjects,
                          size: 20,
                          emptyIcon: switch (ref.kind) {
                            DocumentNodeKind.layer => Icons.layers_outlined,
                            DocumentNodeKind.group => Icons.folder_open,
                            DocumentNodeKind.object => Icons.polyline,
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: renaming
                              ? _renameField(ref)
                              // Finder-style rename: clicking the label
                              // of the already-selected node edits it —
                              // instant selection, no double-tap delay.
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _focusNode.requestFocus();
                                    if (selected &&
                                        _canRename(ref) &&
                                        widget.selectedRefs.length == 1 &&
                                        !_toggle &&
                                        !_extend) {
                                      _startRename(ref);
                                    } else {
                                      widget.onSelect(ref,
                                          toggle: _toggle, extend: _extend);
                                    }
                                  },
                                  child: Text(
                                    label,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: selected || highlighted
                                          ? AppTokens.primary
                                          : AppTokens.textPrimary,
                                      fontSize: 12,
                                      fontWeight: selected ||
                                              holdsSelection ||
                                              highlighted
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                        ),
                        // Illustrator-style target dot: filled = selected,
                        // ring = contains the selection, faint ring on
                        // hover; clicking it selects the node.
                        SizedBox(
                          width: 14,
                          child: (selected || holdsSelection || hovered)
                              ? Center(
                                  child: InkWell(
                                    onTap: () => widget.onSelect(ref,
                                        toggle: _toggle, extend: _extend),
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: selected
                                            ? AppTokens.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          width: 1.2,
                                          color: selected || holdsSelection
                                              ? AppTokens.primary
                                              : AppTokens.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 4),
                        // Visibility / lock: visible on hover or when in
                        // a non-default state; always laid out so rows
                        // never shift.
                        Opacity(
                          opacity: hovered || !visible ? 1 : 0,
                          child: InkWell(
                            onTap: () =>
                                widget.onCommand(SetNodeVisible(ref, !visible)),
                            child: Icon(
                              visible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 14,
                              color: AppTokens.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Opacity(
                          opacity: hovered || locked ? 1 : 0,
                          child: InkWell(
                            onTap: () =>
                                widget.onCommand(SetNodeLocked(ref, !locked)),
                            child: Icon(
                              locked
                                  ? Icons.lock_outline
                                  : Icons.lock_open_outlined,
                              size: 14,
                              color: locked
                                  ? AppTokens.primary
                                  : AppTokens.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _renameField(DocumentNodeRef ref) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() => _renaming = null);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: _renameFieldBody(ref),
    );
  }

  Widget _renameFieldBody(DocumentNodeRef ref) {
    return SizedBox(
      height: 20,
      child: TextField(
        key: Key('rename-${ref.id.value}'),
        controller: _renameController,
        focusNode: _renameFocus,
        style: TextStyle(color: AppTokens.textPrimary, fontSize: 12),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _commitRename(),
        onTapOutside: (_) => _commitRename(),
        onEditingComplete: _commitRename,
      ),
    );
  }
}
