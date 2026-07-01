# ADR
## ADR-011 Use Render Graph

**Title:** Use Render Graph  
**Status:** Accepted
---

# Context

As rendering complexity grows, pass ordering and resource coordination become difficult to manage with ad hoc imperative drawing code.

---

# Decision

Coordinate rendering work through a declarative render graph with explicit passes and resource dependencies.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Manual pass orchestration
- Single giant renderer without pass isolation

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/008-rendering-architecture.md
docs/05-engineering/304-render-graph.md
```
