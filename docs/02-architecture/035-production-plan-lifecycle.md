# Architecture
## ARCH-035 Production Plan Lifecycle

**Document ID:** ARCH-035  
**Title:** Production Plan Lifecycle  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** High  
**Owner:** Production Platform Team

**Related Documents**

```text
ARCH-032 Universal Design Document
ARCH-033 Production Engine Architecture
ARCH-039 Production Capability Model
ADR-035 Keep Derived Production Plans Regenerable
```

---

# Purpose

Production plans describe domain-specific manufacturing intent derived from the Universal Design Document.

# Responsibilities

- Represent derived production intent.
- Support validation, simulation, optimization, and compile readiness.
- Cache expensive results where useful.
- Regenerate after relevant design, profile, or configuration changes.

# Domain Examples

- Embroidery: Stitch Plan, then Stitch IR and Machine IR.
- Weaving: Weave Plan, then Loom IR.
- Digital Printing: Print Plan, then Print IR.

# Rules

- Production plans are not the editable source of truth.
- Cached plans must declare the design/configuration inputs they were derived from.
- Stale plans must be invalidated or clearly marked stale.
- Exporters consume compiled domain IR, not editable design objects.

# Out of Scope

- Requiring full incremental regeneration in MVP.
- Persisting every intermediate cache permanently.

# Acceptance Criteria

- Regeneration is documented as the recovery path for stale production data.
- Domain plans are named precisely.
- Export readiness depends on current validation state.
