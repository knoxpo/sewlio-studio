import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../shell.dart';
import '../../workspace_view_model.dart';
import '../tool_option_fields.dart';

/// Hoop tool options-bar content (ToolContribution.optionsBuilder):
/// inline hoop size/shape edits (each an undoable UpdateHoop command)
/// plus the full Document Setup dialog for fabric and presets.
List<Widget> hoopOptions(
  BuildContext context,
  Tool tool,
  VoidCallback onChanged,
  WorkspaceViewModel? model,
) {
  final m = model;
  if (m == null) return const [];
  return [
    Row(mainAxisSize: MainAxisSize.min, children: [
      optionNumberField('Width', m.hoop.widthMm, suffix: 'mm', min: 10, (v) {
        m.updateHoop(m.hoop.copyWith(widthMm: v));
        onChanged();
      }),
      const SizedBox(width: 8),
      optionNumberField('Height', m.hoop.heightMm, suffix: 'mm', min: 10, (v) {
        m.updateHoop(m.hoop.copyWith(heightMm: v));
        onChanged();
      }),
    ]),
    StudioDropdown<HoopShape>(
      value: m.hoop.shape,
      width: 120,
      items: const [
        (HoopShape.rectangle, 'Rectangle'),
        (HoopShape.roundedRectangle, 'Rounded'),
        (HoopShape.oval, 'Oval'),
      ],
      onChanged: (shape) {
        m.updateHoop(m.hoop.copyWith(shape: shape));
        onChanged();
      },
    ),
    StudioButton(
      label: 'Edit Hoop…',
      onPressed: () => showDocumentSetup(context, m),
    ),
  ];
}
