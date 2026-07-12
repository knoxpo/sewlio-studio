import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/panels/panel_def.dart';
import 'package:studio/src/panels/panel_registry.dart';
import 'package:studio/src/tools/tool_contributions.dart';
import 'package:studio/src/workspace_view_model.dart';

void main() {
  // panelRegistry is a lazy top-level final that aggregates tool panels
  // on first access — register the fake contribution before anything
  // touches the registry, mirroring how plugins append at startup.
  toolContributions.add(ToolContribution(
    id: 'test.fake',
    kind: ToolKind.measure,
    label: 'Fake',
    icon: Icons.help_outline,
    panels: [
      PanelDef(
        id: 'fake-panel',
        title: 'Fake Panel',
        icon: Icons.help_outline,
        builder: (context, model) => const SizedBox(),
      ),
    ],
  ));

  test('tool-contributed panels join the registry deterministically', () {
    expect(defaultPanelIds, contains('fake-panel'));
    expect(panelById('fake-panel').title, 'Fake Panel');
    // Tool panels append after built-ins — default layout rows stay
    // owned by designPanelRows, so built-in order is unchanged.
    expect(defaultPanelIds.indexOf('fake-panel'),
        greaterThan(defaultPanelIds.indexOf('layers')));
  });

  test('registry ids are unique', () {
    final ids = defaultPanelIds;
    expect(ids.toSet().length, ids.length);
  });
}
