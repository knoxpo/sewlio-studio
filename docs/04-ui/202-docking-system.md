# UI
## UI-202 Docking System

**Document ID:** UI-202  
**Title:** Docking System  
**Version:** 1.0.0  
**Status:** Implementation Guidance  
**Priority:** High  
**Owner:** Product Experience Team

**Related Documents**

```text
docs/02-architecture/000-system-overview.md
docs/02-architecture/003-command-system.md
docs/02-architecture/004-event-system.md
docs/02-architecture/005-document-model.md
docs/02-architecture/008-rendering-architecture.md
```
---

# Purpose

This document defines the docking system architecture for Sewlio Studio.

It describes how the UI surface supports a professional embroidery, CAD, and digitizing workflow without owning domain logic.

All behavior described here is presentation, interaction, or workflow orchestration layered on top of the command system and state projections exposed by the runtime.

---

# Philosophy

The docking system is command-driven and state-derived.

UI components may gather intent, display projections, and stage previews, but they must never mutate the project directly or embed embroidery rules that belong in the core engine.

The interface should feel precise, low-latency, and trustworthy for expert operators working on dense, production-bound documents.

---

# Goals

- Provide dock regions
- Provide tear-off behavior
- Provide persistent identities
- Provide layout serialization

---

# Definition

Docking System is the UI subsystem responsible for exposing dock regions and tear-off behavior to end users.

Its state is derived from document snapshots, view models, user preferences, task status, and permission-aware extension contributions.

Its outputs are visual feedback, validated intent capture, and command requests dispatched through the application bridge.

---

# Responsibilities

- Render docking system state using deterministic projections from the document model and runtime services.
- Collect user intent and translate it into command payloads, tool interactions, or task requests.
- Surface validation, progress, diagnostics, and approval requirements before work reaches the domain engine.
- Support plugin-contributed actions or overlays only through declared extension points and sandboxed UI contracts.

---

# Architecture

```text
User Intent

↓

UI Surface

↓

View Model / Interaction State

↓

Command / Task Request

↓

Runtime Services

↓

Events / Derived State

↓

Updated UI
```

The docking system participates in this loop without bypassing command validation, event propagation, or scheduler-owned background work.

---

# UI Rules

- UI must not own embroidery business rules, machine constraints, or file-format semantics.
- All persistent mutations must be issued as commands and reflected back through runtime state.
- Long-running operations must expose scheduler progress, cancellation, and observable failure states.
- Preview state may be ephemeral, but committed state must always be reproducible from commands and document snapshots.

---

# Out of Scope

- Core document mutation logic.
- Embroidery compilation, simulation physics, and machine encoding internals.
- Persistence formats and storage policy enforcement.
- Background execution primitives owned by the task scheduler.

---

# Future Topics

- Plugin-specific extensions for docking system.
- Cross-device adaptations for tablet and web workflows where applicable.
- Advanced telemetry and usage analytics for expert workflow optimization.
- Incremental refinements informed by testing, accessibility audits, and production feedback.

---

# Acceptance Criteria

- The docking system surface can be implemented without introducing direct domain mutations from UI code.
- All described states and interactions can be derived from documented runtime services, commands, events, and document projections.
- Cross-references align with existing architecture and domain specifications.
- The document is specific enough to guide implementation, testing, and plugin-safe extension design.

---

# Implementation Status (MVP)

Implemented in `apps/studio/lib/src/dock/` and `apps/studio/lib/src/panels/`
(in-app for now — see the package-map MVP note; lift into
`packages/studio_panels` with an ADR when a second consumer appears).

## As built

- **Panel registry** — `panels/panel_def.dart`: `PanelDef { id, title,
  icon, minHeight, builder }` in a plain `panelRegistry` list. Adding a
  panel is one list entry; builders wire content widgets to the
  `WorkspaceViewModel` (content stays stateless-props and headless-testable).
- **Layout model** — `dock/dock_layout.dart`: `DockLayout { width,
  groups, hidden }`, `DockGroup { panelIds, activeId, flex, collapsed }`.
  `normalize()` self-repairs against the registry (unknown ids dropped,
  new panels appended, empty groups removed, bounds clamped).
- **Controller** — `dock/dock_controller.dart`: `selectTab / movePanel /
  splitOut / togglePanel / toggleCollapsed / resizePair / resizeWidth /
  resetToDefault`; persists to `~/.sewlio_studio/workspace_layout.json`
  (FR-1003) on every mutation, tolerant load, `.memory()` for tests.
- **Host widget** — `dock/dock_host.dart`: right dock as a vertical
  stack of tabbed groups. Tabs drag to reorder / join groups (insertion
  caret) or tear out via gap zones (mounted only while a tab drag is in
  flight); splitters resize adjacent groups; left-edge handle resizes
  dock width (220–480 px); groups collapse to their tab bar.
- **Window menu** — Show/Hide per registered panel + Reset Workspace, in
  both the native macOS menu bar and the in-app fallback.

## Persistence schema (v1)

```json
{ "version": 1, "width": 300, "hidden": [],
  "groups": [ { "panels": ["stitches", "layers", "properties"],
                "active": "stitches", "flex": 1.0, "collapsed": false } ] }
```

## Not yet built

Floating/tear-off windows, left/bottom dock zones, plugin panel API
(the registry list is the extension point), named workspace presets.
