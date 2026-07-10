# Architecture
## ARCH-010 Simulation Pipeline

**Document ID:** ARCH-010  
**Title:** Simulation Pipeline  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Simulation Engine Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-005 Document Model
ARCH-008 Rendering Architecture
ARCH-009 Digitizer Pipeline
ARCH-011 Export Pipeline
```

---

# Purpose

The Simulation Pipeline is responsible for transforming **Stitch IR** into an interactive, real-time representation suitable for playback, visualization, analysis, and user feedback.

Platform note: this document describes embroidery simulation unless a section explicitly says shared simulation framework. Future Weaving and Digital Printing Projects contribute their own simulation providers through the active Production Engine.

Simulation is **not rendering**.

Simulation is **not digitizing**.

Simulation is **not export**.

Simulation is a compiler that converts embroidery instructions into a time-based execution model.

---

# Philosophy

The simulation engine answers one question:

> "If a real embroidery machine executed these stitches, what would happen?"

It does **not** generate stitches.

It **interprets** them.

---

# Core Principles

## Machine Independent

Simulation consumes Stitch IR.

It never executes DST, PES, JEF or VP3 files.

---

## Deterministic

Identical Stitch IR always produces identical playback.

---

## Read Only

Simulation never modifies Stitch IR.

---

## Cacheable

Playback IR is disposable.

It may be regenerated at any time.

---

## Incremental

Only modified stitch regions are recompiled.

---

## Parallel

Playback generation supports parallel compilation.

---

# High-Level Pipeline

```text
Stitch IR

↓

Playback Compiler

↓

Playback IR

↓

Simulation Engine

↓

Frame Stream

↓

Renderer
```

---

# Simulation Compiler

Simulation is implemented as another compiler.

```text
Stitch IR

↓

Analysis

↓

Timeline Planning

↓

Frame Generation

↓

Optimization

↓

Validation

↓

Playback IR
```

---

# Pipeline Stages

## Stage 1

Stitch Analysis

Produces

```text
Needle Count

Jump Count

Thread Changes

Estimated Duration

Needle Distance

Region Dependencies
```

---

## Stage 2

Timeline Builder

Produces

```text
Timeline

↓

Events

↓

Needle Schedule

↓

Frame Schedule
```

---

## Stage 3

Playback Generation

Generates

```text
Needle Positions

Thread State

Frame Events

Playback Frames
```

---

## Stage 4

Optimization

Optimizes

- frame count
- interpolation
- cache layout
- playback memory
- timeline lookup

---

## Stage 5

Validation

Checks

- invalid timestamps
- missing events
- frame ordering
- playback consistency

---

# Playback IR

Playback IR is optimized exclusively for playback.

Contains

```text
Timeline

Frames

Needle Position

Thread Color

Needle State

Camera Hints

Playback Metadata
```

It never stores editable geometry.

---

# Timeline Model

```text
Timeline

↓

Segments

↓

Frames

↓

Playback Events
```

Supports

- seek
- pause
- resume
- reverse
- looping

---

# Playback Events

Examples

```text
NeedleDown

NeedleUp

ThreadChange

Jump

Trim

Stop

ColorChange

RegionStart

RegionEnd

PlaybackFinished
```

---

# Playback Frame

Each frame contains

```text
Timestamp

Needle Position

Current Stitch

Current Thread

Machine State

Playback Flags
```

---

# Time Model

Simulation uses logical time.

```text
Frame

↓

Logical Time

↓

Playback Speed

↓

Real Time
```

Allows

- slow motion
- fast forward
- frame stepping

without changing Stitch IR.

---

# Playback Speed

Supports

```text
0.1×

0.25×

0.5×

1×

2×

4×

8×

Unlimited
```

Unlimited mode renders as quickly as possible.

---

# Playback Modes

## Real-Time

Machine speed simulation.

---

## Instant

Entire design immediately rendered.

---

## Step Mode

One stitch per step.

---

## Region Mode

One embroidery region at a time.

---

## Thread Mode

One thread color at a time.

---

## Debug Mode

Displays diagnostics.

---

# Camera System

Simulation suggests camera behavior.

```text
Playback IR

↓

Camera Hints

↓

Viewport Animation
```

Supports

- follow needle
- fit design
- zoom region
- manual mode

Camera belongs to Workspace.

---

# Simulation Statistics

Generated during compilation.

Includes

```text
Current Stitch

Remaining Stitches

Remaining Time

Distance

Thread Usage

Current Region

Progress

Estimated Completion
```

---

# Needle Model

Needle state

```text
Idle

Moving

Stitching

Jumping

Changing Thread

Stopped
```

Machine independent.

---

# Thread State

Tracks

```text
Current Thread

Thread Changes

Remaining Colors

Needle Assignment
```

---

# Region Simulation

Playback grouped by embroidery regions.

```text
Region

↓

Playback Segment

↓

Frames
```

Allows

- region preview
- selective replay
- debugging

---

# Incremental Compilation

If one region changes

```text
Region Dirty

↓

Compile Region

↓

Merge Playback

↓

Finished
```

Entire playback is never rebuilt unnecessarily.

---

# Frame Generation

Frames generated lazily.

Visible timeline

↓

Generate

↓

Cache

↓

Render

---

# Playback Cache

Contains

```text
Frame Cache

Timeline Cache

Interpolation Cache

Statistics Cache
```

Disposable.

---

# Interpolation

Supports

- linear
- smooth
- future custom interpolation

Interpolation never changes Stitch IR.

---

# Overlay Integration

Simulation provides overlays.

Examples

- stitch number
- needle direction
- travel path
- jump visualization
- density heatmap
- speed graph

---

# Rendering Integration

Simulation never draws.

Instead

```text
Playback IR

↓

Render Scene

↓

Flutter Renderer
```

Rendering owns pixels.

Simulation owns playback.

---

# Audio Hooks (Future)

Supports

```text
Needle Sound

Machine Sound

Thread Change

Completion Tone
```

Optional.

---

# Haptic Hooks (Future)

Tablet

Phone

Stylus

May receive playback feedback.

Simulation never depends on haptics.

---

# AI Integration

AI may

Analyze

- inefficient paths
- dense regions
- travel optimization
- estimated production time

AI never modifies Playback IR directly.

---

# Plugin Integration

Plugins may contribute

- playback overlays
- playback analyzers
- statistics providers
- visualization layers

Plugins cannot replace Playback IR.

---

# Performance Targets

Small Design

<50 ms

Playback Generation

---

Medium Design

<300 ms

---

Large Design

<2 s

---

Seek

<16 ms

---

Pause

Immediate

---

Resume

Immediate

---

Frame Generation

Background

---

# Memory Strategy

Playback IR

Long-lived cache

Frame Buffers

Generated lazily

Statistics

Cached

Renderer Resources

Not owned by simulation

---

# Thread Safety

Simulation is

Read-only

Parallel

Deterministic

Worker-thread friendly

No shared mutable state.

---

# Diagnostics

Simulation reports

```text
Invalid Playback

Frame Gap

Negative Time

Missing Thread

Broken Region

Statistics Error
```

Uses the shared compiler diagnostics framework.

---

# Testing

Simulation requires

- timeline tests
- playback tests
- frame tests
- seek tests
- performance benchmarks
- memory benchmarks
- deterministic replay tests
- golden playback tests

---

# AI Agent Rules

Simulation owns

- Playback Compiler
- Timeline
- Playback IR
- Playback Statistics

Simulation never owns

- Geometry
- Stitch Generation
- Export
- Rendering
- Commands

---

# Architectural Constraints

1. Simulation consumes Stitch IR only.
2. Simulation produces Playback IR only.
3. Simulation never mutates Stitch IR.
4. Rendering consumes Playback IR.
5. Camera belongs to Workspace.
6. Playback IR is disposable.
7. Frame generation is deterministic.
8. Playback supports incremental regeneration.
9. Simulation is independently testable.
10. Simulation remains machine independent.

---

# Future Enhancements

- Physics-based thread simulation
- Fabric deformation
- Needle penetration visualization
- GPU playback compilation
- Real machine timing profiles
- 3D embroidery preview
- Video rendering pipeline
- VR/AR preview
- Heat-map visualization
- Manufacturing analytics

---

# Acceptance Criteria

The Simulation Pipeline is complete when

✓ Stitch IR compiles into Playback IR.

✓ Playback is deterministic.

✓ Playback supports seeking, stepping, and speed control.

✓ Simulation remains independent from rendering.

✓ Incremental playback generation is supported.

✓ Playback statistics are generated.

✓ Playback IR is cacheable.

✓ Plugins can extend visualization.

✓ Large projects simulate efficiently.

✓ The Simulation Pipeline remains independently testable.
