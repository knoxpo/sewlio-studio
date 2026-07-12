import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_tools/studio_tools.dart';

import '../panels/panel_def.dart';
import '../shape_palette.dart';
import '../workspace_view_model.dart';
import 'hoop/hoop_options.dart';
import 'pen/pen_options.dart';
import 'pencil/pencil_options.dart';
import 'select/select_contribution.dart';
import 'shape/shape_options.dart';
import 'text/text_options.dart';
import 'view/view_options.dart';

/// Floating quick-options palette a tool shows while active (UI-410):
/// compact secondary controls (shape variants, presets, modes).
final class QuickOptions {
  const QuickOptions({
    required this.paletteId,
    required this.paletteKey,
    required this.gripKey,
    required this.builder,
  });

  /// Dock-position memory key (WorkspaceViewModel.palettePlacements).
  final String paletteId;
  final Key paletteKey;
  final Key gripKey;
  final Widget Function(BuildContext context, WorkspaceViewModel model) builder;
}

/// Everything one tool contributes to the shell (ADR-037): identity,
/// toolbox entry, shortcut, quick options, dockable panels. The core
/// interaction behavior stays in `studio_tools` ([Tool]); the context
/// toolbar renders per active tool in ToolOptionsBar. Plugins later
/// append to [toolContributions] with namespaced ids — nothing else.
final class ToolContribution {
  const ToolContribution({
    required this.id,
    required this.kind,
    required this.label,
    required this.icon,
    this.shortcutKey,
    this.shortcutLabel,
    this.shortcutCycle,
    this.quickOptions,
    this.panels = const [],
    this.createTool,
    this.optionsBuilder,
    this.revealPanel,
  });

  /// Namespaced identity: `core.*` for built-ins, `<plugin>.*` later.
  final String id;
  final ToolKind kind;
  final String label;
  final IconData icon;

  /// Single-key activation; pressing again cycles [shortcutCycle].
  final LogicalKeyboardKey? shortcutKey;
  final String? shortcutLabel;
  final List<ToolKind>? shortcutCycle;

  final QuickOptions? quickOptions;

  /// Dockable panels this tool registers (same treatment as built-in
  /// panels: docking, tabbing, persistence, Window menu).
  final List<PanelDef> panels;

  /// Builds the tool's interaction core (ADR-044). When set, it
  /// overrides the view model's inline default — tools migrate here
  /// one at a time.
  final Tool Function(WorkspaceViewModel vm)? createTool;

  /// Contextual options-bar content while this tool is active
  /// (ADR-044) — ToolOptionsBar renders whatever this builds; no
  /// options bar when null.
  final List<Widget> Function(BuildContext context, Tool tool,
      VoidCallback onChanged, WorkspaceViewModel? model)? optionsBuilder;

  /// Panel whose tab is brought forward when this tool activates
  /// (ADR-044). Only selects the tab of a panel already visible in a
  /// dock group — a panel the user closed stays closed.
  final String? revealPanel;
}

/// Built-in tools, single source of truth: the toolbox layout, the
/// shortcut map, quick-options palettes, and panel registration all
/// derive from this list.
final toolContributions = <ToolContribution>[
  selectContribution,
  const ToolContribution(
    id: 'core.node',
    kind: ToolKind.node,
    label: 'Node',
    icon: TablerIcons.vector,
    shortcutKey: LogicalKeyboardKey.keyA,
    shortcutLabel: 'A',
  ),
  const ToolContribution(
    id: 'core.hoop',
    kind: ToolKind.hoop,
    label: 'Hoop',
    icon: TablerIcons.frame,
    shortcutKey: LogicalKeyboardKey.keyD,
    shortcutLabel: 'D',
    optionsBuilder: hoopOptions,
  ),
  const ToolContribution(
    id: 'core.pen',
    kind: ToolKind.pen,
    label: 'Pen',
    icon: TablerIcons.ballpen,
    shortcutKey: LogicalKeyboardKey.keyP,
    shortcutLabel: 'P',
    // Affinity-style: P cycles the drawing tools.
    shortcutCycle: [ToolKind.pen, ToolKind.pencil],
    optionsBuilder: penOptions,
  ),
  const ToolContribution(
    id: 'core.pencil',
    kind: ToolKind.pencil,
    label: 'Pencil',
    icon: TablerIcons.pencil,
    shortcutKey: LogicalKeyboardKey.keyB,
    shortcutLabel: 'B',
    optionsBuilder: pencilOptions,
  ),
  ToolContribution(
    id: 'core.shape',
    kind: ToolKind.shape,
    label: 'Shapes',
    icon: TablerIcons.rectangle,
    shortcutKey: LogicalKeyboardKey.keyM,
    shortcutLabel: 'M',
    quickOptions: QuickOptions(
      paletteId: 'shapes',
      paletteKey: const Key('shape-palette'),
      gripKey: const Key('shape-palette-grip'),
      builder: (context, model) => ShapePaletteGrid(model: model),
    ),
    optionsBuilder: shapeOptions,
  ),
  const ToolContribution(
    id: 'core.text',
    kind: ToolKind.text,
    label: 'Text',
    icon: TablerIcons.typography,
    shortcutKey: LogicalKeyboardKey.keyT,
    shortcutLabel: 'T',
    optionsBuilder: textOptions,
    revealPanel: 'character',
  ),
  const ToolContribution(
    id: 'core.measure',
    kind: ToolKind.measure,
    label: 'Measure',
    icon: TablerIcons.ruler_2,
    shortcutKey: LogicalKeyboardKey.keyR,
    shortcutLabel: 'R',
  ),
  const ToolContribution(
    id: 'core.pan',
    kind: ToolKind.pan,
    label: 'View (Pan)',
    icon: TablerIcons.hand_stop,
    shortcutKey: LogicalKeyboardKey.keyH,
    shortcutLabel: 'H',
    optionsBuilder: viewOptions,
  ),
  const ToolContribution(
    id: 'core.zoom',
    kind: ToolKind.zoom,
    label: 'Zoom',
    icon: TablerIcons.zoom_in,
    shortcutKey: LogicalKeyboardKey.keyZ,
    shortcutLabel: 'Z',
    optionsBuilder: viewOptions,
  ),
];

ToolContribution? toolContributionFor(ToolKind kind) {
  for (final c in toolContributions) {
    if (c.kind == kind) return c;
  }
  return null;
}

ToolContribution toolContributionById(String id) =>
    toolContributions.firstWhere((c) => c.id == id);

/// Shortcut → tool cycle, derived (WorkspaceViewModel.onKey consumes).
Map<LogicalKeyboardKey, List<ToolKind>> buildToolShortcuts() => {
      for (final c in toolContributions)
        if (c.shortcutKey != null) c.shortcutKey!: c.shortcutCycle ?? [c.kind],
    };

/// Panels contributed by tools, appended to the built-in registry.
List<PanelDef> toolContributedPanels() =>
    [for (final c in toolContributions) ...c.panels];
