# Domain
## DOM-1201 Color and RIP Pipeline

**Document ID:** DOM-1201  
**Title:** Color and RIP Pipeline  
**Version:** 1.0.0  
**Status:** Future Foundation  
**Priority:** Medium  
**Owner:** Printing Domain Team

**Related Documents**

```text
DOM-1200 Printing Overview
DOM-1202 Print Plan and Print IR
ARCH-039 Production Capability Model
```

---

# Purpose

This document separates design color from production color for digital textile printing.

# Responsibilities

- Distinguish design color, working color space, printer color space, ink channels, ICC transforms, RIP processing, and final raster/output generation.
- Define future validation areas for ICC availability, substrate profiles, resolution, bleed, and ink limits.

# Rules

- Design color is not printer output color.
- Ink channels are production-domain data.
- RIP processing may be external, embedded, or adapter-driven depending on capability.
- Unsupported color transforms must produce diagnostics.

# Out of Scope

- Implementing color separation in MVP.
- Hardcoding vendor RIP behavior.

# Acceptance Criteria

- Printing docs do not collapse ICC, ink channels, and RIP output into generic export.
- Future Print Engine work has clear color-management boundaries.
