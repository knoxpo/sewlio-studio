# Domain
## DOM-1200 Printing Overview

**Document ID:** DOM-1200  
**Title:** Digital Printing Overview  
**Version:** 1.0.0  
**Status:** Future Foundation  
**Priority:** Medium  
**Owner:** Printing Domain Team

**Related Documents**

```text
ARCH-031 Platform Domain Architecture
ARCH-033 Production Engine Architecture
DOM-1201 Color and RIP Pipeline
DOM-1202 Print Plan and Print IR
```

---

# Purpose

This document defines digital textile printing as a future Sewlio Studio production domain.

# Responsibilities

- Resolve design intent into print areas, substrate settings, ink/channel requirements, layout, bleed, resolution, and RIP/export readiness.
- Validate against printer, RIP, substrate, ICC profile, and output constraints.

# Rules

- Digital Printing Project is a production domain.
- Print Preview remains a UI/document preview concept unless explicitly tied to Digital Printing.
- PDF or TIFF export is not the same as complete printer/RIP integration.

# Out of Scope

- Implementing printing in the embroidery MVP.
- Claiming support for specific printer protocols without research.

# Acceptance Criteria

- Printing is separated from embroidery export and normal document print preview.
- Print Plan and Print IR are documented as derived artifacts.
