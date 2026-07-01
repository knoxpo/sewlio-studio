# Architecture
## ARCH-005 Document Model

**Document ID:** ARCH-005  
**Title:** Document Model  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Core Platform Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-004 Event System
ARCH-006 Project Format
```

---

# Purpose

The Document Model defines the authoritative in-memory representation of an embroidery project.

It is the heart of the application.

Everything else interacts with the Document Model.

Examples

- Commands
- Events
- Geometry
- Digitizer
- Simulation
- Machine
- Export
- Plugins
- AI
- Recovery
- Storage

The Document Model is independent from:

- Flutter
- Storage
- Rendering
- Export formats
- Platform

---

# Design Philosophy

The Document is a living object graph.

It represents the editable project.

The document is **not**:

- a database
- a file
- a renderer
- a simulation
- an export

Those are separate concerns.

---

# Core Principles

## Single Source of Truth

Only one Document exists.

Everything derives from it.

---

## Domain Driven

The document is organized around business domains.

Not UI.

Not storage.

Not rendering.

---

## Immutable Commands

The Document never changes directly.

Commands mutate the Document.

---

## Event Driven

Changes publish Events.

---

## Platform Independent

The Document knows nothing about Flutter.

---

## Machine Independent

The Document never contains

DST

PES

JEF

VP3

Machine bytes.

---

## Renderer Independent

The Document contains no GPU resources.

---

## AI Independent

AI never owns Document state.

---

# High-Level Structure

```text
Workspace
        │
        ▼
Project
        │
 ┌──────┼────────────────────────────────────────────┐
 ▼      ▼        ▼        ▼        ▼        ▼         ▼
Meta  Geometry Thread Machine Assets History Statistics
        │
        ▼
 Embroidery Domain
        │
        ▼
Recovery
```

---

# Complete Document

```text
Document
│
├── Metadata
├── Workspace
├── Geometry Domain
├── Embroidery Domain
├── Thread Domain
├── Machine Domain
├── Asset Domain
├── History Domain
├── Recovery Domain
├── Statistics Domain
├── Plugin Domain
└── Extension Data
```

Every subsystem owns exactly one domain.

---

# Metadata Domain

Contains project identity.

```text
Project ID

Name

Description

Author

Company

Version

Created

Modified

Schema Version

Thumbnail

Tags
```

Metadata never contains geometry.

---

# Workspace Domain

Workspace represents editor state.

```text
Camera

Zoom

Viewport

Grid

Guides

Selection

Panels

Open Tabs

Inspector

Theme Overrides
```

Workspace is not required to export embroidery.

---

# Geometry Domain

Owns editable artwork.

```text
Geometry Domain

↓

Layers

↓

Groups

↓

Entities

↓

Components
```

---

Contains

- Layers
- Groups
- Paths
- Shapes
- Text
- Images
- Constraints
- Guides

---

Does NOT contain

- stitches
- playback
- machine commands

---

# Embroidery Domain

Owns embroidery information.

```text
Embroidery Objects

↓

Regions

↓

Digitizer Metadata

↓

Generated Stitch IR

↓

Validation
```

---

Contains

Running Stitch

Fill

Satin

Underlay

Density

Angle

Pull Compensation

Tie In

Tie Off

Thread Assignment

---

# Thread Domain

Contains

```text
Project Palette

Thread Library

Thread Mapping

Assignments

Statistics
```

---

Objects reference Thread IDs.

Never RGB values directly.

---

# Machine Domain

Contains

```text
Machine Profile

Hoop

Capabilities

Constraints

Export Defaults

Warnings
```

Machine Domain never stores binary exports.

---

# Asset Domain

Contains

```text
Reference Images

Imported SVG

Fonts

Fabric Textures

Icons

Brushes

Linked Assets
```

Assets are referenced.

Not duplicated.

---

# History Domain

Contains

```text
Undo Stack

Redo Stack

Transactions

Command History

Command Metadata
```

History never stores document snapshots.

---

# Recovery Domain

Contains

```text
Autosave Info

Checkpoint References

Recovery Journal

Snapshot Metadata
```

Recovery data is lightweight.

Actual recovery files are stored by the Storage subsystem.

---

# Statistics Domain

Computed only.

Contains

```text
Object Count

Stitch Count

Jump Count

Thread Count

Estimated Time

Estimated Length

Bounding Box

Warnings
```

Never edited manually.

---

# Plugin Domain

Contains

```text
Plugin Metadata

Plugin Components

Plugin Storage References

Plugin Settings
```

Plugins never modify core domains directly.

---

# Entity Model

The Document follows a component-based architecture.

Every editable object is an Entity.

```text
Entity

↓

Components
```

Example

```text
Rectangle Entity

↓

Geometry Component

Appearance Component

Metadata Component

Selection Component
```

---

Embroidery Example

```text
Embroidery Entity

↓

Geometry Component

Stitch Component

Thread Component

Metadata Component

Validation Component
```

---

# Why Components?

Avoids deep inheritance.

Instead of

```text
Object

↓

Rectangle

↓

EmbroideryRectangle

↓

RunningRectangle

↓

FillRectangle
```

Use

```text
Entity

↓

Components
```

Advantages

- Extensible
- Plugin friendly
- AI friendly
- Easier serialization
- Better migrations

---

# Component Types

## Geometry

```text
Path

Bezier

Transform

Bounds
```

---

## Appearance

```text
Fill

Stroke

Opacity

Visibility
```

---

## Embroidery

```text
Stitch Type

Density

Angle

Compensation

Underlay
```

---

## Thread

```text
Thread ID

Overrides

Mappings
```

---

## Metadata

```text
Name

Notes

Created

Modified

Owner
```

---

## Validation

```text
Warnings

Errors

Quality Flags
```

---

## Plugin

Plugin-defined data.

---

# Entity IDs

Every entity has

```text
UUID
```

Never

Indexes.

Never

Pointers.

References always use IDs.

---

# References

Example

```text
Embroidery Object

↓

Geometry Entity ID

↓

Thread ID

↓

Machine ID
```

No cyclic ownership.

---

# Ownership Rules

Geometry owns

Geometry Components.

Embroidery owns

Embroidery Components.

Thread owns

Thread Components.

Machine owns

Machine Components.

Nobody owns another domain.

---

# Lifetime

```text
Create

↓

Modify

↓

Validate

↓

History

↓

Delete

↓

Garbage Collection
```

Deletion never invalidates history.

---

# Selection

Selection belongs to Workspace.

Never Geometry.

---

# Clipboard

Clipboard uses temporary entities.

Never references live entities.

---

# Layers

Layers own ordering only.

Layers do not own geometry.

```text
Layer

↓

Entity IDs
```

---

# Groups

Groups are entities.

Groups reference children.

No deep ownership.

---

# Constraints

Constraints stored separately.

```text
Constraint

↓

Entity IDs
```

Supports

Alignment

Distribution

Locking

Future parametric editing.

---

# Derived Data

Never stored permanently.

Examples

Bounding Boxes

Simulation Cache

Machine Validation

Statistics

Playback

Generated lazily.

---

# Dirty Flags

Every domain tracks

```text
Dirty

Clean
```

Examples

Geometry Dirty

↓

Digitizer Required

↓

Playback Dirty

↓

Export Dirty

Allows incremental updates.

---

# Dependency Graph

```text
Geometry

↓

Embroidery

↓

Stitch IR

├───────────┐

▼           ▼

Playback   Machine
```

Geometry changes invalidate downstream caches only.

---

# Object Lifecycle

```text
Import

↓

Entity

↓

Edit

↓

Validate

↓

Digitize

↓

Export

↓

Archive
```

---

# Serialization

The Document never serializes itself.

Instead

```text
Document

↓

Serializer

↓

Storage
```

Storage owns persistence.

---

# Thread Safety

Reads

Concurrent.

Writes

Single writer.

Document mutation always occurs through Commands.

---

# Memory Strategy

Long-lived

Metadata

Geometry

Embroidery

Threads

Machine

Assets

History

---

Disposable

Playback

Simulation Cache

Render Cache

Validation Cache

---

# Performance Targets

Open Project

<1 s

Selection

Immediate

Entity Lookup

O(1)

Reference Lookup

O(1)

Dirty Propagation

Incremental

Large Projects

Millions of stitches

Thousands of entities

---

# Testing

Each domain requires

- Unit Tests
- Validation Tests
- Serialization Tests
- Migration Tests
- Performance Tests

Cross-domain integration tests verify reference integrity.

---

# AI Rules

AI may

Read Document

Generate Commands

Read Components

Query Metadata

---

AI may not

Modify Components directly

Bypass Commands

Create invalid references

---

# Plugin Rules

Plugins may

Register Components

Register Metadata

Register Validation

Register Commands

---

Plugins may not

Modify existing core components

Break ownership rules

---

# Architectural Constraints

1. The Document is the single source of truth.
2. Every entity has a stable UUID.
3. Components belong to exactly one domain.
4. Domains never own other domains.
5. Geometry never stores stitches.
6. Machine data never stores geometry.
7. Selection belongs to Workspace.
8. History stores Commands, not snapshots.
9. Recovery stores metadata, not business objects.
10. Derived data is regenerated.
11. Rendering data never enters the Document.
12. Storage never owns the Document.
13. Flutter never owns the Document.
14. Plugins extend through Components.
15. AI interacts through Commands only.

---

# Future Enhancements

Future domains may include

```text
Fabric Domain

Material Domain

Manufacturing Domain

Collaboration Domain

Cloud Sync Domain

Version Control Domain

AI Context Domain
```

These can be added without changing the existing document architecture.

---

# Acceptance Criteria

The Document Model is complete when

✓ Every editable object is represented as an Entity.

✓ Business data is organized into independent domains.

✓ Components replace inheritance.

✓ References use stable UUIDs.

✓ Commands are the only mutation path.

✓ Events notify all downstream systems.

✓ Rendering, storage, export, and simulation remain independent of the Document.

✓ Plugins can safely extend the model through new components.

✓ AI interacts only through Commands and public APIs.

✓ The model scales to large projects while preserving determinism, portability, and testability.
