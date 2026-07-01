# Architecture
## ARCH-016 Performance Architecture

**Document ID:** ARCH-016  
**Title:** Performance Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Platform Performance Team

**Related Documents**

```text
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-004 Event System
ARCH-005 Document Model
ARCH-007 Storage Architecture
ARCH-008 Rendering Architecture
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
ARCH-014 AI Runtime
```

---

# Purpose

The Performance Architecture defines the principles, budgets, execution strategies, and optimization techniques that ensure Sewlio Studio remains responsive while processing projects ranging from a few stitches to several million stitches.

Performance is **not** an optimization phase.

Performance is a first-class architectural requirement.

---

# Philosophy

Performance should be achieved through architecture, not micro-optimizations.

Preferred order of optimization:

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

SIMD

↓

GPU

↓

Micro-optimizations
```

Never optimize the last layer first.

---

# Core Performance Goals

The application shall

- Feel instantaneous
- Never block the UI
- Scale linearly
- Support incremental computation
- Exploit multicore CPUs
- Utilize GPU acceleration
- Minimize memory allocations
- Minimize unnecessary work

---

# Performance Principles

## Immutable Data

Immutable data enables

- parallel execution
- caching
- deterministic behavior
- lock-free reads

---

## Incremental Everything

Never recompute the world.

Only recompute what changed.

---

## Lazy Evaluation

Compute only when needed.

---

## Parallel by Default

Heavy workloads execute on worker threads.

---

## Cache Aggressively

CPU is cheaper than recomputation.

---

## Event Driven

Events invalidate only affected systems.

---

# System Overview

```text
                    Document
                        │
                        ▼
                  Event Bus
                        │
      ┌─────────────────┼─────────────────┐
      ▼                 ▼                 ▼
 Dirty Tracker   Dependency Graph   Scheduler
      ▼                 ▼                 ▼
 Incremental      Task Graph      Worker Pool
      ▼                 ▼                 ▼
 Render       Compiler       AI Runtime
```

---

# Performance Layers

Performance exists at multiple levels.

```text
Application

↓

Workspace

↓

Document

↓

Domain

↓

Compiler

↓

Renderer

↓

Storage

↓

GPU
```

Each layer owns its own performance budget.

---

# Performance Budget

## UI Response

Target

```text
<16 ms
```

---

## Pointer Interaction

Target

```text
<8 ms
```

---

## Zoom

Target

```text
<16 ms
```

---

## Pan

Target

```text
<16 ms
```

---

## Selection

Target

```text
<10 ms
```

---

## Undo

Target

```text
<50 ms
```

---

## Autosave

Background

Never blocks UI.

---

## Import

```text
Small <100 ms

Medium <500 ms

Large <3 s
```

---

## Digitizer

Incremental

```text
<100 ms
```

---

## Export

Large project

```text
<2 s
```

---

# Dirty Tracking

Everything supports dirty tracking.

```text
Document

↓

Dirty Objects

↓

Dirty Regions

↓

Dirty Layers

↓

Dirty Systems
```

Nothing recomputes unnecessarily.

---

# Dependency Graph

Each subsystem declares dependencies.

```text
Geometry

↓

Digitizer

↓

Simulation

↓

Machine Compiler

↓

Export
```

Only affected nodes execute.

---

# Incremental Execution

Instead of

```text
Entire Project

↓

Compile
```

Use

```text
Changed Region

↓

Compile

↓

Merge Result
```

This principle applies to

- rendering
- simulation
- digitizer
- machine compiler
- export preparation

---

# Task Graph

Heavy work is represented as a task graph.

```text
Compile Project

├── Region A
├── Region B
├── Region C
└── Region D
```

Independent tasks execute concurrently.

---

# Scheduler

The scheduler prioritizes

```text
UI

↓

Selection

↓

Visible Rendering

↓

Background Compilation

↓

AI

↓

Indexing
```

User interaction always wins.

---

# Worker Pool

Worker threads execute

- import
- digitizer
- playback
- simulation
- machine compilation
- export preparation
- thumbnails
- indexing
- AI tools

Main thread never performs heavy computation.

---

# Memory Strategy

Memory is divided into

```text
Persistent

Transient

Cache

Streaming

Scratch
```

Each category has different lifetime rules.

---

# Allocation Strategy

Prefer

- object pools
- arena allocators
- stack allocation
- reusable buffers

Avoid

- unnecessary heap allocations
- repeated allocations inside hot loops

---

# Cache Architecture

Multiple cache layers exist.

## Geometry Cache

Stores tessellated geometry.

---

## Stitch Cache

Stores compiled stitch meshes.

---

## Playback Cache

Stores playback frames.

---

## Machine Cache

Stores compiled Machine IR.

---

## Render Cache

Stores GPU resources.

---

## Thumbnail Cache

Stores previews.

---

## AI Cache

Stores embeddings and summaries.

---

Caches are disposable.

---

# Cache Invalidation

Caches invalidate through Events.

```text
GeometryChanged

↓

Invalidate Geometry Cache

↓

Invalidate Stitch Cache

↓

Invalidate Playback Cache

↓

Invalidate Machine Cache
```

Only affected caches rebuild.

---

# Rendering Performance

Renderer uses

- dirty regions
- LOD
- batching
- GPU instancing
- culling
- texture atlases

Rendering never rebuilds the scene unnecessarily.

---

# Compiler Performance

Compilers use

- incremental compilation
- region compilation
- task graphs
- immutable IRs
- compiler pass reuse

---

# AI Performance

AI uses

- context summarization
- incremental context
- cached embeddings
- streaming responses
- background indexing

Large projects are summarized instead of serialized.

---

# Storage Performance

Storage uses

- incremental saves
- atomic writes
- lazy loading
- asynchronous IO
- streaming

Projects open metadata before loading heavy assets.

---

# Resource Management

Shared resources

- fonts
- thread libraries
- machine profiles
- templates

are loaded once per workspace.

---

# GPU Strategy

GPU accelerates

- rendering
- image scaling
- shader effects
- future compute workloads

Business logic remains CPU-based.

---

# SIMD Strategy

SIMD may accelerate

- geometry transforms
- matrix operations
- stitch calculations
- image processing

Implementation is transparent to higher layers.

---

# Profiling

Every subsystem exposes metrics.

Examples

```text
Execution Time

Memory

Cache Hits

Task Count

Queue Time

FPS

Compiler Time

Export Time

AI Tool Time
```

---

# Instrumentation

Every pipeline stage is traceable.

```text
Pipeline

↓

Stage

↓

Pass

↓

Metrics
```

Metrics are available through diagnostics.

---

# Performance Modes

Workspace may select

```text
Battery Saver

Balanced

Performance

Maximum Performance
```

Each mode adjusts

- worker count
- cache sizes
- rendering quality
- AI background work

---

# Large Project Strategy

Large projects use

- lazy loading
- partial rendering
- partial compilation
- background indexing
- streaming
- virtualized UI lists

No subsystem assumes the entire project is active.

---

# Mobile Strategy

Mobile devices

- reduce worker count
- reduce cache sizes
- lower rendering quality
- pause background AI
- prefer battery efficiency

---

# Desktop Strategy

Desktop prioritizes

- maximum parallelism
- aggressive caching
- GPU utilization
- background indexing
- AI preprocessing

---

# Diagnostics

Performance diagnostics report

```text
Slow Tasks

Slow Passes

Cache Misses

Memory Growth

Frame Drops

Thread Contention

GPU Utilization

Task Queue Length
```

---

# Testing

Performance tests include

- startup benchmarks
- rendering benchmarks
- million-stitch benchmarks
- import benchmarks
- export benchmarks
- memory leak tests
- long-running stability tests
- mobile benchmarks

Performance regressions block releases.

---

# AI Agent Rules

Performance changes must

- include benchmarks
- preserve determinism
- avoid hidden allocations
- avoid unnecessary locking
- respect architecture

Micro-optimizations without measurements are discouraged.

---

# Architectural Constraints

1. UI thread never performs heavy computation.
2. All compilers support incremental execution.
3. Rendering is dirty-region based.
4. Events drive cache invalidation.
5. Shared resources are loaded once per workspace.
6. Large projects are streamed.
7. Background work never blocks interaction.
8. Every subsystem exposes profiling metrics.
9. Performance budgets are enforced continuously.
10. Performance remains measurable and reproducible.

---

# Future Enhancements

- GPU compute digitizer
- Adaptive task scheduler
- Distributed compilation
- Remote rendering
- Background machine compilation
- Predictive cache warming
- AI-assisted optimization
- NUMA-aware scheduling
- Incremental cloud synchronization
- Hardware capability auto-tuning

---

# Acceptance Criteria

The Performance Architecture is complete when

✓ UI remains responsive during heavy workloads.

✓ Incremental execution is used throughout the platform.

✓ Background work is fully asynchronous.

✓ Performance budgets are defined and measurable.

✓ Caches are event-driven and disposable.

✓ Large projects scale efficiently.

✓ Mobile and desktop have adaptive performance profiles.

✓ Every major subsystem exposes diagnostics and benchmarks.

✓ Performance regressions are detectable.

✓ The platform remains responsive across supported hardware.
