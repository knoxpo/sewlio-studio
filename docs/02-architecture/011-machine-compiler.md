# Architecture
## ARCH-011 Machine Compiler

**Document ID:** ARCH-011  
**Title:** Machine Compiler  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Manufacturing Engine Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-005 Document Model
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-012 Export Pipeline
```

---

# Purpose

The Machine Compiler is embroidery-specific. It transforms machine-independent embroidery instructions (**Stitch IR**) into a validated, optimized, machine-specific representation (**Machine IR**).

Weaving uses Loom IR. Digital printing uses Print IR. Neither should be routed through embroidery Machine IR.

The Machine Compiler is responsible for manufacturing intelligence.

It is **not** responsible for binary encoding.

It is **not** responsible for rendering.

It is **not** responsible for digitizing.

Its only responsibility is preparing embroidery data for a specific embroidery machine family.

---

# Philosophy

The embroidery pipeline consists of multiple compilers.

```text
Geometry IR

↓

Digitizer Compiler

↓

Stitch IR

↓

Machine Compiler

↓

Machine IR

↓

Export Encoder

↓

DST / PES / JEF / VP3
```

Every stage owns exactly one responsibility.

---

# Goals

The Machine Compiler shall

- Validate machine compatibility
- Apply machine capabilities
- Optimize for manufacturing
- Generate diagnostics
- Assign needles
- Assign threads
- Validate hoops
- Produce deterministic Machine IR

---

# Core Principles

## Machine Aware

Unlike the Digitizer,

the Machine Compiler understands

- machine families
- hoop limits
- needle counts
- thread assignments
- jump limits
- trim behavior

---

## Format Independent

The compiler never writes

DST

PES

JEF

VP3

EXP

HUS

Those belong to Export Encoders.

---

## Deterministic

Same Stitch IR

+

Same Machine Profile

↓

Same Machine IR

---

## Incremental

Only modified embroidery regions are recompiled.

---

## Extensible

Machine families may be added through plugins.

---

# High-Level Pipeline

```text
Stitch IR

↓

Machine Analysis

↓

Capability Validation

↓

Thread Mapping

↓

Needle Assignment

↓

Travel Optimization

↓

Manufacturing Optimization

↓

Diagnostics

↓

Machine IR
```

---

# Compiler Pipeline

```text
Stitch IR

↓

Machine Profile

↓

Analysis Passes

↓

Planning Passes

↓

Optimization Passes

↓

Validation Passes

↓

Machine IR
```

Every stage is independently testable.

---

# Machine Profile

Machine compilation always begins with a Machine Profile.

```text
Machine Profile

↓

Compiler Context
```

---

Machine Profile contains

```text
Manufacturer

Model

Needle Count

Maximum Colors

Hoop Sizes

Maximum Jump

Maximum Stitch

Maximum Speed

Supported Commands

Capabilities

Limitations
```

---

# Supported Machine Families

Examples

```text
Brother

Bernina

Janome

Pfaff

Baby Lock

Singer

Tajima

Barudan

Happy

Melco

ZSK

SWF

Custom Profiles
```

Profiles are data-driven.

---

# Compiler Context

Compiler receives

```text
Stitch IR

Machine Profile

Thread Library

Project Settings

Manufacturing Preferences
```

No UI state.

---

# Stage 1 — Machine Analysis

Analyzes

```text
Thread Count

Needle Count

Travel

Hoop Usage

Jump Lengths

Color Sequence

Estimated Time
```

Produces

Machine Analysis Model.

---

# Stage 2 — Capability Validation

Checks

```text
Hoop Limits

Maximum Jump

Maximum Stitch

Thread Limits

Needle Count

Supported Commands

Maximum Colors
```

Produces

Warnings

Errors

Suggestions

---

# Stage 3 — Thread Mapping

Maps project thread palette onto machine needles.

```text
Project Palette

↓

Machine Needles

↓

Thread Assignments
```

Supports

- automatic mapping
- manual mapping
- palette optimization

---

# Stage 4 — Needle Assignment

Assigns

```text
Thread

↓

Needle

↓

Machine Sequence
```

Supports

- fixed needles
- automatic balancing
- future multi-head machines

---

# Stage 5 — Manufacturing Optimization

Optimizes

- travel
- trims
- jumps
- thread changes
- machine stops
- color ordering

without changing embroidery quality.

---

# Stage 6 — Machine Validation

Validates

```text
Needle Overflow

Hoop Overflow

Jump Limits

Thread Limits

Machine Constraints

Unsupported Commands
```

---

# Stage 7 — Machine IR Generation

Produces

```text
Machine Commands

Needle Mapping

Thread Mapping

Machine Metadata

Manufacturing Metadata

Diagnostics
```

No binary encoding.

---

# Machine IR

Machine IR represents embroidery ready for one machine family.

Contains

```text
Needle Commands

Machine Stops

Thread Assignments

Needle Assignments

Jump Commands

Trim Commands

Machine Metadata

Validation Metadata
```

Machine IR is still platform independent.

---

# Hoop Validation

Checks

```text
Design Bounds

↓

Selected Hoop

↓

Margins

↓

Safe Area

↓

Warnings
```

Supports automatic hoop recommendations.

---

# Thread Optimization

Optimizes

```text
Color Sequence

Needle Changes

Thread Swaps

Duplicate Colors
```

---

# Jump Optimization

Optimizes

```text
Travel Distance

Jump Commands

Machine Efficiency
```

Respects machine-specific limitations.

---

# Trim Optimization

Determines

```text
Trim Required?

↓

Trim Location

↓

Trim Command
```

Machine-dependent.

---

# Manufacturing Diagnostics

Compiler produces diagnostics.

Examples

```text
Warning

Design exceeds hoop.

--------------------

Warning

Needle count exceeded.

--------------------

Warning

Jump exceeds capability.

--------------------

Suggestion

Rotate design 90°.

--------------------

Suggestion

Merge thread colors.
```

Diagnostics never block compilation unless severity is Error.

---

# Machine Statistics

Generated during compilation.

Includes

```text
Estimated Runtime

Needle Changes

Thread Changes

Trims

Stops

Maximum Jump

Maximum Stitch

Machine Utilization
```

---

# Incremental Compilation

If only one embroidery region changes

```text
Region Dirty

↓

Compile Region

↓

Merge Machine IR
```

Entire Machine IR is not regenerated.

---

# Multi-Machine Support

Future

One Stitch IR

↓

Brother Machine IR

↓

Tajima Machine IR

↓

Barudan Machine IR

↓

Comparison

Useful for production planning.

---

# Manufacturing Policies

Workspace or organization may define policies.

Examples

```text
Maximum Jump

Preferred Needles

Preferred Thread Library

Minimum Trim Distance

Maximum Runtime
```

Policies apply before export.

---

# Plugin Support

Plugins may contribute

```text
Machine Profiles

Validation Rules

Optimization Passes

Manufacturing Reports

Capability Definitions
```

Plugins never modify Machine IR directly.

---

# AI Integration

AI may

Analyze

- hoop selection
- thread optimization
- runtime estimation
- manufacturing diagnostics

AI may generate Commands that trigger recompilation.

AI never edits Machine IR directly.

---

# Performance Targets

Machine Analysis

<100 ms

---

Machine Compilation

<500 ms

---

Incremental Compilation

<100 ms

---

Validation

Background

---

# Thread Safety

Machine Compiler is

Read-only

Parallel

Deterministic

Worker-thread friendly

No shared mutable state.

---

# Memory Strategy

Consumes

Stitch IR

Produces

Machine IR

Temporary analysis structures are released after compilation.

---

# Testing

Each machine profile requires

- capability tests
- hoop tests
- needle assignment tests
- thread mapping tests
- diagnostics tests
- regression tests
- performance benchmarks

Golden Machine IR fixtures validate deterministic output.

---

# AI Agent Rules

Machine Compiler owns

- machine capabilities
- manufacturing validation
- thread mapping
- needle assignment
- hoop validation
- Machine IR

Machine Compiler never owns

- Geometry
- Stitch generation
- Binary encoding
- Rendering
- Storage

---

# Architectural Constraints

1. Machine Compiler consumes Stitch IR only.
2. Machine Compiler produces Machine IR only.
3. Machine Compiler never writes export files.
4. Export Encoders consume Machine IR.
5. Machine Profiles are data-driven.
6. Validation is independent of encoding.
7. Diagnostics are machine-specific.
8. Compilation is deterministic.
9. Incremental recompilation is supported.
10. Machine Compiler is independently testable.

---

# Future Enhancements

- Multi-head embroidery optimization
- Multi-machine scheduling
- Production line balancing
- Fleet-aware machine selection
- AI-assisted manufacturing optimization
- Automatic hoop selection
- Fabric-aware machine tuning
- Enterprise manufacturing policies
- Predictive maintenance integration
- Digital twin machine simulation

---

# Acceptance Criteria

The Machine Compiler is complete when

✓ Stitch IR compiles into Machine IR.

✓ Machine capabilities are validated.

✓ Thread and needle assignments are generated.

✓ Hoop validation is performed.

✓ Manufacturing diagnostics are produced.

✓ Machine IR remains independent of binary export formats.

✓ Machine Profiles are extensible.

✓ Plugins can contribute profiles and validation rules.

✓ Large designs compile efficiently.

✓ The Machine Compiler remains deterministic, modular, and independently testable.
