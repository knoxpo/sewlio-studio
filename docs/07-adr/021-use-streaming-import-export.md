# ADR
## ADR-021 Use Streaming Import Export

**Title:** Use Streaming Import Export  
**Status:** Accepted
---

# Context

Large assets and machine outputs should report progress and avoid high memory spikes or long blocking phases.

---

# Decision

Implement import and export as streaming, progress-reporting workflows where formats and platforms allow it.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Whole-file buffering only
- Background threads without progress visibility

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/015-import-pipeline.md
docs/02-architecture/012-export-pipeline.md
```
