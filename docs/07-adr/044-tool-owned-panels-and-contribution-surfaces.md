# ADR-044: Tool-Owned Panels and Contribution Surfaces

## Status

Accepted

## Context

ADR-037 defined `ToolContribution` as a tool's single registration —
including `panels: [PanelDef...]` — but three seams remained between
that contract and the shell:

1. **Non-deterministic panel aggregation.** Tool panels joined
   `panelRegistry` only through a `main()`-time `addAll`, so tests and
   any other composition root saw a registry without tool panels, and
   no tool actually declared one — the path had never been exercised.
2. **Hardcoded tool→UI mapping.** `ToolOptionsBar` switched on the
   concrete `Tool` runtime type to render each tool's contextual
   controls, and `WorkspaceViewModel._bind` hardwired every tool's
   construction — both shell-side special-casing that a plugin tool
   could not participate in.
3. **No activation behavior.** Nothing defined what happens to a
   tool's panel when the tool activates; ad-hoc solutions would have
   crept in per tool.

## Decision

Extend ADR-037's contract (this ADR does not supersede it) and close
the seams with data on the contribution, evaluated by generic shell
machinery:

1. **Deterministic registry.** `PanelDef` (the contract) and the
   registry list are separate files; `panelRegistry`
   (`apps/studio/lib/src/panels/panel_registry.dart`) aggregates
   built-ins plus `toolContributedPanels()` at declaration. Every
   composition root — app, tests, future plugin host — sees the same
   list with no startup wiring.
2. **Panel ownership model.** Three owners, one consumption path:
   - **Tool-owned** — declared in `ToolContribution.panels`; joins
     `panelRegistry` (docking, tabbing, persistence, Window menu —
     indistinguishable from built-ins, per ADR-037).
   - **Feature/domain-owned** — declared on `DomainUiModule`
     (`domainPanels`/`simulationPanels`, ARCH-038); scoped to the
     domain/simulation docks via `AppViewModel.dockFor`.
   - **Built-in** — the app's own design panels.
   Tool UI lives in-app, folder-per-tool
   (`apps/studio/lib/src/tools/<tool>/`): contribution, options
   builder, panel widgets. Later extraction to `packages/studio_panels`
   (UI-202's gate: a second consumer) becomes pure file moves.
3. **Availability rules map to existing mechanisms — no rule engine:**
   - *Always available* → registered in `panelRegistry`; the dock's
     hidden set (user-controlled, persisted) governs visibility.
   - *Document-mode-scoped* → `DomainUiModule` + per-mode
     `DockController`.
   - *Tool-active* → reveal-on-activate (below); the panel itself stays
     a normal dockable panel.
   - *Selection-scoped* → panels adapt their content to the selection
     (the Properties panel's existing pattern); panels never appear or
     disappear on selection changes.
4. **Reveal-on-activate.** Optional `revealPanel: String?` on
   `ToolContribution`. When the tool activates, the shell selects that
   panel's tab **only if the panel is currently in a dock group** —
   never un-hides, never mutates layout. User customisation wins: a
   user-closed panel stays closed. "Restore previous state" is emergent
   from dock persistence.
5. **Options toolbar from the contribution.** Optional
   `optionsBuilder` on `ToolContribution` replaces `ToolOptionsBar`'s
   runtime-type switch; the bar keeps the chrome and renders whatever
   the active tool's contribution builds. The concrete-type knowledge
   moves into the tool's own folder.
6. **Tool construction from the contribution.** Optional
   `createTool: Tool Function(WorkspaceViewModel)` on
   `ToolContribution`; `_bind` consults contributions first and falls
   back to its inline defaults, migrating per tool.

The Select tool is the reference implementation: its contribution
lives in `tools/select/select_contribution.dart` and owns the
`transform` panel (selection/move semantics), exercising the full
chain: contribution → registry → default rows → `panelById` → Panels
menu → persistence.

## Deferred

- `packages/studio_panels` extraction — gated on a second consumer
  (UI-202, ADR-033).
- `availableWhen` predicates / availability rule objects — every rule
  requested so far maps onto an existing mechanism; add when a panel
  genuinely needs conditional *presence*.
- `createTool` for the remaining built-in tools — migrated
  opportunistically; their construction closures are heterogeneous and
  bulk migration is churn without behavior change.
- A subtools API — toolbox flyout groups already cover grouped tools.
- Narrowing the panel-builder signature away from
  `WorkspaceViewModel` — revisit at package extraction.
- Third-party registration/lifecycle — plugin runtime scope, per
  ADR-037's deferral.

## Consequences

- A tool (built-in today, plugin later) contributes toolbox entry,
  shortcut, quick options, contextual options, dockable panels,
  activation behavior, and construction through one registration; the
  shell contains no per-tool conditionals for any of these surfaces.
- Registry content is identical in production and tests, so dock
  layout, normalization, and Panels-menu behavior are testable without
  replaying `main()` wiring.
- Existing dock tests (default rows, persistence, domain-panel
  isolation) hold unchanged: default layout stays owned by
  `designPanelRows`, and panel ids are stable through the ownership
  transfer.
