import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import 'tools/tool_contributions.dart';
import 'workspace_view_model.dart';

/// Illustrator-style control bar: contextual options for the active
/// tool, shown above the canvas. The content comes from the active
/// tool's contribution (`optionsBuilder`, ADR-044) — this widget owns
/// only the chrome and renders whatever the tool builds.
class ToolOptionsBar extends StatelessWidget {
  const ToolOptionsBar({
    super.key,
    required this.tool,
    required this.onChanged,
    this.model,
  });

  final Tool tool;

  /// Workspace model for options that reach beyond the tool itself
  /// (stroke defaults). Null in isolated previews/tests.
  final WorkspaceViewModel? model;

  /// Called after any option edit so the shell repaints.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final contribution =
        model == null ? null : toolContributionFor(model!.activeKind);
    if (contribution == null) return const SizedBox.shrink();
    final built =
        contribution.optionsBuilder?.call(context, tool, onChanged, model) ??
            const <Widget>[];
    // The bar is always present so tool switches never reflow the
    // canvas: every tool leads with its name, then its options (the
    // status bar already carries the usage hint).
    final options = <Widget>[
      Text(contribution.label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTokens.textPrimary)),
      ...built,
    ];
    return Container(
      height: 34,
      // Fill the whole strip and keep content left-aligned — the bar
      // must never shrink-wrap and float centered over the canvas.
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      // Rich toolbars (Text) can outgrow narrow windows — scroll, never
      // overflow.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (index, option) in options.indexed) ...[
            if (index > 0)
              Container(
                width: 1,
                height: 18,
                color: AppTokens.border,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
            option,
          ],
        ]),
      ),
    );
  }
}
