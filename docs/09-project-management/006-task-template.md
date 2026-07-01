# Project Management

## PM-006 Task Template

**Document ID:** PM-006
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Tech Lead

Canonical shape for every engineering task. Tasks are **4-12h, never larger than one day**. Copy
this block per task (also the `body` schema used in `tools/github/issues.json`).

---

```markdown
### <ID e.g. E3-F2-T1> — <short imperative title>

**Objective:** one sentence — the outcome.

**Description:** what to build and why; reference the source spec (docs/…) and the parent
feature/epic. Note the approach and any deliberate simplification (`ponytail:` ceiling + upgrade).

**Dependencies:** <task/feature IDs that must be Done first> (must precede this in 004-development-order).

**Expected files:**
- `crates/…/src/….rs` (or `packages/…/lib/….dart`) — new/changed
- test file(s)

**Expected tests:** <unit | serialization | golden | property | integration> — the specific
assertion that fails if the logic breaks.

**Estimate:** <XS ≤4h | S 4-8h | M 1-2 days> (tasks stay ≤ M)

**Priority:** <P0 | P1 | P2 | P3>

**Complexity:** <low | medium | high>

**Labels:** <domain/layer> <stack> `task` <priority> <size>

**Definition of Done:** meets Task DoD in docs/08-implementation/008-definition-of-done.md.
```

---

# Worked example

```markdown
### E1-F3-T1 — Command trait + dispatch

**Objective:** Provide the single mutation entry point for the engine.

**Description:** Define a `Command` trait and an in-memory `CommandBus` that validates then routes a
command to its handler, returning a result or a domain error. Source: docs/02-architecture/003.
Foundation for all mutation (Non-Negotiable #3). ponytail: in-memory synchronous dispatch now;
async/scheduler routing when background work lands.

**Dependencies:** E1-F1-T1 (ids/time)

**Expected files:**
- `crates/es_core/src/command.rs`
- `crates/es_core/src/command.rs` inline `#[cfg(test)]`

**Expected tests:** unit — dispatching a registered command runs its handler and returns Ok; an
unregistered/invalid command returns the expected error.

**Estimate:** M (1-2 days)   **Priority:** P0   **Complexity:** medium

**Labels:** `runtime` `rust` `task` `P0` `size/M`

**Definition of Done:** Task DoD green (fmt/clippy/test), no cross-layer dep, rustdoc on the trait.
```

Rules: if a task can't be stated with a concrete failing test, it's not ready. If it exceeds size/M,
split it. Every task traces to a feature and a milestone.
