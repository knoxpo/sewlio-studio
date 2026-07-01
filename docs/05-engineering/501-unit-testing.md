# Engineering
## ENG-501 Unit Testing

**Document ID:** ENG-501  
**Title:** Unit Testing  
**Version:** 1.0.0  
**Status:** Implementation Guidance  
**Priority:** High  
**Owner:** Core Engineering Team

**Related Documents**

```text
docs/02-architecture/000-system-overview.md
docs/02-architecture/024-service-registry.md
docs/02-architecture/026-task-scheduler.md
docs/02-architecture/027-dependency-graph.md
docs/02-architecture/028-observability.md
```
---

# Purpose

This document defines how unit testing should be implemented in Sewlio Studio.

It translates the platform architecture into engineering constraints, package boundaries, runtime responsibilities, and measurable quality gates.

The guidance is intended to be directly usable by implementation teams working on a deterministic, immutable, plugin-extensible system.

---

# Philosophy

Engineering decisions for unit testing must preserve local-first behavior, command-driven mutation, event-derived updates, and scheduler-owned background work.

Implementation convenience must never override determinism, testability, or observability.

Cross-platform concerns should be isolated behind stable interfaces rather than leaking platform-specific behavior into domain code.

---

# Goals

- Establish pure logic isolation
- Establish stable fixtures
- Establish property-focused assertions
- Establish fast feedback

---

# Definition

Unit Testing is the engineering subsystem or policy area that governs pure logic isolation and stable fixtures.

It spans interfaces, runtime services, build/runtime behavior, and verification practices required for production delivery.

Where user-facing flows exist, they are enabled through application services and UI adapters rather than implemented as domain mutations.

---

# Responsibilities

- Define package-level and service-level contracts for unit testing.
- Constrain implementation choices so they remain deterministic, observable, and compatible with the documented architecture.
- Provide clear integration points for testing, diagnostics, and plugin-safe extension where relevant.
- Document failure handling, lifecycle ownership, and performance expectations for the subsystem.

---

# Implementation Architecture

```text
Specification

↓

Public Interfaces

↓

Service Implementation

↓

Scheduler / Dependency Graph / Resource Layer

↓

Telemetry and Tests
```

The unit testing implementation must fit within this layered model so that behavior remains testable and inspectable.

---

# Engineering Rules

- Core domain logic belongs in engine packages, not in UI or platform-shell code.
- Background work must execute through the task scheduler with explicit priority, cancellation, and tracing.
- Cross-package dependencies must remain acyclic and pass through documented public APIs only.
- All persistent formats, plugin contracts, and externally visible APIs must be versioned and compatibility-tested.

---

# Out of Scope

- Product prioritization and roadmap decisions outside engineering execution.
- Undocumented shortcuts that bypass service boundaries or lifecycle management.
- Platform-specific hacks that cannot be validated across supported targets.
- Direct mutation paths that circumvent commands, events, or versioned persistence.

---

# Future Topics

- Automated enforcement through linting, CI policy, and architecture tests.
- Additional platform-specific optimization notes as runtime targets mature.
- Extended plugin and AI integration contracts where engineering ownership expands.
- Operational playbooks derived from production telemetry and failure analysis.

---

# Acceptance Criteria

- The unit testing guidance can be implemented without contradicting the documented architecture.
- Interfaces, responsibilities, and lifecycle boundaries are explicit enough to guide package and service design.
- Testing, observability, security, and performance implications are all addressed at an implementation level.
- The document can be used as a review baseline for future engineering changes in this area.
