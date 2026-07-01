# Architecture
## ARCH-003 Command System

**Document ID:** ARCH-003  
**Title:** Command System Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Owner:** Core Platform Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-004 Event System
ARCH-005 Document Model
ARCH-015 Security Model
```

---

# Purpose

The Command System is the **only mechanism** that may modify the project.

Every operation, regardless of where it originates, must be represented as one or more Commands.

Commands provide:

- Deterministic editing
- Undo / Redo
- History
- Recovery
- Collaboration
- Plugin integration
- AI integration
- Testing
- Automation
- Auditing

Without the Command System, none of the above systems exist.

---

# Philosophy

The application never asks:

> "Change the project."

Instead it asks:

> "Execute this Command."

Everything becomes a command.

Examples

```text
CreateRectangle

DeleteLayer

MoveNode

MirrorSelection

GenerateFill

ReplaceThread

ImportSVG

ExportDST

RotateObject

CreateGuide

AssignMachine

DeleteProjectAsset
```

---

# Golden Rule

The project can **only** change through Commands.

No exceptions.

Flutter

❌ Cannot modify project

Plugins

❌ Cannot modify project

AI

❌ Cannot modify project

Automation

❌ Cannot modify project

Storage

❌ Cannot modify project

Only:

```text
Command

↓

Command Bus

↓

Document
```

---

# Architecture

```text
                 User
                  │
                  ▼
             Flutter UI
                  │
                  ▼
        Command Dispatcher
                  │
                  ▼
         Security Gateway
                  │
                  ▼
            Command Bus
                  │
       ┌──────────┼───────────┐
       ▼          ▼           ▼
 Validation   Authorization  Logging
                  │
                  ▼
          Command Handler
                  │
                  ▼
          Document Mutation
                  │
                  ▼
             Event Bus
```

---

# Why Commands?

Traditional applications often mutate objects directly.

```text
Button

↓

Object

↓

Property
```

Sewlio Studio instead uses

```text
Button

↓

Command

↓

Document

↓

Events
```

Benefits

- Predictable
- Replayable
- Recoverable
- Testable
- Auditable

---

# Command Lifecycle

```text
Created

↓

Validated

↓

Authorized

↓

Executed

↓

Committed

↓

Events Published

↓

Recorded

↓

Completed
```

Every command follows the same lifecycle.

---

# Command Structure

Every command contains

```text
Command ID

Command Type

Schema Version

Timestamp

User

Origin

Payload

Metadata
```

---

Example

```text
MoveObjectCommand

Object ID

Delta X

Delta Y

Timestamp

Workspace

Selection Version
```

---

# Command Origin

Commands may originate from

User

AI

Plugin

Automation

Macro

Recovery

Import

Collaboration

Regardless of origin,

execution is identical.

---

# Command Categories

## Geometry

```text
Create

Delete

Move

Scale

Rotate

Mirror

Align

Distribute

Boolean

Convert
```

---

## Layer

```text
Create Layer

Delete Layer

Rename Layer

Move Layer

Lock

Hide
```

---

## Embroidery

```text
Generate Fill

Generate Satin

Generate Running Stitch

Generate Underlay

Change Density

Change Angle

Compensation

Pull Compensation
```

---

## Thread

```text
Assign Thread

Replace Thread

Import Library

Create Palette
```

---

## Machine

```text
Assign Machine

Change Hoop

Validate Machine

Optimize Machine
```

---

## Workspace

```text
Zoom

Pan

Guides

Grid

Rulers
```

Workspace commands may be non-persistent.

---

## Project

```text
Open

Save

Close

Rename

Duplicate

Import

Export
```

---

# Persistent vs Non-Persistent Commands

Persistent

```text
MoveObject

DeleteLayer

AssignThread
```

Saved inside project.

---

Non-Persistent

```text
Zoom

Pan

OpenPanel

ToggleSidebar
```

Not stored.

---

# Command Bus

The Command Bus coordinates execution.

Responsibilities

- Dispatch
- Validation
- Authorization
- Execution
- Logging
- History
- Event publication

The Command Bus contains **no business logic**.

---

# Command Handler

Every command has exactly one handler.

```text
MoveObjectCommand

↓

MoveObjectHandler
```

Handler owns

- Validation
- Domain logic
- Document mutation

---

# Handler Rules

A handler

May

- Read document
- Validate state
- Modify owned domain
- Emit events

Must not

- Modify unrelated domains
- Call UI
- Perform rendering
- Access Flutter

---

# Validation Pipeline

Before execution

```text
Schema Validation

↓

Permission Validation

↓

Business Validation

↓

Conflict Validation

↓

Ready
```

If validation fails,

execution stops.

---

# Authorization

Authorization depends on origin.

Example

```text
User

↓

Allowed

----------------

Plugin

↓

Permission Check

----------------

AI

↓

Confirmation Policy

----------------

Automation

↓

Policy Engine
```

---

# Command Transactions

Multiple commands may execute atomically.

```text
Begin Transaction

↓

Command A

↓

Command B

↓

Command C

↓

Commit
```

Failure

↓

Rollback

---

# Nested Commands

Nested commands are discouraged.

Preferred

```text
Parent Command

↓

Domain Service

↓

Document
```

Instead of

```text
Command

↓

Command

↓

Command
```

---

# Composite Commands

Composite commands group multiple commands.

Example

```text
Mirror Design

↓

Mirror Geometry

↓

Recalculate Stitches

↓

Update Statistics
```

Appears as one history item.

---

# Undo

Undo executes reverse commands.

```text
History

↓

Reverse Command

↓

Document

↓

Events
```

Example

```text
Create

↓

Delete

----------------

Move

↓

Reverse Move
```

---

# Redo

Redo replays commands.

```text
History

↓

Replay

↓

Document
```

---

# History

History stores

```text
Command

Timestamp

User

Origin

Metadata

Undo Data
```

History never stores UI state.

---

# Recovery

Recovery uses command history.

```text
Commands

↓

Journal

↓

Recovery

↓

Replay
```

---

# Collaboration

Future collaboration synchronizes commands.

```text
Commands

↓

Change Set

↓

Remote

↓

Replay
```

Project files are never merged.

Commands are merged.

---

# AI Integration

AI generates commands.

Never document mutations.

```text
Prompt

↓

Tools

↓

Commands

↓

Command Bus
```

---

# Plugin Integration

Plugins create commands.

Plugins never modify the document directly.

---

# Macro System

Macros record commands.

```text
Commands

↓

Recorder

↓

Macro

↓

Replay

↓

Commands
```

Macros become deterministic.

---

# Automation

Automation executes command sequences.

```text
Schedule

↓

Commands

↓

Bus
```

No special execution path.

---

# Import

Importer

↓

Import Command

↓

Geometry Builder

↓

Document

---

# Export

Export is also a command.

```text
ExportDSTCommand

↓

Validation

↓

Machine Compiler

↓

Encoder
```

---

# Event Relationship

Every successful command produces events.

```text
Command

↓

Document

↓

Events
```

Commands

↓

Cause

Events

↓

Effect

---

# Storage Relationship

Commands trigger

Autosave

Recovery

Checkpoint

History

Audit

Storage itself never creates commands.

---

# Security Relationship

Every command passes through

```text
Security Gateway

↓

Policy Engine

↓

Permission Engine
```

before execution.

---

# Logging

Every command produces

```text
Start

Duration

Success

Failure

Origin

Errors
```

Useful for

Diagnostics

Performance

Recovery

Audit

---

# Command Metadata

Metadata may include

```text
Workspace

Viewport

Selection

Machine

Thread Library

Plugin

AI Model

Macro

Transaction
```

Not all metadata is persisted.

---

# Thread Safety

Commands execute serially against the document.

Background work

↓

Produces command

↓

Main Command Queue

↓

Execution

Document mutation remains deterministic.

---

# Performance Targets

Dispatch

<0.5 ms

Validation

<1 ms

Execution

Depends on command

History

O(1)

Undo

Immediate

Redo

Immediate

---

# Testing

Every command requires

Unit tests

Validation tests

Undo tests

Redo tests

Serialization tests

Performance benchmarks

Regression tests

---

# AI Agent Rules

Every new feature must answer

- What command does it introduce?
- Which handler owns it?
- Which events are produced?
- Can it be undone?
- Can it be replayed?
- Can it be synchronized?
- Can it be recorded as a macro?

If the answer is "no",

the design should be reconsidered.

---

# Architectural Constraints

1. Commands are the only mutation mechanism.
2. Every command has one handler.
3. Every handler owns one domain.
4. Commands are immutable.
5. Commands are versioned.
6. Commands are serializable.
7. Commands are replayable.
8. Commands are undoable unless explicitly documented.
9. Commands never call Flutter.
10. Commands never perform rendering.
11. Commands produce events.
12. Commands execute through the Command Bus.
13. Commands never bypass validation.
14. Commands never bypass security.
15. Commands may never mutate another domain directly.

---

# Future Enhancements

- Distributed command execution
- Network command streaming
- CRDT-compatible command synchronization
- Command compression
- Incremental command snapshots
- Time-travel debugging
- Command profiler
- Visual command timeline
- Command scripting API
- Remote command execution

---

# Acceptance Criteria

The Command System is complete when

✓ Every project mutation is represented by a command.

✓ Every command executes through the Command Bus.

✓ Every command has a dedicated handler.

✓ Every successful command produces events.

✓ Commands are undoable and redoable where applicable.

✓ Commands support serialization and replay.

✓ Commands integrate with recovery, history, AI, plugins, and future collaboration.

✓ No subsystem bypasses the Command System.

✓ Flutter contains no document mutation logic.

✓ The Command System remains deterministic, thread-safe, and independently testable.
