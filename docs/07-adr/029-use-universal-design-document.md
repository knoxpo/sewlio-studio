# ADR-029: Use a Universal Design Document

**Document ID:** ADR-029  
**Title:** Use a Universal Design Document  
**Status:** Accepted  
**Date:** 2026-07-10  
**Owner:** Architecture Team

**Related Documents:** ARCH-032, ARCH-005, ARCH-006, ADR-028.

## Context

Sewlio Studio is expanding from an embroidery-centered app into a textile design and production platform. The existing editable-object rule must remain, but the source document can no longer be described only as an embroidery project.

## Decision

Use a Universal Design Document as the editable source of truth. Embroidery, weaving, and printing production data are derived or domain-specific extensions around that document.

## Consequences

Design intent remains reusable across domains. Production plans, IRs, simulations, and exports are regenerable. Domain data stays precise instead of being forced into a generic schema.

## Alternatives Considered

- Separate editor documents per domain. Rejected because it duplicates shared design behavior.
- Make production output authoritative. Rejected because it makes edits destructive.

## Implementation Notes

Phase 1 keeps existing Dart document packages and embroidery behavior. This ADR changes terminology and boundaries, not MVP scope.
