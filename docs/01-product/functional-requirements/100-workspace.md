# Functional Requirements
## FR-100 Workspace

**Document ID:** FR-100  
**Title:** Workspace & Editor Environment  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Flutter UI Team

**Related Documents**

- PRD
- User Flows
- Accessibility
- Platform Requirements
- Design System (future)
- Desktop Layout (future)
- Tablet Layout (future)
- FR-000 Product Lifecycle

---

# Purpose

The Workspace is the primary environment where users spend nearly all of their time.

Unlike traditional embroidery software, Sewlio Studio should provide a workspace inspired by modern creative tools such as:

- Figma
- Affinity Designer
- Procreate
- Blender
- VS Code
- DaVinci Resolve

The goal is to maximize available canvas space while providing quick access to editing tools and embroidery-specific information.

---

# Design Principles

The workspace should be:

- Clean
- Responsive
- Distraction free
- Keyboard friendly
- Touch friendly
- Stylus friendly
- Dockable
- Customizable
- Recoverable

The canvas is always the primary focus.

---

# Workspace Hierarchy

```
Application

└── Workspace

    ├── Menu Bar
    ├── Toolbar
    ├── Toolbox
    ├── Canvas
    ├── Inspector
    ├── Layer Panel
    ├── Thread Panel
    ├── History Panel
    ├── Timeline
    ├── Status Bar
    └── Notifications
```

---

# Workspace Layout

Desktop

```
+------------------------------------------------------------+
| Menu Bar                                                   |
+------------------------------------------------------------+
| Toolbar                                                    |
+---------+--------------------------------------+-----------+
| Toolbox |                                      | Inspector |
|         |                                      |           |
|         |              Canvas                  |           |
|         |                                      |           |
|         |                                      |           |
+---------+-------------------------------+------+-----------+
| Layers  | Timeline / Simulation         | Status Bar      |
+------------------------------------------------------------+
```

---

Tablet Landscape

```
+--------------------------------------------------+
| Toolbar                                          |
+--------------------------------------------------+
| Floating Toolbox                                |
|                                                  |
|               Canvas                             |
|                                                  |
| Floating Inspector                              |
+--------------------------------------------------+
| Bottom Drawer                                   |
+--------------------------------------------------+
```

---

Tablet Portrait

```
+--------------------------------------+
| Toolbar                              |
+--------------------------------------+
|                                      |
|                                      |
|              Canvas                  |
|                                      |
|                                      |
+--------------------------------------+
| Bottom Drawer                        |
+--------------------------------------+
```

---

Phone Companion

```
Project Browser

↓

Project Preview

↓

Thread List

↓

Statistics

↓

Share
```

---

# Workspace Regions

---

## Menu Bar

Desktop only.

Contains:

File

Edit

View

Insert

Object

Digitize

Simulation

Export

Window

Help

Future:

Plugins

AI

Developer

---

Functional Requirements

Must support

Native shortcuts

Native menus

Command search (future)

Recent files

---

Acceptance Criteria

✓ Native feel

✓ Keyboard accessible

✓ Searchable (future)

---

## Toolbar

Always visible.

Purpose

Provide quick access to frequently used actions.

---

Contains

New

Open

Save

Undo

Redo

Selection

Zoom

Pan

Simulation

Export

Search (future)

---

Behavior

Responsive

Scrollable if needed

Customizable (future)

---

Acceptance Criteria

✓ Visible

✓ Accessible

✓ Adaptive

---

## Toolbox

Primary editing tools.

Contains

Selection

Node Editing

Hand

Zoom

Pen

Pencil

Rectangle

Ellipse

Polygon

Star

Text

Measure

Eyedropper (future)

Knife (future)

---

Requirements

One active tool.

Persistent selection.

Large touch targets on tablet.

---

Acceptance Criteria

✓ Tool highlighted

✓ Keyboard shortcut available

✓ Tool state remembered

---

## Canvas

The heart of the application.

---

Capabilities

Infinite workspace

Hoop preview

Grid

Guides

Rulers

Selection

Zoom

Pan

Rotate View

Multiple artboards (future)

---

Canvas displays

Vectors

Embroidery Objects

Images

Guides

Selection

Machine boundaries

Simulation

---

Acceptance Criteria

✓ 60 FPS target

✓ High DPI

✓ Infinite workspace

✓ Smooth interaction

---

## Inspector

Displays properties of current selection.

---

Context-sensitive.

Selection changes

↓

Inspector updates.

---

Vector Properties

Position

Rotation

Scale

Stroke

Fill

Opacity

Visibility

Lock

---

Embroidery Properties

Stitch Type

Density

Angle

Direction

Underlay

Pull Compensation

Thread

Machine Settings

---

Acceptance Criteria

✓ Updates instantly

✓ Editable

✓ No unnecessary dialogs

---

## Layer Panel

Displays project hierarchy.

Supports

Create

Rename

Delete

Duplicate

Lock

Hide

Reorder

Group

Ungroup

Future

Folders

Layer filters

---

Acceptance Criteria

✓ Drag reorder

✓ Multi-selection

✓ Search (future)

---

## Thread Panel

Displays thread palette.

Shows

Thread Name

Manufacturer

Code

Color

Usage

Estimated Length

---

Supports

Replace Thread

Search

Sort

Custom Libraries

---

Acceptance Criteria

✓ Updates automatically

✓ Shared across project

---

## History Panel

Displays command history.

Supports

Undo

Redo

History Navigation

Snapshots

Future

Named checkpoints

---

Acceptance Criteria

✓ Every command recorded

✓ History survives autosave where feasible

---

## Timeline

Primary simulation controller.

Contains

Play

Pause

Stop

Step

Needle Position

Current Color

Progress

Speed

---

Acceptance Criteria

✓ Interactive

✓ Smooth playback

✓ Scrubbing supported

---

## Status Bar

Displays

Cursor Position

Zoom

Current Tool

Selection Count

Stitch Count

Warnings

Machine Profile

Autosave Status

Memory Usage (Developer Mode)

---

Acceptance Criteria

✓ Always visible

✓ Lightweight

---

## Notification Center

Displays

Export Complete

Autosave

Warnings

Errors

Background Tasks

---

Notifications

Non-blocking

Dismissible

Persistent when required

---

# Docking System

Desktop

Supports

Dock

Undock

Resize

Collapse

Expand

Reset Layout

Save Layout (future)

---

Tablet

Panels become

Floating

Collapsible

Bottom Sheets

---

Phone

Panels become

Dedicated Screens

---

# Workspace Modes

Only one primary mode is active.

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

Changing mode updates

Toolbar

Inspector

Status Bar

Context Actions

---

# Workspace State

Workspace remembers

Open Project

Panel Positions

Zoom

Viewport

Selected Tool

Theme

Recent Colors

Machine Profile

Thread Library

---

Workspace state is restored on launch.

---

# Empty Workspace

When no project is open

Display

Recent Projects

New Project

Open Project

Import SVG

Documentation

Tutorials

---

# Background Tasks

Workspace supports

SVG Import

Export

Simulation

Thumbnail Generation

Project Migration

Autosave

Background Validation

---

Long-running tasks should not block interaction.

---

# Multiple Projects

MVP

One project open at a time.

Future

Multiple project tabs.

Split view.

---

# Search

Future command palette.

```
Cmd/Ctrl + Shift + P
```

Search

Commands

Panels

Tools

Projects

Settings

Documentation

---

# Workspace Themes

Light

Dark

High Contrast Light

High Contrast Dark

Future

Custom Themes

---

# Workspace Scaling

Supports

100%

125%

150%

175%

200%

250%

300%

Canvas zoom independent from UI scaling.

---

# Keyboard Requirements

Every workspace action should be keyboard accessible.

Examples

Open

Save

Undo

Redo

Zoom

Pan

Select Tool

Switch Panels

Hide UI

Toggle Guides

Toggle Grid

Toggle Simulation

---

# Tablet Requirements

Workspace optimized for

Apple Pencil

Touch

Landscape

Portrait

Floating panels

Large hit targets

Palm rejection

---

# Accessibility

Workspace must satisfy

Keyboard navigation

Screen reader semantics for panels

High contrast themes

Large touch targets

Visible focus indicators

Reduced motion

Reference

accessibility.md

---

# Error Handling

Workspace should recover from

Panel failure

Renderer restart

Project reload

Asset reload

Autosave interruption

---

# Performance Targets

Workspace startup

< 500 ms after project load

Panel switching

< 16 ms

Inspector update

Immediate

Tool switching

< 16 ms

Canvas redraw

60 FPS target

---

# AI Agent Rules

Workspace package owns

Flutter widgets

Docking

Panels

Navigation

Menus

Themes

Workspace state

Workspace package never owns

Geometry

Digitizing

Export

Project serialization

Simulation logic

Machine formats

These belong to Rust.

---

# Testing Requirements

Unit Tests

Workspace state

Panel management

Theme switching

Toolbar behavior

Inspector binding

---

Golden Tests

Desktop

Tablet Landscape

Tablet Portrait

Phone Companion

Dark Theme

Light Theme

High Contrast

---

Integration Tests

Open project

Change tool

Modify inspector

Undo

Export

Autosave

Crash recovery

---

# Acceptance Criteria

The workspace is considered complete when

✓ Canvas is the primary focus

✓ All major panels function

✓ Desktop layout is responsive

✓ Tablet layout is touch-first

✓ Phone companion is simplified

✓ Workspace state persists

✓ Keyboard shortcuts function

✓ Accessibility requirements pass

✓ Performance targets are met

✓ Workspace remains responsive during background operations

---

# Future Enhancements

- Multi-window editing
- Multi-project tabs
- Workspace profiles
- Custom panel layouts
- Command palette
- AI assistant panel
- Plugin panel
- Live collaboration sidebar
- Performance dashboard
- Macro recorder
- Embedded documentation
