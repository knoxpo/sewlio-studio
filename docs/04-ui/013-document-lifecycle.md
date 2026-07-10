# UI
## UI-013 Document Lifecycle

**Document ID:** UI-013  
**Title:** Document Lifecycle  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-010 Application Lifecycle
UI-011 Workspaces
UI-012 Home Workspace

UI-614 New Document Workflow
UI-600 Document Workflow
UI-601 Open & Save

ARCH-004 Document Model
ARCH-006 Command System
ARCH-008 State Management
ARCH-011 Background Tasks
```

---

# Purpose

This document defines how documents are created, opened, managed, edited, saved, and closed within Sewlio Studio.

The Document Lifecycle is independent of the Application Lifecycle and Workspace Lifecycle.

A document represents a Sewlio Studio project with a persistent Project Type. The MVP Project Type is Embroidery.

A document always exists inside a Document Session.

---

# Philosophy

A document should only exist when meaningful work exists.

The application never creates anonymous empty documents automatically.

Instead,

documents are intentionally created or opened by the user.

---

# Goals

The Document Lifecycle shall provide

- Predictable document management
- Multi-document editing
- Independent document sessions
- Reliable recovery
- Safe closing
- Clear separation from application state

---

# Definitions

## Document

A Document represents

- embroidery design
- metadata
- machine settings
- material settings
- project configuration

A Document is persistent.

---

## Document Session

A Document Session represents

a live editing session.

A session contains

```text
Document

Viewport

Selection

Undo History

Redo History

Tool State

Background Tasks

Validation State

Simulation Cache
```

Document Sessions are transient.

---

## Document Tab

A Document Tab is the visual representation of a Document Session.

Tabs belong to the Workspace.

Tabs never own document data.

---

# Lifecycle

```text
New Document

↓

Document Configuration

↓

Document Created

↓

Document Session Created

↓

Document Tab Created

↓

Editor Workspace

↓

Editing

↓

Saving

↓

Closing

↓

Session Destroyed

↓

Document Persisted
```

---

# Creating Documents

Documents are created only through

```text
New Project

Template

Import Workflow

Recovery Workflow
```

The application never creates a document automatically during startup.

---

# Opening Documents

A document may be opened from

- Recent Projects
- File Browser
- Drag & Drop
- Project Recovery
- Command Palette

Opening a document creates

- Document
- Document Session
- Document Tab

---

# Document Sessions

Each open document owns

```text
Selection

Viewport

Undo Stack

Redo Stack

Tool State

Background Jobs

Validation

Simulation Cache
```

Sessions are completely isolated.

---

# Multiple Documents

The application supports multiple simultaneous documents.

Example

```text
🏠 Home

Logo.esproj

Cap.esproj

Patch.esproj
```

Each document has

its own

- history
- viewport
- zoom
- active tool
- simulation state

---

# Active Document

Only one document is active at a time.

The active document receives

- keyboard shortcuts
- tool interactions
- menu commands
- canvas events

Switching tabs changes the active document.

---

# Dirty State

Documents become dirty whenever

persistent data changes.

Example

```text
Add Object

Delete Object

Move Object

Change Density

Rename Layer
```

The following do NOT dirty the document

- viewport movement
- zoom
- panel layout
- workspace switching
- selection

---

# Saving

Saving writes

persistent document data.

Saving does not store

- viewport
- selection
- temporary tool state

These belong to the session.

---

# Auto Save

The application periodically

creates recovery snapshots.

Recovery snapshots

are not project saves.

They exist only for crash recovery.

---

# Closing Documents

Closing a document

destroys

its Document Session.

If dirty,

the application prompts

```text
Save

Discard

Cancel
```

---

# Last Document Closed

When the final document is closed

the application returns

to the Home Workspace.

The application remains running.

---

# Document Tabs

Each document

has exactly one tab.

Example

```text
🏠 Home

Logo.esproj ●

Patch.esproj

Cap.esproj
```

Legend

```text
●

Unsaved Changes

×

Close

⚠

Warning

🔒

Read Only
```

---

# Reopening

Recently closed documents

may be reopened

using

```text
Recent Projects

Recent Documents

History

Command Palette
```

---

# Background Tasks

Each document owns

its own background tasks.

Examples

```text
Simulation

Import

Export

AI Analysis

Validation
```

Closing a document

cancels

or safely completes

its background tasks.

---

# Session Recovery

If the application crashes

the Document Session

is reconstructed from

```text
Recovery Snapshot

↓

Document Session

↓

Editor Workspace
```

Recovery never overwrites

the original document

without user confirmation.

---

# State Ownership

## Application

Owns

```text
Preferences

Workspaces

Themes

Recent Projects

Recovery List
```

---

## Workspace

Owns

```text
Panel Layout

Toolbar Layout

Window State

Docking
```

---

## Document

Owns

```text
Embroidery Data

Machine Profile

Material Profile

Thread Library

Metadata
```

---

## Session

Owns

```text
Viewport

Selection

Undo

Redo

Tool State

Simulation Cache
```

---

# Validation

Documents are validated

before

- export
- machine compilation
- manufacturing preview

Validation is session-based

and does not modify

document data.

---

# Plugins

Plugins may

- observe document lifecycle
- contribute document actions
- register validators

Plugins cannot

replace

the Document Manager.

---

# Domain Rules

The following always apply.

- Every document belongs to exactly one Document Session.
- Every Document Session owns exactly one Document.
- Tabs never own document data.
- Documents remain independent of Workspaces.
- Closing a document destroys only its session.
- Dirty state tracks persistent changes only.
- Auto Save creates recovery snapshots, not project saves.
- The application never creates empty documents automatically.

---

# Out of Scope

This document does not define

- New Document configuration
- Save format
- Import pipeline
- Export pipeline
- Canvas interaction

These are specified elsewhere.

---

# Future Topics

Future versions may support

```text
Split View

Multiple Windows

Linked Documents

Cloud Documents

Live Collaboration

Document Comparison

Version History
```

---

# Acceptance Criteria

The Document Lifecycle specification is complete when

✓ Document ownership is defined.

✓ Document Session responsibilities are documented.

✓ Tab responsibilities are defined.

✓ Dirty state is specified.

✓ Save and recovery behavior are documented.

✓ Multi-document behavior is established.

✓ State ownership between Application, Workspace, Document, and Session is clearly separated.
