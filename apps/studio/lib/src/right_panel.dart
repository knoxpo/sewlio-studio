import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_tools/studio_tools.dart';

import 'font_library.dart';
import 'object_panel.dart';

class StitchListPanel extends StatefulWidget {
  const StitchListPanel({
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
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    this.stitchHighlight,
    this.onHighlightGlyph,
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
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  /// Glyph-inspection highlight (Stitches tab): the highlighted text
  /// object's outline range, and the callback that sets/clears it.
  /// View state only — glyph rows never mutate the document.
  final ({Id id, int start, int end})? stitchHighlight;
  final void Function(({Id id, int start, int end})? highlight)?
      onHighlightGlyph;

  @override
  State<StitchListPanel> createState() => _StitchListPanelState();
}

enum _RightPanelTab { stitches, layers, properties }

class _StitchListPanelState extends State<StitchListPanel> {
  var _tab = _RightPanelTab.stitches;
  final _expanded = <Id>{};

  /// Text objects with their per-glyph stitch rows expanded.
  final _expandedGlyphs = <Id>{};

  bool get _toggle =>
      HardwareKeyboard.instance.isMetaPressed ||
      HardwareKeyboard.instance.isControlPressed;

  bool get _extend => HardwareKeyboard.instance.isShiftPressed;

  int? _count(EmbroideryObject object) {
    try {
      return generateStitches(object).length;
    } on UnimplementedError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleObjects = widget.document.flattenVisibleObjects();
    final counts = [for (final o in visibleObjects) (o, _count(o))];
    final total = counts.fold<int>(0, (sum, entry) => sum + (entry.$2 ?? 0));
    return StudioPanel(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTokens.background,
              border: Border(bottom: BorderSide(color: AppTokens.border)),
            ),
            child: Row(
              children: [
                _tabButton(_RightPanelTab.stitches, 'Stitches'),
                _tabButton(_RightPanelTab.layers, 'Layers'),
                _tabButton(_RightPanelTab.properties, 'Properties'),
              ],
            ),
          ),
          Expanded(child: _body(counts, total)),
        ],
      ),
    );
  }

  static final _headerStyle =
      TextStyle(color: AppTokens.textMuted, fontSize: 10);

  Widget _body(List<(EmbroideryObject, int?)> counts, int total) {
    return switch (_tab) {
      _RightPanelTab.stitches => _buildStitches(counts, total),
      _RightPanelTab.layers => _buildLayers(),
      _RightPanelTab.properties => ObjectPropertiesPanel(
          document: widget.document,
          selectedRefs: widget.selectedRefs,
          primarySelection: widget.primarySelection,
          onCommand: widget.onCommand,
          canUndo: widget.canUndo,
          canRedo: widget.canRedo,
          onUndo: widget.onUndo,
          onRedo: widget.onRedo,
          framed: false,
        ),
    };
  }

  Widget _buildStitches(List<(EmbroideryObject, int?)> counts, int total) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              SizedBox(width: 20, child: Text('#', style: _headerStyle)),
              SizedBox(width: 28, child: Text('Color', style: _headerStyle)),
              Expanded(child: Text('Stitch Type', style: _headerStyle)),
              Text('Stitches', style: _headerStyle),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(children: [
            for (final (index, (object, count)) in counts.indexed) ...[
              _stitchObjectRow(index, object, count),
              if (object is TextObject && _expandedGlyphs.contains(object.id))
                _glyphRows(object),
            ],
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTokens.background,
            border: Border(top: BorderSide(color: AppTokens.border)),
          ),
          child: Text('Total Stitches: $total',
              style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _stitchObjectRow(int index, EmbroideryObject object, int? count) {
    final ref = DocumentNodeRef(DocumentNodeKind.object, object.id);
    final selected = widget.selectedRefs.contains(ref);
    final expandable = object is TextObject;
    final expanded = expandable && _expandedGlyphs.contains(object.id);
    return InkWell(
      onTap: () => widget.onSelect(ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTokens.surfaceHigh : null,
          border: selected ? Border.all(color: AppTokens.primary) : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            SizedBox(
                width: 20,
                child: Text('${index + 1}',
                    style:
                        TextStyle(color: AppTokens.textMuted, fontSize: 10))),
            SizedBox(
              width: 28,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTokens.accentGreen,
                  border: Border.all(color: AppTokens.border),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Text(
                switch (object) {
                  RunningStitchObject() => 'Running Stitch',
                  SatinObject() => 'Satin Stitch',
                  FillObject() => 'Fill Stitch',
                  TextObject(:final text) => 'Text "$text"',
                },
                style: TextStyle(
                  color: selected ? AppTokens.primary : AppTokens.textPrimary,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(count?.toString() ?? '—',
                style: TextStyle(color: AppTokens.textMuted, fontSize: 12)),
            if (expandable)
              InkWell(
                key: Key('glyphs-expand-${object.id.value}'),
                onTap: () => setState(() {
                  expanded
                      ? _expandedGlyphs.remove(object.id)
                      : _expandedGlyphs.add(object.id);
                }),
                child: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 14,
                  color: AppTokens.textMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Per-glyph inspection rows for an expanded text object: derived by
  /// partitioning the object's cached outlines with the same layout the
  /// text tool used, so they always match the generated stitches. The
  /// document keeps ONE editable text object — these rows only drive
  /// the canvas highlight.
  Widget _glyphRows(TextObject object) {
    return FutureBuilder<TextFont>(
      future: FontLibrary.instance.load(object.fontFamily),
      builder: (context, snapshot) {
        final font = snapshot.data;
        if (font == null) return const SizedBox.shrink();
        final groups = glyphOutlineGroups(
          object.text,
          font,
          sizeMm: object.sizeMm,
          trackingMm: object.trackingMm,
          frameWidthMm: object.frameWidthMm,
        );
        final rows = <Widget>[];
        var start = 0;
        for (final group in groups) {
          final end = start + group.outlineCount;
          if (group.outlineCount > 0 && end <= object.outlines.length) {
            rows.add(_glyphRow(object, group, start, end));
          }
          start = end;
        }
        return Column(children: rows);
      },
    );
  }

  Widget _glyphRow(TextObject object, GlyphGroup group, int start, int end) {
    final highlight = (id: object.id, start: start, end: end);
    final active = widget.stitchHighlight == highlight;
    final stitchCount = [
      for (final outline in object.outlines.sublist(start, end))
        generateRunningStitch(outline, stitchLength: object.stitchLength)
            .length,
    ].fold<int>(0, (a, b) => a + b);
    return InkWell(
      key: Key('glyph-${object.id.value}-${group.index}'),
      // Toggle: tapping the highlighted glyph clears the highlight.
      onTap: () => widget.onHighlightGlyph?.call(active ? null : highlight),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: active
            ? AppTokens.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        child: Row(
          children: [
            const SizedBox(width: 20),
            SizedBox(
                width: 28,
                child: Text('${group.index + 1}',
                    style:
                        TextStyle(color: AppTokens.textMuted, fontSize: 10))),
            Expanded(
              child: Text(
                'Glyph "${group.char}" · ${end - start} part(s)',
                style: TextStyle(
                  color: active ? AppTokens.primary : AppTokens.textMuted,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text('$stitchCount',
                style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildLayers() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Row(
            children: [
              StudioIconButton(
                icon: Icons.layers_outlined,
                tooltip: 'Add layer',
                onPressed: widget.onCreateLayer,
              ),
              StudioIconButton(
                icon: Icons.folder_open,
                tooltip: 'Group selection',
                onPressed:
                    widget.selectedRefs.isEmpty ? null : widget.onCreateGroup,
              ),
              StudioIconButton(
                icon: Icons.folder_off_outlined,
                tooltip: 'Ungroup',
                onPressed:
                    widget.primarySelection?.kind == DocumentNodeKind.group
                        ? widget.onUngroup
                        : null,
              ),
              StudioIconButton(
                icon: Icons.copy,
                tooltip: 'Duplicate',
                onPressed:
                    widget.primarySelection == null ? null : widget.onDuplicate,
              ),
              StudioIconButton(
                icon: Icons.delete_outline,
                tooltip: 'Delete',
                onPressed:
                    widget.primarySelection == null ? null : widget.onDelete,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            children: [
              for (final layer in widget.document.layers)
                _layerRow(layer, depth: 0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _layerRow(LayerNode layer, {required int depth}) {
    final ref = DocumentNodeRef(DocumentNodeKind.layer, layer.id);
    final expanded = _expanded.contains(layer.id);
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
          onExpand: canExpand
              ? () => setState(() {
                    if (expanded) {
                      _expanded.remove(layer.id);
                    } else {
                      _expanded.add(layer.id);
                    }
                  })
              : null,
        ),
        if (expanded)
          for (final child in layer.children)
            _childRow(child,
                depth: depth + 1,
                parent: HierarchyParentRef(DocumentNodeKind.layer, layer.id)),
      ],
    );
  }

  Widget _childRow(
    HierarchyChildRef child, {
    required int depth,
    required HierarchyParentRef parent,
  }) {
    return switch (child.kind) {
      DocumentNodeKind.object => _objectRow(
          widget.document.objectById(child.id)!,
          depth: depth,
          parent: parent),
      DocumentNodeKind.group => _groupRow(widget.document.groupById(child.id)!,
          depth: depth, parent: parent),
      DocumentNodeKind.layer => const SizedBox.shrink(),
    };
  }

  Widget _groupRow(
    GroupNode group, {
    required int depth,
    required HierarchyParentRef parent,
  }) {
    final ref = DocumentNodeRef(DocumentNodeKind.group, group.id);
    final expanded = _expanded.contains(group.id);
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
          onExpand: canExpand
              ? () => setState(() {
                    if (expanded) {
                      _expanded.remove(group.id);
                    } else {
                      _expanded.add(group.id);
                    }
                  })
              : null,
        ),
        if (expanded)
          for (final child in group.children)
            _childRow(child,
                depth: depth + 1,
                parent: HierarchyParentRef(DocumentNodeKind.group, group.id)),
      ],
    );
  }

  Widget _objectRow(
    EmbroideryObject object, {
    required int depth,
    required HierarchyParentRef parent,
  }) {
    final ref = DocumentNodeRef(DocumentNodeKind.object, object.id);
    final state = widget.document.objectState(object.id);
    final label = switch (object) {
      RunningStitchObject() => 'Running Stitch',
      SatinObject() => 'Satin Stitch',
      FillObject() => 'Fill Stitch',
      TextObject(:final text) => 'Text "$text"',
    };
    return _treeRow(
      ref: ref,
      depth: depth,
      label: label,
      visible: state.visible,
      locked: state.locked,
      expanded: false,
      canExpand: false,
      onExpand: null,
    );
  }

  Widget _treeRow({
    required DocumentNodeRef ref,
    required int depth,
    required String label,
    required bool visible,
    required bool locked,
    required bool expanded,
    required bool canExpand,
    required VoidCallback? onExpand,
  }) {
    final selected = widget.selectedRefs.contains(ref);
    return DragTarget<DocumentNodeRef>(
      onWillAcceptWithDetails: (details) =>
          details.data != ref &&
          !widget.document.containsNode(details.data, ref),
      onAcceptWithDetails: (details) {
        final dragged = details.data;
        if (ref.kind == DocumentNodeKind.layer) {
          widget.onMoveNode(
            dragged,
            parent: dragged.kind == DocumentNodeKind.layer
                ? null
                : HierarchyParentRef(DocumentNodeKind.layer, ref.id),
            index: dragged.kind == DocumentNodeKind.layer
                ? widget.document.indexOfLayer(ref.id) + 1
                : null,
          );
          return;
        }
        if (ref.kind == DocumentNodeKind.group) {
          widget.onMoveNode(
            dragged,
            parent: HierarchyParentRef(DocumentNodeKind.group, ref.id),
          );
          return;
        }
        final parent = widget.document.parentOf(ref);
        if (parent == null) return;
        final index = widget.document.indexOfChild(parent, ref);
        widget.onMoveNode(dragged, parent: parent, index: index + 1);
      },
      builder: (context, _, __) {
        return LongPressDraggable<DocumentNodeRef>(
          data: ref,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: AppTokens.surfaceHigh,
              child: Text(label),
            ),
          ),
          child: InkWell(
            onTap: () => widget.onSelect(ref, toggle: _toggle, extend: _extend),
            child: Container(
              padding: EdgeInsets.only(
                  left: 8.0 + depth * 16, right: 6, top: 4, bottom: 4),
              decoration: BoxDecoration(
                color: selected ? AppTokens.surfaceHigh : null,
                border: selected ? Border.all(color: AppTokens.primary) : null,
                borderRadius: BorderRadius.circular(4),
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
                  Icon(
                    switch (ref.kind) {
                      DocumentNodeKind.layer => Icons.layers_outlined,
                      DocumentNodeKind.group => Icons.folder_open,
                      DocumentNodeKind.object => Icons.polyline,
                    },
                    size: 14,
                    color: selected ? AppTokens.primary : AppTokens.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? AppTokens.primary
                            : AppTokens.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  InkWell(
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
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => widget.onCommand(SetNodeLocked(ref, !locked)),
                    child: Icon(
                      locked ? Icons.lock_outline : Icons.lock_open_outlined,
                      size: 14,
                      color: AppTokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabButton(_RightPanelTab tab, String label) {
    final active = _tab == tab;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppTokens.surfaceHigh : null,
            border: Border(
              bottom: BorderSide(
                color: active ? AppTokens.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? AppTokens.primary : AppTokens.textMuted,
              fontWeight: active ? FontWeight.w500 : FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
