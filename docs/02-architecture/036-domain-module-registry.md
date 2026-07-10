# Architecture
## ARCH-036 Domain Module Registry

**Document ID:** ARCH-036  
**Title:** Domain Module Registry  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** High  
**Owner:** Platform Extensibility Team

**Related Documents**

```text
ARCH-013 Plugin Architecture
ARCH-034 Project Type Registry
ARCH-038 Dynamic UI Contributions
ARCH-039 Production Capability Model
```

---

# Purpose

The Domain Module Registry describes how production domains contribute behavior to the platform.

# Responsibilities

- Register a domain's engine, validators, simulation providers, compilers, exporters, profiles, UI contributions, and AI knowledge module.
- Keep registration explicit and capability-driven.
- Prevent global shell code from hardcoding every production-domain feature.

# Rules

- Domain modules must expose stable public capabilities.
- Shared platform code depends on registry contracts, not domain internals.
- Domain modules may be built in Dart for MVP and later backed by Rust where justified.
- A domain module cannot mutate project state except through commands.

# Out of Scope

- Third-party binary plugin loading in MVP.
- Requiring all domains to use identical internal data models.

# Acceptance Criteria

- Embroidery registers as the active MVP domain.
- Weaving and printing can be represented as planned modules without implementation.
- UI and export contribution lookup can be described without hardcoded global lists.
