import 'package:flutter/material.dart';

/// Platform-agnostic application menu model (ADR-039): the menu tree
/// is defined once (`buildAppMenus`) and rendered per platform —
/// native macOS menu bar, in-app menu bar (Windows/Linux/web/tablet),
/// and any future surface (command palette, overflow menu).
///
/// Nodes are fully resolved at build time: labels, enabled state
/// (action == null → disabled), checked state, and the callback. The
/// renderers stay dumb tree→widget mappers.
sealed class MenuNode {
  const MenuNode();
}

/// A menu (top level) or nested submenu.
final class AppMenu extends MenuNode {
  const AppMenu(this.label, this.children, {this.nativeOnly = false});

  final String label;
  final List<MenuNode> children;

  /// Rendered only by the native (macOS) renderer — the app menu and
  /// the Window menu are OS chrome, not application commands.
  final bool nativeOnly;
}

/// A leaf command item. [command] is the stable identifier
/// (`file.save`, `edit.undo`) shared by menus, shortcuts, and future
/// palettes/plugins; [action] is the resolved callback (null =
/// disabled); [checked] non-null marks a toggle.
final class AppMenuItem extends MenuNode {
  const AppMenuItem({
    required this.command,
    required this.label,
    this.shortcut,
    this.action,
    this.checked,
    this.icon,
  });

  final String command;
  final String label;
  final SingleActivator? shortcut;
  final VoidCallback? action;
  final bool? checked;

  /// Optional icon, rendered where the platform supports it (in-app
  /// menu bar); the native macOS menu ignores it.
  final IconData? icon;
}

/// Separator between logical groups.
final class AppMenuDivider extends MenuNode {
  const AppMenuDivider();
}

/// A macOS-provided menu item (About, Quit, Minimize…). Skipped by
/// non-native renderers.
final class AppMenuNative extends MenuNode {
  const AppMenuNative(this.type);

  final PlatformProvidedMenuItemType type;
}

// --------------------------------------------------------------- plugins

/// A plugin/menu extension: contributes nodes either into an existing
/// top-level menu (by [intoMenu] label, appended after a divider) or —
/// when [intoMenu] is null — as new top-level menus inserted before
/// Help. Contributions appear on every platform because all renderers
/// consume the same merged tree (ADR-033 registry pattern).
final class MenuContribution {
  const MenuContribution({this.intoMenu, required this.build});

  final String? intoMenu;
  final List<MenuNode> Function() build;
}

final menuContributions = <MenuContribution>[];

/// Applies [menuContributions] to a built menu tree.
List<AppMenu> mergeContributions(List<AppMenu> menus) {
  var merged = [
    for (final menu in menus)
      AppMenu(
        menu.label,
        [
          ...menu.children,
          for (final c in menuContributions)
            if (c.intoMenu == menu.label) ...[
              const AppMenuDivider(),
              ...c.build(),
            ],
        ],
        nativeOnly: menu.nativeOnly,
      ),
  ];
  final topLevel = [
    for (final c in menuContributions)
      if (c.intoMenu == null) ...c.build().whereType<AppMenu>(),
  ];
  if (topLevel.isNotEmpty) {
    final helpIndex = merged.indexWhere((m) => m.label == 'Help');
    merged = [...merged]
      ..insertAll(helpIndex < 0 ? merged.length : helpIndex, topLevel);
  }
  return merged;
}

// -------------------------------------------------------------- commands

/// Every command item in the tree, flattened — the lookup behind
/// [invokeMenuCommand] and shortcut binding.
Iterable<AppMenuItem> menuItems(List<AppMenu> menus) sync* {
  Iterable<AppMenuItem> walk(List<MenuNode> nodes) sync* {
    for (final node in nodes) {
      if (node is AppMenuItem) yield node;
      if (node is AppMenu) yield* walk(node.children);
    }
  }

  yield* walk([for (final m in menus) ...m.children]);
}

/// Runs the command with [id] from a built tree; returns whether an
/// enabled item was found. This is the non-menu entry point — toolbar
/// buttons, scripting, and a future command palette invoke the same
/// commands the menus do.
bool invokeMenuCommand(List<AppMenu> menus, String id) {
  for (final item in menuItems(menus)) {
    if (item.command == id) {
      item.action?.call();
      return item.action != null;
    }
  }
  return false;
}

/// Shortcut → action bindings for platforms without a native menu bar
/// (there the OS dispatches shortcuts itself). macOS-convention `meta`
/// activators are translated to `control` per desktop convention.
Map<ShortcutActivator, VoidCallback> menuShortcutBindings(List<AppMenu> menus) {
  final bindings = <ShortcutActivator, VoidCallback>{};
  for (final item in menuItems(menus)) {
    final shortcut = item.shortcut;
    final action = item.action;
    if (shortcut == null || action == null) continue;
    bindings[SingleActivator(
      shortcut.trigger,
      control: shortcut.meta || shortcut.control,
      shift: shortcut.shift,
      alt: shortcut.alt,
    )] = action;
  }
  return bindings;
}
