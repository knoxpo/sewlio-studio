# Implementation

## IMPL-001 Package Map

**Document ID:** IMPL-001
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Staff Architect

Every package: purpose, owning agent, public API surface, dependencies, test strategy. Layer per
`docs/02-architecture/018`. Deps flow **downward only**. Current repo uses the flat `crates/`
starter layout (Task 1); the long-term layered `engine/<layer>/` target is noted per row and
migrated under an ADR later.

---

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
