import 'package:flutter/widgets.dart';

import '../panels/panel_def.dart';
import '../panels/placeholder_panel.dart';
import '../toolbox.dart';
import '../workspace_view_model.dart';
import 'domain_module.dart';
import 'icon_registry.dart';
import 'overlay_def.dart';
import 'project_type.dart';
import 'simulation_panels.dart';

/// Embroidery domain UI contributions (ARCH-036: embroidery registers
/// as the active MVP domain). Everything below is scaffolding: one real
/// tool (select — the Stitch view is an editing view, not a preview),
/// dimmed placeholders for the rest, filled in as stitch generation
/// lands.
final embroideryModule = DomainUiModule(
  type: ProjectType.embroidery,
  domainLabel: 'Stitch',
  domainToolbox: _stitchToolbox,
  quickActions: _quickActions,
  domainPanels: _stitchPanels,
  simulationPanels: _simulationPanels,
  domainOverlays: _stitchOverlays,
  simulationOverlays: _simulationOverlays,
);

/// Placeholder overlay: an invisible keyed layer so visibility wiring,
/// toggles, and tests work before the painters exist.
// TODO: replace with real painters as stitch generation lands; heavy
// overlays move into CanvasView's paint pipeline.
OverlayDef _stubOverlay(String id, String label,
        {bool defaultVisible = true}) =>
    OverlayDef(
      id: id,
      label: label,
      defaultVisible: defaultVisible,
      builder: (context, model) =>
          IgnorePointer(child: SizedBox.shrink(key: Key('overlay-$id'))),
    );

final _stitchOverlays = [
  _stubOverlay('stitch-points', 'Stitch points'),
  _stubOverlay('stitch-paths', 'Stitch paths'),
  _stubOverlay('direction-arrows', 'Direction arrows'),
  _stubOverlay('entry-exit-markers', 'Entry / exit markers'),
  _stubOverlay('travel-lines', 'Travel lines'),
  _stubOverlay('jump-lines', 'Jump lines'),
  _stubOverlay('trim-markers', 'Trim markers'),
  _stubOverlay('underlay-overlay', 'Underlay'),
  _stubOverlay('hoop-boundary', 'Hoop boundary'),
  _stubOverlay('density-heatmap', 'Density heatmap', defaultVisible: false),
];

final _simulationOverlays = [
  _stubOverlay('active-stitch', 'Active stitch'),
  _stubOverlay('executed-path', 'Executed path'),
  _stubOverlay('pending-path', 'Pending path'),
  _stubOverlay('color-block-highlight', 'Color block highlight'),
  _stubOverlay('needle-position', 'Needle position'),
  _stubOverlay('travel-route', 'Travel / jump route'),
  _stubOverlay('hoop-boundary', 'Hoop boundary'),
  _stubOverlay('problem-markers', 'Problem markers'),
];

const _divider = ToolboxGroup('divider', []);

ToolboxGroup _soon(String id, String iconId, String label) =>
    ToolboxGroup(id, [ToolboxTool(null, iconFor(iconId), label)]);

/// Stitch tool rail. Only selection is live today; every other slot is
/// the standard dimmed "coming soon" toolbox entry.
final _stitchToolbox = <ToolboxGroup>[
  // Selection / reshape
  ToolboxGroup('stitch-select', [
    ToolboxTool(
        ToolKind.select, iconFor('stitch-select'), 'Select Stitch Object',
        shortcut: 'V'),
  ]),
  _soon('stitch-reshape', 'stitch-reshape', 'Reshape Stitch Object'),
  _soon('stitch-entry-exit', 'stitch-entry-exit', 'Entry / Exit Point'),
  _soon('stitch-sequence', 'stitch-sequence', 'Sequence'),
  _divider,
  // Stitch generators
  _soon('stitch-run', 'stitch-run', 'Run Stitch'),
  _soon('stitch-bean', 'stitch-bean', 'Bean / Triple Run'),
  _soon('stitch-satin', 'stitch-satin', 'Satin Column'),
  _soon('stitch-fill', 'stitch-fill', 'Fill / Tatami'),
  _soon('stitch-motif-run', 'stitch-motif-run', 'Motif Run'),
  _soon('stitch-motif-fill', 'stitch-motif-fill', 'Motif Fill'),
  _soon('stitch-zigzag', 'stitch-zigzag', 'Zigzag'),
  _soon('stitch-stem', 'stitch-stem', 'Stem / Border'),
  _soon('stitch-manual', 'stitch-manual', 'Manual Stitch'),
  _soon('stitch-applique', 'stitch-applique', 'Applique'),
  _divider,
  // Structure / machine
  _soon('stitch-underlay', 'stitch-underlay', 'Underlay'),
  _soon('stitch-travel', 'stitch-travel', 'Travel / Connector'),
  _soon('stitch-trim', 'stitch-trim', 'Trim'),
  _soon('stitch-color-change', 'stitch-color-change', 'Color Change'),
  _soon('stitch-angle', 'stitch-angle', 'Stitch Angle'),
  _soon('stitch-compensation', 'stitch-compensation', 'Compensation'),
];

/// Stitch-view quick actions. Disabled until their commands exist.
final _quickActions = <QuickActionDef>[
  QuickActionDef(
      id: 'convert-path-run',
      label: 'Convert path to run',
      icon: iconFor('stitch-run')),
  QuickActionDef(
      id: 'convert-shape-fill',
      label: 'Convert shape to fill',
      icon: iconFor('stitch-fill')),
  QuickActionDef(
      id: 'convert-rails-satin',
      label: 'Convert rails to satin',
      icon: iconFor('stitch-satin')),
  QuickActionDef(
      id: 'regenerate-selected',
      label: 'Regenerate selected',
      icon: iconFor('sim-loop')),
  QuickActionDef(
      id: 'regenerate-all', label: 'Regenerate all', icon: iconFor('sim-loop')),
  QuickActionDef(
      id: 'reverse-direction',
      label: 'Reverse direction',
      icon: iconFor('stitch-entry-exit')),
  QuickActionDef(
      id: 'split-object', label: 'Split object', icon: iconFor('stitch-trim')),
  QuickActionDef(
      id: 'join-objects',
      label: 'Join objects',
      icon: iconFor('stitch-travel')),
  QuickActionDef(
      id: 'optimize-sequence',
      label: 'Optimize sequence',
      icon: iconFor('stitch-sequence')),
];

/// Production panels (Production/Sequence structure) — deliberately
/// separate from the design-side Artwork/Layers panels.
final _stitchPanels = [
  placeholderPanel(
      'stitch-objects', 'Stitch Objects', iconFor('panel-stitch-objects')),
  placeholderPanel('sequence-color-film', 'Sequence / Color Film',
      iconFor('panel-sequence')),
  placeholderPanel('stitch-properties', 'Stitch Properties',
      iconFor('panel-stitch-properties')),
  placeholderPanel('thread', 'Thread', iconFor('panel-thread')),
  placeholderPanel('underlay', 'Underlay', iconFor('panel-underlay')),
  placeholderPanel(
      'compensation', 'Compensation', iconFor('panel-compensation')),
  placeholderPanel('validation', 'Validation', iconFor('panel-validation')),
  placeholderPanel('statistics', 'Statistics', iconFor('panel-statistics')),
  placeholderPanel(
      'machine-hoop', 'Machine / Hoop', iconFor('panel-machine-hoop')),
];

/// Simulation panels: timeline + runtime stats are live; the rest are
/// placeholders until the playback event model exists.
final _simulationPanels = [
  PanelDef(
    id: 'timeline',
    title: 'Timeline',
    icon: iconFor('panel-timeline'),
    builder: (context, model) => TimelinePanelContent(sim: model.simulation),
  ),
  placeholderPanel(
      'playback-events', 'Playback Events', iconFor('panel-playback-events')),
  placeholderPanel(
      'color-sequence', 'Color Sequence', iconFor('panel-color-sequence')),
  placeholderPanel(
      'machine-event-log', 'Machine Event Log', iconFor('panel-event-log')),
  PanelDef(
    id: 'runtime-stats',
    title: 'Runtime Stats',
    icon: iconFor('panel-runtime-stats'),
    builder: (context, model) =>
        RuntimeStatsPanelContent(sim: model.simulation),
  ),
  placeholderPanel('warnings', 'Warnings', iconFor('panel-warnings')),
];
