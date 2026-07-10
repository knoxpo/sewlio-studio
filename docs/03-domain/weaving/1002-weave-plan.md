# Domain
## DOM-1002 Weave Plan

**Document ID:** DOM-1002  
**Title:** Weave Plan  
**Version:** 1.0.0  
**Status:** Future Foundation  
**Priority:** Medium  
**Owner:** Weaving Domain Team

**Related Documents**

```text
ARCH-035 Production Plan Lifecycle
DOM-1000 Weaving Overview
DOM-1101 Loom IR and Controller Export
```

---

# Purpose

The Weave Plan is the derived production plan for a Weaving Project.

# Responsibilities

- Resolve design intent into weave structures, yarn assignments, repeats, and lift/draft intent.
- Provide validation inputs for floats, loom limits, yarn changes, and repeat feasibility.
- Feed Loom IR compilation.

# Rules

- The Weave Plan is derived from the Universal Design Document and weaving configuration.
- It is not the editable source of truth.
- Loom-specific commands belong in Loom IR, not in shared design objects.

# Out of Scope

- MVP implementation.
- A universal rapier output file.

# Acceptance Criteria

- Weave Plan is distinct from Stitch Plan and Print Plan.
- Regeneration from design intent is the documented recovery path.
