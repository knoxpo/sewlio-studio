import 'package:flutter/material.dart';

import 'tokens.dart';

/// Section heading inside dialogs and config panes ("General", "Hoop").
class StudioSectionLabel extends StatelessWidget {
  const StudioSectionLabel(this.text, {super.key, this.first = false});

  final String text;

  /// First section of a pane skips the top gap.
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : 16, bottom: 6),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTokens.textMuted)),
    );
  }
}

/// One form row: muted label on the left, control on the right.
/// The standard layout for dialog and inspector settings.
class StudioFormRow extends StatelessWidget {
  const StudioFormRow({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(
          child: Text(label,
              style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
        ),
        child,
      ]),
    );
  }
}
