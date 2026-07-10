# Architecture
## ARCH-006 Project Format

**Document ID:** ARCH-006  
**Title:** Project Format (.embproj)  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Platform Storage Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-003 Command System
ARCH-005 Document Model
FR-1800 Local Storage
FR-1900 Recovery
```

---

# Purpose

This document defines the official project format used by Sewlio Studio.

The project format is responsible for

- Project portability
- Version compatibility
- Recovery
- Backups
- Large project support
- Future collaboration
- Incremental saving
- Asset management

The project format is the canonical editable representation of a Sewlio Studio project.

Machine, loom, RIP, and file exports are generated artifacts.

---

# Design Philosophy

The project is **not** a single binary file.

Instead, it is a self-contained workspace.

Think of it like

- Figma File
- Unreal Project
- Blender Project
- Xcode Project

rather than

- PSD
- DOCX
- ZIP archive

---

# Design Goals

The project format shall

- Be portable
- Be deterministic
- Be versioned
- Be recoverable
- Support incremental saves
- Support partial loading
- Scale to very large projects
- Support future synchronization

---

# Project Extension

Official extension

```text
.embproj
```

---

# Package Layout

```text
project.embproj/
│
├── manifest.json
├── metadata.json
├── project.db
├── commands.db
│
├── assets/
│   ├── images/
│   ├── vectors/
│   ├── fonts/
│   ├── fabrics/
│   └── custom/
│
├── previews/
│   ├── thumbnail.webp
│   ├── preview.webp
│   └── simulation.webp
│
├── exports/
│
├── cache/
│   ├── render/
│   ├── simulation/
│   └── optimization/
│
├── recovery/
│   ├── autosaves/
│   ├── checkpoints/
│   ├── journals/
│   └── snapshots/
│
├── backups/
│
└── logs/
```

Every directory has a clearly defined purpose.

---

# Why a Directory Package?

Advantages

- Partial loading
- Faster saves
- Faster backups
- Easier synchronization
- Easier recovery
- Easier inspection
- Less corruption risk

---

# Package Rules

Every project

- has exactly one manifest
- has exactly one metadata file
- has exactly one project database
- has exactly one command database

Everything else is optional.

---

# Manifest

Purpose

Defines the package.

Always loaded first.

---

## Example

```json
{
  "projectId": "...",
  "projectType": "embroidery",
  "schemaVersion": "1.0.0",
  "applicationVersion": "1.0.0",
  "databaseVersion": "1.0.0",
  "createdAt": "...",
  "modifiedAt": "...",
  "checksum": "...",
  "packageVersion": 1
}
```

---

## Manifest Responsibilities

Contains

- Project UUID
- Project Type
- Schema version
- Package version
- Database version
- Checksum
- Creation date
- Modification date

Never contains

- Geometry
- Stitches
- Weave plans
- Print rasters
- Assets

---

# Metadata

Metadata exists for the Project Browser.

Should load without opening the project database.

Contains

```text
Name

Description

Author

Company

Thumbnail

Machine

Thread Library

Tags

Statistics

Last Opened

Favorite

Color
```

---

# Project Database

File

```text
project.db
```

Future implementation

libSQL / Turso.

Contains

- Geometry Domain
- Embroidery Domain
- Thread Domain
- Machine Domain
- Assets metadata
- Workspace references
- Statistics

---

# Why libSQL / Turso?

Compared to SQLite

Advantages

- SQLite compatibility
- Better replication support
- Modern architecture
- Strong Rust ecosystem
- Future cloud sync path
- Better incremental synchronization

The architecture remains database-agnostic.

---

# Command Database

Separate database

```text
commands.db
```

Contains

```text
Commands

Transactions

Undo

Redo

Command Metadata

Audit

History
```

Never mixed with project data.

---

# Why Separate Commands?

Allows

- Faster undo
- Replay
- Recovery
- Collaboration
- Time travel
- Smaller project mutations

---

# Assets

Assets are stored separately.

```text
assets/
```

Contains

Images

SVG

Fonts

Fabric Textures

Brushes

Imported Resources

Future

3D models

---

Assets referenced by UUID.

Never duplicated.

---

# Preview Directory

```text
previews/
```

Contains

Thumbnail

Preview

Simulation Preview

Export Preview

Used by

Project Browser

File Explorer

Finder

Windows Explorer

---

# Cache Directory

Disposable.

```text
cache/
```

Contains

Render Cache

Simulation Cache

Optimization Cache

Validation Cache

Cache may be deleted at any time.

---

# Recovery Directory

```text
recovery/
```

Contains

Autosaves

Snapshots

Checkpoints

Journals

Recovery Metadata

Independent from the project database.

---

# Backups

```text
backups/
```

Stores

Versioned backups

Compressed snapshots

Rollback points

Never required to open the project.

---

# Logs

```text
logs/
```

Optional.

Contains

Repair logs

Migration logs

Crash logs

Diagnostics

Useful for debugging.

---

# Package Identity

Every project has

```text
Project UUID
```

Never changes.

Used for

History

Recovery

Synchronization

Future collaboration

---

# Schema Versioning

Every package has

```text
Package Version

Schema Version

Database Version

Manifest Version
```

Each evolves independently.

---

# Migration

Migration workflow

```text
Old Package

↓

Validation

↓

Backup

↓

Migration

↓

Validation

↓

Open
```

Migration never modifies the original without backup.

---

# Checksums

Checksums exist for

Manifest

Database

Commands

Assets

Recovery

Preview

Detects corruption early.

---

# Atomic Saves

Saving never overwrites the original.

Workflow

```text
Write Temporary

↓

Validate

↓

Checksum

↓

Swap

↓

Cleanup
```

Power failures should not corrupt projects.

---

# Incremental Saves

Only modified domains are written.

Example

Geometry changed

↓

Only geometry tables updated.

Not

Entire project.

---

# Compression

Compressed

Backups

Large assets

Snapshots

Preview images

Not compressed

Database

Manifest

Metadata

Command database

---

# Asset References

Assets identified by UUID.

```text
Geometry

↓

Image UUID

↓

Asset Database

↓

Image File
```

Allows deduplication.

---

# Missing Assets

On open

Missing assets detected.

User may

Locate

Replace

Ignore

Remove

Project still opens where possible.

---

# External Assets

Future

Optionally support linked assets.

```text
Image

↓

External File

↓

Watcher

↓

Reload
```

---

# Package Lock

Future

```text
project.lock
```

Prevents simultaneous writes.

Supports future collaboration.

---

# Workspace Data

Workspace state stored separately.

Examples

```text
Camera

Zoom

Selection

Panels

Tool

Layout
```

May be

Shared

User-specific

Machine-specific

depending on future configuration.

---

# Export Directory

Generated exports.

Examples

```text
DST

PES

JEF

VP3

PDF

PNG
```

May be automatically cleaned.

Not authoritative.

---

# Storage Abstraction

Application never accesses files directly.

```text
Project Service

↓

Storage API

↓

Storage Abstraction Layer

↓

Filesystem
```

Supports

Desktop

Mobile

Web

Cloud

without changing business logic.

---

# Large Project Strategy

Large projects support

Partial loading

Lazy assets

Incremental saves

Background indexing

Streaming previews

---

# Recovery Integration

Recovery uses

Commands

Snapshots

Checkpoints

Journal

Recovery never depends on exports.

---

# Security

Manifest validated.

Database validated.

Checksums verified.

Plugin data isolated.

Secrets never stored in project.

---

# Thread Safety

Read

Concurrent.

Write

Single writer.

Package modifications occur through transactions.

---

# Performance Targets

Project Open

<1 second

Small projects

---

Large Project

<5 seconds

---

Incremental Save

<100 ms

---

Thumbnail Load

<50 ms

---

Metadata Load

<20 ms

---

# Testing

Every package version requires

- Open tests
- Save tests
- Migration tests
- Corruption tests
- Recovery tests
- Compatibility tests
- Performance tests

---

# AI Agent Rules

No package may

Write arbitrary files

Modify project layout

Store undocumented data

Change manifest schema

without an ADR.

---

# Architectural Constraints

1. `.embproj` is the only editable project format.
2. Machine files are generated outputs.
3. The project database is authoritative.
4. Commands are stored separately from business data.
5. Recovery is independent.
6. Cache is disposable.
7. Assets are UUID referenced.
8. Manifest is always loaded first.
9. Metadata loads without opening the database.
10. Every package is versioned.
11. Package layout is forward compatible.
12. Storage implementation is hidden behind the Storage API.
13. Schema changes require migrations.
14. Breaking changes require an ADR.
15. The package format must remain platform independent.

---

# Future Evolution

Future additions may include

```text
cloud/

sync/

collaboration/

packages/

plugin-data/

analytics/

manufacturing/

version-control/
```

without changing the existing package layout.

---

# Acceptance Criteria

The Project Format is complete when

✓ Projects are portable.

✓ Manifest validates package integrity.

✓ Metadata loads independently.

✓ Business data is isolated from command history.

✓ Incremental saves are supported.

✓ Recovery is independent.

✓ Atomic saves prevent corruption.

✓ Package versioning supports migration.

✓ Assets are UUID referenced.

✓ Large projects remain performant.

✓ The format is platform independent.

✓ Future cloud synchronization can be added without redesigning the package.
