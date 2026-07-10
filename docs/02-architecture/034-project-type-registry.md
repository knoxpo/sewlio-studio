# Architecture
## ARCH-034 Project Type Registry

**Document ID:** ARCH-034  
**Title:** Project Type Registry  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** Critical  
**Owner:** Platform Product Team

**Related Documents**

```text
ARCH-031 Platform Domain Architecture
ARCH-036 Domain Module Registry
ARCH-038 Dynamic UI Contributions
UI-606 New Document Workflow
```

---

# Purpose

The Project Type Registry defines the persistent production type of a project.

Initial project types are Embroidery, Weaving, and Digital Printing. Only Embroidery is required for the MVP implementation.

# Responsibilities

- Identify supported Project Types.
- Resolve the active production engine and setup sections.
- Resolve domain tools, panels, inspectors, validators, simulation, exporters, profiles, and AI knowledge modules.
- Persist Project Type in project metadata.

# Rules

- Project Type is not a temporary mode.
- Switching Project Type is not a normal toolbar action.
- Cross-domain work uses explicit conversion commands.
- Unsupported Project Types may appear as documented future options but must not imply implemented engines.

# Out of Scope

- Live switching a project between unrelated production domains.
- Implementing a plugin marketplace for Project Types during MVP.

# Acceptance Criteria

- New Project starts with Project Type.
- Existing embroidery projects resolve to Embroidery Project.
- UI contribution and export lists are filtered by Project Type.
