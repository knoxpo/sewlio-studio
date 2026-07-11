import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import 'tool_options.dart';
import 'toolbox.dart';
import 'workspace_view_model.dart';

/// The six canvas-edge hotspots a floating palette can dock on.
const paletteSnapAlignments = <Alignment>[
  Alignment.topLeft,
  Alignment.topRight,
  Alignment.centerLeft,
  Alignment.centerRight,
  Alignment.bottomLeft,
  Alignment.bottomRight,
];

/// Hosts a floating tool palette inside the canvas cell (it can never
/// cover rulers, toolbars, or panels). The palette drags by its grip,
/// clamps to the canvas, and snaps to the six edge hotspots — drop
/// zones appear while dragging, the candidate highlighted. Dragging a
/// docked palette pulls it back out.
class PaletteDock extends StatefulWidget {
  const PaletteDock({
    super.key,
    required this.model,
    required this.id,
    required this.paletteKey,
    required this.gripKey,
    required this.child,
  });

  final WorkspaceViewModel model;
  final String id;
  final Key paletteKey;
  final Key gripKey;

  /// Palette content (the icon grid).
  final Widget child;

  @override
  State<PaletteDock> createState() => _PaletteDockState();
}

class _PaletteDockState extends State<PaletteDock> {
  final _frameKey = GlobalKey();
  Size _canvas = Size.zero;
  Size _palette = const Size(96, 120);
  Offset _position = Offset.zero;

  static const _margin = 8.0;
  static const _snapDistance = 48.0;

  Offset _snapTopLeft(Alignment alignment, Size palette) {
    final w = _canvas.width - palette.width - 2 * _margin;
    final h = _canvas.height - palette.height - 2 * _margin;
    return Offset(
      _margin + (alignment.x + 1) / 2 * (w < 0 ? 0 : w),
      _margin + (alignment.y + 1) / 2 * (h < 0 ? 0 : h),
    );
  }

  Offset _clamp(Offset position) {
    final maxX = _canvas.width - _palette.width - _margin;
    final maxY = _canvas.height - _palette.height - _margin;
    return Offset(
      position.dx.clamp(_margin, maxX < _margin ? _margin : maxX),
      position.dy.clamp(_margin, maxY < _margin ? _margin : maxY),
    );
  }

  void _dragStart() {
    _palette = _frameKey.currentContext?.size ?? _palette;
    final placement = widget.model.palettePlacementFor(widget.id);
    _position = placement.snap != null
        ? _snapTopLeft(placement.snap!, _palette)
        : _clamp(placement.offset);
  }

  void _dragUpdate(Offset delta) {
    _position = _clamp(_position + delta);
    Alignment? candidate;
    var best = _snapDistance;
    for (final alignment in paletteSnapAlignments) {
      final d = (_position - _snapTopLeft(alignment, _palette)).distance;
      if (d < best) {
        best = d;
        candidate = alignment;
      }
    }
    widget.model.updatePaletteDrag(widget.id, _position, candidate);
  }

  /// One hotspot marker: a small rounded box that grows to the
  /// palette's full footprint while it is the snap candidate.
  Widget _dropZone(Alignment alignment, WorkspaceViewModel model) {
    final active = alignment == model.paletteSnapCandidate;
    const compact = Size(26, 26);
    final size = active ? _palette : compact;
    final topLeft = _snapTopLeft(alignment, size);
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      left: topLeft.dx,
      top: topLeft.dy,
      width: size.width,
      height: size.height,
      child: IgnorePointer(
        child: AnimatedContainer(
          key: active ? const Key('palette-snap-candidate') : null,
          duration: const Duration(milliseconds: 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(active ? 8 : 6),
            border: Border.all(
              color: active
                  ? AppTokens.primary
                  : AppTokens.textMuted.withValues(alpha: 0.4),
              width: active ? 2 : 1,
            ),
            color: active
                ? AppTokens.primary.withValues(alpha: 0.10)
                : AppTokens.surfaceHigh.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    // Keep the measured palette size in sync (heights vary by content);
    // snapped placements on the right/bottom depend on it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = _frameKey.currentContext?.size;
      if (mounted && size != null && size != _palette) {
        setState(() => _palette = size);
      }
    });
    return LayoutBuilder(builder: (context, constraints) {
      _canvas = constraints.biggest;
      final placement = model.palettePlacementFor(widget.id);
      // One constant Positioned parent for both snapped and free
      // states: swapping Align/Positioned would reparent the
      // GlobalKey'd subtree during layout and crash.
      final topLeft = placement.snap != null
          ? _snapTopLeft(placement.snap!, _palette)
          : _clamp(placement.offset);
      return Stack(children: [
        // Drop zones while dragging: compact markers on each hotspot;
        // the snap candidate expands to the palette's footprint.
        if (model.paletteDragging)
          for (final alignment in paletteSnapAlignments)
            _dropZone(alignment, model),
        Positioned(
          left: topLeft.dx,
          top: topLeft.dy,
          child: _PaletteFrame(
            frameKey: _frameKey,
            paletteKey: widget.paletteKey,
            gripKey: widget.gripKey,
            onDragStart: _dragStart,
            onDragUpdate: _dragUpdate,
            onDragEnd: () => model.endPaletteDrag(widget.id),
            child: widget.child,
          ),
        ),
      ]);
    });
  }
}

/// Palette chrome: popover surface, grip bar, icon content below.
class _PaletteFrame extends StatelessWidget {
  const _PaletteFrame({
    required this.frameKey,
    required this.paletteKey,
    required this.gripKey,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.child,
  });

  final GlobalKey frameKey;
  final Key paletteKey;
  final Key gripKey;
  final VoidCallback onDragStart;
  final void Function(Offset delta) onDragUpdate;
  final VoidCallback onDragEnd;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: paletteKey,
      width: 96,
      decoration: BoxDecoration(
        color: AppTokens.popoverSurface,
        border: Border.all(color: AppTokens.popoverBorder),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Column(key: frameKey, mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
          key: gripKey,
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) => onDragStart(),
          onPanUpdate: (details) => onDragUpdate(details.delta),
          onPanEnd: (_) => onDragEnd(),
          onPanCancel: onDragEnd,
          child: SizedBox(
            height: 18,
            width: double.infinity,
            child: Center(
              child: Container(
                width: 26,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTokens.surfaceHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(6, 0, 6, 8), child: child),
      ]),
    );
  }
}

/// Shape palette content: icon-only grid of all shapes.
class ShapePaletteGrid extends StatelessWidget {
  const ShapePaletteGrid({super.key, required this.model});

  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        for (final kind in ShapeKind.values)
          StudioIconButton(
            key: Key('shape-${kind.name}'),
            icon: shapeIcon(kind),
            tooltip: shapeLabel(kind),
            active: kind == model.shapeTool.kind,
            onPressed: () => model.activateShape(kind),
          ),
      ],
    );
  }
}

/// Multi-tool group palette content; future tools render dimmed.
class ToolGroupPaletteGrid extends StatelessWidget {
  const ToolGroupPaletteGrid(
      {super.key, required this.model, required this.group});

  final WorkspaceViewModel model;
  final ToolboxGroup group;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        for (final tool in group.tools)
          StudioIconButton(
            key: Key('palette-tool-${tool.label}'),
            icon: tool.icon,
            tooltip: tool.kind == null
                ? '${tool.tooltip} — coming soon'
                : tool.tooltip,
            active: tool.kind != null && tool.kind == model.activeKind,
            onPressed: tool.kind == null
                ? null
                : () {
                    model.toolGroupMemory[group.id] = tool.kind!;
                    model.selectTool(tool.kind!);
                  },
          ),
      ],
    );
  }
}
