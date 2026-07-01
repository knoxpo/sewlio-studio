# ADR
## ADR-016 Use Deterministic Pipelines

**Title:** Use Deterministic Pipelines  
**Status:** Accepted
---

# Context

Production artifacts must be reproducible for testing, audit, and operator confidence.

---

# Decision

Design import, compilation, simulation, and export pipelines to be deterministic for equivalent inputs and configurations.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Allow opportunistic non-determinism for speed
- Rely on manual QA to catch drift

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/021-architecture-principles.md
docs/02-architecture/022-testing-architecture.md
```
