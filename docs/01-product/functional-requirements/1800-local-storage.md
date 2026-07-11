# Functional Requirements
## FR-1800 Local Storage & Persistence

**Document ID:** FR-1800  
**Title:** Local Storage & Persistence  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (Foundation)

**Owner:** Platform Storage Team

**Primary Packages**

```text
Flutter

storage/
project_browser/
preferences/
recovery/

↓

Rust

storage/
project/
serialization/
assets/
database/
manifest/
migration/
compression/
checksum/
```

---

# Purpose

The Local Storage System provides the persistence layer for the entire application.

Sewlio Studio follows a **Local-First Architecture**.

Every project, asset, history entry, thumbnail, export, and recovery file exists locally first.

Cloud synchronization is an optional layer built on top of local storage.

---

# Objectives

The Storage System shall

- Store projects safely
- Support very large projects
- Enable crash recovery
- Support incremental saving
- Support version migration
- Enable offline editing
- Preserve project integrity
- Be portable across platforms

---

# Design Principles

## Local First

Projects belong to the user.

No cloud dependency.

---

## Portable

Projects remain ordinary files.

Users can

Copy

Move

Rename

Archive

Backup

using standard file managers.

---

## Recoverable

Data loss should be extremely unlikely.

---

## Versioned

Every persisted object has a schema version.

---

## Deterministic

Loading then immediately saving a project should never change the logical document.

---

# Storage Architecture

```text
Application

↓

Project Service

↓

Storage Engine

↓

Persistence Layer

↓

Filesystem
```

Storage is completely independent from UI.

---

# Project Package

Projects use the

```
.swl
```

extension.

Internally a project is a package.

```text
logo.swl/

manifest.json

metadata.json

project.turso

command-log.turso

assets/

previews/

exports/

cache/

backups/

recovery/
```

Platforms that do not support directory packages may expose them as folders.

---

# Project Manifest

Every project contains

```text
Project ID

Schema Version

Application Version

Created

Modified

Checksum

Storage Version

Database Version

Asset Version

Compression Version
```

Manifest is always loaded first.

---

# Metadata

Metadata stored separately from project database.

Contains

```text
Project Name

Description

Thumbnail

Tags

Machine Profile

Thread Library

Statistics

Created Date

Modified Date
```

Allows Project Browser to load quickly.

---

# Database

Project data stored in

```
project.turso
```

Contains

Geometry IR

Stitch IR

Machine Settings

Thread References

Workspace

User Metadata

Project Settings

---

Database is transactional.

---

# Command Log

Every command stored separately.

```
command-log.turso
```

Contains

Command

Timestamp

Author

Version

Checksum

---

Supports

Undo

Redo

Recovery

History

Future Collaboration

---

# Assets

Project assets stored separately.

Examples

SVG

PNG

JPEG

Reference Photos

Fonts

Custom Brushes

Fabric Textures

---

Assets referenced using IDs.

---

# Cache

Contains

Simulation Cache

Rendered Cache

Thumbnail Cache

Optimization Cache

---

Cache may be deleted at any time.

Application rebuilds automatically.

---

# Recovery

Contains

Autosaves

Snapshots

Recovery Metadata

---

Recovery independent from project database.

---

# Backups

Automatic backups stored separately.

Contains

Timestamp

Version

Checksum

Reason

---

Backups compressed.

---

# FR-1801

## Create Project

Priority

Critical

---

Creating project

↓

Generate UUID

↓

Create Package

↓

Create Manifest

↓

Initialize Database

↓

Initialize Command Log

↓

Generate Thumbnail

---

Acceptance Criteria

Project immediately recoverable.

---

# FR-1802

## Open Project

Priority

Critical

---

Open sequence

Manifest

↓

Metadata

↓

Validation

↓

Migration

↓

Database

↓

Workspace

↓

Assets

---

Validation occurs before loading.

---

# FR-1803

## Save Project

Priority

Critical

---

Saving performs

Validation

↓

Transaction

↓

Write Database

↓

Update Metadata

↓

Update Manifest

↓

Update Thumbnail

↓

Commit

---

Atomic operation.

---

# FR-1804

## Incremental Save

Priority

Critical

---

Only modified data written.

Avoid rewriting entire project.

---

Acceptance Criteria

Small edits complete quickly.

---

# FR-1805

## Autosave

Priority

Critical

---

Supports

Time-based

Idle-based

Command-count

Manual

---

Default

Every 2 minutes

Configurable.

---

# FR-1806

## Atomic Writes

Priority

Critical

---

Never partially overwrite files.

Workflow

Temporary Write

↓

Validation

↓

Replace Original

---

Power failure must not corrupt projects.

---

# FR-1807

## Migration

Priority

Critical

---

Older projects

↓

Migration

↓

Backup

↓

Validation

↓

Open

---

Migration reversible where practical.

---

# FR-1808

## Compression

Priority

Medium

---

Compress

Assets

Backups

Large previews

Exports (optional)

---

Database remains uncompressed.

---

# FR-1809

## Checksums

Priority

Critical

---

Verify

Manifest

Database

Assets

Command Log

Preview

---

Corruption detected early.

---

# FR-1810

## External File Detection

Priority

Critical

---

Detect

Moved

Deleted

Renamed

Modified

---

Prompt user appropriately.

---

# FR-1811

## Portable Storage

Priority

Critical

---

Projects support

Internal Storage

External SSD

USB

NAS

Network Shares

Cloud Drives

---

No platform lock-in.

---

# FR-1812

## Temporary Files

Priority

Medium

---

Temporary files stored separately.

Automatically cleaned.

---

Never required for recovery.

---

# FR-1813

## Preferences Storage

Priority

Critical

---

Application preferences stored separately from projects.

Project remains portable.

---

# FR-1814

## Thumbnail Storage

Priority

Critical

---

Thumbnail generated automatically.

Updated

Save

Export

Manual Refresh

---

Used by Project Browser.

---

# FR-1815

## Project Locking

Priority

Future

---

Detect

Project already open

↓

Warn user

↓

Read-only option

---

Future collaboration integration.

---

# FR-1816

## Storage Validation

Priority

Critical

---

Validate

Manifest

Schema

Database

Assets

Workspace

Checksums

Recovery

---

Validation levels

Healthy

Warning

Recoverable

Corrupt

---

# FR-1817

## Backup Management

Priority

Medium

---

Supports

Automatic Rotation

Maximum Count

Maximum Age

Manual Backup

Restore

---

# FR-1818

## Storage Statistics

Priority

Medium

---

Displays

Project Size

Asset Size

Cache Size

Recovery Size

Backup Size

Compression Ratio

---

# FR-1819

## Recovery Detection

Priority

Critical

---

Startup checks

Recovery Files

↓

Recovery Dialog

↓

Restore

↓

Discard

---

Recovery never automatic.

---

# FR-1820

## Export Storage

Priority

Medium

---

Exports stored separately from project.

Optional

Keep Export History

---

Future

Export Catalog.

---

# Serialization

Supports

JSON

Binary

Structured Metadata

Versioned Records

---

Every serialized object contains version information.

---

# Storage Locations

Desktop

User Documents

Custom Folder

---

Tablet

Files App

App Sandbox

External Storage

---

Phone

Files App

Scoped Storage

---

Web (Future)

IndexedDB

OPFS

---

# Performance Targets

Project Open

<1 second

Small Project

---

Large Project

<5 seconds

---

Incremental Save

<100 ms

---

Autosave

Background

---

Recovery Detection

<200 ms

---

# Accessibility

Storage dialogs support

Keyboard

Touch

Screen Readers

High Contrast

---

Recovery dialogs written in plain language.

---

# AI Agent Rules

Storage package owns

Persistence

Serialization

Migration

Checksums

Recovery

Atomic writes

---

Storage package never owns

Geometry

Digitizer

Simulation

Export

Business Logic

---

Every subsystem persists through Storage.

---

# Testing

Unit

Serialization

Migration

Checksums

Compression

Validation

Recovery

---

Integration

Create

Save

Load

Move

Rename

Recover

Backup

---

Stress

100 GB projects

Millions of stitches

Thousands of assets

Large command history

---

Regression

Older projects

↓

Migration

↓

Save

↓

Reload

---

# Acceptance Criteria

Local Storage System is complete when

✓ Projects remain portable

✓ Incremental saves implemented

✓ Atomic writes prevent corruption

✓ Autosave operational

✓ Recovery implemented

✓ Migration supported

✓ Checksums verified

✓ Performance targets achieved

✓ Tests pass

---

# Future Enhancements

- Cloud synchronization
- Differential project backups
- Project deduplication
- Content-addressable asset storage
- End-to-end encrypted storage
- Distributed project storage
- Background optimization
- Storage analytics
- Snapshot pruning
- Incremental synchronization
