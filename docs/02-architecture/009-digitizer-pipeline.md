# Architecture
## ARCH-009 Digitizer Pipeline

**Document ID:** ARCH-009  
**Title:** Digitizer Pipeline  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Embroidery Engine Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-005 Document Model
ARCH-008 Rendering Architecture
ARCH-010 Simulation Pipeline
ARCH-011 Export Pipeline
```

---

# Purpose

The Digitizer Pipeline is responsible for converting editable vector artwork into a machine-independent embroidery representation (**Stitch IR**).

The Digitizer is the heart of Sewlio Studio.

Everything before the Digitizer is design.

Everything after the Digitizer is manufacturing.

---

# Philosophy

The Digitizer is **not** an exporter.

It is **not** a renderer.

It is **not** machine specific.

Instead, it behaves like a compiler.

```text
Geometry

↓

Analysis

↓

Planning

↓

Compiler Passes

↓

Optimization

↓

Validation

↓

Stitch IR
```

---

# Core Principles

## Machine Independent

The Digitizer never produces

- DST
- PES
- JEF
- VP3
- EXP

It produces only Stitch IR.

---

## Deterministic

Same Geometry

↓

Same Settings

↓

Same Stitch IR

Every time.

---

## Incremental

Only modified embroidery regions are regenerated.

---

## Parallel

Independent embroidery regions may compile simultaneously.

---

## Modular

Every stitch algorithm is an independent compiler pass.

---

## Extensible

Plugins may contribute

- New stitch generators
- Optimization passes
- Validation passes

without changing the core compiler.

---

# High-Level Pipeline

```text
Geometry IR

↓

Embroidery Planning

↓

Region Analysis

↓

Compiler Pipeline

↓

Optimization Pipeline

↓

Validation Pipeline

↓

Stitch IR
```

---

# Complete Compiler Pipeline

```text
Geometry IR

↓

Geometry Analysis

↓

Region Builder

↓

Embroidery Objects

↓

Planning

↓

Running Stitch

↓

Satin

↓

Fill

↓

Motif

↓

Underlay

↓

Travel Optimization

↓

Thread Optimization

↓

Jump Optimization

↓

Validation

↓

Stitch IR
```

---

# Compiler Stages

## Stage 1

Geometry Analysis

Responsible for

- Closed paths
- Open paths
- Islands
- Direction
- Holes
- Self intersections
- Shape complexity

Produces

```text
Geometry Analysis Model
```

---

## Stage 2

Embroidery Planning

Responsible for

- Stitch type selection
- Entry points
- Exit points
- Stitch direction
- Underlay strategy
- Travel planning

Produces

```text
Embroidery Plan
```

---

## Stage 3

Region Builder

Splits artwork into embroidery regions.

Example

```text
Logo

↓

Text

↓

Border

↓

Fill

↓

Details

↓

Regions
```

Each region compiles independently.

---

# Region Model

Each region contains

```text
Region ID

Geometry

Priority

Thread

Stitch Type

Parameters
```

---

# Compiler Passes

Every stitch type is its own compiler.

```text
Running Stitch Compiler

Satin Compiler

Tatami Compiler

Motif Compiler

Manual Stitch Compiler

Bean Stitch Compiler

Cross Stitch Compiler

Future Compilers
```

Each compiler owns one algorithm.

---

# Running Stitch Compiler

Input

```text
Path

↓

Parameters
```

Produces

Running stitches.

Supports

- Stitch length
- Randomization
- Repeat count
- Bean stitching

---

# Satin Compiler

Input

```text
Region

↓

Rails

↓

Centerline
```

Produces

Satin stitches.

Supports

- Density
- Pull compensation
- Push compensation
- Split satin
- Auto rails

---

# Fill Compiler

Input

```text
Closed Region
```

Produces

Tatami fill.

Supports

- Angle
- Density
- Pattern
- Offset
- Alternate rows
- Random fill

---

# Motif Compiler

Produces

Decorative stitch patterns.

Examples

- Stars
- Leaves
- Waves
- User motifs

---

# Underlay Compiler

Generates

- Edge walk
- Zig-zag
- Tatami
- Center walk

Automatically.

---

# Border Compiler

Responsible for

- Outline
- Triple stitch
- Bean
- Satin border

---

# Manual Stitch Compiler

Supports

Hand-authored stitches.

Never optimized automatically.

---

# Parameter Resolution

Parameters come from

```text
Region

↓

Object

↓

Layer

↓

Project

↓

Defaults
```

Nearest value wins.

---

# Embroidery Settings

Each region contains

```text
Density

Angle

Stitch Length

Compensation

Overlap

Lock Stitches

Tie In

Tie Off

Thread
```

---

# Optimization Pipeline

After stitch generation.

```text
Stitch IR

↓

Travel Optimizer

↓

Jump Optimizer

↓

Color Optimizer

↓

Trim Optimizer

↓

Density Optimizer

↓

Needle Path Optimizer
```

---

# Travel Optimization

Reduces

Jump stitches.

Needle movement.

Travel distance.

---

# Thread Optimization

Optimizes

Thread changes.

Color sequence.

Needle assignments.

---

# Jump Optimization

Removes unnecessary

Jump stitches.

---

# Density Optimization

Ensures

Even stitch spacing.

Avoids over-density.

---

# Compensation

Automatically applies

- Pull compensation
- Push compensation
- Stretch compensation

---

# Validation Pipeline

Validation occurs after optimization.

Checks

```text
Minimum Stitch Length

Maximum Stitch Length

Density

Thread Assignment

Travel Distance

Hoop Limits

Disconnected Regions

Duplicate Stitches
```

Produces

Warnings

Errors

Suggestions

---

# Stitch IR Generation

Validated stitches become

```text
Geometry

↓

Embroidery Objects

↓

Stitch Commands

↓

Metadata

↓

Stitch IR
```

---

# Dirty Propagation

Only changed regions regenerate.

```text
Region Modified

↓

Dirty

↓

Compile Region

↓

Merge Stitch IR
```

Entire document is never regenerated unnecessarily.

---

# Parallel Compilation

Independent regions compile simultaneously.

```text
Region A

↓

Thread 1

----------------

Region B

↓

Thread 2

----------------

Region C

↓

Thread 3
```

Merged after compilation.

---

# Compiler Context

Compiler receives

```text
Geometry

Project Settings

Machine Profile

Thread Library

Fabric

Compiler Options
```

No UI information.

---

# Machine Independence

The Digitizer ignores

Needle numbers

Machine commands

Binary formats

Encoder limitations

Those belong to Machine IR.

---

# Fabric Profiles (Future)

Supports

```text
Cotton

Denim

Leather

Silk

Stretch

Canvas
```

Automatically adjusts

Compensation

Density

Underlay

---

# Compiler Plugins

Plugins may register

```text
New Stitch Compiler

Optimization Pass

Validation Pass

Analysis Pass
```

Compiler pipeline remains unchanged.

---

# AI Integration

AI may

Suggest

- Density
- Stitch type
- Angle
- Compensation
- Optimization

AI never writes Stitch IR directly.

AI produces Commands.

---

# Performance Targets

Small Design

<100 ms

---

Medium Design

<500 ms

---

Large Design

<3 s

---

Incremental Update

<100 ms

---

Background Compilation

Mandatory

---

# Memory Strategy

Geometry

Read-only

↓

Compiler Context

↓

Temporary Buffers

↓

Stitch IR

↓

Discard Buffers

Compiler never modifies Geometry.

---

# Error Recovery

Compiler failures

↓

Region Failure

↓

Continue Remaining Regions

↓

Report Errors

One region should not stop the entire compilation.

---

# Thread Safety

Compiler is

Read-only

Parallel

Deterministic

No shared mutable state.

---

# Testing

Every compiler requires

- Golden stitch tests
- Regression tests
- Performance benchmarks
- Validation tests
- Fabric tests
- Density tests
- Large design tests

---

# AI Agent Rules

Each compiler owns

One stitch algorithm.

Optimization passes never generate stitches.

Validation passes never optimize.

Each pass has one responsibility.

---

# Architectural Constraints

1. The Digitizer consumes Geometry IR only.
2. The Digitizer produces Stitch IR only.
3. The Digitizer never exports machine files.
4. Every stitch algorithm is a compiler pass.
5. Optimization occurs after stitch generation.
6. Validation occurs after optimization.
7. Geometry is never modified.
8. Parallel compilation is deterministic.
9. Plugins extend through compiler passes.
10. AI generates Commands, not stitches.

---

# Future Enhancements

- GPU-assisted stitch planning
- Fabric simulation feedback
- AI-generated embroidery strategies
- Adaptive stitch density
- Physics-aware compensation
- Parametric embroidery
- Live incremental compilation
- Region dependency graphs
- Distributed compilation
- Custom compiler pipelines

---

# Acceptance Criteria

The Digitizer Pipeline is complete when

✓ Geometry IR is compiled into Stitch IR.

✓ Stitch generation is machine independent.

✓ Compiler passes are modular.

✓ Optimization and validation are independent stages.

✓ Regions compile incrementally.

✓ Parallel execution remains deterministic.

✓ Plugins can add new stitch algorithms.

✓ AI can influence compilation through Commands.

✓ Large designs compile efficiently.

✓ The Digitizer remains independently testable.
