# ADR
## ADR-025 Use Testable Domain Rules

**Title:** Use Testable Domain Rules  
**Status:** Accepted
---

# Context

Embroidery quality depends on explicit rules and constraints that must be verified independently of UI or AI behavior.

---

# Decision

Encode domain rules in testable, reusable rule systems that can be verified independently of presentation and provider implementations.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Embed rules in UI handlers
- Rely on expert judgment without executable specifications

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/03-domain/ai/901-digitizing-rules.md
docs/05-engineering/500-testing-strategy.md
```
