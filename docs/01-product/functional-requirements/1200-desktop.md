# Functional Requirements
## FR-1200 Desktop Experience

**Document ID:** FR-1200  
**Title:** Desktop Experience (Windows, macOS & Linux)  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Desktop Experience Team

**Primary Packages**

```text
Flutter

desktop_shell/
desktop_workspace/
window_manager/
menu_bar/
dock_manager/
shortcut_manager/
drag_drop/

↓

Rust

(No desktop-specific business logic)

Shared Core

Project
Geometry
Digitizer
Simulation
Export
```

---

# Purpose

The Desktop Experience provides the flagship professional editing environment for Sewlio Studio.

Desktop users typically work with:

- Large monitors
- Multi-monitor setups
- Mouse
- Keyboard
- Graphics tablets
- Pen displays

The desktop application should maximize productivity while maintaining feature parity with tablet platforms.

---

# Objectives

Desktop shall provide

- Professional editing environment
- Keyboard-first workflow
- High-performance rendering
- Dockable workspace
- Multi-monitor compatibility
- Graphics tablet support
- Native desktop integrations

---

# Design Principles

## Productivity First

Desktop users prioritize speed and efficiency.

---

## Keyboard First

Every major action should be keyboard accessible.

---

## Workspace Customization

Users should be able to tailor the interface to their workflow.

---

## Native Feel

The application should respect platform conventions while remaining visually consistent.

---

## Shared Core

All business logic remains platform-independent.

---

# Supported Platforms

## Windows

Windows 11+

---

## macOS

macOS 14+

---

## Linux

Ubuntu LTS

Fedora

Arch (best effort)

Wayland

X11

---

# Workspace Layout

```text
+---------------------------------------------------------------+
| Menu Bar                                                      |
+---------------------------------------------------------------+
| Toolbar                                                       |
+---------+----------------------------------------+------------+
| Toolbox |                                        | Inspector  |
|         |                                        |            |
|         |               Canvas                   |            |
|         |                                        |            |
|         |                                        |            |
+---------+---------------------------+------------+------------+
| Layers  | Timeline / History        | Status Bar             |
+---------------------------------------------------------------+
```

Panels may be docked, undocked, resized, and hidden.

---

# FR-1201

## Native Window

Priority

Critical

---

Supports

Resize

Maximize

Minimize

Fullscreen

Restore

Window Position Memory

---

Future

Multiple windows

---

Acceptance Criteria

Window state restored on launch.

---

# FR-1202

## Menu Bar

Priority

Critical

---

Desktop includes a traditional menu bar.

Menus

- File
- Edit
- View
- Insert
- Object
- Digitize
- Simulation
- Export
- Window
- Help

Future

Developer

Plugins

AI

---

Keyboard navigation supported.

---

# FR-1203

## Toolbar

Priority

Critical

---

Displays

New

Open

Save

Undo

Redo

Selection

Zoom

Simulation

Export

Search (future)

---

Toolbar customizable in future.

---

# FR-1204

## Dockable Panels

Priority

Critical

---

Supports

Dock

Undock

Collapse

Expand

Resize

Move

Reset Layout

---

Supported Panels

Inspector

Layers

Timeline

History

Thread Library

Project Browser

Statistics

Machine Profiles

---

Workspace layouts persist across sessions.

---

# FR-1205

## Multi-Monitor Support

Priority

Critical

---

Supports

Multiple displays

High DPI

Independent scaling

Dragging windows between monitors

---

Future

Detached panels

Presentation monitor

Reference monitor

---

# FR-1206

## Keyboard Shortcuts

Priority

Critical

---

Supports

Custom shortcuts

Search

Conflict detection

Reset defaults

---

Examples

```text
Ctrl/Cmd + N

Ctrl/Cmd + O

Ctrl/Cmd + S

Ctrl/Cmd + Z

Ctrl/Cmd + Shift + Z

Space = Pan

P = Pen

V = Selection
```

---

# FR-1207

## Mouse Support

Priority

Critical

---

Supports

Left click

Right click

Middle click

Wheel zoom

Wheel pan

Hover

Selection

Context menus

---

# FR-1208

## Graphics Tablet Support

Priority

Critical

---

Supports

Wacom

Huion

XP-Pen

Apple Sidecar

Surface Pen (Windows)

---

Supports

Pressure

Hover

Tilt (future)

Buttons (future)

---

# FR-1209

## Drag & Drop

Priority

Critical

---

Supports

Project files

SVG

PNG

JPEG

Folders (future)

---

Dragging

Project

↓

Open

Dragging

SVG

↓

Import

---

# FR-1210

## Clipboard

Priority

Critical

---

Supports

Copy

Paste

Duplicate

Paste In Place

Cut

Future

Copy Style

Paste Style

---

# FR-1211

## Context Menus

Priority

Critical

---

Available via

Right click

Keyboard

Context key

---

Menu adapts to

Canvas

Layer

Object

Thread

Timeline

---

# FR-1212

## Window Layouts

Priority

Medium

---

Supports

Reset Workspace

Save Workspace

Load Workspace

Future

Named layouts

Shared layouts

---

# FR-1213

## File Associations

Priority

Critical

---

Associate

`.embproj`

Double-click

↓

Launch application

↓

Open project

---

Optional associations

SVG

DST (viewer mode)

---

# FR-1214

## Native File Dialogs

Priority

Critical

---

Supports

Open

Save

Save As

Export

Import

Recent folders

---

Use operating-system dialogs.

---

# FR-1215

## Native Notifications

Priority

Medium

---

Supports

Export complete

Recovery available

Autosave

Updates (future)

---

Uses platform notification APIs where appropriate.

---

# FR-1216

## Desktop Search

Priority

Future

---

Supports

Command Palette

Project Search

Object Search

Documentation Search

---

Shortcut

```text
Ctrl/Cmd + Shift + P
```

---

# FR-1217

## Developer Tools

Priority

Medium

---

Supports

FPS Overlay

Debug Panels

Performance Metrics

Widget Inspector

Render Statistics

---

Hidden by default.

---

# FR-1218

## Background Tasks

Priority

Critical

---

Background operations

Import

Export

Simulation

Thumbnail generation

Autosave

Migration

Validation

---

UI remains responsive.

---

# FR-1219

## High DPI Support

Priority

Critical

---

Supports

100%

125%

150%

200%

300%

Retina

4K

5K

Ultrawide

---

UI remains sharp.

---

# FR-1220

## Performance

Priority

Critical

---

Targets

Startup

<2 seconds

Project Load

<1 second (small project)

Canvas

60 FPS minimum

120 FPS preferred

Panel Updates

Immediate

Tool Switching

<16 ms

---

# Windows Requirements

Supports

Explorer integration

Windows scaling

Native title bar

Taskbar

Jump lists (future)

---

# macOS Requirements

Supports

Native menus

Trackpad gestures

Retina

Finder integration

Services (future)

---

# Linux Requirements

Supports

Wayland

X11

Native dialogs where available

HiDPI

---

# Accessibility

Supports

Keyboard-only workflow

Screen readers

High contrast

Large fonts

Reduced motion

Visible focus indicators

---

# Memory Targets

Medium Project

<500 MB

Large Project

<1 GB

---

# AI Agent Rules

Desktop package owns

Workspace shell

Docking

Menus

Window management

Desktop integrations

Keyboard shortcuts

---

Desktop package never owns

Geometry

Digitizer

Simulation logic

Export

Project serialization

---

Shared Rust core owns all business logic.

---

# Testing

Unit

Window state

Dock manager

Shortcuts

Clipboard

Drag & Drop

---

Golden

Light

Dark

4K

Ultrawide

Dock layouts

---

Integration

Open

Save

Import

Export

Simulation

Multiple monitors

Graphics tablet

---

Performance

Large project

Large SVG

120 FPS

Multiple monitors

---

Regression

Desktop feature parity

Cross-platform project compatibility

---

# Acceptance Criteria

Desktop Experience is complete when

✓ Native desktop workflow supported

✓ Dockable workspace implemented

✓ Multi-monitor compatible

✓ Keyboard-first operation

✓ Graphics tablet support functional

✓ Native file dialogs integrated

✓ Drag & drop supported

✓ High DPI rendering verified

✓ Accessibility requirements met

✓ Performance targets achieved

✓ Full feature parity with shared Rust core

---

# Future Enhancements

- Multi-window editing
- Detached panels
- Command palette
- Workspace profiles
- Plugin sidebar
- AI assistant panel
- Macro recorder
- Window tabbing (macOS)
- Native scripting API
- External monitor presentation mode
- Live collaboration windows
- Integrated performance profiler
