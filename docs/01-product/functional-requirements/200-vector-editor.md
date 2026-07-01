# Functional Requirements
## FR-200 Vector Editor

**Document ID:** FR-200  
**Title:** Vector Editor  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Editor Team

**Primary Packages**

```
Flutter

editor_ui
canvas
selection
tools
layers
inspector

↓

Rust

geometry
document
commands
history
renderer
```

---

# Purpose

The Vector Editor is the foundation of Sewlio Studio.

Everything that ultimately becomes stitches starts as editable vector geometry.

Unlike traditional embroidery software, Sewlio Studio should provide a modern vector editing experience inspired by:

- Figma
- Affinity Designer
- Adobe Illustrator
- Procreate
- Inkscape

The vector editor should feel like a professional illustration tool while remaining embroidery-first.

---

# Goals

The editor should allow users to:

- Draw
- Import
- Edit
- Organize
- Transform
- Prepare

vector artwork before digitization.

---

# Core Principles

## Non-destructive

Editing vectors should never destroy source geometry.

---

## Precision

Support pixel-level and sub-pixel precision.

Internally use floating-point coordinates.

---

## Live Editing

Changes appear immediately.

No Apply button.

---

## Infinite Canvas

Users never run out of space.

Hoops are overlays, not canvas limits.

---

## Undoable

Every modification becomes a command.

---

## Platform Independent

Vector editing must behave identically on:

- Desktop
- Web
- Tablet

---

# Editor Architecture

```
Flutter Canvas

↓

Interaction Layer

↓

Command Dispatcher

↓

Rust Geometry Engine

↓

Document Model

↓

Renderer
```

Flutter owns interaction.

Rust owns geometry.

---

# Coordinate System

Internal units

Millimeters (mm)

Display

Pixels

Conversions handled automatically.

---

Origin

Default

Top Left

Future

User configurable.

---

Precision

Minimum

0.01 mm

---

# Document Structure

```
Project

↓

Artboards (future)

↓

Layers

↓

Groups

↓

Objects

↓

Nodes
```

---

# Supported Object Types

## MVP

Rectangle

Ellipse

Line

Bezier Path

Polygon

Text

Reference Image

SVG Group

---

Future

Spiral

Star

Arc

Mesh

Symbols

Reusable Components

Patterns

---

# Object Model

Every object contains

```
UUID

Type

Layer

Bounds

Transform

Visibility

Lock State

Metadata

Style

Geometry
```

Objects remain editable until digitized.

---

# Drawing Tools

---

## FR-201

### Selection Tool

Priority

Critical

Supports

Single

Multi

Drag Selection

Keyboard Selection

Touch Selection

---

Acceptance Criteria

✓ Single click selects

✓ Shift adds selection

✓ Ctrl/Cmd toggles selection

✓ Touch tap selects

---

## FR-202

### Pen Tool

Creates

Bezier paths.

Supports

Corner node

Smooth node

Close path

Continue path

Cancel

---

Acceptance Criteria

✓ Unlimited nodes

✓ Bezier handles editable

✓ Path closes correctly

---

## FR-203

### Pencil Tool

Freehand drawing.

Produces smoothed Bezier paths.

Configurable

Smoothing

Tolerance

Simplification

---

Acceptance Criteria

✓ Stylus optimized

✓ Mouse supported

✓ Touch supported

---

## FR-204

### Rectangle Tool

Supports

Rectangle

Rounded Rectangle

Future

Independent corner radius

---

Acceptance Criteria

✓ Editable after creation

✓ Resize handles

✓ Rotation

---

## FR-205

### Ellipse Tool

Supports

Ellipse

Circle

Arc (future)

---

Acceptance Criteria

✓ Shift constrains circle

✓ Editable

---

## FR-206

### Polygon Tool

Supports

Configurable sides

Future

Star

Gear

---

Acceptance Criteria

Minimum

3 sides

---

## FR-207

### Text Tool

Supports

Text objects.

Future

Text on path

Variable fonts

OpenType

---

Acceptance Criteria

Editable.

---

# Object Selection

---

Supported

Single

Multiple

Lasso

Rectangle

Select Similar

Select Layer

Select Type

Select Color

Select Locked (future)

---

Selection Overlay

Displays

Bounds

Handles

Rotation

Center

---

Acceptance Criteria

Selection visible at all zoom levels.

---

# Transformations

---

Supported

Move

Rotate

Scale

Flip Horizontal

Flip Vertical

Duplicate

Align

Distribute

Future

Perspective

Warp

Skew

---

Transforms are non-destructive.

---

Acceptance Criteria

Undo supported.

Inspector updates.

---

# Node Editing

Nodes support

Move

Delete

Insert

Convert

Break

Join

Smooth

Corner

Symmetric

---

Bezier handles

Editable.

---

Acceptance Criteria

Path updates live.

---

# Path Operations

---

Supported

Join

Split

Reverse

Close

Open

Simplify

Offset (future)

---

Acceptance Criteria

Path validity preserved.

---

# Boolean Operations

Future Alpha

Union

Subtract

Intersect

Exclude

Divide

---

Operations remain editable where possible.

---

# Snapping

Supported

Grid

Guides

Nodes

Objects

Bounds

Centers

Hoop

Angles

---

Future

Smart Guides

---

Acceptance Criteria

Snapping configurable.

---

# Guides

Supports

Horizontal

Vertical

Center

Custom

---

Future

Perspective

---

Guides never export.

---

# Grid

Supports

Visibility

Spacing

Subdivisions

Color

Snap

---

Future

Isometric

Polar

---

# Rulers

Horizontal

Vertical

Units

mm

Future

Inches

---

# Layers

Objects belong to one layer.

Supports

Move

Duplicate

Group

Ungroup

Hide

Lock

---

# Groups

Objects grouped remain individually editable.

---

Nested groups supported.

---

# Styles

Objects support

Stroke

Fill

Opacity

Visibility

Lock

---

Future

Effects

Shadows

Blur

---

# Images

Supported

PNG

JPEG

SVG

---

Images remain reference objects.

Never become stitches automatically.

---

# SVG Import

Supports

Paths

Shapes

Groups

Transforms

Basic text

---

Unsupported features

Reported.

---

Import never crashes.

---

# Clipboard

Supports

Copy

Paste

Duplicate

Paste In Place

---

Future

Copy Style

Paste Style

---

# Alignment

Supports

Left

Center

Right

Top

Middle

Bottom

Distribute

---

# Zoom

Supports

Zoom In

Zoom Out

Fit Selection

Fit Hoop

Fit Artwork

100%

200%

400%

---

Zoom independent of UI scale.

---

# Pan

Supports

Mouse

Trackpad

Touch

Stylus

Keyboard

---

# Rotation

Viewport rotation.

Not object rotation.

---

Future

Gesture support.

---

# Search

Future

Search

Objects

Layers

Names

Types

---

# Object Naming

Objects may be named.

Example

```
Logo Outline

Left Sleeve

Text

Border
```

---

# Metadata

Objects may contain

Description

Tags

Notes

Custom Properties

Future

Automation metadata

---

# Validation

Invalid geometry should be detected.

Examples

Empty paths

Self intersections (warning)

Duplicate nodes

Zero-length segments

---

System should assist rather than block.

---

# Performance Targets

1000 objects

↓

60 FPS

---

10000 nodes

↓

Interactive editing

---

Selection

<16 ms

---

Move

Immediate

---

Undo

<100 ms

---

# Accessibility

Supports

Keyboard

Touch

Stylus

Screen reader summaries

High contrast

Large hit targets

---

Reference

accessibility.md

---

# AI Agent Rules

Flutter owns

Canvas

Selection UI

Tools

Gestures

Inspector binding

---

Rust owns

Geometry

Paths

Transforms

Validation

Bounds

Boolean operations

Serialization

---

Never

Perform geometry calculations inside Flutter widgets.

---

# Testing

Unit

Geometry

Selection

Transforms

Node editing

---

Golden

Canvas

Selection

Handles

Guides

Grid

---

Integration

Import SVG

Edit path

Undo

Redo

Transform

Copy

Paste

---

Performance

1000 objects

10000 nodes

Large SVG

---

# Acceptance Criteria

The Vector Editor is complete when

✓ Users can draw basic vector artwork

✓ SVG imports correctly

✓ Objects remain editable

✓ Selection behaves consistently

✓ Transformations are non-destructive

✓ Node editing is responsive

✓ Undo/Redo works

✓ Infinite canvas functions correctly

✓ Geometry calculations reside entirely in Rust

✓ All editing operations are deterministic

---

# Future Enhancements

- Live path effects
- Variable-width strokes
- Shape Builder tool
- Pattern fills
- Symbols and reusable assets
- Mesh gradients
- Parametric shapes
- Constraint system
- Auto-layout
- Collaborative cursors
- AI-assisted vector cleanup
- Procedural geometry
