# Architecture
## ARCH-026 Task Scheduler

**Document ID:** ARCH-026  
**Title:** Task Scheduler Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Runtime Platform Team

**Related Documents**

```text
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-004 Event System
ARCH-014 AI Runtime
ARCH-016 Performance Architecture
ARCH-023 Runtime Lifecycle
ARCH-024 Service Registry
ARCH-025 Resource Management
```

---

# Purpose

The Task Scheduler is the execution engine of Sewlio Studio.

Every asynchronous operation, background computation, compiler pipeline, rendering preparation, AI request, and resource loading task executes through the Task Scheduler.

The Task Scheduler provides:

- Deterministic execution
- Parallel scheduling
- Task prioritization
- Cancellation
- Progress reporting
- Dependency resolution
- Resource-aware scheduling
- Performance instrumentation

It is the heartbeat of the Runtime.

---

# Philosophy

Nothing executes in the background unless the Task Scheduler owns it.

Instead of:

```text
Spawn Thread

↓

Run Work
```

Everything becomes

```text
Create Task

↓

Scheduler

↓

Worker Pool

↓

Execution

↓

Completion
```

---

# Goals

The scheduler shall provide

- Centralized task execution
- Priority scheduling
- Task dependencies
- Parallel execution
- Worker pools
- Task cancellation
- Progress reporting
- Deadline awareness
- Resource-aware scheduling
- Deterministic execution
- Performance diagnostics

---

# High-Level Architecture

```text
                  Runtime
                     │
                     ▼
              Task Scheduler
                     │
      ┌──────────────┼──────────────┐
      ▼              ▼              ▼
 Priority Queue  Dependency DAG  Worker Pool
      ▼              ▼              ▼
 Execution      Task Runtime   Diagnostics
```

---

# Core Components

The scheduler consists of

```text
Task Scheduler

Task Queue

Priority Manager

Dependency Graph

Worker Pool

Execution Engine

Cancellation Manager

Progress Manager

Task Monitor

Profiler
```

---

# Design Principles

## Scheduler Owns Execution

Tasks never create threads.

The Scheduler owns workers.

---

## Work Is Data

Tasks are immutable descriptions of work.

---

## Deterministic

Task ordering follows deterministic rules.

---

## Dependency Driven

Tasks execute only after dependencies complete.

---

## Non-blocking UI

UI thread never performs heavy work.

---

## Cancellation First

Every long-running task supports cancellation.

---

# Task Lifecycle

Every task follows

```text
Created

↓

Queued

↓

Waiting

↓

Ready

↓

Running

↓

Completed

↓

Disposed
```

Cancelled tasks

```text
Created

↓

Queued

↓

Cancelled

↓

Disposed
```

Failed tasks

```text
Running

↓

Failed

↓

Disposed
```

---

# Task States

```text
Created

Queued

Waiting

Ready

Running

Completed

Cancelled

Failed

Timed Out

Disposed
```

State transitions are managed only by the Scheduler.

---

# Task Structure

Every task contains

```text
Task ID

Task Type

Priority

Dependencies

Estimated Cost

Progress

Cancellation Token

Context

Metadata

Owner

Result
```

Tasks are immutable after creation except for execution state.

---

# Task Categories

## User Interaction

Examples

```text
Selection

Transform

Zoom

Pan

Undo

Redo
```

Highest priority.

---

## Rendering

Examples

```text
Scene Update

GPU Upload

Texture Build

Thumbnail Generation
```

---

## Compiler

Examples

```text
Import

Digitizer

Playback

Machine Compiler

Export Preparation
```

---

## Storage

Examples

```text
Save

Autosave

Load

Migration

Recovery
```

---

## AI

Examples

```text
Context Build

Tool Execution

Prompt Assembly

Model Request
```

---

## Background

Examples

```text
Cache Cleanup

Indexing

Statistics

Diagnostics

Preloading
```

Lowest priority.

---

# Priority Levels

```text
Critical

Interactive

High

Normal

Low

Background

Idle
```

Interactive tasks always preempt background work.

---

# Task Queue

The Scheduler maintains multiple queues.

```text
Critical Queue

Interactive Queue

High Queue

Normal Queue

Background Queue
```

Workers always consume the highest available priority.

---

# Dependency Graph

Tasks declare dependencies.

Example

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

Tasks become ready only when dependencies complete.

Circular dependencies are rejected.

---

# Worker Pools

Dedicated pools exist for different workloads.

```text
CPU Pool

IO Pool

GPU Submission

AI Pool

Background Pool
```

Pools prevent resource starvation.

---

# Thread Allocation

Suggested defaults

```text
Interactive

1 Reserved Thread

CPU Pool

N - 2

IO Pool

2

Background

1

AI

Configurable
```

User interaction always retains CPU availability.

---

# Task Context

Tasks receive

```text
Runtime Context

Workspace Context

Project Context

Resource Context

Cancellation Token
```

Tasks never access global mutable state.

---

# Cancellation

Cancellation is cooperative.

```text
Task

↓

Cancellation Requested

↓

Checkpoint

↓

Cleanup

↓

Cancelled
```

Tasks must periodically check their cancellation token.

---

# Progress Reporting

Every long-running task exposes progress.

```text
0%

↓

25%

↓

50%

↓

75%

↓

100%
```

Progress supports nested tasks.

---

# Composite Tasks

Tasks may contain child tasks.

Example

```text
Export

├── Validation

├── Machine Compile

├── Encode

└── Verify
```

Completion occurs after all children complete.

---

# Task Batching

Small tasks may be batched.

Example

```text
100 Geometry Updates

↓

Batch

↓

Single Render Update
```

Batching reduces scheduling overhead.

---

# Task Fusion

Independent compatible tasks may be merged.

Example

```text
Geometry Validation

+

Bounding Box Update

↓

One Worker Pass
```

Task fusion is transparent.

---

# Scheduling Policies

Supported policies

```text
Priority First

Dependency First

FIFO

Deadline

Fair Scheduling

Adaptive Scheduling (future)
```

Priority scheduling is the default.

---

# Time Slicing

Long-running tasks yield periodically.

```text
Work

↓

Yield

↓

Resume
```

This maintains UI responsiveness.

---

# Deadlines

Tasks may specify deadlines.

Example

```text
Frame Build

Deadline

16 ms
```

The Scheduler prioritizes deadline-sensitive work.

---

# Resource Awareness

Tasks declare resource usage.

Examples

```text
CPU

IO

GPU

Memory

AI

Storage
```

The Scheduler avoids oversubscription.

---

# Resource Locks

Logical resource locks prevent conflicts.

Example

```text
Project

↓

Exclusive Compile

↓

Export
```

Read operations may execute concurrently.

---

# Retry Policy

Retryable tasks include

```text
Storage

Network

AI Provider

Resource Loading
```

Compiler tasks are deterministic and generally do not retry automatically.

---

# Failure Handling

Failures produce structured errors.

```text
Task

↓

Structured Error

↓

Diagnostics

↓

Recovery Manager
```

Task failure never crashes the Scheduler.

---

# Events

Scheduler emits

```text
TaskCreated

TaskQueued

TaskStarted

TaskCompleted

TaskCancelled

TaskFailed

TaskProgressChanged
```

Events are informational.

---

# Diagnostics

Metrics include

```text
Queue Length

Execution Time

Wait Time

Worker Utilization

Cancellation Rate

Failure Rate

Average Task Time

Task Throughput
```

---

# Performance Targets

```text
Task Creation

<5 µs

Queue Insertion

<5 µs

Dependency Resolution

<20 µs

Cancellation

<5 ms

Progress Update

<1 ms

Scheduling Decision

<10 µs
```

---

# Testing

The scheduler requires

- queue tests
- dependency tests
- cycle detection tests
- priority tests
- cancellation tests
- starvation tests
- deadlock tests
- concurrency tests
- performance benchmarks
- stress tests

---

# AI Agent Rules

AI agents must

- schedule background work through the Task Scheduler
- never create unmanaged threads
- declare dependencies explicitly
- support cancellation
- report progress
- avoid blocking worker threads
- preserve deterministic execution

---

# Architectural Constraints

1. All asynchronous work executes through the Task Scheduler.
2. UI thread performs no heavy computation.
3. Task dependencies form a DAG.
4. Worker pools are Runtime-owned.
5. Cancellation is cooperative.
6. Tasks are immutable after creation.
7. Scheduler owns execution order.
8. Resource conflicts are coordinated centrally.
9. Every long-running task reports progress.
10. Scheduler behavior is deterministic and testable.

---

# Future Enhancements

- Work stealing
- NUMA-aware scheduling
- Distributed execution
- GPU compute scheduling
- Predictive scheduling
- AI-assisted scheduling optimization
- Cluster execution
- Energy-aware scheduling
- Adaptive worker pools
- Timeline visualization

---

# Acceptance Criteria

The Task Scheduler is complete when

✓ All background work executes through the Scheduler.

✓ Tasks support priorities, dependencies, and cancellation.

✓ Worker pools prevent UI starvation.

✓ Task execution is deterministic and observable.

✓ Progress reporting is available for long-running operations.

✓ Resource-aware scheduling prevents contention.

✓ Scheduler diagnostics expose execution metrics.

✓ Task failures are isolated and recoverable.

✓ Scheduler integrates with Runtime Lifecycle and Service Registry.

✓ The Task Scheduler serves as the single execution authority for asynchronous work.
