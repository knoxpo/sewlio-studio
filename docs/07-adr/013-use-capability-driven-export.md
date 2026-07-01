# ADR
## ADR-013 Use Capability Driven Export

**Title:** Use Capability Driven Export  
**Status:** Accepted
---

# Context

Different machine formats and devices support different commands, limits, and metadata; treating export as one generic path causes silent failures.

---

# Decision

Drive export planning and validation from declared format and machine capabilities rather than format-name conditionals alone.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Format-name branching only
- Best-effort export without capability validation

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/03-domain/export/806-format-capabilities.md
docs/02-architecture/012-export-pipeline.md
```
