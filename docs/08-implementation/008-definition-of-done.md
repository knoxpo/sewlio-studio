# Implementation

## IMPL-008 Definition of Done

**Document ID:** IMPL-008
**Version:** 1.0.0
**Status:** Foundation
**Owner:** QA / Review

Done means shippable. Four scopes, each stricter than the last.

---

# Task DoD

- [ ] Objective met; matches its `006-task-template` entry.
- [ ] Code compiles; `cargo build` / `fvm flutter analyze` clean for touched packages.
- [ ] Tests added/updated and passing (unit ≥, plus golden if it's a pipeline stage).
- [ ] `cargo fmt` + `cargo clippy -D warnings` clean; `fvm dart format` clean (Flutter).
- [ ] No new cross-layer dependency; public API unchanged unless the task is an API task.
- [ ] Docs/rustdoc updated for any new public item.

# Feature DoD

- [ ] All child tasks Done.
- [ ] Acceptance criteria (from `002-features.md`) verified.
- [ ] Feature-level test present (golden/integration/property as appropriate).
- [ ] Determinism holds where the feature touches an IR.
- [ ] Reviewed by `qa-review`; architecture-affecting parts reviewed by `architect`.

# Epic DoD

- [ ] All features Done; the owned IR (if any) is versioned, serialized, validated, golden-covered.
- [ ] Package compiles and tests independently; within LOC target.
- [ ] Integration with upstream/downstream epics demonstrated (e.g. Stitch IR consumed by Machine).
- [ ] Perf budgets met where defined (`006-testing-plan.md`).
- [ ] ADR filed for any boundary/schema decision.

# Release DoD (per milestone / channel)

- [ ] Milestone exit criteria met (`010-milestones.md`).
- [ ] Full gate green: unit + golden + integration + compat + perf + cross-platform CI.
- [ ] No open P0/P1; risk register reviewed.
- [ ] `.embproj` back-compat with prior stable verified; recovery tested.
- [ ] Release checklist (`09-PM/009-release-checklist.md`) complete; changelog + signed builds.

---

# Non-negotiable overlay (applies at every scope)

Nothing is Done if it violates the 12 Non-Negotiables (`docs/02-architecture/000` §34): Flutter owns
no business logic, Commands are the only mutation path, Events immutable, exporters consume Machine
IR only, digitizer outputs Stitch IR (not machine files), recovery never auto-overwrites originals,
major architecture changes carry an ADR.
