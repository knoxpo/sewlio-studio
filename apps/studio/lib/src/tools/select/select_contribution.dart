import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../panels/placeholder_panel.dart';
import '../../workspace/icon_registry.dart';
import '../../workspace_view_model.dart';
import '../tool_contributions.dart';
import 'select_options.dart';

/// Select ("Move") tool — the reference implementation for tool-owned
/// contributions (ADR-044): everything this tool adds to the shell
/// lives in this folder, and the shell hosts it through the generic
/// contribution/registry machinery only.
final selectContribution = ToolContribution(
  id: 'core.select',
  kind: ToolKind.select,
  label: 'Move',
  icon: TablerIcons.pointer,
  shortcutKey: LogicalKeyboardKey.keyV,
  shortcutLabel: 'V',
  // Transform is selection/move semantics, so the panel is owned here
  // even while its content is a placeholder.
  panels: [
    placeholderPanel('transform', 'Transform', iconFor('panel-transform')),
  ],
  createTool: (vm) => SelectTool(
    document: vm.session.document,
    history: vm.session.history,
    selection: vm.selection,
  ),
  optionsBuilder: selectOptions,
);
