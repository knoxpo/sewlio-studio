# ADR
## ADR-015 Use Local First Project Format

**Title:** Use Local First Project Format  
**Status:** Accepted
---

# Context

Embroidery work is often performed in studio or production environments where network access and cloud trust cannot be assumed.

---

# Decision

Store projects in a local-first, versioned format that remains fully functional offline and does not depend on cloud coordination.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Cloud-only project storage
- Loose folders with no schema governance

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
docs/02-architecture/007-storage-architecture.md
```
