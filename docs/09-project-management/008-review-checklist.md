# Project Management

## PM-008 Review Checklist

**Document ID:** PM-008
**Version:** 1.0.0
**Status:** Foundation
**Owner:** QA / Review

Every PR passes this before merge. Ties to `agents/qa-review.md`, `agents/architect.md`, and
`docs/05-engineering/904-review-checklist.md`. Correctness first; simplification second.

---

# Architecture

- [ ] No cross-layer / upward dependency; deps flow downward (`02-arch/018`).
- [ ] Mutation only through Commands; state changes emit Events; Flutter owns no business logic.
- [ ] Touched IR stays immutable + versioned + deterministic; schema change carries an ADR.
- [ ] Exporters consume Machine IR only; digitizer outputs Stitch IR; no hidden coupling.
- [ ] Machine IR references are embroidery-specific; Loom IR and Print IR are not routed through Machine IR.
- [ ] Project Type is persistent project data, not a temporary workspace or mode.
- [ ] Production plans are derived/regenerable; editable design intent remains authoritative.
- [ ] Package still owns one responsibility; public API minimal; internals not leaked.

# Correctness

- [ ] Logic matches the spec it cites; edge cases handled (empty, overflow, invalid input).
- [ ] Error handling preserves data; no silent failure at trust boundaries.
- [ ] Determinism: same input ⇒ same output (goldens prove it where applicable).
- [ ] No panic on untrusted input; `unsafe` justified + `unsafe_op_in_unsafe_fn` respected.

# Tests

- [ ] New/changed logic has a runnable test that fails if the logic breaks.
- [ ] Golden added/updated for pipeline stages; regression test added for any fixed bug.
- [ ] `cargo test` / `fvm flutter test` green for touched packages.

# Quality gates

- [ ] `cargo fmt --check` + `cargo clippy -D warnings` clean; `fvm dart format` clean.
- [ ] frb glue regenerated + committed if the FFI API changed (`make gen`, no diff).
- [ ] Perf budget respected where defined.

# Simplification (ponytail pass)

- [ ] No speculative abstraction (interface with one impl, config for a constant, scaffolding "for later").
- [ ] Stdlib/native/existing-dep used before new code or a new dependency.
- [ ] Deliberate shortcuts carry a `ponytail:` comment naming the ceiling + upgrade path.
- [ ] Diff is the shortest that works; deletion preferred over addition.

# Security

- [ ] No secrets in-repo; no unsafe install scripts / remote code.
- [ ] Plugin/AI paths go through the security gateway; no direct state access.

---

Reviewer roles: `qa-review` runs the full list; `architect` gates the Architecture section on any
boundary/IR-affecting PR. A failing box blocks merge — no "fix later".
