# ADR
## ADR-006 Use Service Registry

**Title:** Use Service Registry  
**Status:** Accepted
---

# Context

Application services must be discoverable, lifecycle-managed, and replaceable in tests without hard-coded global dependencies.

---

# Decision

Use a service registry to construct, own, and expose runtime services through explicit contracts and lifecycle management.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Use hard-coded globals
- Construct services ad hoc inside features

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/024-service-registry.md
docs/02-architecture/023-runtime-lifecycle.md
```
