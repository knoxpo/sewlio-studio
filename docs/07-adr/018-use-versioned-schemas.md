# ADR
## ADR-018 Use Versioned Schemas

**Title:** Use Versioned Schemas  
**Status:** Accepted
---

# Context

Projects, APIs, plugins, and AI knowledge assets all evolve over time and must remain readable across releases.

---

# Decision

Version all long-lived schemas and contracts, with compatibility rules and migration strategies defined up front.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Informal compatibility expectations
- Breaking schema changes without migration policy

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/006-project-format.md
docs/05-engineering/107-versioning-release.md
```
