# Architecture
## ARCH-039 Production Capability Model

**Document ID:** ARCH-039  
**Title:** Production Capability Model  
**Version:** 1.0.0  
**Status:** Foundation  
**Priority:** High  
**Owner:** Production Platform Team

**Related Documents**

```text
ARCH-033 Production Engine Architecture
ARCH-036 Domain Module Registry
DOM-806 Export Format Capabilities
```

---

# Purpose

The Production Capability Model describes what a production domain, machine, loom, printer, controller, RIP, or exporter can support.

# Responsibilities

- Represent constraints and supported features.
- Drive validation, setup defaults, export filtering, and diagnostics.
- Avoid invented proprietary format details.
- Let vendors and adapters expose capabilities without leaking implementation internals.

# Rules

- Capabilities are domain-specific.
- Unknown proprietary details are research requirements, not fabricated specs.
- Exporters must reject unsupported output explicitly.
- Capability checks must run before production output is generated.

# Out of Scope

- A universal capability schema that erases domain differences.
- Vendor protocol reverse engineering without evidence.

# Acceptance Criteria

- Embroidery format capabilities remain valid.
- Loom/controller and RIP capabilities can be documented without fake file specifications.
- Validation can explain unsupported settings before export.
