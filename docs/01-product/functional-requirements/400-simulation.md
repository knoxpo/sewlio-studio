# Functional Requirements
## FR-400 Stitch Simulation Engine

**Document ID:** FR-400  
**Title:** Stitch Simulation Engine  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Simulation Team

**Primary Packages**

```text
Rust

simulation/
stitch-ir/
machine/
renderer/
timeline/

↓

Flutter

simulation_ui/
timeline_ui/
playback_controls/
statistics/
```

---

# Purpose

The Stitch Simulation Engine provides a realistic visualization of how an embroidery machine will execute a design before exporting it.

Unlike a simple preview, the simulation is intended to answer questions such as:

- Will the stitch order produce the desired result?
- Are there unnecessary jumps?
- Are trims occurring at the correct locations?
- Is the travel path efficient?
- Will thread changes occur as expected?
- Is the design likely to sew correctly?

The simulation is a visualization of the stitch graph and machine instructions.

It never modifies the design.

---

# Objectives

The simulation should:

- Be accurate
- Be deterministic
- Be interactive
- Be real-time
- Never regenerate stitches
- Remain independent from export formats

---

# Simulation Philosophy

Simulation is a **consumer** of the Stitch IR.

```text
Vector

↓

Digitizer

↓

Stitch IR

├── Export
├── Statistics
├── Validation
└── Simulation
```

Simulation should never contain embroidery generation logic.

---

# Architecture

```text
Stitch IR

↓

Simulation Builder

↓

Simulation Timeline

↓

Playback Engine

↓

Flutter Renderer
```

---

# Simulation Pipeline

```text
Embroidery Objects

↓

Stitch IR

↓

Simulation Graph

↓

Playback Frames

↓

Canvas Renderer

↓

User Interaction
```

---

# Simulation Graph

Simulation Graph is an immutable playback model.

Contains:

- Stitch sequence
- Needle positions
- Thread colors
- Jump events
- Trim events
- Color changes
- Timing information
- Machine commands

---

# Simulation Modes

## MVP

Normal

Displays complete embroidery process.

---

## Future

Wireframe

Thread Only

Needle Only

Travel Path

Heat Map

Fabric Stretch

Machine View

---

# FR-401

## Build Simulation

Priority

Critical

---

Description

Generate a simulation graph from the Stitch IR.

---

Input

Stitch IR

---

Output

Simulation Graph

---

Acceptance Criteria

✓ Deterministic

✓ Cached

✓ Incremental

✓ No mutation

---

# FR-402

## Playback

Priority

Critical

---

Supports

Play

Pause

Resume

Stop

Restart

Step Forward

Step Backward

Jump to Start

Jump to End

---

Playback never changes project state.

---

Acceptance Criteria

✓ Smooth playback

✓ Stable frame timing

✓ Immediate response

---

# FR-403

## Timeline

Priority

Critical

---

Displays

Current Stitch

Progress

Needle Position

Thread Color

Elapsed Time

Remaining Time

---

Supports

Scrubbing

Click to seek

Keyboard navigation

Touch dragging

---

Acceptance Criteria

✓ Accurate seeking

✓ Smooth interaction

---

# FR-404

## Playback Speed

Priority

Critical

---

Supports

0.25×

0.5×

1×

2×

4×

8×

16×

Maximum Speed

---

Future

Real Machine Speed

Custom Speed

---

Acceptance Criteria

Changing playback speed never changes simulation accuracy.

---

# FR-405

## Stitch Rendering

Priority

Critical

---

Display

Completed stitches

Current stitch

Future stitches

Current needle

Travel path

Hoop

Reference artwork (optional)

---

Rendering layers

```text
Background

↓

Grid

↓

Hoop

↓

Reference Images

↓

Vectors (optional)

↓

Completed Stitches

↓

Current Stitch

↓

Needle

↓

Selection

↓

HUD
```

---

Acceptance Criteria

✓ Smooth rendering

✓ High DPI

✓ Zoom independent

---

# FR-406

## Needle Animation

Priority

Critical

---

Display

Needle position

Current penetration point

Travel movement

---

Future

Needle depth

Needle bounce

Machine head

---

Acceptance Criteria

Needle follows stitch graph exactly.

---

# FR-407

## Thread Visualization

Priority

Critical

---

Display

Current thread

Completed thread

Upcoming thread

Color transitions

---

Thread colors come exclusively from Thread Library.

---

# FR-408

## Jump Visualization

Priority

Critical

---

Display

Jump stitches

Travel movement

Jump distance

---

Visualization

Dashed line

Configurable color

---

Acceptance Criteria

Jumps easily distinguishable.

---

# FR-409

## Trim Visualization

Priority

Critical

---

Display

Trim locations

Trim icon

Timeline marker

---

Acceptance Criteria

Trim count matches Stitch IR.

---

# FR-410

## Color Changes

Priority

Critical

---

Simulation pauses optionally

↓

Color change occurs

↓

Playback resumes

---

Future

Interactive thread replacement.

---

# FR-411

## Statistics Overlay

Priority

Critical

---

Displays

Current stitch

Total stitches

Current thread

Current color

Jump count

Trim count

Elapsed simulation time

Remaining simulation time

Completion %

---

Updates live.

---

# FR-412

## Simulation Camera

Priority

Critical

---

Supports

Pan

Zoom

Rotate View

Fit Hoop

Fit Design

Reset Camera

---

Camera movement independent of playback.

---

# FR-413

## Selection During Simulation

Priority

High

---

Users may select

Embroidery Objects

Vectors

Thread Colors

Timeline

---

Selection highlights associated stitches.

---

# FR-414

## Pause Points

Priority

High

---

Supports pausing on

Thread change

Trim

Jump

Layer

User marker (future)

---

# FR-415

## Bookmarks

Priority

Future

---

User may create

Named bookmarks

↓

Jump directly

---

# Simulation Cache

Simulation Graph should be cached.

Cache invalidated only when

- Stitch IR changes
- Thread assignments change
- Machine profile affects simulation
- User changes visualization settings requiring rebuild

Camera movement must not invalidate cache.

---

# Incremental Updates

Changing one embroidery object

↓

Rebuild only affected simulation segment.

---

Never rebuild complete project unless required.

---

# Rendering Quality

Modes

Draft

Normal

High

Ultra

---

Draft

Optimized for editing.

---

High

Optimized for presentation.

---

# Background Simulation

Simulation generation should execute in background.

UI remains interactive.

---

# Visualization Options

Users may toggle

Grid

Hoop

Vectors

Reference Image

Completed Stitches

Future Stitches

Needle

Travel Path

Jump Lines

Trim Icons

Thread Labels

Statistics

---

# Timeline Markers

Timeline displays

Thread Changes

Jump

Trim

Bookmarks

Warnings

Machine Events

---

# Machine Events

Simulation supports

Needle Down

Needle Up

Jump

Trim

Color Change

Stop

End Design

---

Future

Machine-specific commands.

---

# Export Verification

Simulation must match exported stitch order.

Mismatch is a bug.

---

# Fabric Preview

Future

Fabric texture

Fabric color

Stretch simulation

Pull compensation preview

Lighting

---

# Thread Rendering

Future

Thread thickness

Thread sheen

Lighting

Shadowing

Thread overlap

---

# Presentation Mode

Future

Hide UI

Fullscreen

Loop playback

Auto camera

Customer preview

---

# Error Handling

Invalid Stitch IR

↓

Simulation unavailable

↓

Readable message

↓

Retry after regeneration

---

Corrupt simulation cache

↓

Discard cache

↓

Rebuild

---

# Performance Targets

Generate simulation

100k stitches

<250 ms

---

Playback

60 FPS minimum

120 FPS preferred

---

Camera movement

<16 ms

---

Timeline seek

<50 ms

---

Pause

Immediate

---

Memory

Reuse immutable simulation graph.

Avoid duplicate stitch storage.

---

# AI Agent Rules

Simulation package owns

Playback

Timeline

Rendering model

Statistics

Simulation graph

---

Simulation package never owns

Digitization

Geometry

Export

Project persistence

---

Flutter owns

Playback controls

Timeline widgets

Canvas drawing

HUD

---

Rust owns

Simulation graph

Playback engine

Statistics

Frame generation

---

# Testing

Unit

Playback

Timeline

Simulation graph

Statistics

Needle position

Jump visualization

Trim visualization

---

Golden

Known stitch graph

↓

Known simulation frames

---

Integration

Digitizer

↓

Simulation

↓

Export

↓

Validation

---

Performance

100k stitches

500k stitches

1 million stitches

---

Regression

Simulation output identical for identical Stitch IR.

---

# Accessibility

Supports

Keyboard controls

Touch controls

Stylus interaction

Reduced motion

High contrast

Screen reader summaries

Playback controls fully keyboard accessible.

---

# Acceptance Criteria

Simulation Engine is complete when

✓ Playback is deterministic

✓ Timeline functions correctly

✓ Needle follows stitch order

✓ Thread changes are visualized

✓ Jumps and trims are displayed

✓ Statistics update live

✓ Camera controls work smoothly

✓ Simulation never mutates project data

✓ Performance targets are met

✓ Tests pass

---

# Future Enhancements

- Fabric deformation simulation
- Real machine timing profiles
- Thread tension visualization
- Needle penetration depth
- Multi-head machine simulation
- Slow-motion analysis
- AI quality analysis
- Collision detection
- Hoop repositioning preview
- Multi-hoop simulation
- Thread break prediction
- Stitch density heat maps
- 3D embroidery visualization
- VR/AR preview
