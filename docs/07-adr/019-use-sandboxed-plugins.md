# ADR
## ADR-019 Use Sandboxed Plugins

**Title:** Use Sandboxed Plugins  
**Status:** Accepted
---

# Context

Third-party code introduces risk to project integrity, user data, and runtime stability.

---

# Decision

Isolate plugin execution inside sandboxed runtimes with permission review, resource limits, and revocation controls.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Trust plugins by default
- Disable plugins entirely

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/013-plugin-architecture.md
docs/05-engineering/702-plugin-security.md
```
