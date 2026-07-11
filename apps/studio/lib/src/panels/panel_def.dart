import 'package:flutter/material.dart';

import '../object_panel.dart';
import '../workspace_view_model.dart';
import 'layers_panel.dart';
import 'stitches_panel.dart';

/// A dockable panel: stable identity, chrome metadata, and a builder
/// that wires the panel's content to the active document's view model.
/// Content widgets stay stateless-props (headless-testable); only these
/// builders touch the view model.
final class PanelDef {
  const PanelDef({
    required this.id,
    required this.title,
    required this.icon,
    this.minHeight = 96,
    required this.builder,
  });

  final String id;
  final String title;
  final IconData icon;

  /// Smallest height the splitters let a group with this panel reach.
  final double minHeight;

  final Widget Function(BuildContext context, WorkspaceViewModel model) builder;
}

/// All built-in panels, in default dock order. Adding a panel here is
/// the whole registration story — the dock renders whatever is listed.
// ponytail: plugin panels later just append to this list at startup.
final panelRegistry = <PanelDef>[
  PanelDef(
    id: 'stitches',
    title: 'Stitches',
    icon: Icons.format_list_numbered,
    builder: (context, model) => StitchesPanelContent(
      document: model.session.document,
      selectedRefs: model.selection.selectedRefs,
      onSelect: model.selectRef,
      onMoveNode: model.moveNode,
      stitchHighlight: model.stitchHighlight,
      onHighlightGlyph: model.setStitchHighlight,
    ),
  ),
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
      framed: false,
    ),
  ),
];

/// Default panel-id order for constructing the dock layout.
List<String> get defaultPanelIds => [for (final p in panelRegistry) p.id];

PanelDef panelById(String id) => panelRegistry.firstWhere((p) => p.id == id);
