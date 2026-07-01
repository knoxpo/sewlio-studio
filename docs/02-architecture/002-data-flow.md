# Architecture
## ARCH-002 Data Flow

**Document ID:** ARCH-002  
**Title:** System Data Flow  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical

**Owner:** Core Architecture Team

**Related Documents**

```text
ARCH-000 System Overview
ARCH-001 Intermediate Representations
ARCH-003 Command System
ARCH-004 Event System
ARCH-005 Document Model
ARCH-006 Project Format
```

---

# Purpose

This document defines how information flows throughout Sewlio Studio.

Unlike traditional applications where UI directly modifies objects, Sewlio Studio follows a strict pipeline:

- Commands mutate state.
- Events communicate changes.
- Intermediate Representations (IRs) communicate between domains.
- Every subsystem is independent.

There should be only one valid path through the system.

---

# High-Level Architecture

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
          Command Bus (Rust)
                  │
                  ▼
        Domain Command Handler
                  │
                  ▼
          Document Mutation
                  │
                  ▼
          Domain Events
                  │
       ┌──────────┼──────────┐
       ▼          ▼          ▼
   Canvas     Inspector   History
       ▼          ▼          ▼
      Autosave   Statistics  Plugins
                  ▼
              AI Runtime
```

---

# Design Principles

The data flow follows these principles:

- Single Direction
- Deterministic
- Immutable Events
- Command-Based Mutation
- Domain Isolation
- Platform Independent
- Thread Safe
- Testable
- Replayable
- Recoverable

---

# System Flow Overview

The application contains several independent pipelines.

```text
Import Pipeline

↓

Editing Pipeline

↓

Digitizing Pipeline

↓

Simulation Pipeline

↓

Export Pipeline

↓

Persistence Pipeline
```

Each pipeline communicates using well-defined contracts.

---

# Primary Data Flow

```text
User

↓

Flutter

↓

Command

↓

Validation

↓

Document

↓

Events

↓

Render

↓

Storage
```

Only Commands modify the Document.

---

# Import Flow

## Purpose

Convert external formats into editable project data.

```text
SVG

PDF

PNG

DXF

AI

↓

Importer

↓

Import IR

↓

Normalizer

↓

Geometry Builder

↓

Geometry IR

↓

Document
```

---

## Responsibilities

Importer

- Parse external format
- Validate
- Generate Import IR

Geometry Builder

- Convert Import IR
- Create Geometry IR
- Preserve metadata

Document

- Store Geometry IR

---

# Editing Flow

Editing is entirely command-driven.

```text
User Gesture

↓

Flutter Tool

↓

Create Command

↓

Command Bus

↓

Geometry Package

↓

Geometry IR

↓

Document

↓

GeometryChanged Event

↓

Canvas Refresh
```

---

# Example

Move Object

```text
Drag

↓

MoveObjectCommand

↓

Validation

↓

Geometry Update

↓

ObjectMovedEvent

↓

Canvas

Inspector

History

Autosave
```

---

# Digitizing Flow

Digitizing converts Geometry IR into Stitch IR.

```text
Geometry IR

↓

Geometry Analysis

↓

Compiler Passes

↓

Running Stitch

↓

Fill Stitch

↓

Satin Stitch

↓

Optimization

↓

Validation

↓

Stitch IR
```

---

# Compiler Pipeline

```text
Geometry IR

↓

Pre-processing

↓

Topology Analysis

↓

Feature Detection

↓

Digitizer Passes

↓

Optimization Passes

↓

Validation

↓

Stitch IR
```

Each pass should be independent.

---

# Stitch Flow

```text
Geometry Object

↓

Digitizer

↓

Embroidery Object

↓

Stitch Sequence

↓

Thread Assignment

↓

Metadata

↓

Stitch IR
```

---

# Simulation Flow

Simulation never reads Geometry IR.

It consumes Stitch IR only.

```text
Stitch IR

↓

Playback Compiler

↓

Playback IR

↓

Animation Timeline

↓

Flutter Renderer
```

---

# Playback Compiler

Produces

```text
Frames

Needle Position

Thread Events

Camera Events

Timeline

HUD Events

Statistics
```

---

# Export Flow

Export begins with Stitch IR.

Never Geometry.

```text
Stitch IR

↓

Machine Compiler

↓

Machine IR

↓

Encoder

↓

DST

PES

JEF

VP3

EXP

HUS
```

---

# Machine Compiler

Responsibilities

- Thread mapping
- Hoop validation
- Machine limits
- Needle allocation
- Stops
- Trims
- Jump optimization

---

# Save Flow

Saving is independent from editing.

```text
Document

↓

Serializer

↓

Storage Engine

↓

Validation

↓

Checksums

↓

Atomic Write

↓

Filesystem
```

---

# Autosave Flow

```text
Command Executed

↓

Recovery Coordinator

↓

Checkpoint

↓

Autosave

↓

Recovery Database
```

Autosave never blocks editing.

---

# Recovery Flow

```text
Crash

↓

Recovery Journal

↓

Restart

↓

Recovery Scan

↓

Recovery Center

↓

Restore

↓

Validation

↓

Project
```

---

# Plugin Flow

Plugins communicate only through APIs.

```text
Plugin

↓

Plugin Runtime

↓

Plugin API

↓

Commands

↓

Document

↓

Events

↓

Plugin Callback
```

Plugins never modify runtime state directly.

---

# AI Flow

AI is another client.

```text
Prompt

↓

Context Builder

↓

Model

↓

Tool Calls

↓

Commands

↓

Command Bus

↓

Document

↓

Events
```

AI never edits memory directly.

---

# Validation Flow

Validation occurs throughout the system.

```text
Command

↓

Validation

↓

Business Rules

↓

Document

↓

Post Validation

↓

Events
```

Validation is layered.

---

# Event Flow

Commands produce Events.

```text
Command

↓

Document Mutation

↓

Events

↓

Canvas

History

Simulation

Plugins

Autosave

AI
```

Events are immutable.

---

# Storage Flow

```text
Document

↓

Serializer

↓

Storage API

↓

Storage Abstraction Layer

↓

Filesystem
```

Storage never knows Flutter.

---

# Rendering Flow

```text
Geometry IR

↓

Renderable Objects

↓

Flutter Renderer

↓

GPU
```

Simulation

```text
Playback IR

↓

Renderable Frames

↓

Flutter Renderer
```

Renderer owns no business logic.

---

# Thread Flow

```text
Thread Library

↓

Thread Selection

↓

Thread Reference

↓

Stitch IR

↓

Machine Compiler

↓

Export
```

---

# Machine Flow

```text
Machine Profile

↓

Validation

↓

Machine Compiler

↓

Machine IR

↓

Export
```

---

# Search Flow

```text
Search Query

↓

Project Index

↓

Metadata

↓

Results
```

No project loading required.

---

# Thumbnail Flow

```text
Project Saved

↓

Thumbnail Generator

↓

Preview

↓

Project Browser
```

Runs asynchronously.

---

# Clipboard Flow

```text
Selection

↓

Clipboard IR

↓

Paste

↓

Commands

↓

Document
```

Clipboard uses its own temporary IR.

---

# Undo Flow

```text
Undo

↓

Command History

↓

Reverse Command

↓

Document

↓

Events
```

---

# Redo Flow

```text
Redo

↓

Command History

↓

Replay Command

↓

Document

↓

Events
```

---

# Collaboration Flow (Future)

```text
Commands

↓

Change Set

↓

Synchronization

↓

Remote

↓

Commands

↓

Document
```

The system synchronizes Commands—not project files.

---

# Multi-threading Flow

UI Thread

```text
Flutter

↓

Commands

↓

Events
```

Worker Threads

```text
Import

Digitizer

Simulation

Export

Validation

Storage

Recovery
```

UI never performs heavy computation.

---

# Memory Flow

```text
Disk

↓

Project Package

↓

Document

↓

IR

↓

Renderer

↓

GPU
```

Caches

```text
Playback Cache

Render Cache

Thumbnail Cache
```

may be discarded at any time.

---

# Error Flow

```text
Failure

↓

Domain Error

↓

Application Error

↓

UI Message

↓

Recovery
```

Errors never bypass recovery.

---

# Security Flow

Every external request follows

```text
User

Plugin

AI

↓

Security Gateway

↓

Permissions

↓

Command Bus

↓

Document
```

No subsystem bypasses security.

---

# Complete Lifecycle

```text
New Project

↓

Geometry

↓

Commands

↓

Document

↓

Digitizer

↓

Stitch IR

↓

Simulation

↓

Validation

↓

Machine IR

↓

Export

↓

Save

↓

Backup

↓

Close
```

---

# Data Ownership

| Data | Owner |
|--------|-------------------|
| Import IR | Import Package |
| Geometry IR | Geometry Package |
| Stitch IR | Digitizer Package |
| Playback IR | Simulation Package |
| Machine IR | Machine Package |
| Document | Project Package |
| Commands | Command Package |
| Events | Event Package |
| Storage | Storage Package |
| Recovery | Recovery Package |

No package modifies another package's data directly.

---

# Thread Safety

Every flow should be

- Immutable where possible
- Lock-minimized
- Message-driven
- Parallelizable
- Deterministic

---

# Architectural Constraints

1. UI never modifies the document directly.
2. Commands are the only mutation mechanism.
3. Events are immutable.
4. Every transformation between IRs is deterministic.
5. Geometry never depends on Machine IR.
6. Simulation never depends on Export.
7. Export never depends on Flutter.
8. Plugins communicate only through Commands, Events, and public APIs.
9. AI communicates through Tools and Commands.
10. Recovery is independent of Storage.
11. Every subsystem owns one domain.
12. Every pipeline is independently testable.

---

# Performance Targets

| Operation | Target |
|-----------|--------|
| Command Dispatch | < 1 ms |
| Event Dispatch | < 1 ms |
| Geometry Update | < 16 ms |
| Canvas Refresh | 60 FPS |
| Digitizer Compile | Background |
| Playback Compile | Background |
| Export | < 500 ms |
| Autosave | Non-blocking |

---

# Acceptance Criteria

The system data flow is complete when

- Every subsystem communicates through documented pipelines.
- Commands are the only mutation path.
- Events are immutable.
- IR transitions are deterministic.
- All major workflows are independently testable.
- Flutter remains presentation-only.
- Rust remains the authoritative source of truth.
- The architecture supports plugins, AI, recovery, and future collaboration without introducing alternative mutation paths.
