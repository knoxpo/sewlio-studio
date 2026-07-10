# Architecture
## ARCH-031 Platform Domain Architecture

**Document ID:** ARCH-031  
**Title:** Platform Domain Architecture  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** Critical  
**Owner:** Architecture Team

**Related Documents**

```text
ARCH-000 System Overview
ARCH-001 Intermediate Representations
ARCH-005 Document Model
ARCH-033 Production Engine Architecture
ARCH-034 Project Type Registry
```

---

# Purpose

This document defines Sewlio Studio as a shared textile design and production platform.

Embroidery remains the MVP production domain. Weaving and digital printing are planned production domains that must fit the same platform without forcing their semantics into embroidery concepts.

# Responsibilities

- Separate shared platform systems from production-domain systems.
- Keep the Universal Design Document as the editable source of truth.
- Route production behavior through the active Project Type.
- Preserve domain-owned engines, plans, optimizers, compilers, IRs, validators, simulations, and exporters.

# Architecture

```text
Universal Design Document
        |
        v
Production Engine
        |
        v
Production Plan
        |
        v
Production Optimizer
        |
        v
Production Compiler
        |
        v
Production IR
        |
        v
Exporter
```

Shared platform systems own project lifecycle, design objects, geometry, assets, commands, events, storage, validation framework, simulation framework, import/export framework, plugins, AI framework, and UI shell.

Production domains own domain meaning and output.

# Domain Boundaries

Embroidery owns Stitch Plan, Stitch IR, Machine IR, machine profiles, stitch validation, embroidery simulation, and embroidery exporters.

Weaving owns Weave Plan, Loom IR, loom profiles, weave validation, weave simulation, and loom/controller exporters.

Digital Printing owns Print Plan, Print IR, print/RIP profiles, print validation, print simulation, and print exporters.

# Rules

- Project Type is persistent project data, not a temporary UI mode.
- Design objects remain editable design intent.
- Production plans and production IRs are derived artifacts.
- Machine IR means embroidery Machine IR unless a document explicitly says Production IR.
- Domain concepts remain precise: stitch, warp, weft, pick, ink channel, ICC profile, and RIP are not interchangeable.

# Out of Scope

- Implementing weaving or printing engines during the embroidery MVP.
- Renaming existing `studio_*` packages.
- Replacing existing embroidery architecture.

# Acceptance Criteria

- Shared platform and domain-owned responsibilities are clearly separated.
- Embroidery MVP remains valid.
- Weaving and printing can be added without changing Project Type into an application mode.
- Production artifacts remain derived from the Universal Design Document.
