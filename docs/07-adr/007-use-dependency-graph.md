# ADR
## ADR-007 Use Dependency Graph

**Title:** Use Dependency Graph  
**Status:** Accepted
---

# Context

Rendering, simulation, validation, AI context, and exports all depend on derived data that should only be recomputed when necessary.

---

# Decision

Use a dependency graph to track derived artifacts, invalidations, and incremental recomputation across the runtime.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Recompute everything on every change
- Manually manage invalidation flags in each subsystem

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/027-dependency-graph.md
docs/02-architecture/026-task-scheduler.md
```
