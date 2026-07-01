# Sewlio Studio
## Product Requirements Document (PRD)

**Version:** 1.0.0  
**Status:** Draft  
**Last Updated:** YYYY-MM-DD  
**Product Codename:** Sewlio Studio

---

# 1. Executive Summary

Sewlio Studio is an open-source, offline-first, professional embroidery design application built for modern operating systems and tablets.

Unlike traditional embroidery software that evolved from decades-old desktop applications, Sewlio Studio is designed from the ground up around modern UI principles, cross-platform support, high-performance computation, and AI-assisted development.

The application combines a Flutter-based user interface with a Rust embroidery engine to create a professional embroidery experience that is fast, intuitive, extensible, and portable.

---

# 2. Vision

Enable designers to create complete embroidery projects—from sketch to machine-ready output—without proprietary software or mandatory cloud services.

Sewlio Studio should become the Blender or Krita of embroidery software.

---

# 3. Mission

Create a platform that allows anyone to:

- Design
- Digitize
- Preview
- Simulate
- Export

professional embroidery designs on every major platform.

---

# 4. Product Goals

## Primary Goals

- Professional embroidery digitizing
- Modern vector editing
- Real-time stitch simulation
- High-performance rendering
- Cross-platform compatibility
- Offline-first workflow
- Local-first data ownership
- Open-source ecosystem

---

## Secondary Goals

- AI-assisted workflows
- Plugin ecosystem
- Automation
- Cloud synchronization (future)
- Collaboration (future)

---

# 5. Non Goals (MVP)

The following are intentionally excluded from the initial MVP:

- Team collaboration
- User accounts
- Cloud backend
- Marketplace
- Plugin system
- Machine connectivity
- AI auto-digitization
- Team libraries
- Real-time collaboration

---

# 6. Target Users

## Hobbyists

Users creating personal embroidery projects.

---

## Etsy Sellers

Small businesses creating embroidery products.

---

## Professional Digitizers

Users producing commercial embroidery files.

---

## Educational Institutions

Learning embroidery and digitizing.

---

## Makerspaces

Shared fabrication labs.

---

## Small Businesses

Embroidery shops.

---

# 7. Product Philosophy

Sewlio Studio follows six principles.

## Offline First

Everything works without internet.

---

## Local First

Users own their data.

---

## Tablet First

Touch interaction is a first-class citizen.

---

## Performance First

Performance is a feature.

---

## Embroidery First

Every feature must improve embroidery workflows.

---

## AI First Development

The architecture should support autonomous AI development.

---

# 8. Supported Platforms

## Desktop

Windows

macOS

Linux

---

## Mobile

iPadOS

Android Tablets

---

## Web

Flutter Web (CSR)

---

# 9. Technology Stack

UI

Flutter

Core Engine

Rust

Storage

libSQL (Turso-compatible)

Project Format

.embproj

Communication

FFI (desktop/mobile)

WASM (web)

---

# 10. Product Architecture

```
Flutter UI

↓

Application Layer

↓

Rust Engine

↓

Project Engine
Geometry
Digitizer
Simulation
Formats
Storage
```

Flutter owns presentation.

Rust owns business logic.

---

# 11. Product Workflow

```
Image

SVG

Sketch

↓

Vector Editor

↓

Digitizer

↓

Simulation

↓

Export

↓

DST

PES

JEF

VP3

EXP
```

---

# 12. Core Features

## Vector Editor

Professional drawing environment.

Supports:

- Pen
- Pencil
- Rectangle
- Ellipse
- Polygon
- Star
- Text
- SVG Import

---

## Digitizer

Converts vectors into embroidery stitches.

Supported stitch types:

Running

Fill

Satin

Bean

Motif

Edge Walk

Future:

Tatami

Cross Stitch

Chain Stitch

---

## Stitch Simulation

Real-time embroidery visualization.

Features:

Needle path

Animation

Thread path

Color sequence

Estimated time

Stitch count

Jump visualization

Trim visualization

---

## Machine Export

Formats:

DST

PES

JEF

VP3

EXP

XXX

HUS

Native format:

.embproj

---

# 13. Native Project Format

Every project is stored as

```
project.embproj
```

Internally

```
project.db

assets/

exports/

preview/

metadata.json

history/
```

Machine files are generated artifacts.

---

# 14. Workspace

The workspace consists of

Top Toolbar

Left Toolbox

Canvas

Properties Panel

Layer Panel

Color Panel

History

Bottom Timeline

Status Bar

---

# 15. Editor Modes

Selection

Node Editing

Drawing

Digitizing

Simulation

Export

Presentation

---

# 16. Canvas

Infinite canvas

High DPI

Smooth zoom

Pan

Rotation

Guides

Grid

Rulers

Snap

Hoop boundaries

---

# 17. Layer System

Supports

Vectors

Embroidery Objects

Reference Images

Text

Guides

Groups

Hidden Layers

Locked Layers

---

# 18. Selection

Single

Multi

Rectangle

Lasso

Select Similar

Select by Layer

Select by Color

Select by Stitch

---

# 19. Transformations

Move

Rotate

Scale

Mirror

Skew

Align

Distribute

Duplicate

---

# 20. Drawing Tools

Pen

Pencil

Rectangle

Rounded Rectangle

Ellipse

Polygon

Star

Bezier

Text

Image Import

SVG Import

---

# 21. Typography

Basic typography support.

Future:

Text on Path

Variable Fonts

OpenType

---

# 22. Color System

Thread Colors

Thread Libraries

Color Groups

Custom Palettes

Thread Mapping

---

# 23. Thread Libraries

Madeira

Brother

Janome

DMC

Isacord

Custom

---

# 24. Machine Profiles

Hoop Sizes

Thread Limits

Supported Formats

Stitch Limits

Warnings

---

# 25. Project Lifecycle

Create

Open

Save

Save As

Export

Duplicate

Archive

Recover

Delete

---

# 26. History

Unlimited Undo

Redo

Snapshots

Timeline

Recovery

---

# 27. Autosave

Automatic local save.

Recover after crash.

Never lose user work.

---

# 28. Storage

libSQL local database.

Portable project package.

Optional storage locations

Local Folder

Google Drive

Dropbox

OneDrive

iCloud Drive

---

# 29. Performance Goals

Startup

< 2 seconds

Save

< 500 ms

Export

100k stitches

< 2 seconds

Canvas

60 FPS

Large Projects

1 million stitches

---

# 30. Security

No mandatory accounts.

No telemetry by default.

No cloud dependency.

Projects remain user owned.

---

# 31. Accessibility

Keyboard navigation

Large UI

High contrast

Touch support

Stylus support

Screen readers where practical

---

# 32. Tablet Experience

Apple Pencil

Hover

Pressure

Tilt

Touch Gestures

Landscape

Portrait

Floating Inspector

Adaptive Panels

---

# 33. Desktop Experience

Keyboard shortcuts

Multi-window

Dockable panels

Native menus

Native dialogs

File associations

---

# 34. Phone Experience

Phones are companion devices.

Supported tasks:

View Projects

Basic Editing

Annotations

Thread Lookup

Export History

Machine Preview

Not intended for full production editing.

---

# 35. AI Features (Future)

Auto Digitize

Background Removal

Image Cleanup

Thread Optimization

Vector Cleanup

AI Suggestions

---

# 36. Future Cloud Features

Projects

Sync

Comments

Collaboration

Organizations

Version History

Sharing

---

# 37. Product Success Metrics

A beginner can create and export an embroidery design within 30 minutes.

Professional digitizers can complete commercial work without proprietary software.

The application performs consistently across all supported platforms.

---

# 38. Acceptance Criteria

The MVP is considered complete when a user can:

- Create a project
- Draw or import an SVG
- Edit vector geometry
- Convert vectors to running and fill stitches
- Preview stitch output
- Save the project as `.embproj`
- Reopen the project
- Export a DST file
- Open the exported file in a compatible embroidery viewer or machine without errors

---

# 39. Future Vision

Sewlio Studio is more than an application.

It is a platform.

The Rust engine should eventually power:

- Desktop applications
- Mobile applications
- Web applications
- CLI tools
- Server-side converters
- Automation pipelines
- Plugin SDKs
- AI-assisted embroidery services

The Flutter application is one client of that platform.

The long-term objective is to establish Sewlio Studio as the reference open-source embroidery ecosystem.
