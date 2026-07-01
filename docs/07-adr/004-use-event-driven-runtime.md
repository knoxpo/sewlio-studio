# ADR
## ADR-004 Use Event Driven Runtime

**Title:** Use Event Driven Runtime  
**Status:** Accepted
---

# Context

Many subsystems need to react to changes without tight coupling, including rendering, diagnostics, history, AI, and plugin extensions.

---

# Decision

Use an event-driven runtime where subsystems react to typed events rather than direct cross-service mutation.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Use direct service callbacks everywhere
- Poll subsystems for changes

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/004-event-system.md
docs/02-architecture/002-data-flow.md
```
