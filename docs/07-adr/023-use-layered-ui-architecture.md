# ADR
## ADR-023 Use Layered UI Architecture

**Title:** Use Layered UI Architecture  
**Status:** Accepted
---

# Context

The UI surface is large and must remain maintainable without absorbing domain behavior or asynchronous orchestration complexity.

---

# Decision

Structure the UI as layered shell, workspace, view-model, interaction, and rendering surfaces on top of runtime services.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Fat widgets/views with embedded business logic
- Single global UI controller

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/04-ui/000-ui-overview.md
docs/02-architecture/000-system-overview.md
```
