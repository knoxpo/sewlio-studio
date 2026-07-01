# Functional Requirements
## FR-1300 Mobile Experience

**Document ID:** FR-1300  
**Title:** Mobile Experience (iPhone & Android Phones)  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** High (Post-MVP Foundation)

**Owner:** Mobile Experience Team

**Primary Packages**

```text
Flutter

mobile_shell/
mobile_workspace/
gesture_engine/
quick_actions/
viewer/
review/

↓

Rust

Shared Core

Project
Geometry
Digitizer
Simulation
Export
Thread
Machine
```

---

# Purpose

The Mobile Experience provides a professional companion experience for Sewlio Studio on smartphones.

Unlike tablets and desktops, phones prioritize reviewing, making small edits, managing projects, and performing field workflows rather than creating complex embroidery designs from scratch.

The mobile experience should feel native while maintaining compatibility with the desktop and tablet applications.

---

# Objectives

The mobile application shall provide

- Project management
- Project review
- Stitch simulation
- Thread management
- Machine validation
- Basic vector editing
- Basic embroidery editing
- Export
- Project sharing

Complex digitizing remains optimized for tablets and desktops.

---

# Product Philosophy

Desktop

↓

Professional Production

---

Tablet

↓

Professional Creation

---

Phone

↓

Review • Approval • Minor Editing • Field Usage

---

# Supported Platforms

## iOS

iOS 18+

---

## Android

Android 14+

---

# Minimum Screen Size

6"

Recommended

6.5"+

---

# Supported Orientations

Portrait

Primary

---

Landscape

Supported

Simulation

Preview

Review

---

# Mobile Home

When the application launches

Display

```text
Recent Projects

↓

Templates

↓

Import

↓

Favorites

↓

Recovery

↓

Settings
```

---

# Mobile Navigation

Bottom Navigation

```text
Projects

Workspace

Simulation

Threads

Settings
```

Maximum

5 tabs.

---

# Mobile Workspace

Portrait

```text
+--------------------------------------+
| Top Bar                              |
+--------------------------------------+
|                                      |
|                                      |
|              Canvas                  |
|                                      |
|                                      |
+--------------------------------------+
| Bottom Tool Palette                  |
+--------------------------------------+
| Bottom Navigation                    |
+--------------------------------------+
```

---

Landscape

```text
+-----------------------------------------------+
| Toolbar                                       |
+-------------------+---------------------------+
| Tools             |                           |
|                   |        Canvas             |
|                   |                           |
+-------------------+---------------------------+
```

---

# FR-1301

## Project Browser

Priority

Critical

---

Supports

Browse

Search

Sort

Create

Duplicate

Delete

Archive

Recover

---

Displays

Thumbnail

Name

Machine

Modified

Stitch Count

---

# FR-1302

## Mobile Workspace

Priority

Critical

---

Supports

Canvas

Selection

Zoom

Pan

Rotate View

Object Selection

---

Workspace optimized for touch.

---

# FR-1303

## Basic Vector Editing

Priority

High

---

Supports

Move

Scale

Rotate

Duplicate

Delete

Node editing (simple)

Group

Ungroup

---

Complex path editing remains easier on tablet.

---

# FR-1304

## Basic Digitizing

Priority

High

---

Supports

Change Stitch Type

Change Density

Change Angle

Change Thread

Underlay

---

Does not expose every advanced property by default.

---

# FR-1305

## Quick Actions

Priority

Critical

---

Supports

Undo

Redo

Duplicate

Delete

Lock

Hide

Rename

Export

---

Quick actions appear in contextual toolbar.

---

# FR-1306

## Touch Gestures

Priority

Critical

---

Supports

Tap

Double Tap

Long Press

Pinch Zoom

Two Finger Pan

Drag

---

Future

Rotate Gesture

Custom Gestures

---

# FR-1307

## Mobile Simulation

Priority

Critical

---

Supports

Play

Pause

Restart

Timeline

Needle

Statistics

Jump Display

Thread Changes

---

Landscape recommended.

---

# FR-1308

## Thread Palette

Priority

Critical

---

Displays

Used Threads

Manufacturer

Code

Color

Length

---

Supports

Replace

Search

Filter

---

# FR-1309

## Machine Validation

Priority

Critical

---

Displays

Machine

Hoop

Warnings

Errors

Compatibility

---

Users can change machine profile.

---

# FR-1310

## Export

Priority

Critical

---

Supports

DST

PES

JEF

VP3

EXP

---

Uses native share sheet after export.

---

# FR-1311

## Import

Priority

Critical

---

Supports

SVG

PNG

JPEG

.embproj

---

Uses

Files App

Android File Picker

---

# FR-1312

## Share

Priority

Critical

---

Supports

Share Project

Share Export

Share Preview

Share Thumbnail

---

Uses native platform APIs.

---

# FR-1313

## Notifications

Priority

Medium

---

Displays

Export Complete

Recovery Available

Import Complete

Validation Errors

---

Uses native notification system.

---

# FR-1314

## Offline Mode

Priority

Critical

---

All functionality except optional sync works offline.

Projects remain fully editable.

---

# FR-1315

## Mobile Preferences

Priority

Medium

---

Supports

Theme

Language

Units

Gesture Settings

Toolbar Position

Default Export

---

# FR-1316

## Performance

Priority

Critical

---

Targets

Application Startup

<2 seconds

Project Open

<1 second

Canvas

60 FPS

Simulation

60 FPS

Tool Switching

Immediate

---

# FR-1317

## Battery Optimization

Priority

Critical

---

Reduce rendering while idle.

Pause simulations in background.

Suspend unnecessary background tasks.

---

# FR-1318

## Accessibility

Priority

Critical

---

Supports

VoiceOver

TalkBack

Large Fonts

High Contrast

Reduced Motion

Screen Reader

---

Minimum touch target

48 dp

---

# FR-1319

## File Integration

Priority

Critical

---

Supports

Files App

Google Drive

iCloud Drive

Dropbox

OneDrive

USB Storage (Android)

---

Projects remain portable.

---

# FR-1320

## Camera Integration

Priority

Medium

---

Supports

Capture reference images.

Import directly into project.

---

Future

Document scanner.

AI vectorization.

---

# Mobile Editing Guidelines

The mobile application prioritizes

Review

↓

Minor Edit

↓

Approve

↓

Export

rather than large-scale illustration.

---

Advanced workflows should naturally transition users to tablets or desktops.

---

# Memory Targets

Small Project

<300 MB

Medium Project

<500 MB

---

# AI Agent Rules

Mobile package owns

Navigation

Adaptive layouts

Gesture handling

Platform integrations

Camera

Share Sheet

---

Mobile package never owns

Geometry

Digitizer

Simulation Engine

Export Engine

Storage

---

All business logic remains inside the shared Rust core.

---

# Testing

Unit

Navigation

Gestures

Share

File Picker

Quick Actions

---

Golden

Portrait

Landscape

Dark Theme

Light Theme

Large Text

---

Integration

Open Project

Simulation

Export

Import

Thread Replacement

Validation

---

Performance

Large Project

Long Simulation

Export

Memory

---

Regression

Desktop

Tablet

Phone

must open identical projects with identical results.

---

# Acceptance Criteria

Mobile Experience is complete when

✓ Project browser implemented

✓ Touch-first workspace functional

✓ Basic editing supported

✓ Simulation fully operational

✓ Thread management available

✓ Machine validation integrated

✓ Export supported

✓ Offline workflow supported

✓ Native sharing implemented

✓ Accessibility requirements met

✓ Performance targets achieved

---

# Future Enhancements

- Apple Vision Pro companion
- AI voice commands
- Live camera tracing
- QR code project transfer
- NFC machine pairing
- Apple Shortcuts integration
- Android Quick Share
- Lock Screen widgets
- Wear OS / Apple Watch companion
- Live production monitoring
- Remote machine status
- Customer approval mode
