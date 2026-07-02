# Implementation

## IMPL-000 Implementation Roadmap

> **Phase 2 document (ADR-026).** This is the **long-term Rust production plan**, preserved intact.
> The **active MVP is Flutter/Dart-only** — see [`000-roadmap.md`](000-roadmap.md) and
> [`../07-adr/026-use-dart-engine-for-mvp.md`](../07-adr/026-use-dart-engine-for-mvp.md). Everything
> below (Rust packages, IR ownership, first-10 Rust tasks) is the Phase 2 migration target, not the
> MVP track. Nothing here is abandoned.

**Document ID:** IMPL-000
**Title:** Implementation Roadmap
**Version:** 1.0.0
**Status:** Foundation (Critical) — Phase 2 (Rust), deferred per ADR-026
**Priority:** Critical
**Owner:** Core Engineering Team

**Related Documents**

```text
docs/02-architecture/000-system-overview.md          (§35 impl order, §34 non-negotiables)
docs/02-architecture/001-intermediate-representations.md
docs/02-architecture/018-package-ownership.md
docs/02-architecture/029-build-system.md
docs/05-engineering/100-monorepo-structure.md
docs/05-engineering/500-testing-strategy.md
```

---

# 1. Purpose & Status

This document turns the existing architecture specs into an executable build plan. It is a
**derivative** of the docs — it adds no new architecture. Where this roadmap and a spec
disagree, the spec wins and this file is the bug.

Repository state at time of writing: **`docs/` only**. No code, no Cargo workspace, no
Flutter app, not yet a git repository. Everything below is greenfield.

Source-of-truth anchors (do not contradict):

- Stack & boundary: `02-architecture/000` §5–7, `05-engineering/100`
- The 5 IRs: `02-architecture/001`
- Package layers & ownership: `02-architecture/018`
- Recommended impl order: `02-architecture/000` §35
- Non-negotiable rules: `02-architecture/000` §34

---

# 2. Stack Summary

```text
Flutter UI  (presentation only)
    │  Commands ↓        Events ↑
Bridge layer  (FFI on native, WASM on web)
    │
Rust Core Engine  (ALL business logic, headless-capable)
    │
Local Persistence  (.embproj package, libSQL/Turso DB, assets, recovery)
```

The app's identity is a **compiler pipeline for embroidery** (`02-architecture/000` §3):

```text
External Input → Import IR → Geometry IR → Stitch IR → ┬─ Playback IR → Simulation
                                                       └─ Machine IR  → Export (DST/PES/…)
```

Rust = Cargo workspace. Flutter = app packages. They meet only at the bridge, and only
through Commands (down) and Events (up). Flutter never mutates state (`02-architecture/000`
§34 rule 1).

---

# 3. Docs → Packages Map

Layer column uses the ownership hierarchy from `02-architecture/018`. Every package sits in
exactly one layer; dependencies flow **downward only**.

| Doc section | Implements | Package | Layer |
|---|---|---|---|
| `02-arch/023` runtime lifecycle, `024` service registry, `025` resources, `026` scheduler, `028` observability; `05-eng/600–605` | Lifecycle, ids, time, logging, config, scheduler, thread/memory pools, diagnostics, tracing, service registry | `engine/kernel` | Kernel |
| `02-arch/003` commands, `004` events, `027` dependency graph; `05-eng/201–206` | Command bus, event bus, task runtime, dependency graph, dirty tracking, resource handles, execution context | `engine/runtime` | Runtime |
| `02-arch/005` document model, `006` project format; `01-product/700` | Workspace/project/document/session/extension/permission managers | `engine/platform` | Platform |
| `03-domain/geometry/*` | Points, curves, paths, groups, layers, transforms — **owns Geometry IR** | `engine/domains/geometry` | Domain |
| `03-domain/embroidery/*` | Embroidery objects, stitch settings, density, underlay, fill params, compensation | `engine/domains/embroidery` | Domain |
| `03-domain/threads/*` | Thread libraries, colors, palettes, mappings | `engine/domains/thread` | Domain |
| `03-domain/machine/*` | Machine profiles, capabilities, constraints, hoops, manufacturing settings | `engine/domains/machine` | Domain |
| `03-domain/fabrics/*` | Material profiles, stabilizers, stretch/distortion params | `engine/domains/fabric` | Domain |
| `01-product/800–900`, asset refs | Images, fonts, templates, fabric assets, external refs | `engine/domains/asset` | Domain |
| `03-domain/import/*`; `02-arch/015`; `05-eng/402` | Format parsing, normalization, validation — **owns Import IR** | `engine/compilers/import` | Compiler |
| `03-domain/embroidery/*` + `06-ai/300–306`; `02-arch/009` | Digitizer passes (running/satin/fill/underlay), optimization — **owns Stitch IR** | `engine/compilers/digitizer` | Compiler |
| `02-arch/010`; `03-domain/simulation/*` | Timeline/frame generation, playback stats — **owns Playback IR** | `engine/compilers/playback` | Compiler |
| `03-domain/export/800,806`; `03-domain/machine/307`; `02-arch/011` | Needle assignment, thread mapping, machine/hoop validation — **owns Machine IR** | `engine/compilers/machine` | Compiler |
| `03-domain/export/801–805`; `02-arch/012`; `05-eng/403` | One crate per format: binary encoding, streaming, verification | `engine/generators/{dst,exp,pes,jef,vp3,hus}` | Generator |
| `02-arch/007`, `006`; `05-eng/400–405` | Persistence, serialization, migration, atomic saves, recovery integration | `engine/services/storage` | Service |
| `05-eng/300–306`; `04-ui/300,803`; `02-arch/008` | Scene graph, GPU submission, dirty regions, LOD, viewport renderable model | `engine/services/rendering` | Service |
| `03-domain/simulation/*`; `04-ui/702` | Playback execution, controls, playback state | `engine/services/simulation` | Service |
| `02-arch/013`; `01-product/1500`; `05-eng/106,701,702` | Plugin runtime, sandbox, extension registry, lifecycle | `engine/services/plugin` | Service |
| `06-ai/*`; `02-arch/014`; `01-product/1600` | Conversations, planning, tool orchestration, prompts, model adapters, knowledge graph, rule engine | `engine/services/ai-runtime` | Service |
| `02-arch/017`; `05-eng/700–704` | Permissions, policies, authorization, audit, secure storage | `engine/services/security` | Service |
| `02-arch/000` §8, §29; `05-eng/103,104,105` | FFI + WASM marshaling, message contracts, command dispatch, progress events | `engine/bridges/{ffi,wasm}` | Bridge |
| `04-ui/100–206`, `600–605` | Shell, window, navigation, theme, workspaces, docking, panels, toolbars, command palette | `apps/flutter/shell` + `apps/flutter/panels` | Flutter |
| `04-ui/300–408` | Canvas widget, gestures, selection visuals, tools | `apps/flutter/canvas` | Flutter |
| `04-ui/*` reusable widgets | Reusable UI components, no business logic | `apps/flutter/widgets` | Flutter |
| `06-ai/500–505`; `04-ui/700–701` | AI assistant UI, chat, quality inspector UI | `apps/flutter/ai` | Flutter |

---

# 4. Recommended Package Boundaries

Restated from `02-architecture/018` — enforce, do not redesign.

**Layer ladder (deps flow down only, never up):**

```text
kernel → runtime → platform → domains → compilers → generators → services → bridges → flutter
```

**IR ownership matrix** (`02-architecture/001` — one owner each, no package owns another's IR):

| IR | Owner package | Lifetime |
|---|---|---|
| Import IR | `engine/compilers/import` | Temporary (destroyed after Geometry IR) |
| Geometry IR | `engine/domains/geometry` | Project lifetime, resident |
| Stitch IR | `engine/compilers/digitizer` | Project lifetime, resident |
| Playback IR | `engine/compilers/playback` | Disposable cache, regenerable |
| Machine IR | `engine/compilers/machine` | Generated on demand during export |

**Rules:**

- One responsibility per package. If two packages own a thing, neither does.
- Package size target 500–3,000 LOC; prefer <2,000; decompose larger.
- Cross-package communication **only** via Commands, Events, pipeline outputs, public APIs.
- Forbidden: shared mutable state, private struct access, direct DB access, global singletons,
  circular deps. Break cycles with an event or an interface.
- Every package exposes Public API → Internal API → Private impl; internals never leak.
- Each IR is immutable, versioned, serializable, deterministic, platform- and (until Machine IR)
  machine-independent.

---

# 5. Implementation Phases

The master prompt's Phases 1–8 folded onto the doc's impl order (`02-architecture/000` §35).
**Strategy: foundation first, then drive one thin vertical slice `SVG → DST` end-to-end** to
prove the whole compiler pipeline before widening any single stage.

| Phase | Goal | Packages | IRs introduced | Exit criteria |
|---|---|---|---|---|
| **1. Foundation** | Workspace, kernel, runtime primitives, error/diagnostics, test harness | `engine/kernel`, `engine/runtime` | — | Cargo workspace builds; command + event bus dispatch round-trips in a unit test; CI green |
| **2. Geometry + Domain Core** | Coordinate system, paths, curves, transforms, bboxes, geometry algorithms | `engine/domains/geometry` | **Geometry IR** | Geometry IR serializes deterministically; validation + golden fixtures pass |
| **3. Document + Project** | Immutable document model over Geometry IR, command-driven mutation, `.embproj`, storage | `engine/platform`, `engine/services/storage` | — | Create/move/delete object via Command emits Events; project round-trips through `.embproj` |
| **4. Embroidery Core (slice)** | Running stitch first (satin/fill/underlay/compensation/optimization follow) | `engine/domains/embroidery`, `engine/compilers/digitizer` | **Stitch IR** | Geometry IR → Stitch IR for running stitch; golden stitch test passes |
| **5. Machine + Export (slice)** | Machine model, machine compiler, DST first (EXP second, PES/JEF/VP3 later) | `engine/domains/machine`, `engine/compilers/machine`, `engine/generators/dst` | **Machine IR** | **Headless `SVG → … → DST` integration test passes** (the architecture proof) |
| **6. Import (widen)** | Vector (SVG) → raster → embroidery import; normalization pipeline | `engine/compilers/import` | **Import IR** | SVG round-trips to Geometry IR via Import IR + normalizer; golden import test |
| **7. Rendering + Simulation** | Scene graph, render graph, viewport, thread render, playback | `engine/services/rendering`, `engine/compilers/playback`, `engine/services/simulation` | **Playback IR** | Stitch IR → Playback IR; renderable model produced headlessly |
| **8. UI** | Flutter shell, canvas, tools, inspector, panels, import/export UI | `engine/bridges/*`, `apps/flutter/*` | — | Flutter sends a Command, receives Events, renders canvas across the bridge |
| **9. AI** | Knowledge graph, rule engine, AI digitizer, quality inspector, assistant | `engine/services/ai-runtime`, `apps/flutter/ai` | — | AI emits Commands only; actions reviewable, undoable, auditable, permission-gated |

Note: Import (Phase 6) lands after the slice because the slice can be driven by a hand-built
Geometry IR fixture, letting `SVG→DST` be proven before the SVG parser is hardened. This keeps
the earliest integration test cheap without violating the doc's order (Import IR is still
defined before it is widened).

---

# 6. Testing Strategy Per Phase

Levels from `05-engineering/500` and `02-architecture/000` §31. Each package owns its unit,
golden, and API-compat tests; integration tests belong to the Platform layer.

| Phase | Required tests |
|---|---|
| 1 | Unit (kernel primitives, bus dispatch); fault-injection on lifecycle/cancellation |
| 2 | Geometry IR: unit + serialization + migration + validation + **golden fixtures**; perf bench Import IR target <200 ms reserved |
| 3 | Document command/event integration; `.embproj` round-trip; atomic-write + recovery fault tests |
| 4 | Stitch IR golden fixtures; determinism test (same Geometry IR ⇒ identical Stitch IR) |
| 5 | Machine IR validation (limits/needle/hoop); **DST binary golden**; **headless `SVG→DST` integration test (gate)**; perf bench Machine compile <500 ms |
| 6 | Import golden fixtures per format; compatibility tests for real-world SVGs |
| 7 | Playback IR timeline-consistency tests; renderable-model golden; rendering perf bench |
| 8 | Flutter widget tests; bridge contract tests; no business logic asserted in UI tests |
| 9 | AI eval harness; safety tests (no direct mutation, approval required); audit-trail tests |

Cross-cutting from day one: every new IR ships with unit + serialization + migration tests
before any consumer is written. Regression suite grows with every fixed bug.

---

# 7. First 10 Coding Tasks

Each task names its package and its test deliverable. Order is a strict refinement of
`02-architecture/000` §35 — no task depends on a later one.

1. **Init Cargo workspace + `engine/kernel`.** Lifecycle, UUID, time, logging, config,
   diagnostics core. CI skeleton (fmt, clippy, test). *Test:* kernel unit tests + CI green.
2. **`engine/runtime`: command + event bus.** Trait-defined `Command`/`Event`, in-memory
   dispatch, execution context. *Test:* command dispatch emits expected event (unit).
3. **IR base + golden harness.** Shared traits: versioned, serializable (binary + debug JSON),
   immutable, deterministic. Golden-fixture test helper. *Test:* round-trip serialization +
   schema-version assertion.
4. **Geometry IR types.** Points, bezier paths, curves, layers, transforms, bounding boxes.
   *Test:* serialization + validation (open paths, dup IDs, broken refs) + golden fixtures.
5. **Document model over Geometry IR.** `engine/platform`: project/layers/objects, mutation
   only via Commands → Events. *Test:* create/move/delete object integration test.
6. **`.embproj` format + storage abstraction.** `engine/services/storage`: package layout,
   atomic write, libSQL/Turso-backed project DB *(confirm storage engine before starting —
   see Risks)*. *Test:* project save→load round-trip + crash-mid-write recovery.
7. **SVG importer → Import IR → normalizer → Geometry IR.** `engine/compilers/import`.
   *Test:* golden import test on a fixture SVG.
8. **Running-stitch digitizer pass.** `engine/compilers/digitizer`: Geometry IR → Stitch IR.
   *Test:* golden stitch test + determinism test.
9. **Machine compiler.** `engine/compilers/machine`: Stitch IR → Machine IR (needle/thread/
   jump/trim, hoop + limit validation). *Test:* Machine IR validation test.
10. **DST generator + end-to-end gate.** `engine/generators/dst`: Machine IR → DST bytes.
    *Test:* DST binary golden + **headless `SVG → Import IR → Geometry IR → Stitch IR →
    Machine IR → DST` integration test** (no Flutter).

After Task 10 the full compiler pipeline is proven end-to-end; subsequent work widens each
stage (satin/fill/underlay, more formats, more importers) against a green integration gate.

---

# 8. Risks & Assumptions

| # | Risk / Assumption | Mitigation |
|---|---|---|
| R1 | **Flutter↔Rust bridge tooling unspecified.** Docs name FFI/WASM but no tool. | Assume `flutter_rust_bridge`; confirm and record an **ADR** before Phase 8. Bridge work is late, so this does not block Phases 1–7. |
| R2 | **WASM parity for web.** Same Rust core must run under WASM (`02-arch/000` §8). | Keep kernel/runtime/domains `no_std`-friendly and free of native-only deps; add a WASM build target to CI in Phase 1. |
| R3 | **Golden fixtures need real machine files.** DST/PES goldens require authentic `.dst`/`.pes`. | Source a small licensed/open fixture set early; commit alongside Task 10. |
| R4 | **Float determinism across platforms.** Geometry uses floats; IRs must be deterministic. | Define rounding/epsilon policy in Task 4; assert byte-identical golden output in CI on all targets. |
| R5 | **Storage engine assumption.** `02-arch/000` §14 says `.embproj` holds `project.turso`/`commands.turso` (libSQL/Turso). | Confirm libSQL/Turso vs. plain SQLite before Task 6; record decision (already implied by docs — verify, don't re-decide). |
| R6 | **IR schema churn.** Early IRs will change as later stages land. | Versioned schemas + migration tests from Task 3; any breaking schema change requires an ADR (`02-arch/001` constraint 10). |
| R7 | **Package-boundary drift** as packages multiply. | Add dependency-direction lint / architecture test in CI (Phase 1 stretch); ownership change requires an ADR. |

---

# 9. Acceptance Criteria

This roadmap is satisfied when:

- ✓ Every package in §3 sits in a valid `02-architecture/018` layer with downward-only deps.
- ✓ The 5 IRs and owners in §4 match `02-architecture/001`'s ownership matrix exactly.
- ✓ The first-10-task order is a prefix-compatible refinement of `02-architecture/000` §35.
- ✓ Nothing here contradicts the 12 Non-Negotiable Rules (`02-architecture/000` §34).
- ✓ The headless `SVG → DST` pipeline (Task 10) is the explicit early integration gate.
