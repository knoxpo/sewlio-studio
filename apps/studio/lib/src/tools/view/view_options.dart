import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../workspace_view_model.dart';
import '../tool_option_fields.dart';

/// Shared options-bar content for the view tools (Pan, Zoom): zoom
/// level plus the two standard view fits.
List<Widget> viewOptions(
  BuildContext context,
  Tool tool,
  VoidCallback onChanged,
  WorkspaceViewModel? model,
) {
  final m = model;
  if (m == null) return const [];
  return [
    optionNumberField('Zoom', m.viewport.percent, suffix: '%', min: 1, (v) {
      m.viewport.setPercent(v);
      onChanged();
    }),
    Row(mainAxisSize: MainAxisSize.min, children: [
      StudioButton(
        label: 'Fit',
        onPressed: () {
          m.fitCanvas();
          onChanged();
        },
      ),
      const SizedBox(width: 6),
      StudioButton(
        label: '100%',
        onPressed: () {
          m.viewport.setPercent(100);
          onChanged();
        },
      ),
    ]),
  ];
}
