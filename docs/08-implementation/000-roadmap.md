# Implementation

## IMPL-000B Executive Roadmap & Suite Index

**Document ID:** IMPL-000B
**Title:** Executive Roadmap & Engineering-Plan Index
**Version:** 2.0.0
**Status:** Foundation
**Owner:** Technical Program Management

> **Strategy (ADR-026):** the **MVP is built Flutter/Dart-only**. Rust remains the long-term
> production architecture and is introduced in **Phase 2** behind stable interfaces, after MVP
> validation. Nothing Rust is removed — the detailed Rust plan below is preserved as the Phase 2/3
> track. See [`docs/07-adr/026-use-dart-engine-for-mvp.md`](../07-adr/026-use-dart-engine-for-mvp.md).

---

# Purpose

Executive roadmap and index to the engineering execution plan. Entry point for planning. The
**long-term technical derivation** (Rust packages, IR ownership, first-10 Rust tasks) lives in
[`000-implementation-roadmap.md`](000-implementation-roadmap.md) and is preserved as the Phase 2
production plan. All content derives from `docs/00`–`docs/07`; where this plan and a spec disagree,
the spec wins (`docs/02-architecture/000` §34).

---

# Phased strategy

```text
Phase 1 — Flutter/Dart MVP        (active)   validate product: workflows, UI, document, embroidery
        ↓  (MVP accepted)
Phase 2 — Rust Engine Migration   (deferred) move performance-critical stages behind stable APIs
        ↓
Phase 3 — Production Hardening     (deferred) GPU rendering, plugins, advanced sim/AI, enterprise
```

## Phase 1 — Flutter/Dart MVP (active)

Pure-Dart engine + Flutter shell. **No Rust required.**

- Flutter desktop app shell
- Dart domain packages (core, diagnostics)
- Dart command / event system
- Dart document model (+ undo/redo)
- Dart geometry engine (coordinates, paths, curves, transforms, bboxes)
- Dart embroidery core (object model, running/satin/fill stitch)
- Dart machine model + **Machine IR in Dart**
- Dart import/export MVP (raster/vector import; DST/EXP export)
- Dart simulation preview MVP
- UI: shell, canvas, tools, panels, inspector
- AI assistant MVP hooks (only if lightweight)

Discipline that keeps Phase 2 cheap: domain packages have **no Flutter dependency**; every engine
capability sits behind a **Dart interface** a Rust module can later implement (ADR-026).

## Phase 2 — Rust Engine Migration (deferred, preserved)

Introduce Rust crates behind the stable interfaces defined in Phase 1.

- Activate the Rust workspace (`crates/es_*`, already scaffolded) + `flutter_rust_bridge`
- Migrate **geometry first**, then embroidery engine, machine compiler, import/export,
  simulation/physics
- **Benchmark before and after** each migration — migrate only where Dart measurably falls short

The full Rust milestone/sprint/package plan is preserved below and in
[`000-implementation-roadmap.md`](000-implementation-roadmap.md) — unchanged, just resequenced
after MVP.

## Phase 3 — Production Hardening (deferred)

GPU-first rendering · plugin runtime · advanced simulation · advanced AI · full format
compatibility · large-document performance · enterprise-grade testing.

---

# Long-term Rust milestones (Phase 2/3 — preserved)

The 10-milestone Rust program. **These are the Phase 2/3 track**, not the active MVP plan; kept
intact per ADR-026. MVP delivers Dart equivalents of M1–M8 first (see
[`../09-project-management/003-sprints.md`](../09-project-management/003-sprints.md), MVP Sprints 1-10).

| # | Milestone | Exit signal | Epics |
|---|---|---|---|
| M1 | Foundation | Command/event bus dispatch round-trips; CI green | E1, E2, E15, E16 |
| M2 | Geometry | Geometry IR serializes deterministically; golden fixtures pass | E3 |
| M3 | Document Model + Storage | Object CRUD via Command→Event; `.embproj` round-trips | E4, E5 |
| M4 | Import | SVG → Import IR → Geometry IR; golden import test | E6 |
| M5 | Embroidery Core | Geometry IR → Stitch IR (running stitch); golden stitch test | E7 |
| M6 | Machine + Export | Headless SVG→DST integration test passes | E8, E9 |
| M7 | Simulation | Stitch IR → Playback IR; headless renderable model | E10 |
| M8 | Desktop Editor | Flutter shell drives Commands, renders Events + canvas | E11, E12 |
| M9 | AI | AI emits Commands only; explainable, human-approved | E13 |
| M10 | Production Ready | Perf/compat/security gates green; GA release | E14 + hardening |

---

# Suite index

**`docs/08-implementation/`** — 000-roadmap (this) · [000-implementation-roadmap](000-implementation-roadmap.md) (Phase 2 detail) · [001-package-map](001-package-map.md) (MVP Dart + Phase 2 Rust) · [002-dependency-map](002-dependency-map.md) · [003-team-structure](003-team-structure.md) · [004-development-order](004-development-order.md) (MVP + Phase 2) · [005-release-plan](005-release-plan.md) · [006-testing-plan](006-testing-plan.md) · [007-risk-register](007-risk-register.md) · [008-definition-of-done](008-definition-of-done.md) · [009-ci-cd-plan](009-ci-cd-plan.md) · [010-milestones](010-milestones.md)

**`docs/09-project-management/`** — [001-epics](../09-project-management/001-epics.md) · [002-features](../09-project-management/002-features.md) · [003-sprints](../09-project-management/003-sprints.md) (MVP S1-10 + Phase 2) · [004-backlog](../09-project-management/004-backlog.md) · [005-priority-matrix](../09-project-management/005-priority-matrix.md) · [006-task-template](../09-project-management/006-task-template.md) · [007-estimation](../09-project-management/007-estimation-guidelines.md) · [008-review-checklist](../09-project-management/008-review-checklist.md) · [009-release-checklist](../09-project-management/009-release-checklist.md) · [010-dashboard](../09-project-management/010-project-dashboard.md)

**`tools/github/`** — `labels.json`, `issues.json` (MVP `mvp` + preserved Rust `post-mvp`), `import.sh`.

---

# How to use

1. **MVP:** work the active plan — Phase 1 above + MVP Sprints 1-10 (`003-sprints.md`) +
   `004-development-order.md` MVP order. Everything Dart.
2. **Phase 2/3:** the Rust milestones/sprints/packages are preserved here and in the linked docs;
   pick them up after MVP acceptance, migrating behind the Dart interfaces.
3. Gate every merge with `008-definition-of-done.md`; ship per `005-release-plan.md`.
