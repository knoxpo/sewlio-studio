# ADR-035: Keep Derived Production Plans Regenerable

**Document ID:** ADR-035  
**Title:** Keep Derived Production Plans Regenerable  
**Status:** Accepted  
**Date:** 2026-07-10  
**Owner:** Production Platform Team

**Related Documents:** ARCH-032, ARCH-035, ADR-028.

## Context

Generated stitches, weave plans, and print plans can be expensive, but making them authoritative would make editing brittle and destructive.

## Decision

Treat production plans, simulations, and compiled production IRs as derived artifacts that can be invalidated and regenerated from design intent plus production configuration.

## Consequences

Caches may be stored for performance, but stale derived data is never trusted as the only source. Recovery and compatibility prioritize editable design intent.

## Alternatives Considered

- Persist production output as primary state. Rejected because it loses editability.
- Never cache generated data. Rejected because large documents may need performance caches.

## Implementation Notes

MVP can use simple full regeneration. Incremental regeneration is a future optimization.
