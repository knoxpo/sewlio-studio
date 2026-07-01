# ADR
## ADR-020 Use Human In The Loop AI

**Title:** Use Human In The Loop AI  
**Status:** Accepted
---

# Context

AI can accelerate embroidery workflows but may also make unsafe or low-quality recommendations if left unsupervised.

---

# Decision

Require human approval for AI actions that change persistent project state or materially affect manufacturing output.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Autonomous AI mutations
- Disable AI actions entirely

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/06-ai/701-human-approval.md
docs/06-ai/700-ai-safety.md
```
