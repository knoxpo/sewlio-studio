# Architecture
## ARCH-021 Architecture Principles

**Document ID:** ARCH-021  
**Title:** Architecture Principles  
**Version:** 1.0.0  
**Status:** Foundational (Immutable)  
**Priority:** Critical

**Owner:** Architecture Council

---

# Purpose

This document defines the architectural principles that govern every subsystem, package, feature, plugin, and contribution within Sewlio Studio.

Unlike other architecture documents, this document is intentionally stable.

It should change very rarely.

Every Architecture Decision Record (ADR), feature proposal, pull request, and implementation should be evaluated against these principles.

These principles are the architectural constitution of the platform.

---

# Guiding Philosophy

Sewlio Studio is a **compiler-driven CAD/CAM platform**, not merely an embroidery editor.

The platform is designed to be:

- Local-first
- Offline-first
- Deterministic
- Extensible
- Observable
- Recoverable
- Secure
- Performant
- AI-native
- Long-lived

Every architectural decision should reinforce these characteristics.

---

# Principle 1 — Local First

User data belongs to the user.

Projects must function completely without an internet connection.

Cloud functionality is optional.

The application must remain fully usable in offline mode.

---

# Principle 2 — Offline First

Every essential feature shall work without network connectivity.

Cloud services provide enhancement, never dependency.

---

# Principle 3 — Rust Owns the Business Logic

Flutter owns presentation.

Rust owns everything else.

Business rules must never migrate into Flutter.

```text
Flutter

↓

FFI

↓

Rust Engine
```

---

# Principle 4 — Flutter Is a View Layer

Flutter is responsible for

- layout
- widgets
- gestures
- navigation
- accessibility
- theming

Flutter is never responsible for

- document mutation
- rendering algorithms
- compiler logic
- storage
- AI planning
- machine logic

---

# Principle 5 — Commands Are the Only Way to Mutate State

Every project modification occurs through Commands.

No subsystem may modify the Document directly.

```text
Command

↓

Command Bus

↓

Document
```

---

# Principle 6 — Events Never Modify State

Events communicate that something happened.

Events never change the Document.

Events are notifications.

Commands perform work.

---

# Principle 7 — One Responsibility Per Package

Every package owns exactly one responsibility.

Ownership overlaps are architectural defects.

---

# Principle 8 — Dependencies Flow Downward

Dependency direction is fixed.

```text
Kernel

↓

Runtime

↓

Platform

↓

Domains

↓

Compilers

↓

Generators

↓

Services

↓

Bridges

↓

Flutter
```

Upward dependencies are prohibited.

---

# Principle 9 — Immutable Intermediate Representations

Every compiler operates on immutable IRs.

Examples

```text
Import IR

Geometry IR

Stitch IR

Playback IR

Machine IR
```

Immutable IRs enable

- parallelism
- caching
- reproducibility
- testing

---

# Principle 10 — One Compiler, One Transformation

Every compiler performs exactly one transformation.

Examples

```text
Geometry IR

↓

Digitizer Compiler

↓

Stitch IR
```

Compilers never perform unrelated work.

---

# Principle 11 — Machine Logic Is Separate From Encoding

Machine Compiler

↓

Machine IR

↓

Export Generator

↓

DST

Manufacturing intelligence and binary serialization are independent concerns.

---

# Principle 12 — Public APIs Only

Subsystems communicate only through public APIs.

Internal structures are never shared.

---

# Principle 13 — Security Is Centralized

All external actors pass through the Security Gateway.

Examples

- Plugins
- AI
- Automation
- Future collaboration

No bypasses are permitted.

---

# Principle 14 — AI Is Another Client

AI does not own the application.

AI behaves like any other client.

AI

↓

Tools

↓

Commands

↓

Command Bus

↓

Document

AI never mutates state directly.

---

# Principle 15 — Plugins Extend, Never Replace

Plugins extend the platform.

They do not modify the core.

Extension occurs only through registered extension points.

---

# Principle 16 — Performance Is an Architectural Requirement

Performance is designed into the platform.

It is not postponed until later.

Preferred optimization order

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

GPU

↓

Micro-optimizations
```

---

# Principle 17 — Incremental by Default

Never recompute everything.

Always prefer

- incremental compilation
- incremental rendering
- incremental simulation
- incremental validation

---

# Principle 18 — Background Work Never Blocks the UI

Long-running work executes through the scheduler.

The UI thread remains responsive.

---

# Principle 19 — Everything Is Observable

Every subsystem exposes

- diagnostics
- tracing
- profiling
- metrics
- logging

Nothing is a black box.

---

# Principle 20 — Errors Are Structured

Errors are data.

Never propagate raw strings.

Every error includes

- code
- severity
- context
- recovery guidance

---

# Principle 21 — Recoverability Over Perfection

Protect user work first.

Application state is secondary.

Recovery is always preferred over data loss.

---

# Principle 22 — Determinism

Given the same

- inputs
- settings
- compiler versions
- machine profile

the platform must produce the same outputs.

Determinism enables testing, debugging, and collaboration.

---

# Principle 23 — Version Everything

Version

- project schema
- IR formats
- plugin API
- compiler interfaces
- machine profiles
- thread libraries

Compatibility is explicit.

---

# Principle 24 — Prefer Composition Over Inheritance

Subsystems compose behavior.

Large inheritance hierarchies are discouraged.

---

# Principle 25 — Prefer Data Over Configuration Code

Machine profiles

Thread libraries

Templates

Export definitions

Compiler options

should be represented as data whenever practical.

---

# Principle 26 — Explicit Ownership

Every

- package
- service
- compiler
- resource
- cache
- manager

has one owner.

Ownership ambiguity is not allowed.

---

# Principle 27 — Stable Public Contracts

Public APIs evolve carefully.

Breaking changes require

- ADR
- migration plan
- compatibility analysis

---

# Principle 28 — AI-Friendly Architecture

The architecture should enable independent implementation by humans and AI agents.

Components should be

- small
- cohesive
- testable
- deterministic
- independently buildable

---

# Principle 29 — Testability First

Every subsystem must support

- unit testing
- integration testing
- performance testing
- deterministic fixtures
- benchmarking

Architecture should make testing easier, not harder.

---

# Principle 30 — Extensibility Without Modification

New functionality should be added through

- plugins
- compiler passes
- generators
- providers
- extension points

rather than modifying existing subsystems.

---

# Principle 31 — Platform Neutrality

Core engine code must not depend on

- Flutter
- Desktop
- Mobile
- Web

Platform adaptation occurs through bridges.

---

# Principle 32 — Workspace and Project Separation

Workspace represents the user's working environment.

Projects represent design data.

Neither owns the other.

Workspace stores

- layout
- panels
- conversations
- caches
- preferences

Project stores

- geometry
- embroidery
- assets
- metadata

---

# Principle 33 — Resource Reuse

Shared resources should be loaded once and referenced many times.

Examples

- thread libraries
- machine profiles
- fonts
- templates

Avoid duplication.

---

# Principle 34 — Documentation Is Part of the Architecture

Architecture is not complete without documentation.

Every major subsystem requires

- ownership
- public API
- testing strategy
- performance expectations
- extension strategy

---

# Principle 35 — Evolution Through ADRs

Significant architectural changes require an Architecture Decision Record.

An ADR must document

- context
- decision
- alternatives
- trade-offs
- migration plan
- consequences

---

# Non-Negotiable Rules

The following rules may not be violated without replacing this document.

✓ Rust owns business logic.

✓ Commands are the only mutation mechanism.

✓ Events never mutate state.

✓ Plugins are sandboxed.

✓ AI interacts through tools and commands.

✓ Flutter remains presentation only.

✓ Public APIs are the only integration points.

✓ Dependencies remain one-directional.

✓ Intermediate Representations remain immutable.

✓ Performance and security remain architectural concerns.

---

# Governance

Every pull request should answer:

1. Does this violate any architecture principle?
2. Does this introduce a new responsibility?
3. Does it preserve dependency direction?
4. Is it deterministic?
5. Is it independently testable?
6. Is it observable?
7. Is it secure?
8. Does it preserve local-first behavior?
9. Is an ADR required?
10. Does it improve or degrade architectural integrity?

---

# Architecture Review Checklist

Every significant feature should be reviewed against:

- Single Responsibility
- Dependency Direction
- Public API Design
- Performance Impact
- Memory Impact
- Security Impact
- AI Compatibility
- Plugin Compatibility
- Testing Strategy
- Migration Strategy
- Observability
- Documentation

---

# Acceptance Criteria

The Architecture Principles are complete when

✓ Every subsystem follows these principles.

✓ New contributors can understand the architectural philosophy.

✓ ADRs reference these principles.

✓ Architecture reviews use these principles.

✓ Violations are identified during design rather than after implementation.

✓ The platform can evolve for years without architectural erosion.

✓ Humans and AI agents share the same architectural contract.

✓ The principles remain stable across major releases.

✓ Architectural decisions remain consistent across teams.

✓ The document serves as the long-term constitution of the Sewlio Studio platform.
