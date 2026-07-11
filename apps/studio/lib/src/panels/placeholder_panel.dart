import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import 'panel_def.dart';

/// Scaffold body for panels whose real content hasn't landed: title,
/// optional scope note, and an explicit "coming soon" so nothing reads
/// as broken. Replaced panel-by-panel as features arrive.
class PlaceholderPanel extends StatelessWidget {
  const PlaceholderPanel({super.key, required this.title, this.note});

  final String title;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pending_outlined, size: 20, color: AppTokens.textMuted),
            const SizedBox(height: 8),
            Text('$title — coming soon',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTokens.textMuted)),
            if (note != null) ...[
              const SizedBox(height: 4),
              Text(note!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: AppTokens.textMuted)),
            ],
          ],
        ),
      ),
    );
  }
}

/// A dockable placeholder panel definition.
PanelDef placeholderPanel(String id, String title, IconData icon,
        {String? note}) =>
    PanelDef(
      id: id,
      title: title,
      icon: icon,
      builder: (context, model) =>
          PlaceholderPanel(key: Key('placeholder-$id'), title: title, note: note),
    );
