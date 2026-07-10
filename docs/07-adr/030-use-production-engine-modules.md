# ADR-030: Use Production Engine Modules

**Document ID:** ADR-030  
**Title:** Use Production Engine Modules  
**Status:** Accepted  
**Date:** 2026-07-10  
**Owner:** Architecture Team

**Related Documents:** ARCH-031, ARCH-033, ARCH-036.

## Context

Embroidery, weaving, and digital printing require different production semantics.

## Decision

Each production domain owns its engine, production plan, optimizer, compiler, IR, validators, simulation, exporters, profiles, and AI knowledge module.

## Consequences

The platform can share design, commands, events, UI shell, and services without flattening domain rules. Embroidery remains the first implemented module.

## Alternatives Considered

- One generic production engine. Rejected because stitches, weave picks, and ink/RIP output do not share one useful command model.
- Separate applications. Rejected because shared design and project workflows would fragment.

## Implementation Notes

Do not create weaving or printing implementation packages for MVP. Add registry seams only when needed by actual work.
