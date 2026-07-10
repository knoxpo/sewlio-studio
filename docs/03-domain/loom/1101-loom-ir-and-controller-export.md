# Domain
## DOM-1101 Loom IR and Controller Export

**Document ID:** DOM-1101  
**Title:** Loom IR and Controller Export  
**Version:** 1.0.0  
**Status:** Future Foundation  
**Priority:** Medium  
**Owner:** Loom Domain Team

**Related Documents**

```text
ARCH-039 Production Capability Model
DOM-1002 Weave Plan
DOM-1100 Loom Overview
```

---

# Purpose

Loom IR is the future domain-specific IR between Weave Plan and loom/controller export.

# Responsibilities

- Represent loom-ready production instructions at a controller-neutral level where possible.
- Capture diagnostics and capability assumptions.
- Feed controller-specific exporters or adapters.

# Rules

- Loom IR is not Machine IR.
- Export requirements depend on loom, controller, shedding system, vendor, and protocol.
- Controller-specific encoders consume Loom IR and must validate capabilities before output.

# Out of Scope

- Defining proprietary byte formats without sources.
- Treating all weaving output as one universal file.

# Acceptance Criteria

- Loom IR remains distinct from embroidery Machine IR and Print IR.
- Proprietary gaps are documented as research, not guessed.
