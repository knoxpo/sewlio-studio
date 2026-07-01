# Architecture
## ARCH-022 Testing Architecture

**Document ID:** ARCH-022  
**Title:** Testing Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Quality Engineering Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-003 Command System
ARCH-004 Event System
ARCH-005 Document Model
ARCH-007 Storage Architecture
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
ARCH-014 AI Runtime
ARCH-016 Performance Architecture
ARCH-017 Security Model
ARCH-019 Error Handling
ARCH-021 Architecture Principles
```

---

# Purpose

The Testing Architecture defines the quality strategy, testing layers, validation mechanisms, automation, and quality gates for Sewlio Studio.

Testing is not a separate phase.

Testing is an architectural capability.

Every subsystem must be independently verifiable, deterministic, and continuously validated.

---

# Philosophy

The architecture should make software easy to test.

A feature that is difficult to test usually indicates an architectural problem.

Testing exists to provide confidence, not merely coverage.

---

# Quality Goals

The testing architecture shall ensure:

- Correctness
- Determinism
- Reliability
- Recoverability
- Performance
- Compatibility
- Security
- Maintainability

---

# Testing Pyramid

```text
                    E2E Tests
                         ▲
                  Integration Tests
                         ▲
                Component/System Tests
                         ▲
                    Unit Tests
                         ▲
                Property-Based Tests
```

Every layer serves a different purpose.

---

# Quality Gates

Every change must pass:

```text
Formatting

↓

Linting

↓

Static Analysis

↓

Unit Tests

↓

Integration Tests

↓

Golden Tests

↓

Performance Tests

↓

Security Tests

↓

End-to-End Tests
```

A merge is blocked if any required gate fails.

---

# Testing Principles

## Deterministic

Tests must produce identical results on every supported platform.

---

## Independent

Tests must not depend on execution order.

---

## Fast

Unit tests should complete within seconds.

---

## Repeatable

A passing test today should pass tomorrow without environmental changes.

---

## Observable

Failures must include sufficient diagnostics to reproduce the issue.

---

## Local First

Every test suite should run without internet connectivity.

---

# Test Categories

---

## Unit Tests

Validate individual functions and components.

Examples

```text
Geometry calculations

Matrix operations

Command validation

Thread mapping

Parser utilities
```

Target runtime

```text
<60 seconds
```

---

## Component Tests

Validate an individual subsystem.

Examples

```text
Digitizer Compiler

Machine Compiler

Export Generator

Simulation Engine

Storage Manager
```

No external dependencies.

---

## Integration Tests

Validate communication between multiple subsystems.

Examples

```text
Import

↓

Digitizer

↓

Simulation

↓

Machine Compiler

↓

Export
```

---

## System Tests

Validate complete workflows.

Example

```text
Create Design

↓

Digitize

↓

Simulate

↓

Export

↓

Re-import

↓

Compare
```

---

## End-to-End Tests

Validate user-facing workflows.

Examples

```text
Desktop

Tablet

Phone

Web
```

Driven through the UI.

---

## Regression Tests

Protect against previously fixed defects.

Every production bug should result in a regression test.

---

## Golden Tests

Compare generated output against known-good references.

Used for

```text
Rendering

Export

Simulation

Machine IR

Playback IR

Geometry
```

---

## Snapshot Tests

Verify UI state.

Examples

```text
Dialogs

Inspector

Panels

Canvas Widgets

Preferences
```

Snapshots should be stable across platforms where practical.

---

## Property-Based Tests

Verify mathematical and logical invariants.

Examples

```text
Undo

↓

Redo

↓

Original State

----------------

Rotate

↓

Rotate Back

↓

Original Geometry

----------------

Import

↓

Export

↓

Import

↓

Equivalent Result
```

---

## Fuzz Tests

Provide malformed input.

Targets

```text
Importers

Project Files

Plugins

Parsers

Machine Profiles

AI Tool Calls
```

Application must never crash.

---

## Stress Tests

Examples

```text
10 Million Stitches

1000 Layers

10000 Objects

1000 Undo Operations

100 Simultaneous Tasks
```

---

## Soak Tests

Long-duration execution.

Examples

```text
24-hour simulation

Continuous rendering

Continuous autosave

Plugin lifecycle

Background AI
```

Memory usage must remain stable.

---

## Performance Tests

Benchmark

```text
Import

Digitizer

Simulation

Machine Compiler

Export

Rendering

Storage
```

Performance budgets enforced automatically.

---

## Security Tests

Validate

```text
Permissions

Sandbox

Policy Engine

Secure Storage

Import Validation

Plugin Isolation
```

---

## Compatibility Tests

Verify

```text
Project Versions

Plugin API Versions

Machine Profiles

Export Formats

Import Formats
```

---

# Compiler Testing

Every compiler follows the same strategy.

```text
Input IR

↓

Compiler

↓

Output IR

↓

Golden Comparison
```

Compilers never require the UI.

---

# Import Testing

Validate

- parsing
- normalization
- validation
- diagnostics
- unsupported features
- malformed files

---

# Digitizer Testing

Validate

- stitch generation
- underlay
- fill generation
- satin generation
- optimization
- deterministic output

---

# Playback Testing

Validate

- timeline
- frame generation
- seeking
- playback statistics
- interpolation

---

# Machine Compiler Testing

Validate

- thread mapping
- needle assignment
- machine validation
- hoop validation
- diagnostics

---

# Export Testing

Validate

- binary encoding
- checksums
- metadata
- streaming
- deterministic output

---

# Rendering Testing

Rendering validation includes

- image comparisons
- GPU compatibility
- zoom levels
- antialiasing
- overlays
- dirty regions

Golden images should include acceptable tolerances for platform differences where necessary.

---

# Storage Testing

Validate

- save
- load
- migration
- autosave
- crash recovery
- corruption detection

---

# AI Runtime Testing

Validate

- tool execution
- permission checks
- planner behavior
- context generation
- conversation lifecycle
- cancellation

Model providers are mocked for deterministic testing.

---

# Plugin Testing

Plugins require

- manifest validation
- permission validation
- sandbox validation
- lifecycle tests
- API compatibility
- failure isolation

---

# Workspace Testing

Validate

- layout persistence
- panel management
- preferences
- multiple documents
- session restoration

---

# Resource Testing

Validate

- thread libraries
- machine profiles
- templates
- font loading
- cache invalidation

---

# Error Testing

Every subsystem must verify

- failure handling
- recovery
- retries
- cancellation
- rollback
- diagnostics

---

# Cross-Platform Testing

Supported platforms

```text
macOS

Windows

Linux

iPadOS

Android

iOS

Web
```

Behavior should remain consistent.

Platform-specific expectations must be documented.

---

# Continuous Integration

Pipeline

```text
Build

↓

Static Analysis

↓

Unit Tests

↓

Integration Tests

↓

Golden Tests

↓

Benchmarks

↓

Security Tests

↓

Package Validation

↓

Artifacts
```

Every pull request executes CI.

---

# Code Coverage

Coverage is a health metric, not a goal.

Suggested targets

```text
Core Runtime

95%

Compiler Packages

95%

Services

90%

Flutter UI

80%

Plugins

Project Dependent
```

Meaningful assertions are more valuable than higher percentages.

---

# Mutation Testing

Critical subsystems should support mutation testing.

Examples

```text
Command Bus

Machine Compiler

Digitizer

Security Gateway

Storage
```

---

# Test Data

Test fixtures belong in dedicated repositories.

Categories

```text
Geometry

Embroidery

Machine Profiles

Export Files

Import Files

Corrupt Projects

Performance Projects
```

Fixtures are versioned.

---

# Deterministic Fixtures

Each fixture includes

```text
Input

Expected Output

Expected Diagnostics

Version

Metadata
```

Fixtures are immutable.

---

# Benchmark Suite

Benchmarks measure

```text
Execution Time

Memory

CPU

Allocations

Cache Hits

GPU Usage

Binary Size
```

Historical results retained.

---

# Failure Reports

Every failure includes

```text
Subsystem

Test Name

Version

Platform

Expected

Actual

Diagnostics

Logs

Artifacts
```

---

# AI Agent Rules

AI-generated code must include

- unit tests
- regression tests
- fixture updates when required
- benchmark updates if performance changes
- documentation updates

No feature is complete without tests.

---

# Architectural Constraints

1. Every package owns its tests.
2. Tests are deterministic.
3. Network access is optional.
4. Every compiler has golden tests.
5. Regression tests accompany bug fixes.
6. Performance budgets are continuously validated.
7. Security is tested independently.
8. Fixtures are versioned.
9. Tests are executable in isolation.
10. Quality gates block regressions.

---

# Future Enhancements

- Distributed test execution
- AI-generated regression tests
- Visual diff dashboard
- Automated flaky test detection
- Property-based fixture generation
- Cross-version compatibility matrix
- Continuous fuzzing
- Hardware performance lab
- Plugin certification suite
- Cloud-free reproducible build validation

---

# Acceptance Criteria

The Testing Architecture is complete when

✓ Every subsystem has a defined testing strategy.

✓ Compiler pipelines are validated independently.

✓ Golden tests ensure deterministic outputs.

✓ Performance regressions are automatically detected.

✓ Security and recovery paths are continuously verified.

✓ Plugins and AI runtime are tested in isolation.

✓ Cross-platform behavior is validated.

✓ Every production defect results in a regression test.

✓ CI enforces architectural quality gates.

✓ Testing remains a first-class architectural concern rather than a post-development activity.
