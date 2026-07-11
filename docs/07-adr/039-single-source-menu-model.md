# ADR-039: Single-Source Application Menu Model

## Status

Accepted

## Context

The application menu existed twice: `buildPlatformMenus` produced the
native macOS menu bar (full: File/Edit/View/Panels/Window/Help with
shortcuts), while the in-app header `MenuBar` (Windows/Linux/web/
tablets) was a hand-written subset with different labels and no
keyboard shortcuts. The two had already diverged (missing Export/Save
As/View items in-app; "Save…" vs "Save"; Show/Hide flips vs
checkmarks), and every new item had to be added twice.

## Decision

One canonical, platform-agnostic menu tree; renderers per surface.

- **Model** (`apps/studio/lib/src/menu/app_menu.dart`): sealed
  `MenuNode` — `AppMenu` (menu/submenu, `nativeOnly` for OS chrome),
  `AppMenuItem` (stable command id, label, shortcut, resolved action —
  null = disabled, optional checked state and icon), `AppMenuDivider`,
  `AppMenuNative` (macOS-provided items, skipped elsewhere).
- **Definition** (`menu/app_menus.dart`): `buildAppMenus(context, app)`
  builds the entire application menu once, states resolved live
  (enabled/checked/recents/panels). This is the only place menu content
  is defined.
- **Renderers** (`menu/menu_renderers.dart`):
  - `toPlatformMenus` → native macOS menu bar (dividers become
    `PlatformMenuItemGroup`s; checked items get a ✓ label prefix since
    AppKit items expose no checked state through Flutter).
  - `toMenuBarWidget` → in-app `MenuBar` for every platform without a
    global menu (Windows, Linux, web, tablets), checkmark icons and
    shortcut labels included. Linux follows the in-app convention.
  - Future surfaces (command palette, tablet overflow) consume the same
    tree.
- **Shortcuts**: macOS dispatches them natively via the menu; all other
  platforms bind the same definitions app-wide with `CallbackShortcuts`
  (`menuShortcutBindings`), translating macOS-convention `meta`
  activators to `control`. Menus and shortcuts cannot drift.
- **Commands**: every item carries a stable id (`file.save`,
  `edit.undo`, `panels.toggle.<id>`); `invokeMenuCommand(menus, id)`
  triggers the same action from toolbars, scripting, or a future
  command palette.
- **Plugins**: `menuContributions` registry (same pattern as the panel
  registry, ADR-033/037) — a contribution adds items into an existing
  menu (appended after a divider) or new top-level menus inserted
  before Help. Contributions appear on every platform automatically.

## Consequences

- Adding/changing a menu item is a one-place edit; all platforms and
  shortcut bindings update together.
- Non-mac platforms gained the full menu set and working keyboard
  shortcuts (previously macOS-only).
- macOS checked items render as a ✓ prefix rather than a real NSMenuItem
  check — a Flutter `PlatformMenuItem` limitation; revisit if Flutter
  exposes checked state.
- OS window chrome (app menu, Window menu) is modeled as `nativeOnly`
  and simply absent on platforms that manage windows themselves.
