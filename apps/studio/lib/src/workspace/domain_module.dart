import 'package:flutter/widgets.dart';

import '../panels/panel_def.dart';
import '../toolbox.dart';
import 'overlay_def.dart';
import 'project_type.dart';

/// Everything one project type contributes to the shell
/// (ARCH-034/036/038): the domain-mode label, toolbars, quick actions,
/// panels, and canvas overlays. Pure data + widget builders — no
/// behavior, no engine access; the shell renders whatever is listed and
/// hardcodes nothing domain-specific.
final class DomainUiModule {
  const DomainUiModule({
    required this.type,
    required this.domainLabel,
    this.planned = false,
    this.domainToolbox = const [],
    this.quickActions = const [],
    this.domainPanels = const [],
    this.simulationPanels = const [],
    this.domainOverlays = const [],
    this.simulationOverlays = const [],
  });

  final ProjectType type;

  /// Domain-mode label in the workspace switcher: 'Stitch', 'Weaving'.
  final String domainLabel;

  /// Registered but not yet creatable (ARCH-036: planned modules are
  /// representable without implementation). Kept out of New Project.
  final bool planned;

  /// Domain-mode tool rail (same slot/flyout model as the design rail).
  final List<ToolboxGroup> domainToolbox;

  /// Domain-mode quick-action strip (convert, regenerate, sequence…).
  final List<QuickActionDef> quickActions;

  /// Production panels (dockable) — separate from the design-side
  /// Artwork/Layers structures, never merged with them.
  final List<PanelDef> domainPanels;

  final List<PanelDef> simulationPanels;

  final List<OverlayDef> domainOverlays;
  final List<OverlayDef> simulationOverlays;
}

/// A domain quick action (toolbar button). No behavior yet — actions
/// render disabled until their commands exist.
// TODO: add an onPressed command factory when stitch generation lands.
final class QuickActionDef {
  const QuickActionDef({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;
}
