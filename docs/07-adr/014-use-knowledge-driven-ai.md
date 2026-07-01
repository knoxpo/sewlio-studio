# ADR
## ADR-014 Use Knowledge Driven AI

**Title:** Use Knowledge Driven AI  
**Status:** Accepted
---

# Context

AI features need domain trustworthiness, explainability, and safer behavior than generic prompt-only systems provide.

---

# Decision

Build AI features around explicit domain knowledge, rules, retrieval, and explainability instead of opaque prompt-only behavior.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Prompt-only AI
- Heuristic-only automation with no model support

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/014-ai-runtime.md
docs/06-ai/200-knowledge-graph.md
```
