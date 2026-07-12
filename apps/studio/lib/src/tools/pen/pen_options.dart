import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../workspace_view_model.dart';
import '../tool_option_fields.dart';

/// Pen tool options-bar content (ToolContribution.optionsBuilder).
List<Widget> penOptions(
  BuildContext context,
  Tool tool,
  VoidCallback onChanged,
  WorkspaceViewModel? model,
) {
  final pen = tool as PenTool;
  return [
    // Drawing mode strip (Smart mode arrives with curve fitting).
    Row(mainAxisSize: MainAxisSize.min, children: [
      for (final (mode, icon, label) in const [
        (PenMode.pen, TablerIcons.ballpen, 'Pen mode — straight segments'),
        (
          PenMode.smart,
          TablerIcons.wand,
          'Smart mode — smooth curve through your points'
        ),
        (
          PenMode.polygon,
          TablerIcons.polygon,
          'Polygon mode — always closes the shape'
        ),
        (PenMode.line, TablerIcons.line, 'Line mode — one two-point segment'),
      ])
        StudioIconButton(
          icon: icon,
          tooltip: label,
          active: pen.mode == mode,
          onPressed: () {
            pen.mode = mode;
            onChanged();
          },
        ),
    ]),
    ...fillStrokeOptions(context, model, onChanged),
  ];
}
