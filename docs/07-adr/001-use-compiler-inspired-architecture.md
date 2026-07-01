# ADR
## ADR-001 Use Compiler Inspired Architecture

**Title:** Use Compiler Inspired Architecture  
**Status:** Accepted
---

# Context

Embroidery workflows transform artwork into progressively richer representations before producing machine instructions. A document editor mental model alone does not fully describe that pipeline.

---

# Decision

Model the product as a compiler-style pipeline that transforms artwork and document intent through intermediate representations into simulation and machine output.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Treat the product as a conventional graphics editor
- Compile directly from UI objects to machine files

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/001-intermediate-representations.md
docs/02-architecture/011-machine-compiler.md
```
