# ADR
## ADR-008 Use Task Scheduler

**Title:** Use Task Scheduler  
**Status:** Accepted
---

# Context

The product performs significant background work including imports, exports, simulation, AI, and asset processing that cannot block the UI thread.

---

# Decision

Centralize background execution in a task scheduler with priorities, cancellation, dependencies, and telemetry.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Spawn threads/tasks opportunistically
- Make each service own its own executor without central coordination

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/026-task-scheduler.md
docs/02-architecture/016-performance-architecture.md
```
