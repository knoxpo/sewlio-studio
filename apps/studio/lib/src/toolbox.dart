import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_design_system/studio_design_system.dart';

import 'flyout.dart';
import 'workspace_view_model.dart';

/// One tool in the toolbox: a real [ToolKind] or a future slot
/// (kind == null → dimmed "soon" entry). Adding a tool = adding a line
/// to [toolboxGroups].
final class ToolboxTool {
  const ToolboxTool(this.kind, this.icon, this.label, {this.shortcut});

  final ToolKind? kind;
  final IconData icon;
  final String label;
  final String? shortcut;

  String get tooltip => shortcut == null ? label : '$label ($shortcut)';
}

/// A toolbar slot: one tool, or a group sharing the slot via flyout.
final class ToolboxGroup {
  const ToolboxGroup(this.id, this.tools);

  final String id;
  final List<ToolboxTool> tools;
}

/// A separator between logical sections.
const _divider = ToolboxGroup('divider', []);

/// The toolbox, Affinity/Illustrator-style. Groups with several tools
/// render as flyout slots that remember the last-used tool.
const toolboxGroups = <ToolboxGroup>[
  // Selection
  ToolboxGroup('move', [
    ToolboxTool(ToolKind.select, TablerIcons.pointer, 'Move', shortcut: 'V'),
  ]),
  ToolboxGroup('node', [
    ToolboxTool(ToolKind.node, TablerIcons.vector, 'Node', shortcut: 'A'),
    ToolboxTool(null, TablerIcons.vector_bezier_2, 'Corner'),
  ]),
  _divider,
  // Document / hoop
  ToolboxGroup('hoop', [
    ToolboxTool(ToolKind.hoop, TablerIcons.frame, 'Hoop', shortcut: 'D'),
  ]),
  _divider,
  // Drawing — one slot per tool (no flyout grouping).
  ToolboxGroup('pen', [
    ToolboxTool(ToolKind.pen, TablerIcons.ballpen, 'Pen', shortcut: 'P'),
  ]),
  ToolboxGroup('pencil', [
    ToolboxTool(ToolKind.pencil, TablerIcons.pencil, 'Pencil', shortcut: 'B'),
  ]),
  ToolboxGroup('contour', [
    ToolboxTool(null, TablerIcons.circle_dashed, 'Contour'),
  ]),
  ToolboxGroup('path-brush', [
    ToolboxTool(null, TablerIcons.brush, 'Path Brush'),
  ]),
  ToolboxGroup('blob-brush', [
    ToolboxTool(null, TablerIcons.paint, 'Vector Blob Brush'),
  ]),
  // Shapes (special-cased: flyout over ShapeKind), Text
  ToolboxGroup('shapes', []),
  ToolboxGroup('text', [
    ToolboxTool(ToolKind.text, TablerIcons.typography, 'Text', shortcut: 'T'),
  ]),
  _divider,
  // Fill & color (arrive with the fill/stroke system)
  ToolboxGroup('color', [
    ToolboxTool(null, TablerIcons.bucket_droplet, 'Fill'),
    ToolboxTool(null, TablerIcons.color_picker, 'Color Picker'),
  ]),
  // Utility
  ToolboxGroup('utility', [
    ToolboxTool(ToolKind.measure, TablerIcons.ruler_2, 'Measure',
        shortcut: 'R'),
    ToolboxTool(null, TablerIcons.crop, 'Vector Crop'),
  ]),
  _divider,
  // Navigation
  ToolboxGroup('navigate', [
    ToolboxTool(ToolKind.pan, TablerIcons.hand_stop, 'View (Pan)',
        shortcut: 'H'),
    ToolboxTool(ToolKind.zoom, TablerIcons.zoom_in, 'Zoom', shortcut: 'Z'),
  ]),
];

/// The tool rail: renders [toolboxGroups] plus the persistent
/// fill/stroke controls at the bottom.
class ToolboxRail extends StatelessWidget {
  const ToolboxRail({super.key, required this.model});

  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(right: BorderSide(color: AppTokens.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                for (final group in toolboxGroups) _slot(group),
              ]),
            ),
          ),
          _FillStrokeChips(model: model),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _slot(ToolboxGroup group) {
    if (group.id == 'divider') return const RailSeparator();
    if (group.id == 'shapes') {
      return ShapeFlyoutButton(
        shapeTool: model.shapeTool,
        active: model.activeKind == ToolKind.shape,
        onActivate: model.activateShape,
      );
    }
    final real = [
      for (final tool in group.tools)
        if (tool.kind != null) tool,
    ];
    // Single tool: plain button; a future tool renders dimmed.
    if (group.tools.length == 1) {
      final tool = group.tools.single;
      return StudioIconButton(
        icon: tool.icon,
        tooltip:
            tool.kind == null ? '${tool.tooltip} — coming soon' : tool.tooltip,
        active: model.activeKind == tool.kind,
        onPressed:
            tool.kind == null ? null : () => model.selectTool(tool.kind!),
      );
    }
    // Group slot: shows the group's current tool (active or last used).
    final remembered = model.toolGroupMemory[group.id];
    final current = group.tools.firstWhere(
      (t) => t.kind == model.activeKind,
      orElse: () => group.tools.firstWhere(
        (t) => remembered != null && t.kind == remembered,
        orElse: () => group.tools.first,
      ),
    );
    final groupActive = real.any((tool) => tool.kind == model.activeKind);
    return ToolFlyoutSlot(
      icon: current.icon,
      tooltip: current.tooltip,
      active: groupActive,
      onActivate: real.isEmpty
          ? () {}
          : () =>
              _pick(group, model.toolGroupMemory[group.id] ?? real.first.kind!),
      entries: [
        for (final tool in group.tools)
          FlyoutEntry(
            icon: tool.icon,
            label: tool.tooltip,
            selected: tool.kind != null && tool.kind == model.activeKind,
            onPick: tool.kind == null ? null : () => _pick(group, tool.kind!),
          ),
      ],
    );
  }

  void _pick(ToolboxGroup group, ToolKind kind) {
    model.toolGroupMemory[group.id] = kind;
    model.selectTool(kind);
  }
}

/// Persistent fill/stroke swatches (Illustrator-style): tap a chip to
/// pick its color, swap, or reset to defaults.
// ponytail: the colors are stored as upcoming defaults — objects gain
// fill/stroke when the color system lands; the control is wired so
// that system drops in without UI changes.
class _FillStrokeChips extends StatelessWidget {
  const _FillStrokeChips({required this.model});

  final WorkspaceViewModel model;

  Color _color(String hex) =>
      Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

  Future<void> _edit(BuildContext context, {required bool stroke}) async {
    model.strokeChipActive = stroke;
    model.notify();
    final hex = await showStudioColorPicker(
      context: context,
      initialHex: stroke ? model.strokeColorHex : model.fillColorHex,
    );
    if (hex == null) return;
    stroke ? model.setStrokeColor(hex) : model.setFillColor(hex);
  }

  @override
  Widget build(BuildContext context) {
    final active = model.strokeChipActive;
    return Column(children: [
      SizedBox(
        width: 34,
        height: 34,
        child: Stack(children: [
          // Stroke chip (hollow), bottom-right.
          Positioned(
            right: 0,
            bottom: 0,
            child: InkWell(
              key: const Key('stroke-chip'),
              onTap: () => _edit(context, stroke: true),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: active ? AppTokens.primary : AppTokens.border,
                      width: active ? 2 : 1),
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: _color(model.strokeColorHex), width: 3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Fill chip, top-left, above the stroke chip.
          Positioned(
            left: 0,
            top: 0,
            child: InkWell(
              key: const Key('fill-chip'),
              onTap: () => _edit(context, stroke: false),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _color(model.fillColorHex),
                  border: Border.all(
                      color: !active ? AppTokens.primary : AppTokens.border,
                      width: !active ? 2 : 1),
                ),
              ),
            ),
          ),
        ]),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        InkWell(
          key: const Key('swap-fill-stroke'),
          onTap: model.swapFillStroke,
          child: Tooltip(
            message: 'Swap fill and stroke (X)',
            child: Icon(Icons.swap_horiz, size: 13, color: AppTokens.textMuted),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          key: const Key('reset-fill-stroke'),
          onTap: model.resetFillStroke,
          child: Tooltip(
            message: 'Reset to default colors',
            child:
                Icon(Icons.filter_none, size: 11, color: AppTokens.textMuted),
          ),
        ),
      ]),
    ]);
  }
}
