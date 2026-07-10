# Architecture
## ARCH-032 Universal Design Document

**Document ID:** ARCH-032  
**Title:** Universal Design Document  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** Critical  
**Owner:** Document Model Team

**Related Documents**

```text
ARCH-005 Document Model
ARCH-006 Project Format
ARCH-028 Observability
ADR-028 Editable Objects Are Authoritative
ADR-029 Use Universal Design Document
```

---

# Purpose

The Universal Design Document is the editable source of truth for Sewlio Studio projects.

It stores design intent that can be interpreted by production domains. It does not store final machine, loom, RIP, or controller output as authoritative state.

# Responsibilities

- Store editable design objects, layers, groups, text, paths, curves, raster assets, colors, materials, transforms, guides, and metadata.
- Preserve user intent across save, reopen, undo, redo, import, and conversion.
- Provide stable input to production engines.
- Keep derived production caches disposable and regenerable.

# Boundaries

The Universal Design Document may contain shared design data and domain-specific production configuration.

It must not replace domain-specific production data with vague generic fields. Embroidery production data, weaving production data, and printing production data remain separate.

# Rules

- Design intent is authoritative.
- Production plans are caches or generated artifacts.
- Export files are generated artifacts.
- Cross-domain reuse happens through explicit conversion or derivation commands.
- Domain-specific terms stay domain-specific.

# Out of Scope

- A single universal production command language for all domains.
- Making weaving or printing editable through embroidery stitch objects.
- Persisting generated production output as the only editable project state.

# Acceptance Criteria

- A project can identify its Project Type and still store shared design data.
- Embroidery stitches, weave plans, and print rasters are documented as derived unless specifically imported as source assets.
- The document model remains headless-testable and command-driven.
