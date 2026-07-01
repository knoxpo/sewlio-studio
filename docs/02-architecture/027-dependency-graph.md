# Architecture
## ARCH-027 Dependency Graph

**Document ID:** ARCH-027  
**Title:** Dependency Graph Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Runtime Platform Team

**Related Documents**

```text
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-004 Event System
ARCH-005 Document Model
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
ARCH-016 Performance Architecture
ARCH-023 Runtime Lifecycle
ARCH-024 Service Registry
ARCH-025 Resource Management
ARCH-026 Task Scheduler
```

---

# Purpose

The Dependency Graph is the central execution model of Sewlio Studio.

It models relationships between every major runtime object and determines:

- What changed
- What depends on it
- What must be recomputed
- What may be reused
- What can execute in parallel

Without the Dependency Graph, every subsystem would implement its own invalidation logic.

The Dependency Graph becomes the single source of truth for incremental execution.

---

# Vision

Instead of asking:

> "What should I recompute?"

Every subsystem asks:

> "What changed?"

The Dependency Graph answers everything else.

---

# Philosophy

Everything is a node.

Everything has dependencies.

Everything becomes incremental.

---

# Goals

The Dependency Graph shall provide

- Dependency tracking
- Dirty propagation
- Incremental execution
- Cache invalidation
- Task generation
- Parallel execution planning
- Change detection
- Cycle prevention
- Diagnostics
- Performance optimization

---

# High-Level Architecture

```text
                Document
                    │
                    ▼
           Dependency Graph
                    │
       ┌────────────┼────────────┐
       ▼            ▼            ▼
 Dirty Nodes   Task Planner   Cache Manager
       ▼            ▼            ▼
 Scheduler    Worker Pools   Incremental Runtime
```

---

# Core Components

The Dependency Graph consists of

```text
Dependency Graph

Graph Nodes

Graph Edges

Dirty Tracker

Change Detector

Task Planner

Execution Planner

Cache Invalidation Engine

Diagnostics

Metrics
```

---

# Fundamental Principle

Every computation is represented as a node.

Example

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

Dependencies are explicit.

---

# Node Types

## Document Nodes

```text
Project

Layer

Group

Object

Path

Image
```

---

## Geometry Nodes

```text
Curve

Transform

Bounds

Mesh

Selection
```

---

## Embroidery Nodes

```text
Stitch Object

Underlay

Fill

Density

Pull Compensation
```

---

## Compiler Nodes

```text
Digitizer

Playback

Machine Compiler

Export Generator
```

---

## Rendering Nodes

```text
Scene

Viewport

Texture

Overlay

Thumbnail
```

---

## Resource Nodes

```text
Thread Library

Machine Profile

Template

Fabric

Font
```

---

## AI Nodes

```text
Conversation

Context

Embedding

Knowledge Index
```

---

# Edge Types

Relationships include

```text
Depends On

Uses

Generates

Consumes

References

Invalidates
```

Edges are directional.

---

# Graph Structure

```text
Geometry

↓

Stitch Object

↓

Simulation

↓

Machine Compiler

↓

DST Export
```

Each node knows

- parents
- children
- dependencies
- dependents

---

# Dependency Rules

Dependencies must

- be explicit
- be acyclic
- be deterministic

Cycles are prohibited.

---

# Dirty Tracking

Every modification creates a dirty node.

```text
Geometry Changed

↓

Geometry Node Dirty

↓

Dependents Dirty

↓

Scheduler
```

Dirty state propagates automatically.

---

# Dirty States

```text
Clean

Dirty

Invalid

Computing

Failed

Disposed
```

Only the Dependency Graph changes state.

---

# Dirty Propagation

Example

```text
Curve

↓

Fill

↓

Simulation

↓

Machine Compiler

↓

Export
```

Only affected nodes recompute.

---

# Incremental Execution

Instead of

```text
Entire Project

↓

Recompile
```

The graph performs

```text
Changed Node

↓

Affected Nodes

↓

Task Plan

↓

Incremental Execution
```

---

# Task Planning

The Dependency Graph produces execution plans.

```text
Dirty Nodes

↓

Dependency Analysis

↓

Execution Plan

↓

Task Scheduler
```

The Scheduler executes.

The Graph decides what.

---

# Topological Ordering

Execution follows topological order.

Example

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

Children never execute before parents complete.

---

# Parallel Execution

Independent branches execute simultaneously.

Example

```text
Geometry A

Geometry B

Geometry C

↓

Parallel Digitizers

↓

Merge
```

The Dependency Graph determines safe parallelism.

---

# Resource Dependencies

Resources participate in the graph.

Example

```text
Thread Library

↓

Thread Mapping

↓

Machine Compiler

↓

Export
```

Updating a thread library invalidates dependent nodes.

---

# Rendering Dependencies

```text
Geometry

↓

Mesh

↓

GPU Buffer

↓

Viewport
```

Rendering updates incrementally.

---

# AI Dependencies

AI context depends on

```text
Project

Selection

Machine Profile

Workspace
```

Only modified context is rebuilt.

---

# Cache Invalidation

Caches are graph-aware.

```text
Geometry

↓

Invalidate Mesh

↓

Invalidate Playback

↓

Invalidate Export Cache
```

Unaffected caches remain valid.

---

# Graph Updates

Operations

```text
Create Node

Delete Node

Update Edge

Remove Edge

Mark Dirty

Mark Clean
```

All updates occur through the Runtime.

---

# Graph Queries

Supported queries

```text
Dependencies

Dependents

Dirty Nodes

Execution Order

Affected Subgraph

Shortest Path

Cycles

Reachability
```

---

# Execution Plans

The Dependency Graph produces immutable execution plans.

Example

```text
Execution Plan

↓

Task A

Task B

Task C

↓

Scheduler
```

Execution Plans are snapshots.

---

# Graph Versioning

Every graph mutation increments

```text
Graph Version
```

Caches associate with graph versions.

Outdated caches invalidate automatically.

---

# Observability

Graph metrics

```text
Node Count

Edge Count

Dirty Nodes

Execution Depth

Parallelism

Cache Hits

Cache Misses

Execution Time
```

---

# Diagnostics

Diagnostics include

```text
Cycles

Orphan Nodes

Unused Nodes

Large Subgraphs

Expensive Paths

Long Chains
```

---

# Visualization

Future tooling should visualize

```text
Dependency Graph

Execution Graph

Dirty Graph

Task Graph

Resource Graph
```

Useful for debugging and optimization.

---

# Performance Targets

```text
Node Lookup

<100 ns

Edge Lookup

<100 ns

Dirty Propagation

<20 µs

Execution Plan

<200 µs

Topological Sort

Linear O(V+E)
```

---

# Thread Safety

Graph mutations occur through the Runtime.

Read operations are lock-free where practical.

Execution plans are immutable.

---

# Failure Handling

If execution fails

```text
Failed Node

↓

Mark Invalid

↓

Diagnostics

↓

Recovery Manager
```

Unaffected graph branches continue.

---

# Testing

The Dependency Graph requires

- graph construction tests
- cycle detection tests
- dirty propagation tests
- execution ordering tests
- parallel execution tests
- cache invalidation tests
- graph version tests
- concurrency tests
- stress tests
- million-node benchmarks

---

# AI Agent Rules

AI agents must

- declare dependencies explicitly
- never bypass the graph
- avoid hidden dependencies
- support incremental execution
- avoid cyclic relationships
- use execution plans instead of ad hoc scheduling

---

# Architectural Constraints

1. Every computation is represented as a graph node.
2. Dependencies are explicit.
3. The graph must remain acyclic.
4. Dirty propagation is centralized.
5. Execution plans are immutable.
6. Cache invalidation is graph-driven.
7. Parallel execution is graph-derived.
8. Rendering, AI, compilers, and resources participate in the graph.
9. The Runtime owns graph mutations.
10. The Dependency Graph is the single authority for incremental execution.

---

# Future Enhancements

- Distributed dependency graphs
- GPU-assisted graph traversal
- Persistent graph snapshots
- Live graph visualization
- Predictive invalidation
- AI-assisted graph optimization
- Incremental graph serialization
- Cross-workspace dependency graphs
- Collaborative dependency tracking
- Graph-based build acceleration

---

# Acceptance Criteria

The Dependency Graph is complete when

✓ Every significant computation is represented as a node.

✓ Dependencies are explicit, deterministic, and acyclic.

✓ Dirty propagation is automatic and centralized.

✓ Execution plans are generated from dependency analysis.

✓ Cache invalidation is driven by graph changes.

✓ Parallel execution opportunities are automatically identified.

✓ Resources, compilers, rendering, AI, and workspace state participate in the graph.

✓ Diagnostics expose graph health and execution characteristics.

✓ The graph scales efficiently to very large projects.

✓ The Dependency Graph serves as the execution backbone for the entire Runtime.
