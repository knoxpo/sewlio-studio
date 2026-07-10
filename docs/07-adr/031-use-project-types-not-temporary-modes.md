# ADR-031: Use Project Types, Not Temporary Modes

**Document ID:** ADR-031  
**Title:** Use Project Types, Not Temporary Modes  
**Status:** Accepted  
**Date:** 2026-07-10  
**Owner:** Product Architecture Team

**Related Documents:** ARCH-034, UI-606, ARCH-038.

## Context

Production domain selection changes tools, validation, simulation, export, profiles, and AI behavior. Treating it as a mode would make projects ambiguous.

## Decision

Store Project Type as persistent project data selected during project creation.

## Consequences

The active Project Type resolves production behavior. Cross-domain work happens through explicit conversion or derivation.

## Alternatives Considered

- Toolbar mode switch. Rejected because it hides destructive semantic changes.
- One universal project with all tools always visible. Rejected because it creates confusing and invalid workflows.

## Implementation Notes

Embroidery is the only required Phase 1 Project Type implementation. Weaving and Digital Printing can be shown as future-capable where product docs require it.
