# UI
## UI-012 Home Workspace

**Document ID:** UI-012  
**Title:** Home Workspace  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-010 Application Lifecycle
UI-011 Workspaces
UI-013 Document Lifecycle

UI-614 New Document Workflow

UI-601 Open & Save
UI-602 Import UI

ARCH-004 Document Model
ARCH-008 State Management
```

---

# Purpose

This document defines the Home Workspace.

The Home Workspace is the application's landing experience.

It provides access to projects, templates, recovery sessions, imports, and onboarding.

The Home Workspace exists independently of any document.

---

# Philosophy

Opening the application should never display an empty editor.

Instead, users are presented with a productive starting point that provides immediate access to their work.

The Home Workspace represents the application.

The Editor Workspace represents a document.

---

# Goals

The Home Workspace shall provide

- Fast project access
- Project discovery
- Recent history
- Project recovery
- Template selection
- Import entry points
- Learning resources

---

# Layout

The Home Workspace consists of five primary areas.

```text
Application Header

↓

Primary Actions

↓

Recent Projects

↓

Templates

↓

Learning & Updates
```

The layout is optimized for desktop displays.

---

# Application Header

The header displays

- Application logo
- Application name
- Current version
- User profile
- Settings
- Theme selector

Example

```text
Sewlio Studio                            Settings   User
```

---

# Primary Actions

The following actions are always visible.

```text
New Project

Open Project

Open Embroidery File

Import Artwork

Browse Templates
```

These actions provide the primary entry points into the application.

---

# New Project

Starts the New Document workflow.

```text
Home Workspace

↓

New Project

↓

Document Setup

↓

Document Session

↓

Editor Workspace
```

---

# Open Project

Opens an existing Sewlio Studio project.

Supported file types are determined by the project format specification.

---

# Open Embroidery File

Imports an embroidery machine file.

Examples

```text
DST

PES

JEF

VP3

EXP
```

The imported design is converted into an editable document where supported.

---

# Import Artwork

Imports source artwork.

Examples

```text
SVG

PDF

PNG

JPEG

BMP

TIFF
```

Importing artwork starts the artwork normalization workflow.

---

# Templates

Templates provide predefined project configurations.

Examples

```text
Blank Project

Left Chest Logo

Cap Front

Jacket Back

Patch

Sleeve Logo

Towel

Custom Hoop
```

Templates configure

- Hoop
- Material
- Thread Library
- Units
- Machine Defaults

Templates never contain user project data.

---

# Recent Projects

The Home Workspace displays recently opened projects.

Each project card displays

- Thumbnail
- Project Name
- Last Modified
- File Location
- Hoop
- Machine
- Stitch Count (optional)
- Favorite Status

---

# Recent Project Actions

Each project supports

```text
Open

Pin

Duplicate

Rename

Show in Folder

Remove from Recent
```

Removing from Recent never deletes the actual project.

---

# Favorites

Projects may be pinned.

Pinned projects appear before the normal recent list.

Pinned projects remain until manually removed.

---

# Recovery

If unsaved recovery data exists,

the Home Workspace displays

Recovered Projects.

Each recovery item supports

```text
Restore

Discard

View Details
```

Recovery never occurs automatically.

The user must explicitly restore the session.

---

# Search

The Home Workspace provides global project search.

Search includes

- Project Name
- File Path
- Tags
- Notes
- Customer Name (future)
- Machine
- Hoop

Search is local by default.

---

# Learning Resources

The Home Workspace may display

- Tutorials
- What's New
- Documentation
- Keyboard Shortcuts
- Sample Projects

This section is optional and configurable.

---

# Empty State

If no projects exist,

the Home Workspace emphasizes

- Create Project
- Import Artwork
- Open Project

Recent Projects are hidden until available.

---

# Session Persistence

The Home Workspace stores

- Recently Opened Projects
- Favorite Projects
- Last Search
- Preferred Layout
- Learning Card Visibility

These preferences belong to the user profile.

---

# Relationship to Documents

The Home Workspace

- owns no document
- owns no undo history
- owns no viewport
- owns no tool state
- owns no save state

It is purely an application workspace.

---

# Relationship to Tabs

The Home Workspace may be implemented in one of two ways.

## Option A

Displayed only when no documents are open.

```text
Application

↓

Home Workspace

↓

Open Document

↓

Editor
```

## Option B (Recommended)

The Home Workspace is a permanent pinned tab.

```text
🏠 Home | Logo.esproj | Cap.esproj | Patch.esproj
```

The Home tab

- cannot be closed
- cannot be renamed
- cannot become dirty
- cannot be saved

It always provides access to project management functions.

---

# Performance

The Home Workspace should load almost instantly.

Project thumbnails should be loaded asynchronously.

Large project metadata should be cached.

---

# Accessibility

The Home Workspace supports

- Keyboard navigation
- Screen readers
- High contrast mode
- Scalable text
- Focus indicators

Every primary action must be keyboard accessible.

---

# Domain Rules

The following always apply.

- The Home Workspace is not a document.
- The Home Workspace never appears in undo history.
- Closing documents never closes the Home Workspace.
- Removing a recent project never deletes project files.
- Recovery always requires user confirmation.
- Templates never modify existing documents.
- The Home Workspace owns only application-level state.

---

# Out of Scope

This document does not define

- Document creation
- Document editing
- Panel layouts
- Canvas behavior

These are defined elsewhere.

---

# Future Topics

Future versions may include

```text
Cloud Projects

Team Workspaces

Project Collections

Recent Machines

Favorite Materials

Pinned Customers

Template Marketplace

Plugin Recommendations
```

---

# Acceptance Criteria

The Home Workspace specification is complete when

✓ The landing experience is defined.

✓ Primary actions are documented.

✓ Recent project behavior is defined.

✓ Recovery workflow is specified.

✓ Template behavior is documented.

✓ Search behavior is documented.

✓ Home Workspace responsibilities are clearly separated from document responsibilities.

✓ Performance and accessibility expectations are established.
