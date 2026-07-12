import 'package:flutter/material.dart';

import '../workspace_view_model.dart';

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
