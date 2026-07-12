import 'package:flutter/material.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../workspace_view_model.dart';
import '../tool_option_fields.dart';

/// Pencil tool options-bar content (ToolContribution.optionsBuilder).
List<Widget> pencilOptions(
  BuildContext context,
  Tool tool,
  VoidCallback onChanged,
  WorkspaceViewModel? model,
) {
  final pencil = tool as PencilTool;
  return [
    optionNumberField('Smoothing', pencil.toleranceMm, suffix: 'mm', min: 0.05,
        (v) {
      pencil.toleranceMm = v;
      onChanged();
    }),
  ];
}
