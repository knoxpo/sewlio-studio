import '../panels/placeholder_panel.dart';
import '../toolbox.dart';
import 'domain_module.dart';
import 'icon_registry.dart';
import 'project_type.dart';

/// Weaving domain: a planned module (ARCH-036 — representable without
/// implementation). Proves the shell renders a second domain purely
/// from registry data; contains zero weaving logic. Domain vocabulary
/// per ARCH-031: warp, weft, pick — not stitches.
final weavingModule = DomainUiModule(
  type: ProjectType.weaving,
  domainLabel: 'Weaving',
  planned: true,
  domainToolbox: [
    ToolboxGroup('weave-select', [
      ToolboxTool(null, iconFor('panel-warp-setup'), 'Select Weave Region'),
    ]),
    ToolboxGroup('weave-pick', [
      ToolboxTool(null, iconFor('panel-weft-sequence'), 'Pick Editor'),
    ]),
  ],
  domainPanels: [
    placeholderPanel('warp-setup', 'Warp Setup', iconFor('panel-warp-setup')),
    placeholderPanel(
        'weft-sequence', 'Weft Sequence', iconFor('panel-weft-sequence')),
  ],
);
