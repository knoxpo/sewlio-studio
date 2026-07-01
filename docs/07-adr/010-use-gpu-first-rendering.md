# ADR
## ADR-010 Use GPU First Rendering

**Title:** Use GPU First Rendering  
**Status:** Accepted
---

# Context

A professional embroidery workstation must render dense vector, stitch, and overlay content interactively across large documents.

---

# Decision

Treat GPU-backed rendering as the primary rendering strategy for the interactive canvas and overlays.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- CPU-first immediate rendering
- Hybrid rendering without a primary strategy

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
docs/05-engineering/301-gpu-backend.md
```
