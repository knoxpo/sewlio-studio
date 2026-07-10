# Domain
## DOM-1000 Weaving Overview

**Document ID:** DOM-1000  
**Title:** Weaving Overview  
**Version:** 1.0.0  
**Status:** Future Foundation  
**Priority:** Medium  
**Owner:** Weaving Domain Team

**Related Documents**

```text
ARCH-031 Platform Domain Architecture
ARCH-033 Production Engine Architecture
ARCH-039 Production Capability Model
DOM-1100 Loom Overview
```

---

# Purpose

This document defines weaving as a future Sewlio Studio production domain.

Weaving is not part of the embroidery MVP. The architecture must support it without forcing weaving into stitch or machine-file concepts.

# Responsibilities

- Define warp, weft, picks, weave structures, repeats, floats, yarn planning, and draft/lift-plan concepts.
- Produce a Weave Plan from the Universal Design Document.
- Validate weave feasibility against loom capabilities.
- Compile domain output into Loom IR.

# Boundaries

Weaving uses shared design geometry and color assets, but production meaning is assigned by the Weaving Engine.

# Rules

- Warp, weft, pick, harness, denting, and float remain weaving-specific.
- A rapier system is a weft-insertion mechanism, not a universal pattern file format.
- Pattern control may come from dobby or Jacquard shedding systems.

# Out of Scope

- Implementing weaving tools in Phase 1.
- Inventing proprietary loom controller formats.

# Acceptance Criteria

- Weaving is documented as a production domain separate from embroidery.
- Loom and controller export depend on capabilities and adapters.
- Weave Plan and Loom IR remain distinct from Stitch Plan and Machine IR.
