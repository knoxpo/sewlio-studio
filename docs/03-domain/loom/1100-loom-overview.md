# Domain
## DOM-1100 Loom Overview

**Document ID:** DOM-1100  
**Title:** Loom Overview  
**Version:** 1.0.0  
**Status:** Future Foundation  
**Priority:** Medium  
**Owner:** Loom Domain Team

**Related Documents**

```text
DOM-1000 Weaving Overview
DOM-1002 Weave Plan
DOM-1101 Loom IR and Controller Export
```

---

# Purpose

This document defines loom-related concepts for future Weaving Projects.

# Responsibilities

- Represent loom profiles, shedding systems, dobby/Jacquard capabilities, harness limits, width limits, yarn/pick constraints, and controller adapters.
- Feed weaving validation and Loom IR compilation.

# Rules

- Loom profile capabilities determine export readiness.
- Rapier, air-jet, water-jet, and shuttle are insertion mechanisms; pattern control is separate.
- Unknown controller details are research requirements.

# Out of Scope

- Implementing loom connectivity in MVP.
- Claiming support for a vendor protocol without fixtures or documentation.

# Acceptance Criteria

- Loom capability documentation can support validation and exporter filtering.
- Dobby and Jacquard control are documented as distinct pattern-control paths.
