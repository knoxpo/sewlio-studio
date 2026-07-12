import 'package:flutter/material.dart';

import '../object_panel.dart';
import '../shell.dart';
import '../tools/tool_contributions.dart';
import '../workspace/icon_registry.dart';
import '../workspace/project_type_registry.dart';
import 'character_panel.dart';
import 'color_panel.dart';
import 'layers_panel.dart';
import 'panel_def.dart';
import 'placeholder_panel.dart';
import 'preview_panels.dart';

/// All built-in panels, in default dock order. Adding a panel here is
/// the whole registration story — the dock renders whatever is listed.
/// Design panels are vector/document surfaces only (Illustrator-like);
/// stitch structures live in the domain module's panels.
final _builtinPanels = <PanelDef>[
  PanelDef(
    id: 'layers',
    title: 'Layers',
    icon: Icons.layers_outlined,
    builder: (context, model) => LayersPanelContent(
      document: model.session.document,
      selectedRefs: model.selection.selectedRefs,
      primarySelection: model.primarySelection,
      onSelect: model.selectRef,
      onCommand: model.execute,
      onCreateLayer: model.createLayer,
      onCreateGroup: model.createGroupFromSelection,
      onUngroup: model.ungroupPrimary,
      onDelete: model.deleteSelection,
      onDuplicate: model.duplicatePrimary,
      onMoveNode: model.moveNode,
    ),
  ),
  PanelDef(
    id: 'properties',
    title: 'Properties',
    icon: Icons.tune,
    builder: (context, model) => ObjectPropertiesPanel(
      document: model.session.document,
      selectedRefs: model.selection.selectedRefs,
      primarySelection: model.primarySelection,
      onCommand: model.execute,
      onConvertText: model.convertTextToStitches,
      framed: false,
    ),
  ),
  PanelDef(
    id: 'hoop',
    title: 'Hoop',
    icon: iconFor('panel-machine-hoop'),
    minHeight: 200,
    builder: (context, model) => HoopPanelContent(
      hoop: model.hoop,
      onEdit: () => showDocumentSetup(context, model),
    ),
  ),
  // Design-view placeholder panels — universal (not embroidery-specific),
  // filled in as each feature lands. 'stitches'/'layers' above are the
  // Artwork structures; production/sequence panels are contributed
  // separately by domain modules and never merged with these.
  // ('transform' is tool-owned — the Select contribution registers it.)
  PanelDef(
    id: 'color',
    title: 'Color',
    icon: Icons.palette_outlined,
    builder: (context, model) => ColorPanelContent(model: model),
  ),
  PanelDef(
    id: 'fill',
    title: 'Fill',
    icon: Icons.format_color_fill_outlined,
    builder: (context, model) => FillPanelContent(model: model),
  ),
  PanelDef(
    id: 'stroke',
    title: 'Stroke',
    icon: Icons.border_color_outlined,
    builder: (context, model) => StrokePanelContent(model: model),
  ),
  placeholderPanel(
      'assets-reference', 'Assets / Reference', iconFor('panel-assets')),
  placeholderPanel(
      'path-operations', 'Path Operations', iconFor('panel-path-ops')),
  PanelDef(
    id: 'character',
    title: 'Character',
    icon: iconFor('panel-character'),
    minHeight: 240,
    builder: (context, model) => CharacterPanel(model: model),
  ),
  placeholderPanel('paragraph', 'Paragraph', iconFor('panel-paragraph')),
  placeholderPanel('align-arrange', 'Align / Arrange', iconFor('panel-align')),
];

/// The panel registry the dock, Panels menu, and persistence consume:
/// built-ins plus tool-contributed panels (ADR-037), aggregated at
/// declaration so every composition root (app, tests) sees the same
/// list — no startup wiring required.
// ponytail: plugin panels later just append to this list at startup.
final panelRegistry = <PanelDef>[
  ..._builtinPanels,
  ...toolContributedPanels(),
];

/// Default panel-id order for constructing the dock layout.
List<String> get defaultPanelIds => [for (final p in panelRegistry) p.id];

/// Design-mode dock panels (all registered panels today; domain and
/// simulation modes resolve their own sets from the active module).
List<String> get designPanelIds => defaultPanelIds;

/// Default design dock: three stacked tab rows.
final designPanelRows = <List<String>>[
  [
    'properties',
    'color',
    'fill',
    'stroke',
    'character',
    'align-arrange',
    'paragraph'
  ],
  ['layers', 'assets-reference', 'path-operations'],
  ['hoop', 'transform'],
];

/// Panel lookup for the dock host: built-ins/tool panels first, then
/// domain-module contributions (ARCH-038) — modules keep their panels
/// out of the design dock by not being in [panelRegistry].
PanelDef panelById(String id) => panelRegistry.firstWhere(
      (p) => p.id == id,
      orElse: () => domainModules
          .expand((m) => [...m.domainPanels, ...m.simulationPanels])
          .firstWhere((p) => p.id == id),
    );
