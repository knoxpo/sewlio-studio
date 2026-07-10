# Architecture
## ARCH-038 Dynamic UI Contributions

**Document ID:** ARCH-038  
**Title:** Dynamic UI Contributions  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** High  
**Owner:** Product Experience Team

**Related Documents**

```text
ARCH-034 Project Type Registry
ARCH-036 Domain Module Registry
UI-400 Tool System
UI-500 Property Inspector
UI-603 Export UI
```

---

# Purpose

Dynamic UI contributions allow the shared application shell to expose tools, panels, inspectors, validation, simulation, and export flows for the active Project Type.

# Responsibilities

- Keep shared design tools available across project types.
- Load production tools and panels from the active domain module.
- Filter inspectors, validators, simulations, and exporters by Project Type.
- Keep all persistent mutations command-driven.

# Rules

- Shared shell code must not hardcode every domain tool.
- UI contributions describe interaction and presentation only.
- Domain rules remain in production engines or validators.
- Unsupported domain contributions must be hidden or marked unavailable.

# Out of Scope

- Plugin marketplace UX.
- Domain-specific UI implementation for weaving or printing in MVP.

# Acceptance Criteria

- Embroidery-specific stitch tools remain available for Embroidery Projects.
- Future weaving and printing tools can be contributed without redesigning the shell.
- Export UI lists only compatible exporters.
