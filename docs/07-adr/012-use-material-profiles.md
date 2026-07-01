# ADR
## ADR-012 Use Material Profiles

**Title:** Use Material Profiles  
**Status:** Accepted
---

# Context

Fabric, stabilizer, thread, and machine interactions materially affect digitizing quality and manufacturing outcomes.

---

# Decision

Represent fabric, stabilizer, and related manufacturing constraints through explicit material profiles used by rules, simulation, and AI.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Free-form notes only
- Hard-code a few fabric categories in UI logic

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/03-domain/fabrics/505-material-profiles.md
docs/03-domain/fabrics/500-fabric-theory.md
```
