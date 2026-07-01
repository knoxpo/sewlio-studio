# ADR
## ADR-005 Use Immutable Document Model

**Title:** Use Immutable Document Model  
**Status:** Accepted
---

# Context

Complex editing, replay, testing, and background derivations become fragile when shared mutable state is modified in place.

---

# Decision

Represent project and document state as immutable snapshots with derived state rebuilt through commands and events.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Use mutable shared objects with locks
- Snapshot only for save/export boundaries

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/005-document-model.md
docs/02-architecture/022-testing-architecture.md
```
