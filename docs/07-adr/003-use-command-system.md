# ADR
## ADR-003 Use Command System

**Title:** Use Command System  
**Status:** Accepted
---

# Context

The platform requires undo/redo, auditability, automation support, AI integration, and deterministic mutations across desktop and web runtimes.

---

# Decision

Require all persistent project mutations to be represented as commands executed through the command system.

---

# Consequences

- Implementation work receives a stable default that reduces architectural drift.
- Cross-team reviews can evaluate changes against an explicit decision record.
- The chosen approach imposes constraints on APIs, testing, and observability that must be respected going forward.
- Tradeoffs are accepted in exchange for stronger determinism, maintainability, and domain correctness.

---

# Alternatives Considered

- Permit direct object mutation from UI/services
- Use best-effort history recording after mutation

---

# Implementation Notes

- Reference the related architecture and domain documents when implementing or reviewing work in this area.
- If future requirements materially invalidate this decision, create a new ADR rather than silently drifting from it.
- Add tests, telemetry, and compatibility checks appropriate to the subsystem impacted by this ADR.
- Ensure plugin, AI, and UI integrations follow the same decision boundary where relevant.

---

# Related Documents

```text
docs/02-architecture/003-command-system.md
docs/02-architecture/005-document-model.md
```
