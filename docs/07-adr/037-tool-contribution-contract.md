# ADR-037: Tool Contribution Contract

## Status

Accepted

## Context

Tools integrated with the shell through scattered, parallel mechanisms:
the toolbox list, a separate shortcut map in the workspace view model,
special-cased floating palettes, the contextual options bar, and the
panel registry. Nothing tied them together, shortcut labels and keys
could drift apart, and there was no single answer to "what does a
complete tool contribute?" — a prerequisite for the plugin ecosystem
(ADR-009, ADR-033).

## Decision

A tool integrates with the shell through one registration —
`ToolContribution` (`apps/studio/lib/src/tools/tool_contributions.dart`)
— plus per-surface conventions. The contract's extension points:

1. **Toolbox entry** — identity (`id`, namespaced: `core.*` for
   built-ins, `<plugin>.*` later), label, icon, shortcut label.
   The toolbox layout (`toolboxGroups`) is layout-only; every real
   entry resolves from the contribution, so labels/icons/shortcuts
   cannot drift. Multi-tool slots render flyouts and remember the
   last-used tool.
2. **Shortcut** — `shortcutKey` + optional `shortcutCycle`
   (repeat-press cycles tools, Affinity-style). The view model's
   shortcut map is derived from the registry. Shortcuts are inert while
   a text field has focus; modifier chords belong to the menus.
3. **Quick options** — optional `QuickOptions`: a compact floating
   palette shown while the tool is active (shape variants, presets),
   hosted by `PaletteDock` with per-palette position memory.
4. **Context toolbar** — contextual controls above the canvas
   (`ToolOptionsBar`), rendered per active tool. Controls gather intent
   and dispatch commands; they never mutate documents directly
   (ARCH-003).
5. **Dockable panels** — `panels: [PanelDef...]` join the same registry
   as built-in panels (UI-202): docking, tabbing, persistence, Window
   menu — indistinguishable from first-party panels.
6. **Behavior** — the interaction core (`Tool` in `studio_tools`):
   pointer handling, geometry, cursors, previews. Domain logic stays in
   domain packages; all mutations are commands (undo/redo for free).

### Active tool vs selection

Two deliberately independent contexts:

- **Active tool** drives cursor, pointer behavior, the context toolbar,
  and quick options.
- **Selection** drives the Properties panel: it inspects the selected
  object's type and loads the matching editors, regardless of which
  tool is active (a text object selected with the Move tool still shows
  text properties).

Property editors register by object type, not by tool. Plugins that add
object types register matching property editors the same way.

## Deferred (plugin runtime scope)

Not built until the plugin runtime (ADR-009/019) exists — the contract
above is designed so these slot in without reshaping it:

- Third-party registration/lifecycle, permission boundaries, error
  isolation, version/capability checks, resource disposal.
- Property-editor contribution API for plugin object types.
- Unsupported-object preservation: a document containing objects from a
  disabled/missing plugin must preserve their serialized data and render
  a placeholder state — never corrupt the document. (The serialization
  layer's unknown-type handling is the enforcement point.)

## Consequences

- Adding a built-in tool = one `ToolContribution` + a `Tool` behavior +
  a `ToolOptionsBar` section + optional toolbox-layout slot. Tests
  enforce registry invariants (unique namespaced ids, one contribution
  per kind, collision-free shortcuts, toolbox/registry consistency).
- Plugins get a single, documented integration surface; per-tool custom
  shell wiring is no longer needed for the covered extension points.
