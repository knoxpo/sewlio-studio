# UI
## UI-604 Print Preview

**Document ID:** UI-604  
**Title:** Print Preview  
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

Terminology note: Print Preview previews document output for normal printing or page-style review. It is not the same as a Digital Printing Project, Print Engine, Print Plan, Print IR, or RIP integration.

This document defines the print preview architecture for Sewlio Studio.

It describes how the UI surface supports a professional embroidery, CAD, and digitizing workflow without owning domain logic.

All behavior described here is presentation, interaction, or workflow orchestration layered on top of the command system and state projections exposed by the runtime.

---

# Philosophy

The print preview is command-driven and state-derived.

UI components may gather intent, display projections, and stage previews, but they must never mutate the project directly or embed embroidery rules that belong in the core engine.

The interface should feel precise, low-latency, and trustworthy for expert operators working on dense, production-bound documents.

---

# Goals

- Provide print-safe layout
- Provide scale verification
- Provide annotation overlays
- Provide non-mutating preview state

---

# Definition

Print Preview is the UI subsystem responsible for exposing print-safe layout and scale verification to end users.

Its state is derived from document snapshots, view models, user preferences, task status, and permission-aware extension contributions.

Its outputs are visual feedback, validated intent capture, and command requests dispatched through the application bridge.

---

# Responsibilities

- Render print preview state using deterministic projections from the document model and runtime services.
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

The print preview participates in this loop without bypassing command validation, event propagation, or scheduler-owned background work.

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

- Plugin-specific extensions for print preview.
- Cross-device adaptations for tablet and web workflows where applicable.
- Advanced telemetry and usage analytics for expert workflow optimization.
- Incremental refinements informed by testing, accessibility audits, and production feedback.

---

# Acceptance Criteria

- The print preview surface can be implemented without introducing direct domain mutations from UI code.
- All described states and interactions can be derived from documented runtime services, commands, events, and document projections.
- Cross-references align with existing architecture and domain specifications.
- The document is specific enough to guide implementation, testing, and plugin-safe extension design.
