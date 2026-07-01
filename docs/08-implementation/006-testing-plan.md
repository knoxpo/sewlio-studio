# Implementation

## IMPL-006 Testing Plan

**Document ID:** IMPL-006
**Version:** 1.0.0
**Status:** Foundation
**Owner:** QA / Review

Derived from `docs/05-engineering/500-testing-strategy.md` and `docs/02-architecture/000` §31.
Core principle: **the engine is headless-testable** — `SVG → Import IR → Geometry IR → Stitch IR →
Machine IR → DST` runs with no Flutter.

---

# Test levels (ownership)

| Level | What | Owner | Runs |
|---|---|---|---|
| Unit | one function/type | each package | every commit |
| Serialization | IR round-trips byte-stable | IR owner | every commit |
| Migration | old schema → current | IR owner | on schema change |
| Golden | fixture in → expected out | each pipeline stage | every commit |
| Property | invariants over random input (geometry) | geometry/domain | every commit |
| Integration | multi-package flows (SVG→DST) | platform | every commit (post-M6) |
| Compatibility | real-world files (SVG, DST/PES) | import-export | pre-release |
| Performance | benchmark budgets | owner | nightly + pre-release |
| Fault injection | crash/cancel/IO-fail recovery | platform/storage | nightly |

Each package owns its unit/serialization/golden/API-compat tests; integration tests belong to the
platform layer.

---

# Per-phase requirements

| Milestone | Required before exit |
|---|---|
| M1 Foundation | unit (bus, ids); fault-injection on lifecycle/cancellation |
| M2 Geometry | Geometry IR unit+serialization+migration+validation+**golden**; property tests; Import-IR perf budget reserved (<200 ms) |
| M3 Document+Storage | command/event integration; `.embproj` round-trip; atomic-write + recovery fault tests |
| M4 Import | golden import fixtures; SVG compatibility set |
| M5 Embroidery | Stitch IR golden; **determinism test** (same input ⇒ identical Stitch IR) |
| M6 Machine+Export | Machine IR validation (limits/needle/hoop); **DST binary golden**; **headless SVG→DST integration gate**; Machine-compile perf budget (<500 ms) |
| M7 Simulation | Playback IR timeline-consistency; renderable-model golden |
| M8 Desktop UI | Flutter widget tests; bridge contract tests; no business logic asserted in UI tests |
| M9 AI | rule/eval harness; safety tests (no direct mutation, approval required); audit-trail |
| M10 Production | full compat matrix, perf gates, security tests, cross-platform CI |

---

# Determinism & goldens

- Rounding/epsilon policy fixed at the Geometry IR (M2); golden outputs are byte-identical across
  platforms in CI (guards float-determinism risk — see `007-risk-register.md`).
- Golden machine files (`.dst`/`.pes`) sourced from a small licensed/open fixture set committed
  under `testdata/`; every generator diffs against them.
- Regression suite grows by one test per fixed bug (`docs/05-engineering/506`).

---

# Gates

`make check` / `tools/check.sh` is the local gate; CI runs the same plus goldens, perf, compat, and
the cross-platform matrix (`009-ci-cd-plan.md`). A red golden or a failed integration gate blocks
merge and release.
