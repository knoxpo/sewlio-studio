# Project Management

## PM-004 Backlog & Label Taxonomy

**Document ID:** PM-004
**Version:** 1.0.0
**Status:** Living
**Owner:** Technical Program Management

Backlog categorized by phase (ADR-026). **MVP Flutter/Dart is the active category**; the Rust
program is preserved under Post-MVP. The machine-importable form lives in `tools/github/issues.json`
(MVP tasks labeled `mvp`; preserved Rust tasks labeled `post-mvp`) + `labels.json`, `import.sh`.

---

# 1. MVP Flutter/Dart (active · P0/P1)

Task ids `MVP-S<n>-T<n>`; see `003-sprints.md` MVP Sprints 1-10 and `004-development-order.md` MVP
order. All Dart, no Rust.

1. **Foundation** — workspace, `studio_diagnostics`, `studio_core` (MVP-S1) · P0
2. **Core runtime** — `studio_events`, `studio_commands`, `studio_document` + undo/redo (MVP-S2) · P0
3. **Geometry** — `studio_geometry` coords/paths/curves/transforms/bbox (MVP-S3) · P0
3a. **Shared platform framing** — Universal Design Document terminology + Project Type metadata where needed · P0
4. **Embroidery core** — `studio_embroidery` object model + running/satin/fill (MVP-S4) · P0
5. **Machine core** — `studio_machine` model + **Machine IR (Dart)** + validation (MVP-S5) · P0
6. **Export MVP** — `studio_export` DST/EXP + golden (MVP-S6) · P0
7. **Import MVP** — `studio_import` raster/vector + normalization (MVP-S7) · P1
8. **UI shell** — `apps/studio`, `studio_design_system` shell/menu/panels (MVP-S8) · P0
9. **Canvas + tools** — `studio_canvas`, `studio_tools` (MVP-S9) · P0
10. **MVP integration** — save/load, inspector, import/export UI, sim preview (MVP-S10) · P0
11. **AI assistant hooks** — `studio_ai` (lightweight) · P1
12. **Quality diagnostics + QA pass** — `studio_testing` · P1

# 1.5. Platform Foundation (planned · P1)

Shared Textile Platform · Universal Design Document · Project-Type Architecture · Production Engine Framework · Dynamic UI Contributions · Production Capability Framework.

# 1.6. Additional Production Domains (post-MVP · P2)

Weaving Engine · Loom Compiler · Digital Printing Engine · Print Pipeline · Cross-Domain Conversion. These are post-MVP unless a future roadmap explicitly pulls a slice forward.

# 2. Post-MVP Rust Migration (deferred · P2)

Preserved from the Rust program — **not deleted**, begins after MVP acceptance. Introduce behind the
Dart interfaces, geometry first, benchmark before/after.

1. **E1 Foundation** — E1-F1…F5 · P0(post-mvp)
2. **E2 IR Framework** — E2-F1…F3
3. **E3 Geometry** → **E4 Document** → **E5 Storage**
4. **E6 Import**, **E7 Embroidery**, **E8 Machine**, **E9 Export (DST + gate)**
5. **E7/E9 widening** (satin/fill/underlay/optimization; EXP/PES/JEF/VP3/HUS)
6. **E15 FFI marshaling / WASM** (`flutter_rust_bridge`)
7. **E16 Testing/CI/Security** — continuous

# 3. Production Rendering (P2)
**E11 Rendering** — scene/render graph, GPU backend, viewport, LOD, thread render.

# 4. Advanced AI (P2)
**E13 AI** — knowledge graph, rule engine, AI digitizer, quality inspector, assistant (full).

# 5. Plugin System (P3)
**E14 Plugin** — runtime, sandbox, extension registry, contribution points, plugin UI.

# 6. Enterprise / Performance (P2/P3)
Perf benchmarks, compatibility matrix, fault-injection, security/audit hardening, signed builds,
large-document performance (E16 hardening + E10 Simulation advanced).

Cross-cutting continuous work (testing/CI/security) is not a single slot — each sprint carries its
share.

---

# Label taxonomy (Step 10)

Mirrors `tools/github/labels.json`. Colors are hints.

**Phase** : `mvp` `#0e8a16` · `post-mvp` `#5a5a5a` · `phase-2` `#5a5a5a`

**Domain / layer** `#1d76db`: `kernel` `runtime` `geometry` `platform` `production` `embroidery`
`weaving` `printing` `thread` `machine` `loom` `rip` `import` `export` `generator` `simulation`
`rendering` `ui` `ai` `plugin` `storage` `security` `ffi`

**Stack** `#5319e7`: `rust` `flutter` `dart`

**Kind** `#0e8a16`: `epic` `feature` `task` `bug` `research` `docs` `testing` `performance` `ci-cd`

**Priority** `#b60205`: `P0` `P1` `P2` `P3`

**Size** `#fbca04`: `size/XS` `size/S` `size/M` `size/L`

**Workflow** `#d93f0b`: `blocked` `good-first-issue`

---

# Grooming rules

- Reprioritize every sprint boundary; keep the top ~2 sprints task-ready.
- Every backlog item maps to an epic/feature ID and carries labels + priority + size.
- Split any item > size/M into tasks before it enters a sprint.
- `blocked` items name the blocking ID; nothing `blocked` is pulled into a sprint.
