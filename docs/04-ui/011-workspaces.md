# UI
## UI-011 Workspaces

**Document ID:** UI-011  
**Title:** Workspaces  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-010 Application Lifecycle
UI-012 Home Workspace
UI-013 Document Lifecycle

UI-200 Window Management
UI-201 Workspace Management
UI-202 Docking System
UI-203 Panels

UI-300 Canvas Overview

ARCH-004 Document Model
ARCH-006 Command System
ARCH-008 State Management
```

---

# Purpose

This document defines the Workspace architecture of Sewlio Studio.

Workspace is an application/editor arrangement. Project Type is production identity. The two must not be treated as the same concept.

A Workspace represents a mode of the application that provides a specific environment for a particular workflow.

A Workspace is **not** a document.

It is an application-level concept responsible for arranging windows, panels, tools, and interactions around one or more document sessions.

---

# Philosophy

The application should always present a meaningful workspace.

Users interact with workspaces.

Documents are edited inside workspaces.

Separating Workspaces from Documents allows the application to support different editing experiences without changing the underlying document model.

---

# Goals

The Workspace system shall provide

- Multiple editing environments
- Configurable layouts
- Persistent panel arrangements
- Multi-document support
- Workflow-specific interfaces
- Future extensibility

---

# Definitions

## Workspace

A Workspace defines

- Layout
- Visible Panels
- Toolbar Configuration
- Active Tool Groups
- Available Commands
- Interaction Model

A Workspace never owns document data.

---

## Document Session

A Document Session owns

- Document
- Selection
- Undo History
- Viewport
- Tool State
- Background Tasks

Document Sessions exist independently of Workspaces.

---

# Architecture

```text
Application
│
├── Preferences
├── Recent Projects
├── Plugins
├── Themes
└── Workspace Manager
        │
        ├── Home Workspace
        ├── Editor Workspace
        ├── Simulation Workspace
        ├── Manufacturing Workspace
        └── AI Workspace
                │
                ▼
         Document Session(s)
```

The Workspace Manager coordinates active workspaces but does not own document data.

---

# Workspace Types

Sewlio Studio supports the following workspace types.

## Home Workspace

Purpose

Application landing page.

Responsibilities

- Recent Projects
- Templates
- Create New Project
- Open Project
- Import Artwork
- Recovery
- Learning Resources

The Home Workspace contains no document.

---

## Editor Workspace

Purpose

Primary embroidery editing environment.

Responsibilities

- Canvas
- Toolbars
- Layers
- Inspector
- Thread Panel
- Machine Panel
- Properties
- Timeline

This is the default workspace when a document is opened.

---

## Simulation Workspace

Purpose

Inspect embroidery simulation.

Responsibilities

- Thread Simulation
- Needle Motion
- Playback
- Heat Maps
- Thread Consumption
- Fabric Preview

This workspace focuses on verification rather than editing.

---

## Manufacturing Workspace

Purpose

Prepare embroidery for production.

Responsibilities

- Machine Selection
- Hoop Configuration
- Thread Changes
- Export Validation
- Production Estimates
- Manufacturing Diagnostics

---

## AI Workspace

Purpose

Provide AI-assisted workflows.

Responsibilities

- AI Chat
- Quality Reports
- Digitizing Suggestions
- Design Explanation
- Rule Inspection
- Optimization Recommendations

---

# Workspace Switching

Users may switch workspaces without affecting the document.

Example

```text
Editor Workspace

↓

Simulation Workspace

↓

Manufacturing Workspace

↓

Editor Workspace
```

The document remains unchanged.

Only the application layout changes.

---

# Workspace Layout

Each workspace defines

```text
Visible Panels

Panel Positions

Toolbar Groups

Default Shortcuts

Canvas Overlays

Window Arrangement
```

Layout changes are persisted independently.

---

# Workspace Persistence

Each workspace stores

- Dock Layout
- Panel Visibility
- Toolbar State
- Zoom Preferences
- Overlay Visibility

The document never stores workspace information.

Workspace preferences belong to the user profile.

---

# Relationship with Documents

A Workspace may host

- Zero documents
- One document
- Multiple documents

Multiple documents may share the same workspace.

Each document still maintains its own independent Document Session.

---

# Home Workspace

The Home Workspace is always available.

It may be displayed

- on application startup
- after closing the final document
- through a permanent Home tab
- via menu command

The Home Workspace cannot be closed.

---

# Editor Workspace

The Editor Workspace is automatically activated whenever a document is opened.

It contains

- Canvas
- Layers
- Inspector
- Tool Panels
- Status Bar

Editing commands are available only inside an Editor Workspace.

---

# Workspace Independence

Changing workspaces never

- modifies the document
- clears selection
- changes undo history
- affects save state
- alters embroidery objects

Only presentation changes.

---

# Multiple Windows

Future versions may allow multiple application windows.

Each window owns

```text
Workspace

↓

Document Tabs

↓

Document Sessions
```

Different windows may display different workspaces simultaneously.

---

# Plugins

Plugins may contribute

- New Workspaces
- Panels
- Toolbars
- Commands

Plugins cannot replace the Home Workspace.

Plugins cannot modify existing workspace responsibilities.

---

# Workspace State

Workspace state includes

```text
Dock Layout

Open Panels

Toolbar Configuration

Window Geometry

Theme Overrides

Overlay Settings
```

Workspace state is application-level.

---

# Document State

Document state includes

```text
Embroidery Objects

Machine Profile

Material Profile

Thread Library

Viewport

Selection

Undo History
```

Document state remains independent of workspace state.

---

# Lifecycle

```text
Application Launch

↓

Home Workspace

↓

Open Document

↓

Editor Workspace

↓

Simulation Workspace

↓

Manufacturing Workspace

↓

Editor Workspace

↓

Close Last Document

↓

Home Workspace
```

---

# Domain Rules

The following always apply.

- Workspaces are application-level concepts.
- Documents are independent of workspaces.
- The Home Workspace contains no document.
- Workspace switching never modifies document data.
- Workspace preferences belong to the user profile.
- Multiple documents may exist inside a workspace.
- Plugins may add new workspaces.
- Workspace layouts are persistent.
- Workspace state and document state remain independent.

---

# Out of Scope

This document does not define

- Home Workspace UI
- New Document workflow
- Panel behavior
- Docking implementation
- Canvas interaction

These are defined in their respective UI specifications.

---

# Future Topics

Future workspaces may include

```text
Batch Processing

Plugin Manager

Cloud Collaboration

Training Mode

Classroom Mode

Job Queue

Enterprise Dashboard
```

---

# Acceptance Criteria

The Workspace specification is complete when

✓ Workspace architecture is defined.

✓ Workspace responsibilities are documented.

✓ Workspace and document responsibilities are separated.

✓ Workspace persistence is specified.

✓ Workspace lifecycle is defined.

✓ Plugin extensibility is documented.

✓ Workspace switching behavior is documented.

✓ Workspace state remains independent of document state.
