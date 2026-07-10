# Domain
## DOM-1202 Print Plan and Print IR

**Document ID:** DOM-1202  
**Title:** Print Plan and Print IR  
**Version:** 1.0.0  
**Status:** Future Foundation  
**Priority:** Medium  
**Owner:** Printing Domain Team

**Related Documents**

```text
ARCH-035 Production Plan Lifecycle
DOM-1200 Printing Overview
DOM-1201 Color and RIP Pipeline
```

---

# Purpose

The Print Plan and Print IR are the future derived production artifacts for Digital Printing Projects.

# Responsibilities

- Resolve design objects into print layout, bleed, safe area, substrate, color-separation, resolution, and output readiness.
- Compile printer/RIP-ready data through Print IR.

# Rules

- Print Plan is derived from the Universal Design Document and print configuration.
- Print IR is not Machine IR or Loom IR.
- Exporters and RIP adapters consume Print IR or validated raster/file output, depending on capability.

# Out of Scope

- Treating standard document PDF/TIFF export as full printer integration.
- MVP implementation.

# Acceptance Criteria

- Print Plan and Print IR are distinct from design objects and export files.
- Regeneration from design intent is required after relevant changes.
