# Implementation

## IMPL-000B Executive Roadmap & Suite Index

**Document ID:** IMPL-000B
**Title:** Executive Roadmap & Engineering-Plan Index
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Technical Program Management

---

# Purpose

Executive-level roadmap for Sewlio / Embroidery Studio and the index to the engineering
execution plan. This is the entry point for planning; the **technical derivation** lives in
[`000-implementation-roadmap.md`](000-implementation-roadmap.md) (packages, IR ownership,
first-10 tasks, verification). This file does not duplicate it — it sequences the whole program
and links every planning artifact.

All content is derived from `docs/00`–`docs/07`. Where this plan and a spec disagree, the spec
wins (see `docs/02-architecture/000` §34 Non-Negotiables).

---

# The one-paragraph plan

Sewlio Studio is a **compiler pipeline for embroidery** (Flutter UI · Rust engine · frb bridge).
Build it foundation-first, proving the full pipeline with a thin **SVG → DST** vertical slice by
Milestone 6 before widening any stage. One senior engineer over ~2 years (≈52 two-week sprints),
using the 10-agent team (`agents/`) as force-multipliers. Deterministic core infrastructure ships
before any user-facing feature; UI waits for the engine, AI waits for domain knowledge, exporters
wait for Machine IR, rendering waits for geometry.

---

# Milestones (10)

| # | Milestone | Exit signal | Epics |
|---|---|---|---|
| M1 | Foundation | Command/event bus dispatch round-trips; CI green | E1, E2, E15, E16 |
| M2 | Geometry | Geometry IR serializes deterministically; golden fixtures pass | E3 |
| M3 | Document Model + Storage | Object CRUD via Command→Event; `.embproj` round-trips | E4, E5 |
| M4 | Import | SVG → Import IR → Geometry IR; golden import test | E6 |
| M5 | Embroidery Core | Geometry IR → Stitch IR (running stitch); golden stitch test | E7 |
| M6 | Machine + Export | **Headless SVG→DST integration test passes** | E8, E9 |
| M7 | Simulation | Stitch IR → Playback IR; headless renderable model | E10 |
| M8 | Desktop Editor | Flutter shell drives Commands, renders Events + canvas | E11, E12 |
| M9 | AI | AI emits Commands only; explainable, human-approved | E13 |
| M10 | Production Ready | Perf/compat/security gates green; GA release | E14 + hardening |

---

# Suite index

**`docs/08-implementation/` — engineering plan**

| File | Contents |
|---|---|
| [000-implementation-roadmap.md](000-implementation-roadmap.md) | Technical derivation: packages, IRs, first-10 tasks |
| [001-package-map.md](001-package-map.md) | Every crate/package: purpose, owner, public API, deps, tests |
| [002-dependency-map.md](002-dependency-map.md) | Layer/package/epic dependency graphs, acyclicity proof |
| [003-team-structure.md](003-team-structure.md) | Agent roles → ownership, RACI, solo-senior model |
| [004-development-order.md](004-development-order.md) | Topological build order, vertical slices, gates |
| [005-release-plan.md](005-release-plan.md) | Release trains, semver, alpha/beta/GA |
| [006-testing-plan.md](006-testing-plan.md) | Test pyramid per phase, gates |
| [007-risk-register.md](007-risk-register.md) | Risks × likelihood/impact/mitigation |
| [008-definition-of-done.md](008-definition-of-done.md) | DoD: task/feature/epic/release |
| [009-ci-cd-plan.md](009-ci-cd-plan.md) | Pipelines, quality gates, release automation |
| [010-milestones.md](010-milestones.md) | Milestone entry/exit criteria + demos |

**`docs/09-project-management/` — execution artifacts**

| File | Contents |
|---|---|
| [001-epics.md](../09-project-management/001-epics.md) | 16 epics: deps, complexity, duration, priority |
| [002-features.md](../09-project-management/002-features.md) | Features per epic: acceptance + testing |
| [003-sprints.md](../09-project-management/003-sprints.md) | Rolling-wave sprint plan |
| [004-backlog.md](../09-project-management/004-backlog.md) | Prioritized backlog + label taxonomy |
| [005-priority-matrix.md](../09-project-management/005-priority-matrix.md) | Value/effort, MoSCoW, P0-P3 |
| [006-task-template.md](../09-project-management/006-task-template.md) | Canonical task template |
| [007-estimation-guidelines.md](../09-project-management/007-estimation-guidelines.md) | Sizing → hours, velocity |
| [008-review-checklist.md](../09-project-management/008-review-checklist.md) | PR/code-review checklist |
| [009-release-checklist.md](../09-project-management/009-release-checklist.md) | Pre-release gate |
| [010-project-dashboard.md](../09-project-management/010-project-dashboard.md) | Status dashboard template |

**`tools/github/` — importable issue bundle** (`labels.json`, `issues.json`, `import.sh`).

---

# How to use this plan

1. Read `010-milestones.md` for the arc, `004-development-order.md` for what to build next.
2. Pick the current sprint in `003-sprints.md`; each task follows `006-task-template.md`.
3. Import issues once a GitHub remote exists: `tools/github/import.sh`.
4. Gate every merge with `008-definition-of-done.md` + `008-review-checklist.md`; ship per
   `005-release-plan.md`.
