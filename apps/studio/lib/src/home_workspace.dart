import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import 'app_shell.dart';
import 'app_view_model.dart';
import 'prompts.dart';
import 'recents.dart';

/// Application-level landing workspace (UI-012): primary actions and
/// recent projects. Owns no document, no save state, no undo history.
class HomeWorkspace extends StatelessWidget {
  const HomeWorkspace({super.key, required this.app});

  final AppViewModel app;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTokens.background,
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.draw, color: AppTokens.primary, size: 28),
              SizedBox(width: 10),
              Text('Sewlio Studio',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 24),
            Row(children: [
              StudioButton(
                key: const Key('home-new-project'),
                label: 'New Project',
                icon: Icons.add,
                variant: StudioButtonVariant.primary,
                onPressed: () => showNewProjectDialog(context, app),
              ),
              const SizedBox(width: 8),
              StudioButton(
                key: const Key('home-open-project'),
                label: 'Open Project',
                icon: Icons.folder_open,
                onPressed: () => _open(context),
              ),
            ]),
            const SizedBox(height: 32),
            Text('Recent Projects',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.textMuted)),
            const SizedBox(height: 8),
            Expanded(
              child: app.recents.entries.isEmpty
                  ? Align(
                      alignment: Alignment.topLeft,
                      child: Text('No recent projects yet',
                          style: TextStyle(
                              color: AppTokens.textMuted, fontSize: 12)),
                    )
                  : ListView(
                      children: [
                        for (final recent in app.recents.entries)
                          _recentCard(context, recent),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentCard(BuildContext context, RecentProject recent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _openRecent(context, recent),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppTokens.panel,
            border: Border.all(color: AppTokens.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Icon(Icons.description_outlined,
                size: 18, color: AppTokens.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recent.name,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(recent.path,
                      style:
                          TextStyle(fontSize: 10, color: AppTokens.textMuted)),
                ],
              ),
            ),
            Text(
              '${recent.hoopWidthMm.round()} × ${recent.hoopHeightMm.round()} mm'
              '   ·   ${_date(recent.lastOpened)}',
              style: TextStyle(fontSize: 10, color: AppTokens.textMuted),
            ),
            const SizedBox(width: 8),
            StudioIconButton(
              icon: Icons.close,
              tooltip: 'Remove from recents',
              onPressed: () => app.removeRecent(recent.path),
            ),
          ]),
        ),
      ),
    );
  }

  static String _date(DateTime time) =>
      '${time.year}-${time.month.toString().padLeft(2, '0')}-'
      '${time.day.toString().padLeft(2, '0')}';

  Future<void> _open(BuildContext context) async {
    final path = await pickOpenPath(suffix: '.embproj');
    if (path == null || !context.mounted) return;
    await _openPath(context, path);
  }

  Future<void> _openRecent(BuildContext context, RecentProject recent) async {
    if (!app.projectFileExists(recent.path)) {
      await _missingFileDialog(context, recent);
      return;
    }
    await _openPath(context, recent.path);
  }

  Future<void> _openPath(BuildContext context, String path) async {
    try {
      await app.openProject(path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Open failed: $e')));
      }
    }
  }

  /// UI-608: missing project files are recoverable — removing from
  /// recents never deletes anything on disk.
  Future<void> _missingFileDialog(
      BuildContext context, RecentProject recent) async {
    final remove = await showStudioDialog<bool>(
      context: context,
      title: 'Project Missing',
      body: Text('${recent.path} no longer exists.'),
      actions: [
        Builder(
          builder: (context) => StudioButton(
            label: 'Keep',
            variant: StudioButtonVariant.ghost,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Builder(
          builder: (context) => StudioButton(
            label: 'Remove',
            variant: StudioButtonVariant.danger,
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
      ],
    );
    if (remove == true) app.removeRecent(recent.path);
  }
}
