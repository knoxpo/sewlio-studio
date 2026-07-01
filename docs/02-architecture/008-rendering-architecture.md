# Architecture
## ARCH-008 Rendering Architecture

**Document ID:** ARCH-008  
**Title:** Rendering Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Rendering Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-005 Document Model
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
```

---

# Purpose

The Rendering Architecture defines how Sewlio Studio transforms domain data into pixels.

Rendering is intentionally isolated from:

- Business logic
- Document mutation
- Digitizing
- Export
- Storage
- Commands

Rendering is a consumer of immutable data.

It never owns the project.

---

# Goals

The renderer shall

- Support 60–120 FPS interaction
- Support very large embroidery projects
- Render millions of stitches
- Support desktop, tablet and mobile
- Support zoom from 1% to 6400%
- Support GPU acceleration
- Support incremental rendering
- Support multiple render modes
- Support future WebGPU rendering

---

# Design Philosophy

Rendering is a projection of the Document.

The renderer never asks:

> "How should I change the project?"

Instead it asks:

> "Given this immutable state, what should I draw?"

---

# Architectural Layers

```text
Flutter UI

↓

Canvas Widget

↓

Render Coordinator

↓

Scene Builder

↓

Render Graph

↓

GPU
```

The renderer is stateless.

All persistent state belongs to the Document.

---

# High-Level Pipeline

```text
Document

↓

Geometry IR

↓

Renderable Scene

↓

Render Graph

↓

Flutter Canvas

↓

GPU

↓

Display
```

Simulation follows a different pipeline.

---

# Rendering Responsibilities

Rendering owns

- Drawing
- Culling
- Visibility
- GPU batching
- Dirty region rendering
- Viewport transforms
- Selection overlays
- Guides
- Rulers
- Preview rendering

Rendering never owns

- Geometry
- Stitch generation
- Commands
- Events
- Storage
- Export

---

# Rendering Modes

The renderer supports multiple modes.

## Geometry Mode

Displays

- Paths
- Shapes
- Images
- Text
- Guides

---

## Stitch Preview

Displays

- Running stitches
- Satin stitches
- Fill stitches
- Underlay
- Jump stitches

Generated from Stitch IR.

---

## Simulation Mode

Displays

Playback IR.

Needle animation.

Thread animation.

Fabric visualization.

---

## Print Preview

Displays

Printable layout.

Margins.

Registration marks.

---

## Machine Preview

Displays

Hoop boundaries.

Machine limits.

Warnings.

---

# Scene Graph

Rendering does not consume the Document directly.

Instead

```text
Document

↓

Scene Builder

↓

Renderable Scene

↓

Renderer
```

Scene Graph contains only drawing information.

---

# Renderable Scene

Contains

```text
Layers

Nodes

Transforms

Styles

Visibility

Render Order

Selection

Bounding Boxes
```

No business objects.

---

# Render Node

Every drawable object becomes

```text
Render Node

↓

Transform

Geometry

Style

Visibility

Children
```

Render Nodes are immutable.

---

# Render Graph

The renderer organizes Render Nodes into a graph.

```text
Scene

↓

Layers

↓

Nodes

↓

GPU Commands
```

---

# Coordinate Systems

The renderer supports

```text
Document Space

↓

Workspace Space

↓

Viewport Space

↓

Device Space

↓

Screen Space
```

Transformations are performed incrementally.

---

# Viewport

Viewport owns

```text
Zoom

Pan

Rotation (future)

Device Scale

Visible Region
```

Viewport belongs to Workspace.

Not Document.

---

# Camera

The renderer uses a virtual camera.

```text
Camera

↓

Projection

↓

Viewport

↓

Screen
```

Supports

- Smooth zoom
- Animated pan
- Fit to screen
- Zoom to selection

---

# Layer Rendering

Layers render independently.

```text
Layer

↓

Visible?

↓

Dirty?

↓

Render
```

Hidden layers skipped.

Locked layers still rendered.

---

# Dirty Region Rendering

Only changed regions redraw.

```text
Geometry Changed

↓

Bounding Box

↓

Dirty Region

↓

Redraw
```

Entire canvas is never redrawn unless required.

---

# Render Caching

Supports

```text
Layer Cache

↓

Path Cache

↓

Text Cache

↓

Stitch Cache

↓

Bitmap Cache
```

Caches invalidated by Events.

---

# Level of Detail (LOD)

Rendering adapts to zoom.

Low Zoom

- Simplified paths
- Reduced stitch detail

Medium Zoom

- Accurate paths
- Representative stitches

High Zoom

- Individual stitches
- Needle points
- Direction arrows

Extreme Zoom

- Stitch IDs
- Control points
- Hit testing overlays

---

# Stitch Rendering

Consumes

```text
Stitch IR

↓

Renderable Stitch Mesh

↓

GPU
```

Never regenerates stitches.

---

# Simulation Rendering

Consumes

```text
Playback IR

↓

Playback Scene

↓

Animation

↓

GPU
```

Simulation never reads Geometry IR.

---

# Text Rendering

Supports

- Native fonts
- Outlined text
- Imported fonts
- Future embroidery fonts

Text caches separately.

---

# Image Rendering

Supports

- PNG
- JPEG
- SVG
- WebP

Images decode asynchronously.

Large images use mipmaps.

---

# Selection Rendering

Selection is a render overlay.

Contains

- Bounding boxes
- Handles
- Rotation gizmos
- Resize handles
- Control points

Selection never belongs to Geometry.

---

# Guides

Guides render independently.

```text
Workspace

↓

Guides

↓

Overlay
```

Not stored in Geometry.

---

# Grid

Grid generated procedurally.

Not stored.

Supports

- Dot grid
- Line grid
- Adaptive spacing

---

# Overlay System

Separate overlay renderer.

Examples

- Selection
- Rulers
- Guides
- Measurements
- Snapping hints
- Machine warnings

---

# Render Coordinator

Coordinates rendering.

Responsibilities

- Scene updates
- Cache invalidation
- Dirty regions
- Scheduling
- Performance monitoring

Contains no drawing logic.

---

# Rendering Scheduler

Prioritizes work.

```text
User Interaction

↓

Visible Region

↓

Selection

↓

Background Rendering

↓

Thumbnail Updates
```

Interaction always has priority.

---

# Multi-threading

UI Thread

```text
Flutter

↓

Frame Submission
```

Worker Threads

```text
Scene Building

Text Layout

Image Decode

Stitch Mesh

LOD Generation

Thumbnail Rendering
```

GPU submission occurs on the UI thread.

---

# GPU Strategy

Preferred backend

Flutter Impeller

Future

- WebGPU
- Metal
- Vulkan
- Direct3D
- OpenGL (fallback)

Renderer abstracts GPU APIs.

---

# Render Services

```text
Render Coordinator

↓

Scene Builder

↓

Cache Manager

↓

Overlay Renderer

↓

GPU Backend
```

Each service owns one responsibility.

---

# Render Statistics

Collect

- Frame Time
- FPS
- Draw Calls
- Visible Nodes
- GPU Memory
- Cache Hits
- Dirty Regions

Available through diagnostics.

---

# Performance Targets

Canvas Interaction

120 FPS (target)

Minimum

60 FPS

---

Zoom

<16 ms

---

Pan

<16 ms

---

Scene Build

Background

---

Dirty Region Update

<4 ms

---

Selection Update

Immediate

---

# Memory Targets

Geometry cache

Adaptive

---

Stitch cache

Adaptive

---

Images

LRU cache

---

GPU memory

Bounded

---

# Accessibility

Supports

- High contrast
- Reduced motion
- Large cursor
- Touch targets
- Screen readers (UI only)

Rendering never embeds accessibility logic.

---

# Testing

Renderer requires

- Golden image tests
- Performance benchmarks
- Zoom tests
- Pan tests
- LOD tests
- GPU stress tests
- Memory leak tests
- Large project tests

---

# AI Agent Rules

Rendering owns

- Drawing
- Scene graph
- GPU
- Caching
- LOD
- Overlays

Rendering never owns

- Geometry
- Stitch generation
- Simulation logic
- Commands
- Export
- Storage

---

# Architectural Constraints

1. Rendering never mutates the Document.
2. Rendering consumes immutable IRs.
3. Scene Graph is separate from the Document.
4. Viewport belongs to Workspace.
5. Selection is an overlay.
6. Dirty region rendering is mandatory.
7. GPU implementation is abstracted.
8. Rendering is deterministic.
9. Simulation uses Playback IR only.
10. Stitch rendering uses Stitch IR only.
11. Geometry rendering uses Geometry IR only.
12. Rendering must remain independently testable.

---

# Future Enhancements

- WebGPU renderer
- HDR rendering
- Fabric shaders
- Realistic thread lighting
- Shadow rendering
- Ambient occlusion
- 3D embroidery preview
- Multi-monitor rendering
- Remote rendering
- GPU compute stitch visualization

---

# Acceptance Criteria

The Rendering Architecture is complete when

✓ Rendering is fully separated from business logic.

✓ Scene Graph is generated from immutable IRs.

✓ Dirty region rendering minimizes redraw work.

✓ Multiple rendering modes are supported.

✓ Stitch rendering consumes Stitch IR only.

✓ Simulation rendering consumes Playback IR only.

✓ Viewport and overlays remain workspace-specific.

✓ GPU backend is abstracted.

✓ Rendering scales to large projects.

✓ The renderer is independently testable and platform-independent.
