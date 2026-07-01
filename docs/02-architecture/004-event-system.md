# Architecture
## ARCH-004 Event System

**Document ID:** ARCH-004  
**Title:** Event System Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Owner:** Core Platform Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-005 Document Model
ARCH-018 Package Ownership
```

---

# Purpose

The Event System is responsible for notifying the rest of the application that something **has already happened**.

Events are produced **only after** successful command execution.

Events never mutate the document.

Events exist to synchronize every subsystem without coupling them together.

The Event System enables:

- UI updates
- Inspector refreshes
- Layer refreshes
- History
- Autosave
- Recovery
- Statistics
- Plugin notifications
- AI notifications
- Future collaboration
- Performance monitoring

---

# Philosophy

Commands describe intention.

Events describe facts.

```text
Command

"I want to move this object."

↓

Document Mutation

↓

ObjectMovedEvent

"This object moved."
```

Commands represent the future.

Events represent the past.

---

# Golden Rule

Events never modify application state.

They only describe something that has already occurred.

```text
Command

↓

Document

↓

Event

↓

Subscribers
```

No subscriber may mutate the document while processing an event.

If a mutation is required,

a **new Command** must be issued.

---

# Event Architecture

```text
                Command
                   │
                   ▼
           Document Mutation
                   │
                   ▼
             Event Publisher
                   │
                   ▼
               Event Bus
                   │
      ┌────────────┼────────────┐
      ▼            ▼            ▼
   Canvas      Inspector     History
      ▼            ▼            ▼
 Statistics     Plugins      Autosave
      ▼            ▼            ▼
 Recovery      AI Runtime    Analytics
```

---

# Why Events?

Without events

```text
Geometry

↓

Canvas

↓

History

↓

Inspector

↓

Statistics

↓

Simulation
```

Every subsystem depends on every other subsystem.

With events

```text
Geometry

↓

ObjectMovedEvent

↓

Subscribers
```

Geometry knows nothing about Canvas.

Canvas knows nothing about Geometry.

Everything is loosely coupled.

---

# Event Lifecycle

```text
Created

↓

Published

↓

Dispatched

↓

Handled

↓

Completed
```

Events never return values.

---

# Event Structure

Every event contains

```text
Event ID

Event Type

Schema Version

Timestamp

Origin

Correlation ID

Aggregate ID

Payload

Metadata
```

---

Example

```text
ObjectMovedEvent

Object ID

Old Position

New Position

Timestamp

Workspace

Correlation ID
```

---

# Event Categories

## Geometry

```text
ObjectCreated

ObjectDeleted

ObjectMoved

ObjectScaled

ObjectRotated

ObjectMirrored

NodeAdded

NodeDeleted

NodeMoved

PathClosed
```

---

## Layer

```text
LayerCreated

LayerDeleted

LayerRenamed

LayerMoved

LayerLocked

LayerUnlocked

LayerHidden

LayerVisible
```

---

## Stitch

```text
StitchesGenerated

DensityChanged

AngleChanged

ThreadAssigned

UnderlayGenerated

OptimizationCompleted
```

---

## Machine

```text
MachineAssigned

MachineValidated

HoopChanged

MachineWarningGenerated
```

---

## Thread

```text
ThreadLibraryLoaded

ThreadChanged

PaletteUpdated

ColorMapped
```

---

## Project

```text
ProjectCreated

ProjectOpened

ProjectSaved

ProjectClosed

ProjectRecovered

ProjectMigrated
```

---

## Storage

```text
AutosaveCompleted

CheckpointCreated

BackupCompleted

RecoveryDetected
```

---

## Export

```text
ExportStarted

ExportCompleted

ExportFailed
```

---

## Import

```text
ImportStarted

ImportCompleted

ImportFailed
```

---

## Plugin

```text
PluginLoaded

PluginUnloaded

PluginEnabled

PluginDisabled
```

---

## AI

```text
SuggestionGenerated

PromptCompleted

ToolExecuted

AICommandGenerated
```

---

# Event Bus

The Event Bus is responsible for

- Publishing
- Dispatching
- Subscription management
- Ordering
- Delivery
- Diagnostics

The Event Bus contains no business logic.

---

# Event Publisher

Only the owning package may publish domain events.

Example

```text
Geometry Package

↓

ObjectMovedEvent
```

Simulation cannot publish Geometry events.

---

# Subscribers

Subscribers observe events.

They never own them.

Example

```text
ObjectMovedEvent

↓

Canvas

↓

Repaint
```

---

# Subscriber Rules

Subscribers may

- Refresh UI
- Update cache
- Recalculate statistics
- Schedule background work
- Trigger autosave
- Update history

Subscribers may not

- Modify Geometry
- Modify Stitch IR
- Modify Document

---

# Event Ordering

Events are processed in publication order.

```text
ObjectCreated

↓

ObjectMoved

↓

ObjectDeleted
```

Ordering must be deterministic.

---

# Event Immutability

Once published,

events never change.

No subscriber may modify

- payload
- metadata
- timestamp

---

# Correlation IDs

Commands and events share correlation IDs.

Example

```text
MoveObjectCommand

Correlation

12345

↓

ObjectMovedEvent

Correlation

12345
```

Useful for

- debugging
- tracing
- profiling
- AI
- telemetry

---

# Aggregate IDs

Aggregate IDs identify

Project

Layer

Object

Thread

Machine

etc.

Allows subscribers to filter efficiently.

---

# Event Propagation

```text
Command

↓

Document

↓

Event

↓

Subscribers

↓

UI Refresh
```

Subscribers never publish additional domain events directly.

---

# Event Priorities

High

```text
DocumentChanged

ObjectMoved

LayerDeleted
```

---

Medium

```text
StatisticsUpdated

SelectionChanged
```

---

Low

```text
Analytics

Logging

Telemetry
```

---

# Event Transactions

Commands may generate multiple events.

```text
MirrorSelection

↓

ObjectMirrored

↓

BoundsChanged

↓

SelectionChanged
```

Subscribers observe the complete committed transaction.

---

# Event Replay

Future

Events may be replayed for

Diagnostics

Testing

Performance analysis

Visual debugging

---

# UI Integration

Flutter subscribes to events.

```text
Event

↓

State Adapter

↓

Flutter State

↓

Widget Tree
```

Flutter never polls the document.

---

# Plugin Integration

Plugins subscribe through

Plugin Runtime

↓

Public Event API

Plugins never receive private runtime events.

---

# AI Integration

AI subscribes to

ProjectChanged

SelectionChanged

ValidationCompleted

SimulationCompleted

The AI receives only events permitted by the security policy.

---

# Recovery Integration

Recovery observes

DocumentChanged

↓

Checkpoint

↓

Journal

↓

Autosave

Recovery never modifies commands.

---

# History Integration

History listens for

Committed Commands

↓

Events

↓

Timeline

---

# Statistics Integration

Statistics observes

Geometry

↓

Stitch

↓

Thread

↓

Machine

events.

---

# Search Integration

Metadata index updates through events.

```text
ProjectSaved

↓

MetadataChanged

↓

Search Index Updated
```

---

# Notification Integration

User notifications originate from events.

```text
ExportCompleted

↓

Notification

↓

Toast
```

---

# Performance Monitoring

The Event Bus measures

Dispatch Time

Subscriber Time

Queue Length

Dropped Events

Failures

---

# Event Versioning

Each event contains

```text
Major

Minor

Patch

Schema
```

Breaking changes require migration.

---

# Event Naming

Past tense only.

Correct

```text
ObjectCreated

LayerDeleted

ExportCompleted
```

Incorrect

```text
CreateObject

DeleteLayer

ExportProject
```

Commands use verbs.

Events use completed actions.

---

# Thread Safety

Events are immutable.

Subscribers execute independently.

Long-running subscribers move work to background workers.

The UI thread must never block on event processing.

---

# Error Handling

Subscriber failure

↓

Logged

↓

Isolated

↓

Remaining subscribers continue.

One failing subscriber must never stop event delivery.

---

# Security

Sensitive events remain internal.

Public subscribers receive only

Approved Events

↓

Filtered Payload

↓

Public Metadata

---

# Performance Targets

Publish

<0.5 ms

Dispatch

<1 ms

Subscriber Registration

O(1)

Subscriber Lookup

O(1)

UI Notification

Next frame

---

# Testing

Every event requires

Unit tests

Serialization tests

Ordering tests

Versioning tests

Subscriber tests

Performance benchmarks

---

# AI Agent Rules

Every new feature must answer

- Which command creates it?
- Which events are published?
- Who subscribes?
- Can subscribers execute independently?
- Does the event leak implementation details?
- Is the event immutable?
- Is ordering deterministic?

If not,

the design should be revisited.

---

# Architectural Constraints

1. Events are immutable.
2. Events never modify the document.
3. Commands produce events.
4. Subscribers never bypass Commands.
5. Every event has one publisher.
6. Every event is versioned.
7. Every event is serializable.
8. Event names are always past tense.
9. Flutter consumes events only.
10. Plugins consume public events only.
11. AI consumes filtered events only.
12. Subscriber failures are isolated.
13. Event ordering is deterministic.
14. Events never contain UI state.
15. Events never contain platform-specific data.

---

# Future Enhancements

- Event recording
- Distributed Event Bus
- Event compression
- Event snapshots
- Event profiler
- Event visualizer
- Remote event streaming
- Enterprise auditing
- Time-travel debugging
- Event sourcing analytics

---

# Acceptance Criteria

The Event System is complete when

✓ Every successful command produces one or more events.

✓ Events are immutable.

✓ Events never modify the document.

✓ Subscribers are loosely coupled.

✓ Flutter updates through events only.

✓ Plugins receive public events only.

✓ AI receives filtered events only.

✓ Recovery, autosave, history, and statistics are event-driven.

✓ Subscriber failures are isolated.

✓ Event ordering is deterministic.

✓ The Event System is independently testable.

✓ No subsystem bypasses the Event Bus.
