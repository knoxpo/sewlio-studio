# Architecture
## ARCH-030 Coding Standards

**Document ID:** ARCH-030  
**Title:** Coding Standards & Engineering Guidelines  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Architecture Council

**Related Documents**

```text
ARCH-018 Package Ownership
ARCH-021 Architecture Principles
ARCH-022 Testing Architecture
ARCH-023 Runtime Lifecycle
ARCH-024 Service Registry
ARCH-025 Resource Management
ARCH-026 Task Scheduler
ARCH-027 Dependency Graph
ARCH-028 Observability
ARCH-029 Build System
```

---

# Purpose

This document defines the engineering standards that govern the implementation of Sewlio Studio.

Unlike language style guides (such as `rustfmt` or `dart format`), these standards focus on architectural consistency, maintainability, correctness, performance, and long-term scalability.

Every contributor—human or AI—must follow these standards.

---

# Philosophy

Code should optimize for:

1. Correctness
2. Readability
3. Maintainability
4. Testability
5. Performance

Never optimize readability away for minor performance gains unless proven necessary.

---

# Core Engineering Principles

Every piece of code should be

- Deterministic
- Testable
- Observable
- Documented
- Thread-safe where required
- Minimal
- Explicit
- Composable

---

# General Rules

## Single Responsibility

Every

- function
- struct
- enum
- trait
- package
- service

should have one primary responsibility.

---

## Prefer Composition

Prefer

```text
Small Components

↓

Composition
```

Avoid deep inheritance hierarchies.

---

## Explicit Over Implicit

Prefer

```rust
compile(project)
```

Instead of

```rust
run()
```

Names should communicate intent.

---

## Small Functions

Target

```text
20–40 lines
```

Maximum

```text
100 lines
```

Longer functions should usually be decomposed.

---

## Small Files

Recommended

```text
200–500 lines
```

Large files should be split by responsibility.

---

## Small Packages

Recommended

```text
500–3000 LOC
```

Packages should remain cohesive.

---

# Naming Conventions

Names should describe intent rather than implementation.

Good

```text
MachineCompiler

ResourceHandle

ExecutionPlan

ThreadPalette
```

Avoid

```text
Manager2

Helper

Utils

Data

Stuff
```

Generic names should be avoided unless their meaning is universally understood.

---

# API Design

Public APIs should

- be minimal
- be stable
- be documented
- expose intent
- avoid leaking implementation details

Breaking public APIs requires an ADR.

---

# Documentation

Every public item requires documentation.

Include

- purpose
- parameters
- return values
- errors
- examples (where helpful)

Complex algorithms should explain *why*, not merely *what*.

---

# Error Handling

Never ignore errors.

Prefer

```rust
Result<T, Error>
```

Every error should be

- structured
- contextual
- recoverable where appropriate

Never propagate plain strings.

---

# Logging

Logs should be

- structured
- actionable
- concise

Do not log

- passwords
- tokens
- API keys
- personal information

---

# Concurrency

Concurrency should use the Runtime Scheduler.

Do not

- spawn unmanaged threads
- create hidden executors
- block worker threads unnecessarily

Synchronization should be explicit.

---

# Memory Management

Avoid unnecessary allocations.

Prefer

- borrowing
- reuse
- object pools (where justified)
- immutable data

Premature optimization should be avoided.

---

# Immutability

Prefer immutable data.

Mutation should be localized and intentional.

Intermediate Representations (IRs) are immutable.

---

# Dependency Management

Dependencies must

- flow downward
- be explicit
- avoid cycles

No package may depend on implementation details of another package.

---

# Service Usage

Services are resolved through the Runtime Context.

Never create services manually.

Never access global singletons.

---

# Resource Usage

Always use

```text
ResourceHandle
```

Never store raw references to managed resources.

Resource lifetime belongs to the Resource Manager.

---

# Commands

State changes must occur through Commands.

Do not modify the Document directly.

---

# Events

Events communicate state changes.

Events never perform state changes.

---

# Task Scheduling

Background work must be submitted to the Task Scheduler.

Long-running work must

- support cancellation
- report progress
- avoid blocking

---

# Dependency Graph

Incremental computation must integrate with the Dependency Graph.

Never implement custom invalidation logic unless explicitly justified.

---

# Plugin Development

Plugins must

- use public APIs
- declare permissions
- avoid hidden dependencies
- remain sandbox-compatible

Plugins must never depend on internal engine packages.

---

# AI Development

AI features must

- operate through tools
- produce Commands
- respect Security policies
- preserve determinism where applicable

AI must never bypass platform architecture.

---

# Performance

Optimize in this order

```text
Architecture

↓

Algorithms

↓

Data Structures

↓

Parallelism

↓

Caching

↓

Micro-optimizations
```

Benchmark before optimizing.

---

# Testing

Every feature requires

- unit tests
- integration tests where appropriate
- regression tests for bug fixes

Performance-sensitive code should include benchmarks.

---

# Code Reviews

Every review should evaluate

- correctness
- architecture
- readability
- testing
- performance
- security
- documentation

Style issues should be handled automatically by tooling.

---

# Security

Never

- trust external input
- bypass permission checks
- store secrets in project files
- expose internal APIs unintentionally

Security is everyone's responsibility.

---

# Versioning

Changes affecting

- project schema
- plugin API
- public engine API
- compiler interfaces

must include compatibility analysis.

---

# Dependency Guidelines

Before adding a dependency, ask

1. Can the standard library solve this?
2. Can an existing internal package solve this?
3. Is the dependency actively maintained?
4. Does it justify its maintenance cost?

Minimize external dependencies.

---

# Code Generation

Generated code

- must be deterministic
- must be isolated
- must not be edited manually

Generators should be version-controlled.

---

# Comments

Write comments to explain

- intent
- assumptions
- trade-offs
- algorithmic reasoning

Avoid comments that simply restate code.

---

# TODO Policy

Every TODO must include

- owner (optional but recommended)
- reason
- tracking reference (issue/ADR)
- expected resolution

Example

```text
TODO(#245):
Support incremental shader compilation.
```

Avoid permanent TODOs.

---

# Feature Flags

Feature flags must

- have clear purpose
- be documented
- be removable
- not become permanent architecture

---

# Benchmarks

Benchmark changes affecting

- compilers
- rendering
- scheduler
- dependency graph
- storage
- AI runtime

Performance regressions should block release.

---

# Pull Request Checklist

Every pull request should answer

- Does this preserve architecture?
- Does it introduce new dependencies?
- Are tests included?
- Is documentation updated?
- Are performance implications understood?
- Are security implications reviewed?
- Is an ADR required?

---

# AI Agent Standards

AI-generated code must

- follow package ownership
- update tests
- update documentation
- avoid architectural violations
- preserve deterministic behavior
- use existing abstractions
- avoid duplicate implementations

AI should prefer extending existing systems over introducing parallel implementations.

---

# Definition of Done

A feature is complete when

- implementation is finished
- tests pass
- documentation is updated
- benchmarks are updated (if applicable)
- diagnostics are included
- architecture rules are preserved
- code review is complete
- CI passes

Code alone is not considered "done."

---

# Common Anti-Patterns

Avoid

- God objects
- Circular dependencies
- Hidden global state
- Service locators
- Tight coupling
- Duplicate logic
- Unmanaged threads
- Silent failures
- Large mutable state
- Direct document mutation
- Long-lived locks
- Premature abstraction
- Excessive configuration
- Business logic in UI
- Plugin access to internal APIs

---

# Architectural Constraints

1. Code must follow the Architecture Principles.
2. Package ownership must remain explicit.
3. Runtime services are Runtime-managed.
4. Background work executes through the Scheduler.
5. Shared resources use the Resource Manager.
6. State mutations occur through Commands.
7. Events remain side-effect-free.
8. Public APIs are documented and stable.
9. Tests accompany new functionality.
10. Readability and maintainability take precedence over cleverness.

---

# Future Enhancements

- Automated architecture linting
- AI coding rule enforcement
- API stability checker
- Documentation completeness validation
- Performance budget enforcement
- Security rule validation
- Plugin certification rules
- Contributor scorecards
- Automated ADR reminders
- Continuous architecture conformance

---

# Acceptance Criteria

The Coding Standards are complete when

✓ Contributors share a consistent engineering philosophy.

✓ Architectural rules are reflected in implementation practices.

✓ Public APIs remain clean and maintainable.

✓ Code reviews use these standards.

✓ AI agents produce code aligned with the architecture.

✓ New contributors can onboard efficiently.

✓ Quality expectations are explicit.

✓ Long-term maintainability is prioritized.

✓ The standards evolve alongside the architecture without compromising its core principles.

✓ This document serves as the engineering handbook for all implementation work.
