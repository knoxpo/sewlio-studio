# Functional Requirements
## FR-300 Digitizer Engine

**Document ID:** FR-300  
**Title:** Digitizer Engine  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Rust Digitizer Team

**Primary Packages**

```
Rust

digitizer/
stitch/
geometry/
simulation/
machine/
validation/
document/

↓

Flutter

digitizer_ui/
property_editor/
preview/
```

---

# Purpose

The Digitizer Engine is the heart of Sewlio Studio.

It transforms editable vector geometry into machine-readable embroidery instructions.

Unlike traditional embroidery software, the digitizer should be:

- Deterministic
- Non-destructive
- Real-time
- Extensible
- Platform-independent

The editable vector artwork always remains the source of truth.

Generated stitches are derived artifacts.

---

# Design Philosophy

```
Vector Objects

↓

Digitizer

↓

Embroidery Objects

↓

Simulation

↓

Machine Export
```

Users should never directly edit machine stitches during MVP.

They edit embroidery objects and their parameters.

The engine regenerates stitches automatically.

---

# Architecture

```
Vector Geometry

↓

Geometry Analysis

↓

Digitizer Pipeline

↓

Stitch Graph

↓

Optimization

↓

Simulation

↓

Export
```

---

# Core Principles

## Deterministic

Identical input must always produce identical stitch output.

---

## Non-destructive

Original vectors remain editable.

Changing stitch parameters regenerates stitches.

---

## Incremental

Only affected embroidery objects should regenerate.

Never regenerate the whole project unnecessarily.

---

## Multi-threaded

Digitization runs on Rust worker threads.

Flutter UI remains responsive.

---

## Extensible

Adding a new stitch algorithm should not require changes to existing ones.

---

# Embroidery Object Model

The document contains two primary object types.

```
Vector Object

↓

Digitizer

↓

Embroidery Object

↓

Stitch Graph
```

---

Each embroidery object stores:

```
UUID

Source Vector ID

Digitizer Type

Parameters

Thread Color

Generated Stitch Graph

Statistics

Warnings

Metadata
```

---

# Stitch Graph

The stitch graph is an internal representation.

```
Embroidery Object

↓

Stitch Graph

↓

Machine Format
```

Each node represents a stitch command.

---

Each stitch contains

```
Position

Thread Index

Needle Command

Jump

Trim

Tie In

Tie Off

Metadata
```

---

# Stitch Types

## MVP

Running Stitch

Fill Stitch

---

## Alpha

Satin Stitch

Bean Stitch

Edge Walk

Center Walk

Motif Stitch

---

## Future

Tatami

Cross Stitch

Chain Stitch

Feather Stitch

Ripple Fill

Gradient Fill

Programmable Stitch

---

# Digitizer Pipeline

```
Vector

↓

Validation

↓

Geometry Analysis

↓

Parameter Resolution

↓

Stitch Generation

↓

Optimization

↓

Statistics

↓

Simulation Cache

↓

Export Ready
```

---

# FR-301

## Running Stitch

Priority

Critical

---

Purpose

Convert an open or closed vector path into a running stitch sequence.

---

Supported Input

Bezier Path

Polyline

Line

Closed Path

---

Parameters

Stitch Length

Start Point

End Point

Tie In

Tie Off

Lock Stitch

Trim

Jump

---

Outputs

Ordered stitch graph.

---

Validation

Path must contain

Minimum

2 nodes.

---

Acceptance Criteria

✓ Deterministic

✓ Direction preserved

✓ Editable

✓ Undo supported

✓ Export supported

---

# FR-302

## Fill Stitch

Priority

Critical

---

Purpose

Convert a closed region into fill stitches.

---

Supported Geometry

Closed Path

Polygon

Rectangle

Ellipse

---

Parameters

Density

Angle

Spacing

Underlay

Compensation

Edge Compensation

Fill Pattern

---

Validation

Shape must be closed.

---

Acceptance Criteria

✓ Closed region validated

✓ Density respected

✓ Angle respected

✓ Live preview

---

# FR-303

## Satin Stitch

Priority

Alpha

---

Supports

Column

Centerline

Variable Width

Split Satin

Compensation

---

Acceptance Criteria

Editable.

---

# FR-304

## Bean Stitch

Priority

Alpha

---

Parameters

Pass Count

Stitch Length

---

Acceptance Criteria

Repeat path correctly.

---

# FR-305

## Underlay

Priority

Alpha

---

Supported Types

Center Walk

Edge Walk

Zigzag

Double Zigzag

---

Underlay generated before top stitching.

---

# FR-306

## Pull Compensation

Priority

Alpha

---

Supports

Positive

Negative

Automatic (future)

---

Compensation stored per embroidery object.

---

# FR-307

## Density

Supported

Manual

Preset

Future

Fabric-based

---

Units

mm

---

Validation

Minimum density.

Maximum density.

---

# FR-308

## Stitch Angle

Supports

0°

360°

Future

Gradient angles.

---

# FR-309

## Stitch Direction

Supports

Forward

Reverse

Custom start point

---

Direction preserved after regeneration.

---

# FR-310

## Stitch Ordering

Project stores explicit embroidery order.

Supports

Move Earlier

Move Later

Drag Drop

Automatic Optimize (future)

---

Order affects

Simulation

Export

Thread Changes

---

# Regeneration

Regeneration occurs when

Vector changes

Density changes

Angle changes

Underlay changes

Thread changes (statistics only)

Machine profile changes

---

Only affected objects regenerate.

---

# Stitch Statistics

Each embroidery object stores

Stitch Count

Thread Length

Bounding Box

Estimated Time

Jump Count

Trim Count

Color Index

---

Statistics update automatically.

---

# Validation

Validation levels

Healthy

↓

Warning

↓

Recoverable

↓

Error

---

Examples

Open fill region

↓

Error

---

Too many stitches

↓

Warning

---

Tiny segments

↓

Warning

---

# Optimization

MVP

Basic optimization.

---

Future

Travel optimization

Thread optimization

Jump reduction

Color optimization

Automatic ordering

---

# Machine Constraints

Digitizer must validate

Hoop

Stitch count

Jump distance

Needle limits

Thread changes

---

Warnings shown before export.

---

# Regeneration Cache

Each embroidery object maintains

```
Source Hash

↓

Parameter Hash

↓

Generated Stitch Graph

↓

Statistics
```

If hashes unchanged

↓

Reuse cache.

---

# Incremental Updates

Changing one embroidery object

↓

Regenerate one object

↓

Do not regenerate project.

---

# Preview Quality

Preview modes

Draft

Normal

High

Future

Machine Accurate

---

Draft prioritizes responsiveness.

---

# Simulation Integration

Digitizer outputs

Simulation graph.

Simulation never re-generates stitches.

---

# Export Integration

Digitizer outputs normalized stitch graph.

Machine exporters transform graph into

DST

PES

JEF

VP3

EXP

XXX

HUS

---

Exporters never regenerate stitches.

---

# Thread Assignment

Embroidery objects reference

Thread Library

↓

Thread Entry

↓

Machine Color

---

Changing thread updates

Statistics

Simulation

Export

---

# Fabric Profiles

Future

Cotton

Denim

Leather

Canvas

Stretch Fabric

Fleece

Silk

---

Profiles adjust

Density

Compensation

Underlay

---

# Presets

Future

Hat

Patch

Shirt

Jacket

Sleeve

Left Chest

Large Back

---

# Error Handling

Invalid vector

↓

Readable explanation

↓

Suggested correction

---

Failed generation

↓

Object remains editable

↓

Previous valid result retained

---

# Performance Targets

Running Stitch

1000 paths

<100 ms

---

Fill Stitch

100 regions

<300 ms

---

Large Project

100k stitches

Interactive

---

1 million stitches

Usable

---

Memory

Avoid duplicate stitch arrays.

Reuse buffers where practical.

---

# AI Agent Rules

Digitizer package owns

Algorithms

Stitch graph

Generation

Optimization

Validation

Statistics

---

Digitizer package never owns

Canvas

Flutter widgets

Menus

Dialogs

File management

---

Geometry package provides

Curves

Bounds

Intersections

Sampling

Transforms

---

Machine package provides

Format constraints

Needle commands

Thread limits

Export capabilities

---

# Testing

Unit

Running stitch

Fill stitch

Density

Angle

Ordering

Validation

---

Golden

Known vector

↓

Known stitch output

---

Regression

Same input

↓

Same stitch graph

---

Performance

1000 paths

100 regions

Large project

---

Property Tests

Random valid geometry

↓

Valid stitch graph

---

Integration

SVG

↓

Digitizer

↓

Simulation

↓

DST

↓

Validation

---

# Acceptance Criteria

Digitizer is complete when

✓ Running stitch implemented

✓ Fill stitch implemented

✓ Stitch graph deterministic

✓ Incremental regeneration works

✓ Statistics generated

✓ Simulation receives stitch graph

✓ Export consumes stitch graph

✓ Validation reports issues

✓ Performance targets met

✓ Tests pass

---

# Future Enhancements

- AI-assisted auto-digitizing
- Multi-object optimization
- Stitch graph editor
- Interactive stitch editing
- Variable density fills
- Artistic fills
- Procedural stitch generators
- Plugin stitch algorithms
- Fabric simulation feedback
- GPU-assisted stitch preview
