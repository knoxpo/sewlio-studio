# Functional Requirements
## FR-000 Product Lifecycle

**Document ID:** FR-000  
**Title:** Product Lifecycle  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Project Engine Team

**Related Documents**

- PRD
- User Flows
- Use Cases
- Project Format
- Storage Architecture
- System Architecture

---

# Purpose

This document defines the complete lifecycle of an embroidery project.

Every project created inside Sewlio Studio follows this lifecycle.

```
Create

↓

Edit

↓

Save

↓

Close

↓

Open

↓

Modify

↓

Export

↓

Archive

↓

Recover (if needed)

↓

Delete
```

The lifecycle applies identically across:

- Desktop
- Web
- iPad
- Android Tablet

Only platform-specific file dialogs may differ.

---

# Goals

The project lifecycle must guarantee:

- User owns all data
- Offline operation
- Recoverability
- Deterministic saves
- Safe migration
- Version compatibility
- Crash recovery

---

# Lifecycle States

```
Not Created

↓

Created

↓

Opened

↓

Modified

↓

Saving

↓

Saved

↓

Exported

↓

Archived

↓

Deleted
```

Projects may return from Saved → Modified multiple times.

---

# Project Identity

Every project has:

```text
Project ID (UUID)

Project Name

Creation Date

Modified Date

Version

Engine Version

Project Format Version

Machine Profile

Thumbnail

Author (optional)

Description

Tags
```

Project IDs never change.

---

# Native Project Format

Editable projects are always stored as

```
project.swl
```

Machine formats are never editable.

```
.swl

↓

DST

PES

JEF

VP3
```

---

# Project Package

```
project.swl/

project.db

metadata.json

assets/

exports/

preview/

history/

thumbnails/

temp/
```

---

# Metadata

Metadata should remain lightweight.

Example

```json
{
  "id": "...",
  "name": "Logo",
  "createdAt": "...",
  "modifiedAt": "...",
  "projectVersion": 1,
  "engineVersion": "...",
  "machineProfile": "...",
  "thumbnail": "..."
}
```

Metadata must be readable without loading the full project.

---

# Project Versioning

Every project stores

Project Version

Engine Version

Schema Version

Migration Version

Example

```
Project Version

1.0

↓

Engine Version

1.2.4

↓

Schema

4
```

---

# Functional Requirements

---

## FR-001

### Create Project

Priority

Critical

---

Description

The system shall allow users to create a new embroidery project.

---

Inputs

Project Name

Optional Description

Machine Profile

Hoop Size

Thread Library

---

Workflow

```
New Project

↓

Configure

↓

Initialize Database

↓

Initialize Layers

↓

Open Workspace
```

---

Outputs

New project

Initialized database

Default layer

History initialized

Viewport initialized

---

Acceptance Criteria

✓ Project created

✓ Unique ID assigned

✓ Project saved

✓ Undo available

✓ Canvas opens

---

## FR-002

### Open Project

Priority

Critical

---

Description

The system shall open an existing project.

---

Workflow

```
Open

↓

Validate

↓

Migration

↓

Load

↓

Editor
```

---

Validation

Project exists

Version supported

Database valid

Assets readable

Metadata valid

---

Acceptance Criteria

✓ Loads correctly

✓ Restores viewport

✓ Restores layers

✓ Restores preferences

✓ Restores machine profile

---

## FR-003

### Save Project

Priority

Critical

---

Description

Persist all project data.

---

Save includes

Geometry

Stitches

History

Layers

Viewport

Settings

Assets

Thread mappings

Machine profile

---

Behavior

Atomic save.

Never partially overwrite project.

---

Acceptance Criteria

✓ Save succeeds

✓ Save indicator updated

✓ Project reloads correctly

---

## FR-004

### Save As

Priority

Critical

---

Description

Duplicate project.

---

Behavior

New Project ID

Same content

Same assets

Independent history

---

Acceptance Criteria

Original untouched.

Duplicate editable.

---

## FR-005

### Autosave

Priority

Critical

---

Autosave triggers

Time interval

Idle period

Before export

Before migration

Application backgrounding

---

Requirements

Non-blocking.

Silent.

Recoverable.

---

Acceptance Criteria

Autosave never interrupts workflow.

---

## FR-006

### Close Project

Priority

Critical

---

Workflow

```
Close

↓

Modified?

↓

Save?

↓

Close
```

---

User options

Save

Don't Save

Cancel

---

Acceptance Criteria

Unsaved work never lost silently.

---

## FR-007

### Reopen Project

Priority

Critical

---

Description

Reopen previously saved project.

---

Requirements

State restored.

No corruption.

---

Acceptance Criteria

Project identical after reload.

---

## FR-008

### Recover Project

Priority

Critical

---

Trigger

Crash

Power loss

Forced shutdown

---

Workflow

```
Launch

↓

Recovery Found

↓

Recover

↓

Workspace
```

---

Recovered

Project

Viewport

Layers

Selection (where feasible)

Undo history

---

Acceptance Criteria

Recovery offered.

Recovery safe.

Original preserved.

---

## FR-009

### Archive Project

Priority

Medium

---

Archive means

Read-only state

Still editable after restore

Not deleted

---

Acceptance Criteria

Archived projects hidden by default.

---

## FR-010

### Delete Project

Priority

Medium

---

Delete removes

Project package

Thumbnail

Temporary files

Cache

---

Confirmation required.

---

Acceptance Criteria

Deletion reversible via Trash where platform supports it.

---

# Project Validation

Project should validate

Metadata

Database

Assets

Thread libraries

Machine profile

History

Schema

---

Validation Result

```
Healthy

↓

Warning

↓

Recoverable

↓

Corrupt
```

---

# Migration

When opening an older project

```
Old Version

↓

Migration

↓

Backup

↓

Upgrade

↓

Open
```

Migration rules

Never overwrite original before successful migration.

---

Acceptance Criteria

Migration logged.

Rollback possible.

---

# Temporary Files

Temporary files

Autosave

Export cache

Simulation cache

Preview cache

---

Temporary files should never become project source.

---

# Recent Projects

Store

Path

Thumbnail

Last opened

Modified date

Pinned status

---

Requirements

Recent list survives restart.

Broken paths identified.

---

# Thumbnails

Every project should maintain

Preview image

Project icon

Modified date

---

Thumbnail generation

Background

After save

After export

Manual refresh

---

# Project Locking

Future

Prevent concurrent writes.

Example

Desktop

+

Tablet

Same file

↓

Warning

---

# File Conflicts

Future

Detect

Conflict

↓

User decides

Keep local

Keep newer

Duplicate

---

# Storage Locations

Supported

Local Folder

iCloud Drive

Google Drive

Dropbox

OneDrive

---

Application never depends on provider APIs.

Providers synchronize files.

Application edits files.

---

# Imported Assets

Assets stored inside project

Supported

PNG

JPEG

SVG

Future

PDF

AI

---

Assets should remain portable.

Never reference absolute paths.

---

# Export Management

Exports stored

```
exports/

design.dst

design.pes
```

Exports

Optional.

User configurable.

---

# Backup

Future

Automatic versions

Daily snapshots

Manual snapshots

Restore points

---

# Error Handling

Project missing

↓

Readable message

↓

Choose another project

---

Database corrupted

↓

Recovery attempt

↓

Backup

↓

Continue

---

Missing assets

↓

Warning

↓

Continue

---

Migration failure

↓

Restore original

↓

Log error

---

# Performance Targets

Create Project

<100 ms

Save

<500 ms

Open

<1 second (small project)

Autosave

Background

Thumbnail

<200 ms

---

# Security

Projects remain local.

No upload.

No telemetry.

No cloud dependency.

---

# AI Agent Rules

Agents modifying lifecycle code must:

Read:

Project Format

Storage

Architecture

Migration

Never modify

Project schema

without ADR approval.

---

# Testing Requirements

Unit Tests

Project creation

Save

Load

Recovery

Migration

Validation

Deletion

---

Integration Tests

Open large project

Crash recovery

Migration

Autosave

---

Regression Tests

Older project versions

Corrupted projects

Missing assets

Interrupted save

---

# Definition of Done

A lifecycle feature is complete when:

✓ Project creates correctly

✓ Project saves correctly

✓ Project opens correctly

✓ Autosave works

✓ Recovery works

✓ Migration works

✓ Validation passes

✓ Tests pass

✓ Documentation updated

✓ Architecture review approved

---

# Future Enhancements

- Project templates
- Workspace profiles
- Cloud synchronization
- Git-style project history
- Automatic conflict resolution
- Project encryption
- Team project ownership
- Incremental project storage
- Background project indexing
