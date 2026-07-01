# Functional Requirements
## FR-1100 Tablet Experience

**Document ID:** FR-1100  
**Title:** Tablet Experience (iPadOS & Android Tablets)  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Tablet Experience Team

**Primary Packages**

```text
Flutter

tablet_shell/
tablet_workspace/
floating_panels/
stylus/
gestures/
adaptive_layout/
tablet_shortcuts/

↓

Rust

(No tablet-specific business logic)

Shared Core

Geometry
Digitizer
Simulation
Export
Project
```

---

# Purpose

This document defines the tablet-first experience of Sewlio Studio.

Unlike many desktop applications that are merely adapted to tablets, Sewlio Studio should provide a professional tablet workflow that feels native to:

- iPad Pro
- iPad Air
- Android Tablets
- Samsung Galaxy Tab
- Pixel Tablet

The tablet version is a first-class editing environment, not a companion application.

---

# Objectives

The tablet application shall provide

- Professional vector editing
- Professional embroidery digitizing
- Full simulation
- Full export capability
- Apple Pencil optimization
- Android stylus optimization
- Touch-first navigation

Everything available on desktop should be available on tablets unless limited by the operating system.

---

# Design Principles

## Touch First

Every interaction should be designed for touch before mouse.

---

## Stylus First

Stylus should feel like the primary drawing device.

---

## Canvas First

Maximum screen space should be dedicated to the canvas.

---

## Minimal Chrome

Panels should disappear when not needed.

---

## Contextual UI

Only relevant controls should appear.

---

# Supported Devices

## Tier 1

iPad Pro

11"

13"

---

iPad Air

11"

13"

---

Samsung Galaxy Tab S

---

Pixel Tablet

---

## Minimum Screen Size

10"

Phones are handled separately.

---

# Supported Orientations

Landscape

Portrait

---

Landscape is recommended.

Portrait remains fully supported.

---

# Workspace Layout

Landscape

```text
+---------------------------------------------------------+
| Toolbar                                                 |
+---------------------------------------------------------+
|                                                         |
|     Floating Tools          Canvas                      |
|                                                         |
|                                         Inspector       |
|                                                         |
+---------------------------------------------------------+
| Bottom Drawer                                           |
+---------------------------------------------------------+
```

---

Portrait

```text
+-------------------------------------------+
| Toolbar                                   |
+-------------------------------------------+
|                                           |
|                                           |
|               Canvas                      |
|                                           |
|                                           |
+-------------------------------------------+
| Bottom Drawer                             |
+-------------------------------------------+
```

---

# Floating Panels

Panels support

Move

Collapse

Expand

Resize

Snap

Auto-hide

---

Supported Panels

Layers

Inspector

Thread Library

History

Timeline

Statistics

Project

---

# FR-1101

## Toolbar

Priority

Critical

---

Displays

Undo

Redo

Selection

Pen

Pencil

Shapes

Simulation

Export

Settings

---

Toolbar adapts

Landscape

↓

Single Row

Portrait

↓

Scrollable

---

# FR-1102

## Floating Toolbox

Priority

Critical

---

Contains

Selection

Pen

Pencil

Rectangle

Ellipse

Polygon

Text

Hand

Zoom

---

Supports

Collapse

Expand

Drag

Dock (future)

---

# FR-1103

## Floating Inspector

Priority

Critical

---

Displays

Object properties

Digitizer settings

Simulation settings

Export settings

---

Inspector updates immediately.

---

# FR-1104

## Bottom Drawer

Priority

Critical

---

Contains

Layers

Timeline

History

Thread Palette

Statistics

Project Info

---

Supports

Swipe

Expand

Collapse

Remember last state

---

# FR-1105

## Touch Navigation

Priority

Critical

---

Supports

Tap

Double Tap

Long Press

Drag

Multi-touch

---

Interactions

Selection

Transform

Menus

Context Actions

---

# FR-1106

## Gesture Navigation

Priority

Critical

---

Supports

Pinch

Zoom

Two Finger Pan

Two Finger Tap Undo

Three Finger Redo

Long Press Context Menu

Drag Selection

---

Future

Rotate Gesture

Custom Gestures

---

Gestures configurable.

---

# FR-1107

## Apple Pencil

Priority

Critical

---

Supports

Pressure

Hover (supported devices)

Double Tap

Palm Rejection

Latency Optimization

---

Future

Barrel Roll

Squeeze (Apple Pencil Pro)

Custom shortcuts

---

# FR-1108

## Android Stylus

Priority

Critical

---

Supports

Pressure

Hover

Palm Rejection

Stylus Buttons (future)

---

USI compatible where supported.

---

# FR-1109

## Keyboard Support

Priority

Critical

---

Supports

Magic Keyboard

Bluetooth Keyboard

USB Keyboard

---

All desktop shortcuts available.

---

# FR-1110

## Trackpad Support

Priority

Critical

---

Supports

Cursor

Selection

Scroll

Pinch Zoom

Context Menu

Hover

---

# FR-1111

## Context Menu

Priority

Critical

---

Long Press

↓

Context Menu

---

Supports

Copy

Paste

Duplicate

Delete

Bring Forward

Send Backward

Convert

Group

Ungroup

---

# FR-1112

## Canvas Interaction

Priority

Critical

---

Supports

Draw

Move

Rotate

Scale

Node Editing

Digitizing

Simulation

Selection

---

Canvas always remains primary.

---

# FR-1113

## Apple Pencil Drawing

Priority

Critical

---

Pencil input

↓

Bezier

↓

Geometry

↓

History

↓

Live Preview

---

Input latency should feel immediate.

---

# FR-1114

## Workspace Persistence

Priority

Critical

---

Remember

Panel Positions

Drawer State

Last Tool

Zoom

Viewport

Theme

---

Restored automatically.

---

# FR-1115

## External Display

Priority

Future

---

Supports

Extended Canvas

Presentation Mode

Dual Workspace

Reference Window

---

# FR-1116

## Split View

Priority

Future

---

Supports

Side-by-side

Files App

Reference PDF

Browser

---

Project remains editable.

---

# FR-1117

## Stage Manager

Priority

Medium

---

Supports

Window resizing

Multiple windows (future)

---

Adaptive layout required.

---

# FR-1118

## File Management

Priority

Critical

---

Supports

Files App

Google Drive

Dropbox

OneDrive

USB Storage

---

Uses platform-native file pickers.

---

# FR-1119

## Share Sheet

Priority

Critical

---

Supports

Share Preview

Share Export

Share Project

---

Uses native share sheet.

---

# FR-1120

## Performance

Priority

Critical

---

Targets

60 FPS minimum

120 FPS preferred

Canvas redraw

<16 ms

Tool switch

Immediate

Panel animation

Smooth

---

# Tablet-Specific UI Rules

Never use

Hover-only interactions.

---

Never require

Right-click.

---

Never require

Keyboard.

---

Every action must be available through touch.

---

# Accessibility

Supports

VoiceOver

TalkBack

Dynamic Type (where appropriate)

Large Touch Targets

Reduced Motion

High Contrast

Screen Reader

---

Minimum touch target

44×44 pt (Apple)

48×48 dp (Android)

---

# Battery Optimization

Avoid

Unnecessary redraws

Polling

Busy loops

---

Pause expensive rendering when application is backgrounded.

---

# Memory Targets

Medium project

<500 MB

Large project

<1 GB

---

Aggressively reuse rendering resources.

---

# AI Agent Rules

Tablet package owns

Adaptive layouts

Floating panels

Gestures

Stylus integration

Touch interactions

Platform-specific UX

---

Tablet package never owns

Geometry

Digitizer

Simulation logic

Export

Project persistence

---

Business logic remains shared across all platforms.

---

# Testing

Unit

Gesture recognition

Panel persistence

Adaptive layouts

Stylus events

---

Golden

Landscape

Portrait

Dark Mode

Light Mode

Large Text

---

Integration

Apple Pencil

Samsung S Pen

Magic Keyboard

Trackpad

External Files

Export

Simulation

---

Performance

120 FPS

Large projects

Gesture latency

Panel animations

---

Regression

Desktop parity

Feature parity

Project compatibility

---

# Acceptance Criteria

Tablet Experience is complete when

✓ Professional editing workflow supported

✓ Apple Pencil optimized

✓ Android stylus optimized

✓ Floating workspace functional

✓ Landscape and portrait supported

✓ Keyboard and trackpad supported

✓ Native file management integrated

✓ Share sheet supported

✓ Accessibility requirements met

✓ Performance targets achieved

✓ Full feature parity with desktop core functionality

---

# Future Enhancements

- Apple Pencil Pro advanced gestures
- AI handwriting-to-vector conversion
- Scribble support for text entry
- Multi-window editing
- External display workspace
- Reference image window
- Quick radial tool palette
- Gesture customization
- Haptic feedback
- Vision Pro companion integration
- Collaborative whiteboard mode
- Live stylus collaboration
