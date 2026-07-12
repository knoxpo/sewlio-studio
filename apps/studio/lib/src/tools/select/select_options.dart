import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../workspace_view_model.dart';
import '../tool_option_fields.dart';

/// Select (Move) tool options-bar content: style of the selection and
/// the essential selection operations.
List<Widget> selectOptions(
  BuildContext context,
  Tool tool,
  VoidCallback onChanged,
  WorkspaceViewModel? model,
) {
  final m = model;
  if (m == null) return const [];
  final hasSelection = m.selection.selectedRefs.isNotEmpty;
  return [
    ...fillStrokeOptions(context, m, onChanged),
    Row(mainAxisSize: MainAxisSize.min, children: [
      StudioButton(
        label: 'Duplicate',
        onPressed: hasSelection
            ? () {
                m.duplicatePrimary();
                onChanged();
              }
            : null,
      ),
      const SizedBox(width: 6),
      StudioButton(
        label: 'Delete',
        onPressed: hasSelection
            ? () {
                m.deleteSelection();
                onChanged();
              }
            : null,
      ),
    ]),
  ];
}
