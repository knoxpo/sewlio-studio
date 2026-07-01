# ADR
## ADR-002 Use Machine Ir

**Title:** Use Machine Ir  
**Status:** Accepted
---

# Context

Exporting directly from high-level document objects to multiple machine formats would duplicate logic and make capabilities hard to reason about.

---

# Decision

Introduce a machine-oriented intermediate representation between stitch/domain output and format-specific encoders.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Encode each export directly from stitch objects
- Maintain separate per-format compilation trees

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/03-domain/export/800-machine-ir.md
docs/02-architecture/012-export-pipeline.md
```
