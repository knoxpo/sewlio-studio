# ADR
## ADR-022 Use Cross Platform Engine Core

**Title:** Use Cross Platform Engine Core  
**Status:** Accepted
---

# Context

The product targets desktop and web while requiring identical domain semantics across runtimes.

---

# Decision

Keep domain logic in a cross-platform engine core shared across supported runtimes, with thin platform adapters.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Separate engine implementations per platform
- Push logic upward into UI/runtime adapters

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/000-system-overview.md
docs/05-engineering/103-runtime-targets.md
```
