import 'package:barley/barley.dart';
import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import 'app_view_model.dart';
import 'home_workspace.dart';
import 'menu/app_menu.dart';
import 'menu/app_menus.dart';
import 'menu/menu_renderers.dart';
import 'new_project_page.dart';
import 'prompts.dart';
import 'shell.dart';
import 'workspace/project_type_registry.dart';
import 'workspace_view_model.dart';

/// Application shell (UI-010/012 Option B): a pinned Home tab plus one
/// tab per open document. No documents → Home Workspace; the editor is
/// only ever shown for a real document session.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.create});

  final AppViewModel Function() create;

  @override
  Widget build(BuildContext context) {
    return BarleyView<AppViewModel>(
      create: create,
      builder: (context, app) => _AppView(app: app),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView({required this.app});

  final AppViewModel app;

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      // Panel color behind the system insets so the status-bar strip
      // reads as chrome, not a hole.
      backgroundColor: AppTokens.panel,
      // Keep UI clear of the status bar, notch, and home indicator on
      // iOS/Android; zero insets on desktop, so layout is unchanged.
      body: SafeArea(
        child: Column(children: [
          _appHeader(context),
          Divider(height: 1, color: AppTokens.border),
          _tabStrip(context),
          Divider(height: 1, color: AppTokens.border),
          Expanded(child: _body()),
        ]),
      ),
    );
    // One menu definition (ADR-039), two surfaces: macOS renders it in
    // the system menu bar (which also dispatches its shortcuts); other
    // platforms render it in the header and bind the same shortcuts
    // app-wide via CallbackShortcuts.
    if (useNativeMenus) {
      return PlatformMenuBar(
        menus: buildPlatformMenus(context, app),
        child: scaffold,
      );
    }
    return CallbackShortcuts(
      bindings: menuShortcutBindings(buildAppMenus(context, app)),
      child: scaffold,
    );
  }

  Widget _body() {
    final tab = app.activeTab;
    if (tab == null) return HomeWorkspace(app: app);
    // Editor view models are long-lived (one per tab); fitCanvas once
    // the first frame has laid the canvas out.
    if (!tab.readied) {
      tab.readied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => tab.vm.onReady());
    }
    return KeyedSubtree(
      key: ObjectKey(tab),
      child: ListenableBuilder(
        listenable: tab.vm,
        builder: (context, _) => EditorWorkspace(model: tab.vm, app: app),
      ),
    );
  }

  // ------------------------------------------------------------- app header

  /// Application header (all platforms): brand + menus left (in-app
  /// menus only where no native menu bar exists), workspace mode
  /// switcher centered, theme selector right.
  Widget _appHeader(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTokens.panel,
      ),
      child: Row(
        children: [
          Expanded(child: _headerLeft(context)),
          if (app.activeTab != null)
            ListenableBuilder(
              listenable: app.activeTab!.vm,
              builder: (context, _) => WorkspaceModeSwitcher(
                mode: app.activeTab!.vm.mode,
                domainLabel:
                    moduleFor(app.activeTab!.vm.projectType).domainLabel,
                onChanged: app.activeTab!.vm.setMode,
              ),
            ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _themeButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerLeft(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.draw, color: AppTokens.primary, size: 18),
        const SizedBox(width: 6),
        const Text('Sewlio Studio',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(width: 12),
        if (!useNativeMenus)
          // Same tree as the macOS menu bar (ADR-039) — rendered
          // in-app on Windows/Linux/web/tablets.
          Flexible(
            child: toMenuBarWidget(buildAppMenus(context, app)),
          ),
      ],
    );
  }

  /// Theme selector: Light / Dark / System, applied immediately.
  Widget _themeButton() {
    final (icon, label) = switch (studioThemeMode.value) {
      ThemeMode.light => (Icons.light_mode_outlined, 'Light'),
      ThemeMode.dark => (Icons.dark_mode_outlined, 'Dark'),
      ThemeMode.system => (Icons.brightness_auto_outlined, 'System'),
    };
    return PopupMenuButton<ThemeMode>(
      tooltip: 'Theme: $label',
      color: AppTokens.popoverSurface,
      icon: Icon(icon, size: 17, color: AppTokens.textMuted),
      onSelected: (mode) => studioThemeMode.value = mode,
      itemBuilder: (context) => [
        for (final (mode, name) in const [
          (ThemeMode.light, 'Light'),
          (ThemeMode.dark, 'Dark'),
          (ThemeMode.system, 'System'),
        ])
          PopupMenuItem(
            value: mode,
            height: 30,
            child: Row(children: [
              Icon(
                mode == studioThemeMode.value
                    ? Icons.check
                    : Icons.check_box_outline_blank,
                size: 14,
                color: mode == studioThemeMode.value
                    ? AppTokens.primary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(name, style: const TextStyle(fontSize: 12)),
            ]),
          ),
      ],
    );
  }

  // ------------------------------------------------------------- tab strip

  Widget _tabStrip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, top: 4),
      alignment: Alignment.bottomLeft,
      decoration: BoxDecoration(
        color: AppTokens.background,
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      child: Row(children: [
        _tab(
          key: const Key('home-tab'),
          active: app.active < 0,
          onTap: app.goHome,
          child:
              Icon(Icons.home_outlined, size: 14, color: AppTokens.textPrimary),
        ),
        for (final (index, tab) in app.tabs.indexed)
          _tab(
            key: Key('doc-tab-$index'),
            active: app.active == index,
            onTap: () => app.activate(index),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                '${tab.title}.swl${tab.dirty ? '*' : ''}',
                key: app.active == index ? const Key('doc-title') : null,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 6),
              InkWell(
                key: Key('close-tab-$index'),
                onTap: () => requestCloseTab(context, app, index),
                child: Icon(Icons.close, size: 12, color: AppTokens.textMuted),
              ),
            ]),
          ),
      ]),
    );
  }

  Widget _tab({
    Key? key,
    required bool active,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTokens.panel : AppTokens.background,
          border: Border(
            top: BorderSide(color: AppTokens.border),
            left: BorderSide(color: AppTokens.border),
            right: BorderSide(color: AppTokens.border),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: child,
      ),
    );
  }
}

/// Segmented pill switching the primary workspaces: Design, the
/// project-type domain view (Stitch / Weaving — resolved, never
/// hardcoded), Simulation. A thumb slides under the active segment.
class WorkspaceModeSwitcher extends StatelessWidget {
  const WorkspaceModeSwitcher({
    super.key,
    required this.mode,
    required this.domainLabel,
    required this.onChanged,
  });

  final WorkspaceMode mode;

  /// Domain-mode label from the active project type's module (ARCH-038).
  final String domainLabel;

  final ValueChanged<WorkspaceMode> onChanged;

  List<(WorkspaceMode, IconData, String)> get _segments => [
        (WorkspaceMode.design, Icons.edit_outlined, 'Design'),
        (WorkspaceMode.domain, Icons.format_line_spacing, domainLabel),
        (WorkspaceMode.simulation, Icons.play_circle_outline, 'Simulation'),
      ];

  static const double _segmentWidth = 118;
  static const double _height = 26;

  @override
  Widget build(BuildContext context) {
    final index = _segments.indexWhere((s) => s.$1 == mode);
    return Container(
      height: _height + 4,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppTokens.field,
        borderRadius: BorderRadius.circular((_height + 4) / 2),
        border: Border.all(color: AppTokens.border),
      ),
      child: Stack(children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          left: index * _segmentWidth,
          top: 0,
          width: _segmentWidth,
          height: _height,
          child: Container(
            decoration: BoxDecoration(
              color: AppTokens.primary.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(_height / 2),
            ),
          ),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          for (final (value, icon, label) in _segments)
            InkWell(
              key: Key('mode-${value.name}'),
              borderRadius: BorderRadius.circular(_height / 2),
              onTap: () => onChanged(value),
              child: SizedBox(
                width: _segmentWidth,
                height: _height,
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(icon,
                      size: 13,
                      color: value == mode
                          ? AppTokens.primary
                          : AppTokens.textMuted),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight:
                            value == mode ? FontWeight.w600 : FontWeight.w400,
                        color: value == mode
                            ? AppTokens.primary
                            : AppTokens.textMuted,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
        ]),
      ]),
    );
  }
}

/// New Embroidery Project workflow (UI-606) hosted as a floating popup
/// dialog: templates | configuration | live preview.
Future<void> showNewProjectDialog(BuildContext context, AppViewModel app) {
  return showStudioDialog<void>(
    context: context,
    title: 'New Embroidery Project',
    width: 960,
    contentPadding: EdgeInsets.zero,
    body: Builder(
      builder: (context) => SizedBox(
        height: 540,
        child: NewProjectPage(
          onCancel: () => Navigator.pop(context),
          onCreate: (name, hoop, units, colorProfile, location) {
            Navigator.pop(context);
            app.createProject(
              name: name,
              hoop: hoop,
              units: units,
              colorProfile: colorProfile,
              location: location,
            );
          },
        ),
      ),
    ),
  );
}

/// Close flow (UI-013): clean tabs close immediately; dirty tabs prompt
/// Save / Discard / Cancel. Closing the last tab returns to Home.
Future<void> requestCloseTab(
    BuildContext context, AppViewModel app, int index) async {
  if (index < 0 || index >= app.tabs.length) return;
  final tab = app.tabs[index];
  if (!tab.dirty) {
    app.closeTab(index);
    return;
  }
  final choice = await showStudioDialog<String>(
    context: context,
    title: 'Unsaved Changes',
    body: Text('Save changes to ${tab.title} before closing?'),
    actions: [
      Builder(
        builder: (context) => StudioButton(
          label: 'Cancel',
          variant: StudioButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      Builder(
        builder: (context) => StudioButton(
          label: 'Discard',
          variant: StudioButtonVariant.danger,
          onPressed: () => Navigator.pop(context, 'discard'),
        ),
      ),
      Builder(
        builder: (context) => StudioButton(
          label: 'Save',
          variant: StudioButtonVariant.primary,
          onPressed: () => Navigator.pop(context, 'save'),
        ),
      ),
    ],
  );
  switch (choice) {
    case 'discard':
      app.closeTab(index);
    case 'save':
      final path = tab.path ??
          await pickSavePath(
            suffix: '.swl',
            suggestedName: '${tab.title}.swl',
          );
      if (path == null) return;
      await app.saveTab(tab, path);
      app.closeTab(app.tabs.indexOf(tab));
  }
}
