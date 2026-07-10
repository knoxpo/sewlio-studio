# UI
## UI-010 Application Lifecycle

**Document ID:** UI-010  
**Title:** Application Lifecycle  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-011 Workspaces
UI-012 Home Workspace
UI-013 Document Lifecycle

UI-600 Document Workflow
UI-601 Open & Save

ARCH-001 System Overview
ARCH-004 Document Model
ARCH-006 Command System

DOM-300 Machine Model
```

---

# Purpose

This document defines the lifecycle of the Sewlio Studio desktop application.

It specifies how the application starts, manages workspaces, opens documents, closes documents, restores sessions, and terminates.

The application lifecycle is independent of the document lifecycle.

---

# Philosophy

Sewlio Studio is an application that manages workspaces and Project Types.

Documents exist inside workspaces.

Project Type is persistent project data. It is resolved when opening or creating a document and determines production tools, panels, validation, simulation, export, and AI knowledge.

The application should always provide a usable environment, even when no documents are open.

---

# Goals

The Application Lifecycle shall provide

- Fast startup
- Persistent user experience
- Session recovery
- Workspace management
- Multi-document editing
- Predictable state transitions

---

# Lifecycle Overview

```text
Application Launch

↓

Initialize Services

↓

Restore User Preferences

↓

Restore Session (Optional)

↓

Open Home Workspace

↓

User Action

↓

Open/Create Document

↓

Editor Workspace

↓

Close Documents

↓

Return Home Workspace

↓

Application Exit
```

---

# Startup

On startup the application shall

- initialize platform services
- load preferences
- initialize plugins
- initialize theme
- restore user settings
- restore recent projects
- detect recovery sessions

No document is automatically created.

---

# Home Workspace

After startup,

the application always enters the Home Workspace.

The Home Workspace is the default application workspace.

It is not a document.

---

# Document Opening

A document may be opened by

- creating a new project
- opening an existing project
- opening a recent project
- importing artwork
- opening an embroidery file
- restoring a recovery session

Opening a document creates a Document Session.

---

# Document Sessions

Each open document owns

```text
Document

Viewport

Selection

History

Undo Stack

Background Tasks

Tool State
```

Closing a document destroys only its Document Session.

The application continues running.

---

# Multiple Documents

The application supports multiple simultaneously opened documents.

Each document owns an independent Document Session.

Documents do not share

- selection
- undo history
- viewport
- temporary state

---

# Returning Home

If the final document is closed,

the application returns to the Home Workspace.

The application never displays an empty editor.

---

# Session Recovery

If recovery information exists,

the Home Workspace shall display

Recovered Projects.

The user chooses

- Restore
- Discard

Recovery never occurs automatically without user approval.

---

# Application Exit

On exit the application shall

- save preferences
- persist window layout
- persist workspace layout
- persist recent projects
- save recovery data for dirty documents
- terminate background tasks gracefully

---

# Lifecycle Rules

The following always apply.

- The application always starts in the Home Workspace.
- Documents never exist outside a Document Session.
- The Home Workspace is never treated as a document.
- Closing the last document returns to the Home Workspace.
- Application state and document state remain independent.
- Recovery is user initiated.
- Startup never creates an empty document.

---

# Out of Scope

This document does not define

- Home Workspace UI
- New Document workflow
- Document properties
- Editor layout

These are defined in their respective UI specifications.

---

# Acceptance Criteria

The Application Lifecycle specification is complete when

✓ Startup behavior is defined.

✓ Home Workspace behavior is defined.

✓ Document opening behavior is defined.

✓ Session management is documented.

✓ Multi-document behavior is defined.

✓ Application shutdown behavior is documented.

✓ Application state is separated from document state.
