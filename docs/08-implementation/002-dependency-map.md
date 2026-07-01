# Implementation

## IMPL-002 Dependency Map

**Document ID:** IMPL-002
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Staff Architect

Dependency graphs at three levels. **All edges point downward / to equal-or-earlier layers — the
graph is acyclic by construction** (`docs/02-architecture/018`). Cycles are prohibited; break them
with an Event or an interface.

---

# Layer graph (authoritative)

```text
kernel → runtime → platform → domains → compilers → generators → services → bridges → flutter
```

No package depends on a layer to its right.

---

# Package dependency graph

```text
es_diagnostics
   ↑
es_core ─────────────────────────────────┐
   ↑            ↑            ↑            │
es_geometry  es_thread   es_machine      │
   ↑   ↑         ↑            ↑           │
   │   └── es_embroidery      │           │
   │            ↑             │           │
es_document   es_digitizer ───┴─ es_machine_compiler
   ↑            ↑   ↑                 ↑
es_storage   es_playback         es_gen_{dst,exp,pes,jef,vp3,hus}
   ↑            ↑
es_import    es_render
                         es_ai · es_plugin · es_security  (depend on es_core + read domains via APIs)
                                        ↑
                                     es_ffi (bridge)
                                        ↑
                          studio_bindings → apps/studio ← studio_design_system
```

Read upward as "is depended on by". Every arrow crosses zero or one layer boundary downward.

---

# IR flow (data contracts, not code deps)

```text
Import IR ──→ Geometry IR ──→ Stitch IR ──┬──→ Playback IR ──→ Simulation
(es_import)   (es_geometry)  (es_digitizer)│   (es_playback)
                                           └──→ Machine IR ──→ Generators (DST/…)
                                               (es_machine_compiler)
```

Constraints (`docs/02-architecture/001`): Geometry never depends on Machine IR; Playback never on
Export; Export never on Simulation; each IR immutable + versioned + one owner.

---

# Epic dependency graph

```text
E1 Foundation ──┬─→ E2 IR Framework ─→ E3 Geometry ─→ E4 Document ─→ E5 Storage ─→ E6 Import
                │                          │                                          │
                │                          ├─→ E11 Rendering (needs geometry)         │
                │                          └─────────────→ E7 Embroidery ←────────────┘
                │                                              │
                │                                              ├─→ E8 Machine ─→ E9 Export
                │                                              └─→ E10 Simulation
                ├─→ E15 FFI Bridge ─→ E12 Desktop UI (needs E4 + E11)
                ├─→ E14 Plugin (needs stable public APIs)
                └─→ E16 Testing/CI/Security (cross-cutting, every epic)
                                   E13 AI (needs E7 + E8 domain knowledge) ─→ after E9
```

---

# Prerequisite gates (never violate)

| Work | Blocked until |
|---|---|
| Any exporter (E9) | Machine IR exists (E8) |
| Rendering (E11) | Geometry IR exists (E3) |
| Desktop UI (E12) | Engine foundation (E1) + Document (E4) |
| AI (E13) | Domain knowledge (E7 + E8) |
| Simulation (E10) | Stitch IR exists (E7) |
| Import widening (E6) | Geometry IR exists (E3) |
| Plugin host (E14) | Public APIs stable (post-E9) |

---

# Acyclicity proof (sketch)

Assign each package its layer index (kernel=0 … flutter=8). Every dependency edge goes from a
higher index to a ≤ index. A cycle would require an edge from a lower to a higher index, which the
layer rule forbids. Therefore the package graph is a DAG. The `es_ffi` → domain edges are all
downward (bridge=7 → domains=3/compilers=4), preserving the property. CI enforces this with a
dependency-direction check (see `009-ci-cd-plan.md`).
