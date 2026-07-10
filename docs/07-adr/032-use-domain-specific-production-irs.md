# ADR-032: Use Domain-Specific Production IRs

**Document ID:** ADR-032  
**Title:** Use Domain-Specific Production IRs  
**Status:** Accepted  
**Date:** 2026-07-10  
**Owner:** Core Architecture Team

**Related Documents:** ARCH-001, ARCH-035, DOM-800, DOM-1101, DOM-1202.

## Context

The existing IR chain is embroidery-specific after Geometry IR. Future domains need their own production contracts.

## Decision

Keep shared design/import/geometry concepts shared, then use domain-specific production IRs: Stitch IR and Machine IR for embroidery, Loom IR for weaving, and Print IR for digital printing.

## Consequences

IR ownership remains clear. Exporters consume the compiled IR for their domain. Machine IR remains embroidery-specific.

## Alternatives Considered

- Rename Machine IR to Production IR. Rejected because it would erase existing embroidery meaning.
- Use one universal textile IR. Rejected until real shared semantics are proven.

## Implementation Notes

Existing embroidery IR docs remain authoritative for embroidery. New domains add docs before implementation.
