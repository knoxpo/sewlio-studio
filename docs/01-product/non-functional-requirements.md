# Non-Functional Requirements (NFR)
## Sewlio Studio

**Document ID:** NFR-001  
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Architecture Team

---

# Purpose

This document defines the quality attributes of Sewlio Studio.

Unlike Functional Requirements, which describe **what the application does**, Non-Functional Requirements describe **how well the application must perform those functions**.

These requirements are mandatory engineering constraints.

Every implementation must satisfy both the Functional Requirements and these Non-Functional Requirements.

---

# Quality Attributes

Sewlio Studio prioritizes the following quality attributes.

| Priority | Attribute |
|-----------|-----------|
| Critical | Performance |
| Critical | Reliability |
| Critical | Offline Capability |
| Critical | Maintainability |
| Critical | Extensibility |
| High | Usability |
| High | Portability |
| High | Testability |
| High | Accessibility |
| Medium | Scalability |
| Medium | Observability |
| Future | Availability (Cloud) |

---

# NFR-100
# Performance

## Objective

Sewlio Studio should feel instant.

The user should never perceive unnecessary delays.

---

## Startup Time

Cold start

Desktop

Target

< 2 seconds

Maximum acceptable

4 seconds

---

Web

Target

< 3 seconds

---

Tablet

Target

< 2.5 seconds

---

## Canvas Performance

Target frame rate

60 FPS

Preferred

120 FPS on supported hardware

---

Canvas interactions should remain smooth during:

Pan

Zoom

Selection

Transform

Drawing

Simulation playback

---

## Memory

Memory usage should scale predictably.

Example targets

Small project

< 200 MB

Medium project

< 500 MB

Large project

< 1 GB

These values are targets and should be validated through profiling.

---

## Rendering

Viewport redraws should be incremental.

Avoid full canvas redraw whenever possible.

Dirty region rendering should be preferred.

---

## Large Project Performance

Target project size

1,000,000 stitches

Expected behavior

Application remains usable.

Selection remains responsive.

Viewport navigation remains interactive.

---

# NFR-200
# Responsiveness

User interactions should begin immediately.

Recommended targets

Button click

< 50 ms

Menu opening

< 100 ms

Inspector update

< 50 ms

Layer selection

< 50 ms

Undo

< 100 ms

Redo

< 100 ms

---

Long-running tasks should become asynchronous.

Examples

SVG import

Export

Simulation generation

Digitizing

Project migration

---

The UI thread must never block during computational work.

Heavy computation belongs in Rust worker threads.

---

# NFR-300
# Reliability

The application should prioritize user work above all else.

---

Autosave

Automatic

Crash-safe

Recoverable

---

Unexpected shutdown

The application should recover:

Project

Workspace

Viewport

Panel layout

Selection where feasible

---

Project corruption

Partial corruption should not destroy recoverable project data.

---

History

Undo history should survive autosave where technically feasible.

---

# NFR-400
# Offline First

Internet connection must never be required.

The following must work offline

Create project

Open project

Save

Export

Digitize

Simulation

Templates

Thread libraries

Machine profiles

---

Future cloud functionality must degrade gracefully.

---

# NFR-500
# Local First

User owns all data.

The application never requires:

Login

Subscription

Cloud account

Vendor services

---

Projects remain portable.

No proprietary storage format should prevent access.

---

# NFR-600
# Portability

Supported platforms

Windows

macOS

Linux

Web CSR

iPadOS

Android Tablet

---

Behavior should remain consistent.

Minor platform-specific UI adaptations are acceptable.

Business logic must remain identical.

---

# NFR-700
# Maintainability

Architecture should maximize maintainability.

---

Rules

Flutter contains presentation.

Rust contains domain logic.

Shared contracts define communication.

No business logic inside widgets.

No Flutter imports inside Rust.

---

Maximum package responsibilities

One package

One responsibility

---

Circular dependencies

Forbidden

---

Architecture violations

Fail review.

---

# NFR-800
# Extensibility

Every subsystem should be replaceable.

Examples

Export engine

Import engine

Thread libraries

Simulation engine

Renderer

Future plugin system

---

Adding a new embroidery format should not require changes throughout the application.

---

# NFR-900
# Modularity

Preferred dependency graph

Flutter

↓

Application Layer

↓

Rust API

↓

Rust Services

↓

Core Domain

---

Dependencies should point inward.

---

# NFR-1000
# Testability

Every package should support automated testing.

Testing pyramid

Unit

Integration

Golden/UI

End-to-End

---

Critical algorithms require deterministic outputs.

Example

Running Stitch

Input A

Always produces

Output A

---

Randomized behavior is prohibited unless explicitly documented.

---

# NFR-1100
# Security

No mandatory telemetry.

No hidden network traffic.

No automatic upload of user projects.

---

Sensitive files remain local.

---

Project metadata should avoid storing unnecessary personal information.

---

# NFR-1200
# Privacy

Users own their designs.

No analytics enabled by default.

Crash reporting

Opt-in.

Usage statistics

Opt-in.

---

# NFR-1300
# Accessibility

Reference

accessibility.md

All accessibility requirements defined there are mandatory.

---

# NFR-1400
# Internationalization

Support

Unicode

Localized UI

Localized number formatting

Localized units

Future RTL evaluation

---

Internal project storage should remain language independent.

---

# NFR-1500
# Error Handling

Errors should be

Recoverable

Human-readable

Actionable

Never expose internal implementation details to end users.

---

Example

Bad

"Null Pointer Exception"

Good

"The selected SVG file could not be imported because it contains unsupported path commands."

---

# NFR-1600
# Logging

Logs should support

Development

Debugging

Diagnostics

AI-assisted troubleshooting

---

Logging levels

Trace

Debug

Info

Warning

Error

Critical

---

Production logging should remain lightweight.

---

# NFR-1700
# Observability

Future

Performance tracing

Export profiling

Memory profiling

Plugin diagnostics

Machine compatibility reports

---

# NFR-1800
# Compatibility

Supported project versions

Current

Previous major version

---

Migration should occur automatically.

---

Export compatibility should be validated using reference machine files.

---

# NFR-1900
# Resource Usage

Avoid

Repeated allocations

Unnecessary cloning

Large temporary buffers

Blocking file operations

Blocking UI operations

---

Prefer

Streaming

Iterators

Zero-copy where practical

Arena allocation where justified

---

# NFR-2000
# Rust Engineering

Unsafe Rust

Avoid unless justified.

Every unsafe block

Documented

Reviewed

Unit tested

---

Prefer

Idiomatic Rust

Ownership

Borrowing

Zero-cost abstractions

---

# NFR-2100
# Flutter Engineering

Widgets remain lightweight.

Business logic belongs elsewhere.

Prefer

Composition

Immutable widgets

Clear widget hierarchy

Platform adaptive UI

---

Avoid

God widgets

Large build methods

Platform-specific branching throughout UI

---

# NFR-2200
# API Stability

Public APIs require

Documentation

Versioning

Deprecation policy

Migration guidance

Breaking changes require ADR approval.

---

# NFR-2300
# AI Development

Every feature requires

Functional Requirement

Acceptance Criteria

Tests

Documentation

Architecture compliance

---

Every AI-generated change should be reviewable independently.

---

Context should remain modular.

Agents should consume only relevant documentation.

---

# NFR-2400
# Documentation

Every public package requires

README

Architecture overview

Dependency graph

Examples

Known limitations

Public API documentation

---

Architecture decisions belong in ADRs.

---

# NFR-2500
# Quality Gates

A pull request cannot merge unless

✓ Functional requirements satisfied

✓ Unit tests pass

✓ Integration tests pass

✓ Lint passes

✓ Formatting passes

✓ Documentation updated

✓ Architecture rules respected

✓ No circular dependencies

✓ No performance regression beyond agreed thresholds

✓ Acceptance criteria verified

---

# Definition of Done

A feature is complete only when

✓ Functional Requirements implemented

✓ Non-Functional Requirements satisfied

✓ Tests added

✓ Benchmarks updated (if applicable)

✓ Documentation updated

✓ ADR created if architecture changed

✓ Claude Code architectural review passed

✓ Local QA agent validation passed

---

# References

- vision.md
- philosophy.md
- roadmap.md
- prd.md
- accessibility.md
- coding-standards.md
- architecture.md
- ADR repository

---

# Future Revisions

This document will expand to include measurable Service Level Objectives (SLOs), platform-specific performance budgets, energy consumption targets, memory budgets by subsystem, and benchmark suites as the project matures.
