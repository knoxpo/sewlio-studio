import 'package:flutter/material.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_tools/studio_tools.dart';

import '../font_library.dart';
import 'object_visuals.dart';

/// Stitch Layers panel: the document's stitch layers as a tree, each
/// holding its stitch objects (per-object counts, expandable per-glyph
/// inspection rows for text). Stateless-props; hosted by the dock via
/// the panel registry.
class StitchesPanelContent extends StatefulWidget {
  const StitchesPanelContent({
    super.key,
    required this.document,
    required this.selectedRefs,
    required this.onSelect,
    required this.onMoveNode,
    required this.onCommand,
    this.stitchHighlight,
    this.onHighlightGlyph,
  });

  final Document document;
  final List<DocumentNodeRef> selectedRefs;
  final void Function(DocumentNodeRef? ref, {bool toggle, bool extend})
      onSelect;

  /// Reordering a stitch entry re-orders the object in the hierarchy —
  /// execution order IS document order, so preview/simulation follow.
  final void Function(DocumentNodeRef ref,
      {HierarchyParentRef? parent, int? index}) onMoveNode;

  /// Layer visibility/lock toggles dispatch the same commands the design
  /// Layers panel uses.
  final void Function(Command command) onCommand;

  /// Glyph-inspection highlight: the highlighted text object's outline
  /// range, and the callback that sets/clears it. View state only —
  /// glyph rows never mutate the document.
  final ({Id id, int start, int end})? stitchHighlight;
  final void Function(({Id id, int start, int end})? highlight)?
      onHighlightGlyph;

  @override
  State<StitchesPanelContent> createState() => _StitchesPanelContentState();
}

class _StitchesPanelContentState extends State<StitchesPanelContent> {
  /// Text objects with their per-glyph stitch rows expanded.
  final _expandedGlyphs = <Id>{};

  /// Stitch layers currently collapsed (expanded is the default).
  final _collapsedLayers = <Id>{};

  /// Reorder-drag hover state: the row targeted and which side.
  Id? _dropTarget;
  bool _dropAfter = false;

  static final _headerStyle = TextStyle(
    color: AppTokens.textMuted,
    fontSize: 9.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
  );

  List<StitchOp>? _ops(EmbroideryObject object) {
    try {
      return generateStitches(object);
    } on UnimplementedError {
      return null;
    }
  }

  /// Total thread path length in mm (consecutive stitch distances).
  static double _threadLengthMm(List<StitchOp> ops) {
    var length = 0.0;
    for (var i = 1; i < ops.length; i++) {
      if (ops[i].kind != StitchKind.stitch) continue;
      length += ops[i - 1].position.distanceTo(ops[i].position);
    }
    return length;
  }

  /// Visible objects owned by [layer], in execution (document) order —
  /// recurses through groups. Hidden objects (or those under a hidden
  /// group/layer) drop out: the panel lists only what will stitch.
  List<EmbroideryObject> _layerObjects(LayerNode layer) {
    final ref = DocumentNodeRef(DocumentNodeKind.layer, layer.id);
    return [
      for (final id in widget.document.subtreeObjectIds(ref))
        if (widget.document.isObjectVisible(id))
          if (widget.document.objectById(id) case final object?) object,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final layers = widget.document.layers;
    // Flat (object, ops) list across all layers for the summary and the
    // global execution index (execution order IS document order).
    final allObjects = [for (final l in layers) ..._layerObjects(l)];
    final entries = [for (final o in allObjects) (o, _ops(o))];
    final total = entries.fold<int>(0, (sum, e) => sum + (e.$2?.length ?? 0));
    final threadMm = entries.fold<double>(
        0, (sum, e) => sum + (e.$2 == null ? 0 : _threadLengthMm(e.$2!)));
    final colors = {for (final (o, _) in entries) threadColor(o)}.length;

    final rows = <Widget>[];
    var index = 0;
    for (final layer in layers) {
      final collapsed = _collapsedLayers.contains(layer.id);
      rows.add(_layerRow(layer, collapsed: collapsed));
      if (collapsed) {
        index += _layerObjects(layer).length;
        continue;
      }
      for (final object in _layerObjects(layer)) {
        final ops = _ops(object);
        rows.add(_stitchObjectRow(index, object, ops?.length));
        if (object is TextObject && _expandedGlyphs.contains(object.id)) {
          rows.add(_glyphRows(object));
        }
        index++;
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
          child: Row(
            children: [
              SizedBox(width: 22, child: Text('#', style: _headerStyle)),
              SizedBox(width: 26, child: Text('CLR', style: _headerStyle)),
              Expanded(child: Text('STITCH TYPE', style: _headerStyle)),
              Text('COUNT', style: _headerStyle),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: allObjects.isEmpty ? _emptyState() : ListView(children: rows),
        ),
        _summary(
          objects: entries.length,
          colors: colors,
          stitches: total,
          threadMm: threadMm,
        ),
      ],
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No stitches yet.\nAdd objects to a layer to begin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTokens.textMuted, fontSize: 11.5),
          ),
        ),
      );

  /// Collapsible stitch-layer header: chevron, name, visibility, lock.
  Widget _layerRow(LayerNode layer, {required bool collapsed}) {
    final ref = DocumentNodeRef(DocumentNodeKind.layer, layer.id);
    return InkWell(
      onTap: () => setState(() {
        collapsed
            ? _collapsedLayers.remove(layer.id)
            : _collapsedLayers.add(layer.id);
      }),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
        decoration: BoxDecoration(
          color: AppTokens.background,
          border: Border(bottom: BorderSide(color: AppTokens.border)),
        ),
        child: Row(
          children: [
            Icon(collapsed ? Icons.chevron_right : Icons.expand_more,
                size: 16, color: AppTokens.textMuted),
            const SizedBox(width: 2),
            Expanded(
              child: Text(
                layer.name,
                style: TextStyle(
                  color: AppTokens.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () =>
                  widget.onCommand(SetNodeVisible(ref, !layer.visible)),
              child: Icon(
                layer.visible ? Icons.visibility : Icons.visibility_off,
                size: 15,
                color: AppTokens.textMuted,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () => widget.onCommand(SetNodeLocked(ref, !layer.locked)),
              child: Icon(
                layer.locked ? Icons.lock : Icons.lock_open,
                size: 15,
                color: AppTokens.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Design summary footer: the metrics that matter at a glance, with
  /// the stitch count as the headline figure.
  Widget _summary({
    required int objects,
    required int colors,
    required int stitches,
    required double threadMm,
  }) {
    // ponytail: flat 700 stitches/min estimate — swap for the machine
    // profile's speed when machine profiles land.
    final minutes = stitches / 700;
    final estimate = stitches == 0
        ? '—'
        : '${minutes.floor()}m ${((minutes - minutes.floor()) * 60).round()}s';
    Widget metric(String label, String value, {bool prominent = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(color: AppTokens.textMuted, fontSize: 10.5)),
            ),
            Text(
              value,
              style: TextStyle(
                color: prominent ? AppTokens.textPrimary : AppTokens.textMuted,
                fontSize: prominent ? 13 : 10.5,
                fontWeight: prominent ? FontWeight.w600 : FontWeight.w400,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: AppTokens.background,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: Column(
        children: [
          metric('Stitch Count', '$stitches', prominent: true),
          metric('Objects', '$objects'),
          metric('Colours', '$colors'),
          metric(
              'Thread Length',
              threadMm >= 1000
                  ? '${(threadMm / 1000).toStringAsFixed(1)} m'
                  : '${threadMm.toStringAsFixed(0)} mm'),
          metric('Est. Time', estimate),
        ],
      ),
    );
  }

  /// Reorder drop: place [dragged] before/after [target] in the
  /// hierarchy — execution order follows document order.
  void _acceptReorder(DocumentNodeRef dragged, DocumentNodeRef target) {
    final after = _dropAfter;
    setState(() => _dropTarget = null);
    final parent = widget.document.parentOf(target);
    if (parent == null) return;
    final index = widget.document.indexOfChild(parent, target);
    widget.onMoveNode(dragged,
        parent: parent, index: after ? index + 1 : index);
  }

  Widget _stitchObjectRow(int index, EmbroideryObject object, int? count) {
    final ref = DocumentNodeRef(DocumentNodeKind.object, object.id);
    final selected = widget.selectedRefs.contains(ref);
    final expandable = object is TextObject;
    final expanded = expandable && _expandedGlyphs.contains(object.id);
    final dropHere = _dropTarget == object.id;
    BuildContext? rowContext;
    return DragTarget<DocumentNodeRef>(
      onWillAcceptWithDetails: (details) => details.data != ref,
      onMove: (details) {
        final box = rowContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final after =
            box.globalToLocal(details.offset).dy > box.size.height / 2;
        if (_dropTarget != object.id || _dropAfter != after) {
          setState(() {
            _dropTarget = object.id;
            _dropAfter = after;
          });
        }
      },
      onLeave: (_) => setState(() => _dropTarget = null),
      onAcceptWithDetails: (details) => _acceptReorder(details.data, ref),
      builder: (context, _, __) {
        rowContext = context;
        return Draggable<DocumentNodeRef>(
          data: ref,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: AppTokens.surfaceHigh,
              child: Text('${index + 1}. ${_stitchTypeLabel(object)}',
                  style: TextStyle(color: AppTokens.textPrimary, fontSize: 12)),
            ),
          ),
          child: _rowBody(index, object, count, ref,
              selected: selected,
              expandable: expandable,
              expanded: expanded,
              dropHere: dropHere),
        );
      },
    );
  }

  static String _stitchTypeLabel(EmbroideryObject object) => switch (object) {
        RunningStitchObject() => 'Running Stitch',
        SatinObject() => 'Satin Stitch',
        FillObject() => 'Fill Stitch',
        TextObject() => 'Running Stitch (Text)',
      };

  Widget _rowBody(
    int index,
    EmbroideryObject object,
    int? count,
    DocumentNodeRef ref, {
    required bool selected,
    required bool expandable,
    required bool expanded,
    required bool dropHere,
  }) {
    return InkWell(
      onTap: () => widget.onSelect(ref),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 5, 10, 5),
        decoration: BoxDecoration(
          color: selected ? AppTokens.surfaceHigh : null,
          // Constant-width borders: accent left, reorder lines top/bottom.
          border: Border(
            left: BorderSide(
              width: 2,
              color: selected ? AppTokens.primary : Colors.transparent,
            ),
            top: BorderSide(
              width: 2,
              color: dropHere && !_dropAfter
                  ? AppTokens.primary
                  : Colors.transparent,
            ),
            bottom: BorderSide(
              width: 2,
              color: dropHere && _dropAfter
                  ? AppTokens.primary
                  : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
                width: 22,
                child: Text('${index + 1}',
                    style:
                        TextStyle(color: AppTokens.textMuted, fontSize: 10))),
            SizedBox(width: 26, child: ThreadSwatch(object: object)),
            Expanded(
              child: Text(
                _stitchTypeLabel(object),
                style: TextStyle(
                  color: selected ? AppTokens.primary : AppTokens.textPrimary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(count?.toString() ?? '—',
                style: TextStyle(
                  color: AppTokens.textMuted,
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
            if (expandable) ...[
              const SizedBox(width: 6),
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
            const SizedBox(width: 24),
            SizedBox(
                width: 26,
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
}
