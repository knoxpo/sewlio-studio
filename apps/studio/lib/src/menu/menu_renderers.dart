import 'package:flutter/material.dart';

import 'app_menu.dart';

/// Renderers for the shared menu model (ADR-039). Each consumes the
/// same `List<AppMenu>` and maps it onto one platform's menu widgets —
/// menu content is never defined here.

// ------------------------------------------------------- native (macOS)

/// Native macOS menu bar. Groups split at dividers become
/// [PlatformMenuItemGroup]s (AppKit draws the separators); checked
/// toggles get a ✓ prefix because [PlatformMenuItem] has no checked
/// state.
List<PlatformMenu> toPlatformMenus(List<AppMenu> menus) => [
      for (final menu in menus)
        PlatformMenu(label: menu.label, menus: _platformChildren(menu.children))
    ];

List<PlatformMenuItem> _platformChildren(List<MenuNode> nodes) {
  final groups = <List<PlatformMenuItem>>[[]];
  for (final node in nodes) {
    switch (node) {
      case AppMenuDivider():
        groups.add([]);
      case AppMenu():
        groups.last.add(PlatformMenu(
            label: node.label, menus: _platformChildren(node.children)));
      case AppMenuNative(:final type):
        groups.last.add(PlatformProvidedMenuItem(type: type));
      case AppMenuItem():
        groups.last.add(PlatformMenuItem(
          label: node.checked == true ? '✓ ${node.label}' : node.label,
          shortcut: node.shortcut,
          onSelected: node.action,
        ));
    }
  }
  return [
    for (final group in groups)
      if (group.isNotEmpty) PlatformMenuItemGroup(members: group),
  ];
}

// --------------------------------------------------- in-app (everywhere)

/// In-app menu bar for platforms without a native global menu
/// (Windows, Linux, web, tablets). Native-only menus/items are OS
/// chrome and skipped; checked toggles get a leading ✓ icon; shortcut
/// labels show the platform convention (Ctrl via the activator
/// translation in [menuShortcutBindings]'s sibling below).
Widget toMenuBarWidget(List<AppMenu> menus) => MenuBar(
      children: [
        for (final menu in menus)
          if (!menu.nativeOnly)
            SubmenuButton(
              menuChildren: _menuBarChildren(menu.children),
              child: Text(menu.label),
            ),
      ],
    );

List<Widget> _menuBarChildren(List<MenuNode> nodes) {
  final children = <Widget>[];
  var pendingDivider = false;
  void add(Widget child) {
    if (pendingDivider && children.isNotEmpty) {
      children.add(const Divider(height: 8));
    }
    pendingDivider = false;
    children.add(child);
  }

  for (final node in nodes) {
    switch (node) {
      case AppMenuDivider():
        pendingDivider = true;
      case AppMenuNative():
        break; // OS chrome — no in-app equivalent.
      case AppMenu():
        add(SubmenuButton(
          menuChildren: _menuBarChildren(node.children),
          child: Text(node.label),
        ));
      case AppMenuItem():
        add(MenuItemButton(
          onPressed: node.action,
          shortcut:
              node.shortcut == null ? null : _desktopActivator(node.shortcut!),
          leadingIcon: node.checked != null
              ? Icon(node.checked! ? Icons.check : null, size: 14)
              : (node.icon != null ? Icon(node.icon, size: 14) : null),
          child: Text(node.label),
        ));
    }
  }
  return children;
}

/// macOS-convention `meta` shortcuts read as Ctrl on other desktops.
SingleActivator _desktopActivator(SingleActivator s) => SingleActivator(
      s.trigger,
      control: s.meta || s.control,
      shift: s.shift,
      alt: s.alt,
    );
