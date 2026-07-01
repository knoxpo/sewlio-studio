# Project Management

## PM-007 Estimation Guidelines

**Document ID:** PM-007
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Engineering Manager

Consistent sizing so sprint load and the 2-year budget stay honest.

---

# Task sizes → hours

| Size | Hours | Meaning |
|---|---|---|
| XS | ≤ 4h | trivial: one function + test, config, small refactor |
| S | 4-8h | ~half–one day: a small type + tests |
| M | 1-2 days | a feature slice: type + logic + tests + docs |
| L | 2-4 days | **features only** — split into M/S tasks before scheduling |

Tasks are always ≤ M. Anything L is a feature; decompose it (`006-task-template.md`).

---

# Velocity assumptions

- One senior engineer + agents. Planning velocity: **~6-8 productive task-days per 2-week sprint**
  (10 working days − meetings, review, integration, CI friction).
- A sprint holds roughly **1 L-feature or 2-3 M-features** worth of tasks, not 10 working days of
  raw estimate — leave slack for review, goldens, and the demo.
- Agents accelerate implementation but **not** review/integration (the human bottleneck). Estimate
  the human's integration time, not just code-gen time.

---

# Estimation method

1. Size each task XS/S/M from the template.
2. Sum per sprint; keep ≤ velocity with ~20% buffer.
3. Epic duration = Σ features ÷ velocity, rounded up to whole sprints (see `001-epics.md`).
4. **Rolling wave:** near-term estimates are firm; estimates > 2 milestones out carry a ±50% band
   and are re-sized when the milestone enters the current wave.

---

# Complexity multipliers (raise the estimate)

| Factor | Effect |
|---|---|
| New IR / schema (needs versioning + migration + goldens) | ×1.5 |
| Determinism-critical (float, ordering) | ×1.3 |
| Cross-package integration | ×1.3 |
| First use of a new tool (frb, GPU backend, storage engine) | ×1.5 + a research spike |
| Binary format / real-file compat | ×1.5 (fixture sourcing) |

---

# Anti-patterns

- Estimating code-gen time and forgetting review/integration (the real constraint).
- Padding every task instead of buffering the sprint.
- Firm estimates for far-future epics — use bands, re-estimate on approach.
- Ignoring test/golden effort — it's part of the task, not extra.
