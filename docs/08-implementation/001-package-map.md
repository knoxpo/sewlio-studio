# Implementation

## IMPL-001 Package Map

**Document ID:** IMPL-001
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Staff Architect

Every package: purpose, owning agent, public API surface, dependencies, test strategy. Layer per
`docs/02-architecture/018`. Deps flow **downward only**.

> **ADR-026:** the **MVP ships as Flutter/Dart packages** (below). The Rust crate map is the
> **Phase 2 / Post-MVP** target — preserved, not active. Each MVP Dart package is designed so a
> Rust crate can later implement the same public API.

---

# MVP Flutter/Dart packages (Phase 1 — active)

Monorepo target for the MVP. **Domain packages have no Flutter dependency** (headless, unit-testable
— the same discipline that keeps the future Rust core headless). UI packages may depend on Flutter
but reach domains **only through public APIs**. A future Rust crate replaces a Dart package behind
the identical interface (ADR-026).

```text
apps/studio/                      Flutter application shell / composition root

packages/
  studio_diagnostics/   pure Dart   severity, diagnostics, logging  (no Flutter)
  studio_core/          pure Dart   ids, time, lifecycle, service registry  (no Flutter)
  studio_events/        pure Dart   immutable event model + bus  (no Flutter)
  studio_commands/      pure Dart   command model + dispatch (the only mutation path)  (no Flutter)
  studio_document/      pure Dart   document/layers/project model, undo/redo  (no Flutter)
  studio_geometry/      pure Dart   coordinates, paths, curves, transforms, bbox  (no Flutter)
  studio_embroidery/    pure Dart   embroidery objects, running/satin/fill stitch  (no Flutter)
  studio_machine/       pure Dart   machine model + Machine IR (Dart) + validation  (no Flutter)
  studio_import/        pure Dart*  raster/vector/embroidery import + normalization
  studio_export/        pure Dart*  DST/EXP MVP encoders (consume Machine IR)
  studio_simulation/    pure Dart   playback/preview model  (no Flutter)
  studio_ai/            pure Dart   lightweight assistant hooks (emits Commands)
  studio_plugin_sdk/    pure Dart   plugin contribution interfaces (surface only for MVP)
  studio_testing/       Dart        shared fixtures + golden/determinism helpers
  studio_design_system/ Flutter     tokens, themes, shared widgets  (exists)
  studio_canvas/        Flutter     viewport, gestures, selection visuals
  studio_tools/         Flutter     selection/transform/pen/shape/text tools
  studio_panels/        Flutter     inspector, layers, assets, machine/thread panels
```
`*` pure Dart where practical; raster decode may use a Dart image package.

| Package | Layer | Public API (interface) | Depends on | Flutter dep? | Tests |
|---|---|---|---|---|---|
| `studio_diagnostics` | core | `Severity`, diagnostic sink | — | no | unit |
| `studio_core` | core | `Id`, `Clock`, `ServiceRegistry` | studio_diagnostics | no | unit |
| `studio_events` | core | `Event`, `EventBus` | studio_core | no | unit |
| `studio_commands` | core | `Command`, `CommandBus` | studio_core, studio_events | no | unit |
| `studio_document` | domain | `Document`, `Project`, doc commands | studio_geometry, studio_commands | no | integration |
| `studio_geometry` | domain | `Point`, `Path`, `Transform`, `GeometryModel` | studio_core | no | unit + golden |
| `studio_embroidery` | domain | embroidery + stitch interfaces | studio_geometry | no | unit + golden |
| `studio_machine` | domain | `MachineModel`, `MachineIr` (Dart) | studio_core | no | unit + validation |
| `studio_import` | domain | `Importer`, `import()` | studio_geometry | no | golden |
| `studio_export` | domain | `Exporter`, `encode(MachineIr)` | studio_machine | no | binary golden |
| `studio_simulation` | domain | `PlaybackModel` | studio_embroidery | no | consistency |
| `studio_ai` | domain | assistant API (emits Commands) | studio_core | no | rule/eval |
| `studio_plugin_sdk` | domain | plugin interfaces | studio_core | no | unit |
| `studio_design_system` | ui | `AppTokens`, theme, components | flutter | yes | widget |
| `studio_canvas` | ui | canvas widgets | design_system, domain APIs | yes | widget + interaction |
| `studio_tools` | ui | tool widgets | canvas, domain APIs | yes | interaction |
| `studio_panels` | ui | panel widgets | design_system, domain APIs | yes | widget |
| `apps/studio` | app | app entry | ui + domain packages | yes | widget + integration |

**Rules:** `studio_core`/`studio_geometry`/`studio_embroidery`/`studio_machine` (and import/export
where practical) carry **no Flutter dependency**. UI packages depend on domain packages **only via
public APIs**. **Do not create Rust crates as MVP deliverables.** The `crates/es_*` scaffold already
in-repo is preserved and documented as Phase 2 (below).

---

# Phase 2 / Post-MVP — Rust crates (preserved, deferred per ADR-026)

The `es_*` crates already scaffolded in `crates/` and `ffi/es_ffi` remain in-tree and compiling.
They are the **migration target**, not MVP deliverables — introduced behind the stable Dart
interfaces above, geometry first, benchmarked before/after. Future layered mapping:

```text
crates/
  es_core/  es_geometry/  es_embroidery/  es_machine/  es_import/
  es_export/  es_simulation/  es_rendering/  es_ai/
```

# Rust crates

| Package (now → target) | Layer | Purpose | Owner | Public API (initial) | Depends on | Test strategy |
|---|---|---|---|---|---|---|
| `es_diagnostics` → `engine/kernel/diagnostics` | Kernel | Severity, diagnostics, logging, tracing | core-engine | `Severity`, diagnostic sink | — | unit |
| `es_core` → `engine/kernel` + `engine/runtime` | Kernel/Runtime | Lifecycle, ids, time, command bus, event bus, service registry, scheduler | core-engine | `Command`, `Event`, `CommandBus`, `EventBus`, `ServiceRegistry` | es_diagnostics | unit + integration |
| `es_geometry` → `engine/domains/geometry` | Domain | **Geometry IR** owner: points, paths, curves, transforms, bbox | geometry | `Point`, `Path`, `Transform`, `GeometryIr` | es_core | unit + golden + property |
| _(planned)_ `es_document` → `engine/platform` | Platform | Document model, layers, project, `.embproj` orchestration | core-engine | `Document`, `Project`, doc commands | es_geometry, es_core | integration |
| _(planned)_ `es_storage` → `engine/services/storage` | Service | Persistence, serialization, migration, atomic saves, recovery | import-export | `ProjectStore`, `save/load` | es_document | round-trip + fault |
| _(planned)_ `es_import` → `engine/compilers/import` | Compiler | **Import IR** owner: parse SVG/raster/emb, normalize | import-export | `import()`, `ImportIr` | es_geometry | golden + compat |
| _(planned)_ `es_embroidery` → `engine/domains/embroidery` | Domain | Embroidery objects, stitch settings, density, underlay, compensation | embroidery | embroidery types | es_geometry | unit |
| _(planned)_ `es_digitizer` → `engine/compilers/digitizer` | Compiler | **Stitch IR** owner: running/satin/fill/underlay passes, optimization | embroidery | `digitize()`, `StitchIr` | es_embroidery, es_geometry | golden + determinism |
| _(planned)_ `es_thread` → `engine/domains/thread` | Domain | Thread libraries, colors, palettes, mapping | embroidery | thread types | es_core | unit |
| _(planned)_ `es_machine` → `engine/domains/machine` | Domain | Machine profiles, capabilities, hoops, constraints | machine-compiler | profile types | es_core | unit |
| _(planned)_ `es_machine_compiler` → `engine/compilers/machine` | Compiler | **Machine IR** owner: needle/thread mapping, validation | machine-compiler | `compile()`, `MachineIr` | es_digitizer, es_machine, es_thread | golden + validation |
| _(planned)_ `es_gen_dst` (+ exp/pes/jef/vp3/hus) → `engine/generators/*` | Generator | One crate per format: binary encode, stream, verify | import-export | `encode(MachineIr) -> bytes` | es_machine_compiler | binary golden |
| _(planned)_ `es_playback` → `engine/compilers/playback` | Compiler | **Playback IR** owner: timeline, frames, stats | rendering | `PlaybackIr` | es_digitizer | timeline consistency |
| _(planned)_ `es_render` → `engine/services/rendering` | Service | Scene graph, render graph, LOD, renderable model | rendering | renderable model API | es_geometry, es_playback | snapshot/golden |
| _(planned)_ `es_ai` → `engine/services/ai-runtime` | Service | Knowledge graph, rule engine, digitizer, quality inspector | ai | AI tool API (emits Commands) | es_core (+ domain reads) | rule/eval/explanation |
| _(planned)_ `es_plugin` → `engine/services/plugin` | Service | Plugin runtime, sandbox, extension registry | core-engine | plugin host API | es_core | sandbox + lifecycle |
| _(planned)_ `es_security` → `engine/services/security` | Service | Permissions, policy, audit, secure storage | qa-review/core | security gateway API | es_core | policy tests |
| `es_ffi` → `engine/bridges/ffi` (+ wasm) | Bridge | frb boundary: command dispatch, event stream, progress | core-engine | frb-exposed API | es_core, es_geometry, … | bridge contract |

---

# Flutter packages

| Package | Purpose | Owner | Public API | Depends on | Test strategy |
|---|---|---|---|---|---|
| `apps/studio` | Application shell / composition root | ui | app entry | studio_bindings, studio_design_system | widget + integration |
| `packages/studio_bindings` | Generated frb bindings + `initEngine()` | ui/core | `initEngine()`, generated API | flutter_rust_bridge | binding smoke |
| `packages/studio_design_system` | Design tokens, themes, shared widgets | ui | `AppTokens`, theme, components | flutter | widget golden |
| _(planned)_ `packages/studio_canvas` | Canvas widget, gestures, selection visuals | ui | canvas widgets | bindings, design_system | widget + interaction |
| _(planned)_ `packages/studio_panels` | Inspector, layers, timeline, resources | ui | panel widgets | bindings, design_system | widget |

---

# Invariants (all packages)

- One responsibility, one owner, one public API (Public → Internal → Private; internals never leak).
- 500–3,000 LOC target (< 2,000 preferred); decompose larger.
- Cross-package comms only via Commands / Events / pipeline outputs / public APIs.
- Each IR has exactly one owner (see `002-dependency-map.md` and `001-implementation-roadmap`).
- Every package compiles and tests independently.
