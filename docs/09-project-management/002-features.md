# Project Management

> **Platform update:** existing embroidery features remain MVP features. Shared Textile Platform,
> Weaving, Digital Printing, and Cross-Domain Conversion features are post-MVP unless explicitly
> marked as Project Type foundation work.

## PM-002 Features

**Document ID:** PM-002
**Version:** 1.0.0
**Status:** Living
**Owner:** Tech Lead

Features per epic, all 16 epics decomposed to feature level with dependencies, acceptance criteria,
and a test requirement. ID scheme `E<epic>-F<n>`. Task-level breakdown lives in
`003-sprints.md` and `tools/github/issues.json`; the 2-year horizon still follows rolling wave, so
far-milestone tasks (M9–M10) are planning estimates refined on approach.

---

# E1 Foundation
| ID | Feature | Depends | Acceptance criteria | Testing |
|---|---|---|---|---|
| E1-F1 | Ids/time/lifecycle | — | deterministic UUIDs; monotonic time source; lifecycle start/stop hooks | unit |
| E1-F2 | Diagnostics/logging | E1-F1 | severity levels; structured log records; tracing spans | unit |
| E1-F3 | Command bus | E1-F1 | `Command` trait; dispatch → handler; validation hook; error path | unit + integration |
| E1-F4 | Event bus | E1-F3 | immutable `Event`; append-only stream; subscribers notified | unit + integration |
| E1-F5 | Service registry | E1-F1 | register/resolve services by type; no global singletons | unit |

# E2 IR Framework
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E2-F1 | IR base traits | E1 | versioned + immutable + serializable contracts | unit |
| E2-F2 | Golden harness | E2-F1 | fixture-in/out helper; byte-stable diff; update mode | serialization + golden |
| E2-F3 | Migration framework | E2-F1 | explicit old→new migration; never implicit | migration |

# E3 Geometry Engine
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E3-F1 | Coordinate system | E2 | mm-internal; no hidden unit conversion; rounding/epsilon policy | unit + property |
| E3-F2 | Paths | E3-F1 | open/closed paths; segment model; validation (open path, dup id) | unit + golden |
| E3-F3 | Curves | E3-F2 | bezier eval/subdivide; deterministic | unit + property |
| E3-F4 | Transforms | E3-F1 | affine compose/apply/invert; associativity | unit + property |
| E3-F5 | Bounding boxes | E3-F2 | tight bbox; union; contains | unit |
| E3-F6 | Geometry algorithms | E3-F3 | length, flatten, hit-test; deterministic | unit + golden |
| E3-F7 | Geometry IR serialization | E3-F1..F6 | round-trip byte-stable; schema version | serialization + golden |

# E4 Document Model & Project
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E4-F1 | Document/layers/objects | E3 | tree of layers/objects over Geometry IR | unit |
| E4-F2 | Geometry commands | E4-F1, E1-F3 | create/move/delete/transform via Command→Event only | integration |
| E4-F3 | History (undo/redo) | E4-F2 | event-sourced undo/redo; deterministic replay | integration |
| E4-F4 | Project metadata | E4-F1 | project settings, thread refs, machine profile ref | unit |

# E5 Storage & Recovery
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E5-F1 | `.embproj` format | E4 | package layout; manifest; versioned | round-trip |
| E5-F2 | Atomic save/load | E5-F1 | crash-safe write; checksum; load validation | round-trip + fault |
| E5-F3 | Recovery | E5-F2 | journal/checkpoint; never auto-overwrite original | fault |
| E5-F4 | Migration | E5-F1 | project schema migration path | migration |

# E6 Import Pipeline
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E6-F1 | Import IR | E3 | normalized shape/group/path/color model | unit |
| E6-F2 | SVG importer | E6-F1 | parse SVG → Import IR; diagnostics preserved | golden + compat |
| E6-F3 | Normalization | E6-F1 | Import IR → Geometry IR; validation | golden |
| E6-F4 | Raster/embroidery importers | E6-F1 | PNG/JPEG + existing stitch files → Import IR | golden + compat |

# E7 Embroidery Engine
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E7-F1 | Stitch IR | E3 | machine-independent stitch model (run/fill/satin/jump/trim/color/tie) | unit + serialization |
| E7-F2 | Running stitch | E7-F1 | Geometry IR → running Stitch IR; deterministic | golden + determinism |
| E7-F3 | Satin | E7-F1 | satin column generation | golden |
| E7-F4 | Fill | E7-F1 | tatami/fill with angle + density | golden |
| E7-F5 | Underlay | E7-F2 | underlay passes | golden |
| E7-F6 | Density | E7-F1 | density model + validation | unit |
| E7-F7 | Pull/push compensation | E7-F3,F4 | compensation applied deterministically | golden |
| E7-F8 | Sequencing | E7-F1 | object order, tie-in/off, trims, jumps | golden |
| E7-F9 | Optimization | E7-F8 | travel/color-change minimization; deterministic | golden + determinism |

# E8 Machine Compiler
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E8-F1 | Machine IR | E7-F1 | needle/thread/stop/jump/trim + hoop metadata | unit + serialization |
| E8-F2 | Needle & thread mapping | E8-F1, E7 | thread → needle assignment | golden |
| E8-F3 | Machine validation | E8-F1 | limits, needle count, hoop size, unsupported commands | validation |

# E9 Export / Generators
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E9-F1 | DST generator | E8 | Machine IR → DST bytes; no optimization in encoder | binary golden |
| E9-F2 | SVG→DST integration | E9-F1, E6 | headless pipeline test green | integration |
| E9-F3 | EXP/PES/JEF/VP3/HUS | E9-F1 | one crate each; capability-checked | binary golden + compat |

# E10 Simulation
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E10-F1 | Playback IR | E7-F1 | timeline/frame/needle-position/stats model; never mutates Stitch IR | unit + serialization |
| E10-F2 | Playback compiler | E10-F1 | Stitch IR → Playback IR; deterministic; regenerable cache | golden + determinism |
| E10-F3 | Needle motion model | E10-F2 | per-frame needle position + speed from stitch sequence | unit |
| E10-F4 | Playback statistics | E10-F2 | stitch count, thread length, color-change count, runtime estimate | unit |
| E10-F5 | Playback service | E10-F2 | play/pause/seek/speed controls over Playback IR (headless) | integration |

# E11 Rendering
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E11-F1 | Renderable model | E3 | Geometry/Playback IR → backend-agnostic renderable; no document mutation | unit |
| E11-F2 | Scene graph | E11-F1 | node hierarchy, dirty tracking, transforms | unit |
| E11-F3 | Render graph | E11-F2 | pass ordering; GPU resources separate from document resources | snapshot |
| E11-F4 | GPU backend | E11-F3 | replaceable backend; renders scene to target | snapshot/golden |
| E11-F5 | Viewport & camera | E11-F2 | pan/zoom/fit; device-pixel correct | unit |
| E11-F6 | LOD / culling | E11-F3 | large-document culling + level-of-detail; perf budget met | perf |
| E11-F7 | Thread rendering | E11-F4, E10-F1 | stitch/thread visual styling from Playback IR | golden |

# E12 Desktop UI
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E12-F1 | App shell & window | E15-F1 | window, navigation, theme, lifecycle; command-driven | widget |
| E12-F2 | Workspace & docking | E12-F1 | panels, layout, docking, persistence | widget |
| E12-F3 | Canvas widget | E12-F1, E11 | render viewport; gestures dispatch Commands; no domain logic | widget + interaction |
| E12-F4 | Selection & transform tools | E12-F3 | select/move/scale/rotate via Commands; gizmos | interaction |
| E12-F5 | Pen / shape / text tools | E12-F3 | create geometry via Commands; tool state separate from doc state | interaction |
| E12-F6 | Inspector & properties | E12-F2 | edit object properties via Commands; derives from events | widget |
| E12-F7 | Layers & history panels | E12-F2 | layer tree + undo/redo view from event stream | widget |
| E12-F8 | Thread / machine panels | E12-F2 | assign thread, pick machine profile via Commands | widget |
| E12-F9 | Import/export UI | E12-F2, E6, E9 | import dialog + export dialog wired to engine pipelines | widget + integration |

# E13 AI Runtime
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E13-F1 | Knowledge graph | E7, E8 | domain rules/relations from `docs/03-domain/ai`; queryable | unit |
| E13-F2 | Rule engine | E13-F1 | deterministic rule evaluation; explainable results | rule eval |
| E13-F3 | Confidence + explainability | E13-F2 | every recommendation carries score + human-readable rationale | unit |
| E13-F4 | Artwork analyzer / classifier | E13-F1, E6 | classify imported artwork objects | eval |
| E13-F5 | Stitch strategy planner (AI digitizer) | E13-F2, E7 | proposes stitch plan as Commands; never mutates state directly | integration |
| E13-F6 | Quality inspector | E13-F2, E8 | flags density/puckering/machine risks with explanations | eval |
| E13-F7 | Assistant / chat + human approval | E13-F3 | tool-calls emit Commands; changes reviewable, undoable, auditable, permission-gated | integration |

# E14 Plugin System
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E14-F1 | Plugin runtime & lifecycle | E1, stable public APIs | load/unload; isolated context | unit |
| E14-F2 | Sandbox & permissions | E14-F1, E16-F4 | plugins reach engine only via public APIs; permission-gated | sandbox |
| E14-F3 | Extension registry | E14-F1 | register importers/exporters/algorithms/panels | unit |
| E14-F4 | Plugin contribution points | E14-F3, E6, E9, E7 | plugin-provided importer/exporter/stitch algorithm runs through IR contracts | integration |
| E14-F5 | Plugin UI panels | E14-F3, E12 | plugin-contributed panels host safely | widget |

# E15 FFI Bridge
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E15-F1 | Command dispatch bridge | E1 | Flutter → frb → Command bus; typed contracts | bridge contract |
| E15-F2 | Event stream bridge | E15-F1, E1 | Rust events → Flutter stream; ordered, lossless | bridge contract |
| E15-F3 | Progress / cancellation | E15-F1 | long ops report progress + cancel across boundary | integration |
| E15-F4 | WASM parity | E15-F1 | same engine API under Flutter Web/WASM | compat |

# E16 Testing, CI/CD & Security (continuous)
| ID | Feature | Depends | Acceptance | Testing |
|---|---|---|---|---|
| E16-F1 | Golden & determinism harness | E2 | reusable golden fixtures + byte-identical determinism assertions | meta |
| E16-F2 | Performance benchmarks | E3 | Import IR <200ms, Machine compile <500ms budgets tracked in CI | perf |
| E16-F3 | Compatibility & fault-injection | E6, E9 | real-world file compat suite; fault-injection on storage/lifecycle | compat + fault |
| E16-F4 | Security: permissions & audit | E1 | security gateway, permission checks, audit log, secure storage | policy |
| E16-F5 | Dependency-direction enforcement | E1 | CI fails on upward/circular deps (architecture fitness test) | meta |

---

# Global acceptance overlay

Every feature: (1) has ≥1 automated test, (2) respects package ownership + downward deps, (3) if it
touches an IR, the IR stays immutable/versioned/deterministic, (4) mutations flow only through
Commands. A feature failing any of these is not accepted regardless of functional completeness.
