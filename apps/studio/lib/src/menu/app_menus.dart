import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_shell.dart';
import '../app_view_model.dart';
import '../panels/panel_registry.dart';
import '../shell.dart';
import '../workspace_view_model.dart';
import 'app_menu.dart';

/// THE application menu definition (ADR-039) — single source of truth
/// for every platform. Add/change a menu item here and the macOS menu
/// bar, the in-app menu bar, and all shortcut bindings pick it up.
///
/// Items resolve their enabled state at build time (action == null =
/// disabled); the tree is rebuilt whenever the app view model
/// notifies, so states stay live.
List<AppMenu> buildAppMenus(BuildContext context, AppViewModel app) {
  final tab = app.activeTab;
  final model = tab?.vm;
  VoidCallback? withModel(void Function(WorkspaceViewModel m) f) =>
      model == null ? null : () => f(model);

  return mergeContributions([
    // macOS application menu (About/Services/Hide/Quit) — OS chrome.
    AppMenu('Sewlio Studio', nativeOnly: true, [
      const AppMenuNative(PlatformProvidedMenuItemType.about),
      const AppMenuDivider(),
      // ponytail: no preferences UI yet — greyed-out placeholder keeps
      // the conventional slot until settings exist.
      const AppMenuItem(
        command: 'app.settings',
        label: 'Settings…',
        shortcut: SingleActivator(LogicalKeyboardKey.comma, meta: true),
      ),
      const AppMenuNative(PlatformProvidedMenuItemType.servicesSubmenu),
      const AppMenuDivider(),
      const AppMenuNative(PlatformProvidedMenuItemType.hide),
      const AppMenuNative(PlatformProvidedMenuItemType.hideOtherApplications),
      const AppMenuNative(PlatformProvidedMenuItemType.showAllApplications),
      const AppMenuNative(PlatformProvidedMenuItemType.quit),
    ]),
    AppMenu('File', [
      AppMenuItem(
        command: 'file.new',
        label: 'New Project…',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyN, meta: true),
        action: () => showNewProjectDialog(context, app),
      ),
      AppMenuItem(
        command: 'file.open',
        label: 'Open Project…',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
        action: () => openProjectWithPicker(context, app),
      ),
      AppMenu('Open Recent', [
        if (app.recents.entries.isEmpty)
          const AppMenuItem(
              command: 'file.openRecent.none', label: 'No Recent Projects')
        else ...[
          for (final (i, recent) in app.recents.entries.take(10).indexed)
            AppMenuItem(
              command: 'file.openRecent.$i',
              label: recent.name,
              action: () => app.openProject(recent.path),
            ),
          const AppMenuDivider(),
          AppMenuItem(
            command: 'file.clearRecents',
            label: 'Clear Menu',
            action: app.clearRecents,
          ),
        ],
      ]),
      const AppMenuDivider(),
      AppMenuItem(
        command: 'file.close',
        label: 'Close Project',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyW, meta: true),
        action: tab == null
            ? null
            : () => requestCloseTab(context, app, app.active),
      ),
      const AppMenuDivider(),
      AppMenuItem(
        command: 'file.save',
        label: 'Save',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
        action: tab == null ? null : () => saveActiveProject(context, app),
      ),
      AppMenuItem(
        command: 'file.saveAs',
        label: 'Save As…',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyS,
            meta: true, shift: true),
        action: tab == null
            ? null
            : () => saveActiveProject(context, app, saveAs: true),
      ),
      AppMenuItem(
        command: 'file.rename',
        label: 'Rename…',
        action: withModel((m) => showRenameDialog(context, m)),
      ),
      const AppMenuDivider(),
      AppMenuItem(
        command: 'file.importSvg',
        label: 'Import SVG…',
        action: withModel((m) => importSvgWithPicker(context, m)),
      ),
      AppMenuItem(
        command: 'file.exportDst',
        label: 'Export DST…',
        action: withModel((m) => exportWithPicker(context, m, '.dst')),
      ),
      AppMenuItem(
        command: 'file.exportExp',
        label: 'Export EXP…',
        action: withModel((m) => exportWithPicker(context, m, '.exp')),
      ),
      const AppMenuDivider(),
      AppMenuItem(
        command: 'file.documentSetup',
        label: 'Document Setup…',
        action: withModel((m) => showDocumentSetup(context, m)),
      ),
      // ponytail: Project Properties (UI-614) not implemented yet.
      const AppMenuItem(
          command: 'file.projectProperties', label: 'Project Properties…'),
    ]),
    AppMenu('Edit', [
      AppMenuItem(
        command: 'edit.undo',
        label: 'Undo',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
        action: (model?.canUndo ?? false) ? model!.undo : null,
      ),
      AppMenuItem(
        command: 'edit.redo',
        label: 'Redo',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyZ,
            meta: true, shift: true),
        action: (model?.canRedo ?? false) ? model!.redo : null,
      ),
      const AppMenuDivider(),
      // ponytail: no clipboard model yet — conventional greyed-out slots.
      const AppMenuItem(
        command: 'edit.cut',
        label: 'Cut',
        shortcut: SingleActivator(LogicalKeyboardKey.keyX, meta: true),
      ),
      const AppMenuItem(
        command: 'edit.copy',
        label: 'Copy',
        shortcut: SingleActivator(LogicalKeyboardKey.keyC, meta: true),
      ),
      const AppMenuItem(
        command: 'edit.paste',
        label: 'Paste',
        shortcut: SingleActivator(LogicalKeyboardKey.keyV, meta: true),
      ),
      const AppMenuDivider(),
      AppMenuItem(
        command: 'edit.duplicate',
        label: 'Duplicate',
        shortcut: const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
        action:
            (model?.primarySelection != null) ? model!.duplicatePrimary : null,
      ),
      AppMenuItem(
        command: 'edit.delete',
        label: 'Delete',
        action: (model?.primarySelection != null) ? model!.deletePrimary : null,
      ),
    ]),
    AppMenu('View', [
      AppMenuItem(
        command: 'view.zoomIn',
        label: 'Zoom In',
        shortcut: const SingleActivator(LogicalKeyboardKey.equal, meta: true),
        action: withModel((m) => m.zoomBy(1.25)),
      ),
      AppMenuItem(
        command: 'view.zoomOut',
        label: 'Zoom Out',
        shortcut: const SingleActivator(LogicalKeyboardKey.minus, meta: true),
        action: withModel((m) => m.zoomBy(0.8)),
      ),
      AppMenuItem(
        command: 'view.actualSize',
        label: 'Actual Size',
        shortcut: const SingleActivator(LogicalKeyboardKey.digit1, meta: true),
        action: withModel((m) => m.viewport.setPercent(100)),
      ),
      AppMenuItem(
        command: 'view.fitWindow',
        label: 'Fit Design to Window',
        shortcut: const SingleActivator(LogicalKeyboardKey.digit0, meta: true),
        action: withModel((m) => m.fitCanvas()),
      ),
      const AppMenuDivider(),
      AppMenuItem(
        command: 'view.toggleRulers',
        label: 'Rulers',
        checked: model?.showRulers ?? true,
        shortcut: const SingleActivator(LogicalKeyboardKey.keyR,
            meta: true, shift: true),
        action: withModel((m) => m.toggleRulers()),
      ),
      // ponytail: grid/hoop/stitch-point visibility toggles arrive with
      // the corresponding render options; not faked here.
    ]),
    // Dedicated Panels menu (FR-1204): identical on every platform.
    AppMenu('Panels', [
      for (final def in panelRegistry)
        AppMenuItem(
          command: 'panels.toggle.${def.id}',
          label: def.title,
          checked: app.dock.isVisible(def.id),
          action: () => app.dock.togglePanel(def.id),
        ),
      const AppMenuDivider(),
      AppMenuItem(
        command: 'panels.reset',
        label: 'Reset Workspace',
        action: app.dock.resetToDefault,
      ),
    ]),
    // Window management is OS chrome — macOS only.
    const AppMenu('Window', nativeOnly: true, [
      AppMenuNative(PlatformProvidedMenuItemType.minimizeWindow),
      AppMenuNative(PlatformProvidedMenuItemType.zoomWindow),
      AppMenuNative(PlatformProvidedMenuItemType.toggleFullScreen),
      AppMenuDivider(),
      AppMenuNative(PlatformProvidedMenuItemType.arrangeWindowsInFront),
    ]),
    AppMenu('Help', [
      AppMenuItem(
        command: 'help.shortcuts',
        label: 'Keyboard Shortcuts',
        action: () => showShortcutsDialog(context),
      ),
      // ponytail: greyed out until public docs / issue tracker URLs exist.
      const AppMenuItem(command: 'help.documentation', label: 'Documentation'),
      const AppMenuItem(command: 'help.reportIssue', label: 'Report an Issue'),
    ]),
  ]);
}
