# UI
## UI-502 Layer Panel

**Document ID:** UI-502  
**Title:** Layer Panel  
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

This document defines the layer panel architecture for Sewlio Studio.

It describes how the UI surface supports a professional embroidery, CAD, and digitizing workflow without owning domain logic.

All behavior described here is presentation, interaction, or workflow orchestration layered on top of the command system and state projections exposed by the runtime.

---

# Philosophy

The layer panel is command-driven and state-derived.

UI components may gather intent, display projections, and stage previews, but they must never mutate the project directly or embed embroidery rules that belong in the core engine.

The interface should feel precise, low-latency, and trustworthy for expert operators working on dense, production-bound documents.

---

# Goals

- Provide hierarchy navigation
- Provide visibility and lock state
- Provide ordering commands
- Provide batch actions

---

# Definition

Layer Panel is the UI subsystem responsible for exposing hierarchy navigation and visibility and lock state to end users.

Its state is derived from document snapshots, view models, user preferences, task status, and permission-aware extension contributions.

Its outputs are visual feedback, validated intent capture, and command requests dispatched through the application bridge.

---

# Responsibilities

- Render layer panel state using deterministic projections from the document model and runtime services.
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

The layer panel participates in this loop without bypassing command validation, event propagation, or scheduler-owned background work.

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

- Plugin-specific extensions for layer panel.
- Cross-device adaptations for tablet and web workflows where applicable.
- Advanced telemetry and usage analytics for expert workflow optimization.
- Incremental refinements informed by testing, accessibility audits, and production feedback.

---

# Acceptance Criteria

- The layer panel surface can be implemented without introducing direct domain mutations from UI code.
- All described states and interactions can be derived from documented runtime services, commands, events, and document projections.
- Cross-references align with existing architecture and domain specifications.
- The document is specific enough to guide implementation, testing, and plugin-safe extension design.

---

# Implementation Status (MVP)

Implemented as `LayersPanelContent` in
`apps/studio/lib/src/panels/layers_panel.dart`, hosted by the dock
(UI-202). The panel represents the editable document model only —
stitch-kind vocabulary lives in the Stitches panel (UI-509, ADR-036).

## As built

- **Naming** — nodes show design-origin names: user name, else
  `<Rectangle>`/`<Ellipse>`/… (stamped by the Shape tool), `<Text>`,
  `<Path>`; layers/groups keep their stored names (ADR-036).
- **Rename** — layers, groups, AND objects: click the selected label
  (Finder-style), F2, or context menu. Layer/group rename dispatches
  `RenameLayer`/`RenameGroup`; object rename dispatches
  `ReplaceObject(object.withName(...))` — all undoable.
- **Search** — real-time, case-insensitive partial filter; a match
  keeps its ancestor path, a matched container reveals its subtree;
  match paths force-expand while filtering; matches highlight.
- **Thumbnails** — every row previews geometry (`object_visuals.dart`):
  objects draw their render contours in thread colour; layers/groups
  show a composite of all descendants; empty containers fall back to a
  kind icon in the same frame.
- **Selection feedback** — selected rows: fill + 2 px accent bar;
  ancestors of the selection: dimmed accent bar + tinted icon + medium
  label; Illustrator-style target dot (filled = selected, ring =
  contains selection, faint on hover; click to select).
- **Auto-expand** — selecting elsewhere (canvas, Stitches) expands
  collapsed ancestors; manual collapse is respected until the selection
  changes.
- **Drag-drop** — pointer-anchored drags with positional zones: top
  quarter inserts before, bottom quarter after, middle nests into
  containers; layers reorder only against layers. All drops issue
  `MoveNode`.
- **Context menu** — custom fast popover (`context_menu.dart`): Rename,
  Duplicate, Delete, Group Selection, Ungroup, Move to Layer… (second-
  level layer picker), Expand/Collapse, Select Parent, Lock/Unlock,
  Hide/Show — state-aware labels, disabled when irrelevant.
- **Bottom toolbar** — context-aware: Add Layer / Group / Ungroup ·
  Expand All / Collapse All / Select Parent · Duplicate / Delete.
- **Shortcut safety** — single-key tool shortcuts are inert while any
  text field (rename, search) has focus; modifier chords pass through.

## Not yet built

Solo layer, isolation mode, masks, per-layer colours, multi-select
drag, virtualized rows for very large documents.
