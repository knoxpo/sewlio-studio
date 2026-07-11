# User Flows
## Sewlio Studio

**Document ID:** UF-001  
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Product Management + UX Architecture

**Related Documents**

- vision.md
- philosophy.md
- prd.md
- personas.md
- use-cases.md
- accessibility.md
- functional-requirements/*
- non-functional-requirements.md

---

# Purpose

This document defines the end-to-end interaction flows within Sewlio Studio.

Unlike Use Cases, which describe **what** users accomplish, User Flows describe **how** users move through the application.

These flows become the foundation for:

- UI wireframes
- Navigation
- State management
- Widget hierarchy
- QA automation
- AI implementation planning

---

# Navigation Philosophy

The application should minimize modal workflows.

Users should remain inside the editor whenever possible.

Every major workflow should require as few context switches as possible.

---

# Workspace Model

```
┌──────────────────────────────────────────────┐
│               Application Shell              │
├──────────────────────────────────────────────┤
│ Toolbar                                      │
├───────┬──────────────────────┬───────────────┤
│ Tools │                      │ Inspector     │
│       │      Canvas          │               │
│       │                      │               │
├───────┴──────────────────────┴───────────────┤
│ Timeline / Status / Properties               │
└──────────────────────────────────────────────┘
```

Tablet layout adapts by collapsing panels.

Phone layout becomes task-oriented.

---

# Application Entry Flow

```
Launch App

↓

Splash

↓

Recent Projects

↓

Choose

New Project

OR

Open Existing

↓

Editor
```

Acceptance Criteria

- Startup under target performance budget
- Recent projects load correctly
- Recovery prompt shown if required

---

# Flow 1
# Create New Project

```
Launch

↓

New Project

↓

Project Name

↓

Machine Profile

↓

Hoop Selection

↓

Create

↓

Editor Opens
```

System Actions

- Create `.swl`
- Initialize project database
- Create default layer
- Initialize undo history
- Initialize viewport

---

# Flow 2
# Open Existing Project

```
Launch

↓

Open Project

↓

Choose .swl

↓

Validation

↓

Migration (if required)

↓

Editor
```

Failure Path

```
Invalid Project

↓

Readable Error

↓

Retry

OR

Cancel
```

---

# Flow 3
# Import SVG

```
Editor

↓

Import

↓

Select SVG

↓

Parse SVG

↓

Convert

↓

Import Report

↓

Canvas
```

Warnings

- Unsupported elements
- Missing fonts
- Unsupported filters

Import must never crash.

---

# Flow 4
# Import Reference Image

```
Editor

↓

Import Image

↓

Select PNG/JPG

↓

Reference Layer

↓

Position

↓

Adjust Opacity

↓

Lock Layer

↓

Begin Tracing
```

Reference images never export.

---

# Flow 5
# Draw Artwork

```
Select Tool

↓

Draw

↓

Vector Created

↓

Edit

↓

Layer Updated
```

Supported Tools

- Pen
- Pencil
- Rectangle
- Ellipse
- Polygon
- Text

---

# Flow 6
# Edit Artwork

```
Select Object

↓

Inspector Opens

↓

Modify Properties

↓

Canvas Updates

↓

History Entry Created
```

Editable

- Position
- Rotation
- Scale
- Fill
- Stroke
- Visibility
- Lock

---

# Flow 7
# Convert to Running Stitch

```
Select Vector

↓

Convert

↓

Running Stitch

↓

Parameters

↓

Generate

↓

Preview

↓

Accept
```

Parameters

- Stitch spacing
- Start direction
- End direction

---

# Flow 8
# Convert to Fill Stitch

```
Closed Shape

↓

Convert

↓

Fill

↓

Density

↓

Angle

↓

Generate

↓

Preview

↓

Accept
```

---

# Flow 9
# Edit Stitch Properties

```
Select Stitch Object

↓

Inspector

↓

Density

↓

Angle

↓

Underlay

↓

Preview Updates
```

No regeneration should require reopening dialogs.

---

# Flow 10
# Preview Simulation

```
Preview Mode

↓

Play

↓

Needle Animation

↓

Pause

↓

Scrub Timeline

↓

Resume
```

Displayed

- Needle
- Thread
- Stitch count
- Current color
- Progress

---

# Flow 11
# Export

```
Export

↓

Select Format

↓

Validation

↓

Warnings

↓

Export

↓

Completed
```

Validation Examples

- Hoop exceeded
- Stitch count exceeded
- Unsupported object

---

# Flow 12
# Save

```
Modified

↓

Save

↓

Write Database

↓

Update Metadata

↓

Saved
```

Autosave follows same flow.

---

# Flow 13
# Crash Recovery

```
Unexpected Close

↓

Launch

↓

Recovery Found

↓

Recover

↓

Workspace Restored
```

Recover

- Viewport
- Layers
- Undo
- Selection (where feasible)

---

# Flow 14
# Undo / Redo

```
Action

↓

History

↓

Undo

↓

Previous State

↓

Redo

↓

Current State
```

Every user-visible modification should be undoable.

---

# Flow 15
# Layer Management

```
Layers

↓

New Layer

↓

Rename

↓

Move Objects

↓

Lock

↓

Hide

↓

Reorder
```

---

# Flow 16
# Thread Color Assignment

```
Select Stitch Object

↓

Thread Library

↓

Search

↓

Choose Thread

↓

Preview Updates
```

Thread shown as

- Manufacturer
- Code
- Name
- Preview

---

# Flow 17
# Machine Profile

```
Settings

↓

Machine Profile

↓

Select Machine

↓

Hoop Updates

↓

Validation Updates
```

---

# Flow 18
# Tablet Workflow

```
Open Project

↓

Apple Pencil

↓

Draw

↓

Pinch Zoom

↓

Convert

↓

Preview

↓

Export
```

Panels become floating.

Canvas remains primary.

---

# Flow 19
# Desktop Workflow

```
Keyboard

↓

Mouse

↓

Panels

↓

Shortcuts

↓

Inspector

↓

Export
```

Supports

- Multi-window (future)
- Dockable panels
- Keyboard-first operation

---

# Flow 20
# Phone Companion

```
Open Project

↓

Preview

↓

Thread List

↓

Share Preview

↓

Close
```

Phones do not expose full editor.

---

# Error Flow
# Invalid SVG

```
Import

↓

Unsupported Elements

↓

Import Report

↓

Continue

OR

Cancel
```

---

# Error Flow
# Export Failure

```
Export

↓

Validation Error

↓

Problem Explained

↓

Fix Suggested

↓

Retry
```

---

# Error Flow
# Missing Asset

```
Open Project

↓

Missing Image

↓

Locate

OR

Ignore

↓

Continue
```

---

# Error Flow
# Project Migration

```
Older Version

↓

Migration Preview

↓

Backup

↓

Migrate

↓

Open
```

---

# State Diagram

```
No Project

↓

Project Open

↓

Modified

↓

Saving

↓

Saved

↓

Modified

↓

Exported

↓

Closed
```

---

# Canvas Modes

```
Selection

↓

Drawing

↓

Node Editing

↓

Digitizing

↓

Simulation

↓

Presentation
```

Only one primary mode is active at a time.

---

# Responsive Layout

## Desktop

```
Left Tools

Canvas

Right Inspector

Bottom Timeline
```

---

## Tablet Landscape

```
Floating Tools

Canvas

Collapsible Inspector
```

---

## Tablet Portrait

```
Canvas

↓

Bottom Drawer

↓

Floating Toolbox
```

---

## Phone

```
Task-Based Screens

Preview

Inspector

Thread List

Project Info
```

---

# AI Implementation Flow

```
PRD

↓

Use Case

↓

User Flow

↓

Functional Requirement

↓

Claude Ticket

↓

Local Coding Agent

↓

QA Agent

↓

Review

↓

Merge
```

Every user flow should be traceable to:

- One or more Use Cases
- One or more Functional Requirements
- One or more Test Scenarios

---

# UX Design Principles

The following principles apply to every flow.

## Progressive Disclosure

Show only what is needed.

Advanced controls remain available but unobtrusive.

---

## Minimize Context Switching

Users should rarely leave the editor.

Avoid unnecessary modal dialogs.

Prefer inline editing.

---

## Immediate Feedback

Every action should provide immediate visual feedback.

Examples

- Selection highlights
- Live preview
- Inspector updates
- Status bar messages

---

## Predictability

Every tool should behave consistently.

The same gesture should produce the same result across all platforms.

---

## Recoverability

Every destructive action should be reversible where technically feasible.

Undo should be preferred over confirmation dialogs.

---

# User Flow Completion Criteria

A user flow is considered complete when:

✓ Entry point defined

✓ Exit point defined

✓ Success path defined

✓ Error path defined

✓ Edge cases identified

✓ Acceptance criteria documented

✓ Related use cases referenced

✓ Functional requirements mapped

✓ Test scenarios identified

✓ Accessibility reviewed

---

# Future User Flows

Future versions will include:

- AI-assisted digitization
- Plugin installation
- Batch export
- Multi-hoop projects
- Collaboration
- Template marketplace
- Cloud synchronization
- Team workflows
- Machine transfer
- Production scheduling
- Fabric simulation
