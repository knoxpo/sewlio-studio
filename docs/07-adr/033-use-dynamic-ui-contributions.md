# ADR-033: Use Dynamic UI Contributions

**Document ID:** ADR-033  
**Title:** Use Dynamic UI Contributions  
**Status:** Accepted  
**Date:** 2026-07-10  
**Owner:** Product Experience Team

**Related Documents:** ARCH-038, UI-400, UI-500, UI-603.

## Context

Different Project Types require different production tools, panels, inspectors, validators, simulations, and exporters.

## Decision

The shared UI shell resolves domain UI contributions from the active Project Type and domain module.

## Consequences

Shared tools remain reusable while embroidery, weaving, and printing can contribute focused production UI. The shell does not hardcode every future domain feature.

## Alternatives Considered

- Global tool list for all domains. Rejected because it exposes invalid actions.
- Separate app shells per domain. Rejected because shared workflows would diverge.

## Implementation Notes

For MVP, direct embroidery wiring is acceptable where no second implementation exists. Add registry abstractions only when the second domain or plugin path needs them.
