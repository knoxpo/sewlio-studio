# Platform Requirements
## Sewlio Studio

**Document ID:** PR-PLATFORM-001  
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Product & Architecture

**Related Documents**

- vision.md
- philosophy.md
- prd.md
- accessibility.md
- non-functional-requirements.md
- system-architecture.md (future)
- flutter-architecture.md (future)
- rust-architecture.md (future)

---

# 1. Purpose

This document defines the platform-specific requirements for Sewlio Studio.

Although the application is built from a shared Flutter UI and Rust core, each platform has different capabilities, interaction models, and operating system constraints.

The goal is to deliver a consistent product experience while respecting platform conventions.

---

# 2. Supported Platforms

## Tier 1 (MVP)

| Platform | Status |
|----------|---------|
| Windows | ✅ |
| macOS | ✅ |
| Linux | ✅ |
| Flutter Web (CSR) | ✅ |

---

## Tier 2 (Public Alpha)

| Platform | Status |
|----------|---------|
| iPadOS | ✅ |
| Android Tablets | ✅ |

---

## Tier 3 (Companion)

| Platform | Status |
|----------|---------|
| iPhone | Companion |
| Android Phone | Companion |

Phones are intentionally **not** first-class editing platforms.

---

# 3. Shared Platform Goals

Regardless of platform:

- Same project format
- Same Rust core
- Same rendering results
- Same export engine
- Same digitizing algorithms
- Same machine compatibility

Users should never receive different embroidery output because they changed devices.

---

# 4. Shared Features

Every supported platform must support:

Project Creation

Project Opening

Project Saving

Autosave

Crash Recovery

Undo

Redo

Vector Editing

Running Stitch

Fill Stitch

Simulation

Project Preview

DST Export

SVG Import

Layer Management

Thread Libraries

Machine Profiles

Settings

---

# 5. Desktop Requirements

## Supported Operating Systems

Windows 11+

macOS 14+

Linux (Ubuntu LTS or equivalent modern distribution)

Earlier versions may work but are not primary support targets.

---

## Primary Input

Mouse

Keyboard

Trackpad

Graphics Tablet

Pen Display

---

## Desktop UX

Desktop receives the most feature-rich interface.

Supports:

Dockable Panels

Keyboard Shortcuts

Context Menus

Right Click

Multi-monitor

Resizable Windows

Native Menus

Native Dialogs

Drag & Drop

---

## Desktop Layout

```
┌─────────────────────────────────────┐
│ Toolbar                             │
├──────┬────────────────────┬─────────┤
│Tools │                    │Inspector│
│      │     Canvas         │         │
│      │                    │         │
├──────┴────────────────────┴─────────┤
│ Timeline / Status                   │
└─────────────────────────────────────┘
```

---

## File Management

Native Open

Native Save

Save As

Recent Projects

Project Associations

Drag project into application

Drag SVG into canvas

Export using native dialogs

---

## Clipboard

Desktop must support

Copy

Paste

Duplicate

Paste In Place

Copy Style (future)

Paste Style (future)

---

## Keyboard

Keyboard is a first-class input device.

Every major feature should have shortcuts.

---

# 6. Windows Requirements

Must support

Windows File Explorer

Windows Clipboard

Native Title Bar

Windows Scaling

High DPI

Multiple Displays

---

# 7. macOS Requirements

Must support

Finder Integration

Native Menus

Trackpad Gestures

Apple Pencil (Sidecar where applicable)

Retina Displays

Native File Dialogs

---

Follow macOS conventions where possible.

---

# 8. Linux Requirements

Target

Ubuntu LTS

Fedora

Arch (best effort)

---

Requirements

Wayland support

X11 compatibility

Native file dialogs where possible

High DPI

---

# 9. Flutter Web Requirements

Flutter Web is supported as a full editing platform.

SEO is not required.

The application is CSR-only.

---

Supported Browsers

Chrome

Edge

Safari

Firefox (best effort)

---

Capabilities

Project Editing

Import SVG

Export DST

Simulation

Local Storage

---

Preferred Storage

Browser File System Access API where available.

Fallback

IndexedDB

Manual import/export.

---

Web Limitations

No direct local filesystem access without user permission.

Platform-native dialogs vary by browser.

Performance depends on browser capabilities.

---

# 10. Tablet Requirements

Tablet is a first-class platform.

Not a companion.

---

Supported Devices

iPad

Android Tablets

---

Primary Input

Stylus

Touch

Keyboard

Trackpad (optional)

---

Goals

Professional editing.

Professional digitizing.

Professional exporting.

---

# 11. iPadOS Requirements

Supported

Apple Pencil

Apple Pencil Pro

Magic Keyboard

Trackpad

External Display (future)

---

Required Features

Pressure

Palm Rejection

Hover (supported hardware)

Touch Gestures

Landscape

Portrait

Floating Panels

---

Preferred Layout

```
Toolbar

↓

Canvas

↓

Floating Inspector

↓

Bottom Properties
```

---

Panel Behaviour

Inspector

Collapsible

Movable

Resizable

Toolbox

Floating

Dockable

Auto-hide option

---

Gestures

Pinch

Zoom

Rotate View

Pan

Long Press

Context Menu

Double Tap Pencil

Future configurable.

---

Storage

Open from Files

Save to Files

iCloud Drive

Google Drive (via Files provider)

Dropbox

OneDrive

---

# 12. Android Tablet Requirements

Support

Stylus

Samsung S Pen

USI Stylus

Touch

Keyboard

---

Support

Landscape

Portrait

Floating Panels

Material navigation where appropriate

---

Storage

Storage Access Framework

Documents

Google Drive

Dropbox

OneDrive

---

# 13. Phone Requirements

Phones are companion devices.

---

Supported Features

Project Browser

Project Preview

Thread List

Statistics

Annotations

Share Preview

Export History

Documentation

Tutorials

---

Unsupported

Large-scale vector editing

Advanced digitizing

Complex panel layouts

Professional production editing

---

Reason

Professional embroidery editing requires large workspaces and precision input.

---

# 14. Responsive Design

Desktop

Permanent Panels

Tablet

Collapsible Panels

Phone

Task-Based Navigation

---

Breakpoints

Desktop

≥ 1200 px

Tablet Landscape

900–1199 px

Tablet Portrait

700–899 px

Phone

< 700 px

---

# 15. Display Requirements

Minimum Resolution

Desktop

1920 × 1080

Recommended

2560 × 1440

4K fully supported

---

Tablet

11"

Recommended

12.9"

---

Phone

Modern high-density displays

---

High DPI

Required.

UI should remain crisp at all scales.

---

# 16. Rendering Requirements

Flutter

CustomPainter

Future

SceneBuilder optimizations

Impeller optimizations

Custom shaders where beneficial

---

Canvas

60 FPS minimum target

120 FPS preferred where hardware allows

---

# 17. Performance Requirements

Canvas interactions

< 16 ms/frame target (60 FPS)

Selection

< 50 ms

Undo

< 100 ms

Inspector Updates

Immediate

Large Project Navigation

Interactive

---

# 18. Platform Consistency

The following must produce identical results on every platform:

SVG Import

Running Stitch

Fill Stitch

Simulation

DST Export

Project Save

Project Load

---

Differences should only exist where required by operating system conventions.

---

# 19. Platform-Specific Adaptation

Allowed

Menus

Shortcuts

Dialogs

Gestures

Window Management

File Access

System Theme

---

Not Allowed

Different digitizing behavior

Different export algorithms

Different project formats

Different simulation logic

---

# 20. Platform Testing Matrix

| Feature | Win | macOS | Linux | Web | iPad | Android Tablet |
|----------|:---:|:------:|:-----:|:---:|:-----:|:--------------:|
| Create Project | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Open Project | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Save Project | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| SVG Import | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Running Stitch | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Fill Stitch | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Simulation | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| DST Export | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Autosave | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Crash Recovery | ✓ | ✓ | ✓ | Limited | ✓ | ✓ |

---

# 21. Future Platform Support

Potential future targets

- visionOS
- ChromeOS
- Steam Deck
- Surface Hub
- Interactive kiosks

These are not roadmap commitments.

---

# 22. Platform Acceptance Criteria

A platform is considered production-ready when:

✓ Full project lifecycle supported

✓ Rust core integrated successfully

✓ Flutter UI behaves consistently

✓ Accessibility requirements met

✓ Platform-specific interactions feel native

✓ Performance targets achieved

✓ Export compatibility verified

✓ Project compatibility identical across platforms

✓ Crash recovery validated

✓ Automated platform tests pass

---

# 23. Platform Design Principles

1. **Shared Core, Native Feel**
   - Business logic is identical everywhere.
   - UX respects platform conventions.

2. **Tablet Is a First-Class Citizen**
   - iPadOS and Android tablets receive professional editing capabilities.

3. **Phone Is a Companion**
   - Phones focus on review, sharing, and light tasks rather than production editing.

4. **Offline by Default**
   - Every platform must work without an internet connection.

5. **No Platform Lock-In**
   - Users can move `.embproj` files freely between devices using any supported storage provider.

6. **Consistency Over Uniformity**
   - The product should behave consistently while allowing platform-appropriate interaction patterns.

---

# Definition of Done

Platform support is complete when:

✓ All mandatory shared features function correctly.

✓ Platform-specific UX guidelines are followed.

✓ Performance budgets are met.

✓ Accessibility validation passes.

✓ Cross-platform project compatibility is verified.

✓ Regression tests pass across the supported platform matrix.

✓ No platform introduces unique behavior in the embroidery engine or project format.
