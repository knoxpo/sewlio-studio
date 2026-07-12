import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_design_system/studio_design_system.dart';

import 'tool_card.dart';
import 'tool_docs.dart';
import 'tool_options.dart';
import 'tools/tool_contributions.dart';
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

/// A registered tool's toolbox entry — identity, icon, label, and
/// shortcut come from its [ToolContribution] (ADR-037), so the toolbox
/// and the shortcut map can never drift apart.
ToolboxTool _tool(String id) {
  final c = toolContributionById(id);
  return ToolboxTool(c.kind, c.icon, c.label, shortcut: c.shortcutLabel);
}

/// The toolbox, Affinity/Illustrator-style. Groups with several tools
/// render as flyout slots that remember the last-used tool. This list
/// is layout only — real tools resolve from [toolContributions];
/// null-kind entries are dimmed "coming soon" placeholders.
final toolboxGroups = <ToolboxGroup>[
  // Selection
  ToolboxGroup('move', [_tool('core.select')]),
  ToolboxGroup('node', [
    _tool('core.node'),
    const ToolboxTool(null, TablerIcons.vector_bezier_2, 'Corner'),
  ]),
  _divider,
  // Document / hoop
  ToolboxGroup('hoop', [_tool('core.hoop')]),
  _divider,
  // Drawing — one slot per tool (no flyout grouping).
  ToolboxGroup('pen', [_tool('core.pen')]),
  ToolboxGroup('pencil', [_tool('core.pencil')]),
  const ToolboxGroup('contour', [
    ToolboxTool(null, TablerIcons.circle_dashed, 'Contour'),
  ]),
  const ToolboxGroup('path-brush', [
    ToolboxTool(null, TablerIcons.brush, 'Path Brush'),
  ]),
  const ToolboxGroup('blob-brush', [
    ToolboxTool(null, TablerIcons.paint, 'Vector Blob Brush'),
  ]),
  // Shapes (flyout over ShapeKind via its quick-options palette), Text
  const ToolboxGroup('shapes', []),
  ToolboxGroup('text', [_tool('core.text')]),
  _divider,
  // Fill & color (arrive with the fill/stroke system)
  const ToolboxGroup('color', [
    ToolboxTool(null, TablerIcons.bucket_droplet, 'Fill'),
    ToolboxTool(null, TablerIcons.color_picker, 'Color Picker'),
  ]),
  // Utility
  ToolboxGroup('utility', [
    _tool('core.measure'),
    const ToolboxTool(null, TablerIcons.crop, 'Vector Crop'),
  ]),
  _divider,
  // Navigation
  ToolboxGroup('navigate', [_tool('core.pan'), _tool('core.zoom')]),
];

/// The tool rail: renders [toolboxGroups] plus the persistent
/// fill/stroke controls at the bottom.
class ToolboxRail extends StatelessWidget {
  const ToolboxRail({
    super.key,
    required this.model,
    this.groups,
    this.touchMode = false,
    this.floating = false,
  });

  final WorkspaceViewModel model;

  /// Rail contents; defaults to the design toolbox. Domain modes pass
  /// the active module's toolbox (ARCH-038).
  final List<ToolboxGroup>? groups;

  /// 48 dp tool targets (platform-requirements §14); rail widens to fit.
  final bool touchMode;

  /// Rendered as an overlay card over the canvas (tablet portrait)
  /// instead of a docked edge column.
  final bool floating;

  double? get _minTarget => touchMode ? 48 : null;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: touchMode ? 56 : 44,
      decoration: floating
          ? BoxDecoration(
              color: AppTokens.panel,
              border: Border.all(color: AppTokens.border),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 12,
                    offset: Offset(0, 2)),
              ],
            )
          : BoxDecoration(
              color: AppTokens.panel,
              border: Border(right: BorderSide(color: AppTokens.border)),
            ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                for (final group in groups ?? toolboxGroups) _slot(group),
                // Color chips sit with the tools (below the last tool),
                // not pinned at the rail bottom.
                const SizedBox(height: 8),
                _FillStrokeChips(model: model),
              ]),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _slot(ToolboxGroup group) {
    if (group.id == 'divider') return const RailSeparator();
    if (group.id == 'shapes') {
      // Activates the Shape tool; shape picking happens in the
      // floating palette that appears while the tool is active.
      return ToolCardHover(
        doc: toolDocFor('Shapes'),
        child: StudioIconButton(
          key: const Key('tool-Shapes'),
          minTarget: _minTarget,
          icon: shapeIcon(model.shapeTool.kind),
          tooltip: null,
          active: model.activeKind == ToolKind.shape,
          flyoutIndicator: true,
          onPressed: () => model.activateShape(null),
        ),
      );
    }
    final real = [
      for (final tool in group.tools)
        if (tool.kind != null) tool,
    ];
    // Single tool: plain button; a future tool renders dimmed.
    if (group.tools.length == 1) {
      final tool = group.tools.single;
      final doc = tool.kind == null ? null : toolDocFor(tool.label);
      return ToolCardHover(
        doc: doc,
        child: StudioIconButton(
          key: Key('tool-${tool.label}'),
          minTarget: _minTarget,
          icon: tool.icon,
          // The learning card replaces the tooltip when a doc exists.
          tooltip: doc != null
              ? null
              : (tool.kind == null
                  ? '${tool.tooltip} — coming soon'
                  : tool.tooltip),
          active: model.activeKind == tool.kind,
          onPressed:
              tool.kind == null ? null : () => model.selectTool(tool.kind!),
        ),
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
    final doc = current.kind == null ? null : toolDocFor(current.label);
    // Activates the group's remembered tool; picking within the group
    // happens in the floating palette shown while the group is active.
    return ToolCardHover(
      doc: doc,
      child: StudioIconButton(
        key: Key('tool-${current.label}'),
        minTarget: _minTarget,
        icon: current.icon,
        tooltip: doc != null ? null : current.tooltip,
        active: groupActive,
        flyoutIndicator: true,
        onPressed: real.isEmpty
            ? null
            : () => _pick(
                group, model.toolGroupMemory[group.id] ?? real.first.kind!),
      ),
    );
  }

  void _pick(ToolboxGroup group, ToolKind kind) {
    model.toolGroupMemory[group.id] = kind;
    model.selectTool(kind);
  }
}

/// Short inset separator between rail tool groups (Affinity-style).
class RailSeparator extends StatelessWidget {
  const RailSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: AppTokens.surfaceHigh,
    );
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

  /// Parsed colour, or null for transparent (rendered as an empty chip).
  Color? _color(String hex) => isTransparent(hex)
      ? null
      : Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

  // Summary of the selection's style (else defaults) — updates live on
  // selection change and inspector edits.
  String get _fillHex => model.activeStroke.fillHex ?? model.fillColorHex;
  String get _strokeHex => model.activeStroke.colorHex ?? model.strokeColorHex;

  Future<void> _edit(BuildContext context, {required bool stroke}) async {
    model.strokeChipActive = stroke;
    model.notify();
    final hex = await showStudioColorPicker(
      context: context,
      initialHex: stroke ? _strokeHex : _fillHex,
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
                          color: _color(_strokeHex) ?? AppTokens.textMuted,
                          width: 3),
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
                  color: _color(_fillHex) ?? AppTokens.field,
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
