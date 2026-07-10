# Architecture

> **Platform note:** package ownership remains downward-only. The MVP package names stay `studio_*`.
> Future production-domain packages such as `studio_production`, `studio_validation`,
> `studio_weaving`, and `studio_printing` are planned only when implementation work needs them.
## ARCH-018 Package Ownership

**Document ID:** ARCH-018  
**Title:** Package Ownership & Architectural Boundaries  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Architecture Team

**Related Documents**

```text
ARCH-000 System Overview
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-004 Event System
ARCH-005 Document Model
ARCH-013 Plugin Architecture
ARCH-017 Security Model
```

---

# Purpose

This document defines ownership boundaries for every package within Sewlio Studio.

Its primary goals are:

- Prevent architectural drift
- Prevent circular dependencies
- Define clear responsibilities
- Reduce coupling
- Enable parallel development
- Enable AI-assisted development
- Keep packages independently testable

This document is the architectural source of truth for package ownership.

---

# Philosophy

Every package owns exactly one responsibility.

If two packages both "own" something, then neither owns it.

Ownership must always be explicit.

---

# Ownership Hierarchy

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

Flutter UI
```

Dependencies only flow downward.

No package may depend upward.

---

# Repository Layout

```text
engine/

kernel/

runtime/

platform/

domains/

compilers/

generators/

services/

bridges/

apps/

flutter/
```

---

# Layer Responsibilities

## Kernel

Provides universal infrastructure.

Owns

- Lifecycle
- Logging
- Configuration
- Scheduler
- Thread Pools
- Memory Pools
- Diagnostics Core
- Tracing
- Service Registry
- Time
- UUID generation

Never owns

- Projects
- Geometry
- Commands
- Rendering
- AI

Depends on

Nothing.

---

## Runtime

Provides execution infrastructure.

Owns

- Pipeline Runtime
- Command Bus
- Event Bus
- Task Runtime
- Dependency Graph
- Dirty Tracking
- Resource Handles
- Execution Context

Never owns business data.

Depends only on Kernel.

---

## Platform

Coordinates application behavior.

Owns

- Workspace Manager
- Project Manager
- Document Manager
- Session Manager
- Extension Manager
- Permission Manager

Never owns

Geometry

Embroidery

Rendering

Depends on Runtime.

---

# Domain Packages

Domain packages own business data.

---

## Geometry Domain

Owns

```text
Points

Curves

Paths

Groups

Layers

Transforms

Geometry Components
```

Never owns

Stitches

Rendering

Commands

Machine Profiles

---

## Embroidery Domain

Owns

```text
Embroidery Objects

Stitch Settings

Density

Underlay

Fill Parameters

Pull Compensation
```

Never owns

Machine commands

Rendering

Export

---

## Thread Domain

Owns

```text
Thread Libraries

Thread Colors

Mappings

Palettes
```

Never owns

Needles

Machine assignments

---

## Machine Domain

Owns

```text
Machine Profiles

Capabilities

Policies

Constraints

Manufacturing Settings
```

Never owns

Binary formats

---

## Asset Domain

Owns

```text
Images

Fonts

Templates

Fabric Assets

External References
```

Never owns

Rendering

---

## Workspace Domain

Owns

```text
Panels

Layout

Selection

Viewport

Preferences

Open Documents
```

Never owns

Project content.

---

# Compiler Packages

Compilers transform one IR into another.

Compilers never own business state.

---

## Import Compiler

Consumes

External files

Produces

Import IR

Owns

Parsing

Normalization

Validation

Never owns

Project mutations

---

## Digitizer Compiler

Consumes

Geometry IR

Produces

Stitch IR

Owns

Compiler passes

Optimization

Validation

Never owns

Rendering

Machine logic

---

## Playback Compiler

Consumes

Stitch IR

Produces

Playback IR

Owns

Timeline generation

Playback statistics

Frame generation

---

## Machine Compiler

Consumes

Stitch IR

Produces

Machine IR

Owns

Needle assignment

Thread mapping

Machine validation

Hoop validation

Manufacturing optimization

Never owns

Export encoding

---

# Generator Packages

Each generator owns exactly one format.

Examples

```text
DST Generator

PES Generator

JEF Generator

VP3 Generator

EXP Generator

HUS Generator
```

Generators own

Binary encoding

Streaming

Verification

Never own

Machine logic

---

# Service Packages

Services provide reusable platform functionality.

---

## Storage Service

Owns

Persistence

Serialization

Migration

Atomic saves

Recovery integration

Never owns

Geometry

Embroidery

Rendering

---

## Rendering Service

Owns

Scene Graph

GPU submission

Dirty regions

LOD

Viewport rendering

Never owns

Geometry generation

Digitizing

---

## Simulation Service

Owns

Playback execution

Playback controls

Playback state

Never owns

Playback compilation

---

## Plugin Service

Owns

Plugin runtime

Sandbox

Extension registry

Plugin lifecycle

Never owns

Project mutations

---

## AI Runtime

Owns

Conversations

Planning

Tool orchestration

Prompt management

Model adapters

Never owns

Commands

Document mutation

Compiler logic

---

## Security Service

Owns

Permissions

Policies

Authorization

Audit

Secure storage

Never owns

Business logic

---

## Resource Manager

Owns

Shared resources

Thread libraries

Fonts

Templates

Machine profiles

Workspace caches

Never owns

Project assets

---

# Flutter Packages

Flutter owns presentation only.

---

## Flutter Shell

Owns

Window

Navigation

Theme

Lifecycle

---

## Canvas

Owns

Gesture handling

Viewport interaction

Cursor

Selection visuals

Never owns

Geometry

---

## Panels

Owns

Inspector

Layers

Timeline

Resources

Properties

---

## Widgets

Owns

Reusable UI components.

Never owns

Business logic.

---

# Bridge Packages

Bridge packages translate between Flutter and Rust.

Own

FFI

Serialization

Platform channels

Never own

Business logic.

---

# Cross-Package Communication

Allowed

```text
Commands

Events

Pipeline Outputs

Public APIs
```

Forbidden

```text
Shared mutable state

Private struct access

Direct database access

Friend packages

Global singletons
```

---

# Dependency Rules

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

No upward dependency.

---

# Circular Dependency Policy

Circular dependencies are prohibited.

Instead

```text
Package A

↓

Event

↓

Package B
```

or

```text
Package A

↓

Interface

↓

Package B
```

---

# API Ownership

Every package exposes only

```text
Public API

↓

Internal API

↓

Private Implementation
```

Internal implementation must never leak.

---

# Package Size Guidelines

Target

```text
500–3,000 LOC
```

Preferred

```text
<2,000 LOC
```

Very large packages should be decomposed.

---

# Team Ownership

Recommended ownership

```text
Kernel Team

Platform Team

Geometry Team

Embroidery Team

Compiler Team

Rendering Team

Storage Team

AI Team

Plugin Team

Flutter Team
```

Every package has exactly one owning team.

---

# AI Agent Ownership

Each AI agent owns one package only.

Example

```text
Digitizer Agent

↓

Digitizer Compiler
```

Never

```text
Digitizer

+

Storage

+

Rendering
```

Keep contexts isolated.

---

# Architectural Decision Records

Breaking ownership changes require an ADR.

Examples

- New package
- Package split
- Package merge
- Responsibility transfer
- Public API changes

---

# Package Health Metrics

Track

- Dependency count
- Build time
- Test coverage
- Public API size
- Coupling score
- Stability score
- Benchmark results

These metrics should be reviewed continuously.

---

# Testing Ownership

Each package owns

- Unit tests
- Benchmarks
- Golden tests (where applicable)
- API compatibility tests

Integration tests belong to the Platform layer.

---

# AI Agent Rules

Agents must not

- move responsibilities across packages
- create cross-layer dependencies
- bypass public APIs
- expose internal structs
- introduce circular dependencies
- duplicate ownership

When uncertain, create an ADR rather than expanding an existing package.

---

# Architectural Constraints

1. Every package has one owner.
2. Every responsibility has one owner.
3. Dependencies are one-directional.
4. Communication occurs only through public APIs.
5. Packages are independently testable.
6. Packages expose minimal public APIs.
7. Circular dependencies are forbidden.
8. Package ownership changes require an ADR.
9. Flutter owns presentation only.
10. Business logic resides entirely within the Rust engine.

---

# Future Enhancements

- Automated architecture validation
- Dependency graph visualization
- Ownership linting
- Architectural fitness functions
- AI ownership verification
- Package maturity scoring
- API stability tracking
- Build impact analysis
- Monorepo dependency enforcement
- Continuous architecture compliance

---

# Acceptance Criteria

The Package Ownership model is complete when

✓ Every package has a clearly defined owner.

✓ Responsibilities do not overlap.

✓ Dependency direction is enforced.

✓ Public APIs are the only communication mechanism.

✓ Circular dependencies are impossible by design.

✓ Teams and AI agents can work independently without ownership conflicts.

✓ Flutter remains a presentation layer.

✓ The Rust engine contains all business logic.

✓ Architectural boundaries are enforceable through tooling.

✓ The package structure can scale to hundreds of packages without architectural erosion.
