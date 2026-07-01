# Domain
## DOM-304 Hoop System

**Document ID:** DOM-304  
**Title:** Hoop System  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Machine Runtime Team

**Related Documents**

```text
DOM-103 Transformations
DOM-200 Stitch Theory
DOM-300 Machine Model
DOM-301 Machine Coordinates
DOM-302 Needle System
DOM-303 Thread Changes

ARCH-005 Document Model
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline

FR-1400 Machine Support
```

---

# Purpose

This document defines the logical Hoop System used by Sewlio Studio.

The Hoop System models the physical embroidery hoop that constrains where embroidery may be stitched.

It provides a machine-independent representation of embroidery work areas while allowing different machine profiles to support different hoop sizes and shapes.

---

# Philosophy

Embroidery does not occur on an infinite canvas.

It occurs inside a constrained manufacturing workspace.

```text
Artwork

↓

Placement

↓

Hoop Validation

↓

Machine Execution
```

The hoop defines manufacturing limits, not artistic limits.

---

# Goals

The Hoop System shall provide

- Machine-independent hoop representation
- Accurate placement
- Manufacturing validation
- Multiple hoop support
- Simulation compatibility
- Extensible machine profiles

---

# Definition

A Hoop represents the physical embroidery area available to the embroidery machine.

All machine coordinates must remain inside the selected hoop before export.

---

# Responsibilities

The Hoop System manages

- hoop geometry
- embroidery placement
- work area validation
- safe sewing regions
- hoop profiles
- coordinate normalization

It does **not** manage

- stitch generation
- thread planning
- sequencing
- machine communication

---

# Hoop Pipeline

```text
Artwork

↓

Embroidery Geometry

↓

Placement

↓

Hoop Validation

↓

Machine Coordinates

↓

Machine Compiler
```

---

# Hoop Model

Each hoop contains

```text
Identifier

Name

Shape

Width

Height

Origin

Safe Area

Machine Compatibility
```

---

# Hoop Shapes

Supported shapes include

```text
Rectangular

Circular

Oval

Custom Polygon
```

Future machine profiles may define additional shapes.

---

# Hoop Dimensions

Dimensions are expressed in

```text
Millimeters
```

Example

```text
100 × 100 mm

130 × 180 mm

200 × 300 mm
```

Logical dimensions are independent of machine file formats.

---

# Hoop Origin

Every hoop defines

```text
Logical Origin
```

The origin is the reference point for

- placement
- coordinate normalization
- simulation

Machine profiles determine how this origin maps to hardware.

---

# Safe Sewing Area

The safe sewing area is

the region guaranteed to be reachable without risking machine collision.

```text
Physical Hoop

↓

Safe Area

↓

Embroidery
```

Designs should remain inside the safe area.

---

# Physical Boundary

The hoop boundary represents

the maximum embroidery area supported by the hoop.

Embroidery outside this boundary is invalid.

---

# Machine Compatibility

Each hoop profile defines

supported machines.

Example

```text
Brother

Janome

Tajima

Barudan

Melco

ZSK
```

The same logical hoop may map to different machine-specific hoop identifiers.

---

# Hoop Profiles

Examples

```text
Small

Medium

Large

Cap Hoop

Sock Hoop

Jacket Hoop

Border Hoop

Free Arm Hoop
```

Profiles are machine-independent.

---

# Placement

Placement positions embroidery

inside the hoop.

Placement determines

```text
Translation

Rotation

Mirror

Scale (optional validation only)
```

Scaling is generally discouraged for production embroidery.

---

# Centered Placement

The default placement mode

centers the embroidery

within the selected hoop.

---

# Custom Placement

Users may specify

```text
Origin Offset

Rotation

Reference Point
```

Professional workflows often require precise placement.

---

# Multi-Hoop Projects

Large embroidery designs

may span

multiple hoops.

Example

```text
Hoop 1

↓

Hoop 2

↓

Hoop 3
```

Multi-hooping is planned before machine compilation.

---

# Hoop Splitting

When a design exceeds

the selected hoop,

the system may

```text
Suggest Larger Hoop

or

Split Design
```

Automatic splitting

is a future capability.

---

# Coordinate Normalization

Before compilation

coordinates are normalized

relative to the hoop origin.

Normalization is deterministic.

---

# Boundary Validation

Validation verifies

```text
Inside Hoop

Inside Safe Area

No Boundary Overflow
```

Validation failures

prevent export.

---

# Collision Margin

Machine profiles may define

a configurable

```text
Safety Margin
```

Embroidery should avoid

operating too close

to the physical hoop edge.

---

# Frame Movement

The logical hoop models

available embroidery space,

not physical frame mechanics.

Frame motion is abstracted

by the Machine Model.

---

# Simulation

Simulation renders

the hoop

alongside

```text
Embroidery

Travel

Safe Area

Origin
```

Professional mode may visualize

boundary violations.

---

# Runtime Events

The Hoop System emits

```text
Hoop Selected

Placement Changed

Validation Failed

Safe Area Warning
```

These events integrate

with the Event System.

---

# Machine Compilation

The compiler maps

logical hoop definitions

to

machine-specific hoop identifiers,

coordinate systems,

and export metadata.

The logical hoop

remains unchanged.

---

# Error Conditions

Common validation errors

```text
Design Outside Hoop

Safe Area Violation

Unsupported Hoop

Invalid Placement

Machine Incompatibility
```

Compilation must fail

if hoop validation fails.

---

# Extensibility

Future hoop capabilities

may include

```text
Magnetic Hoops

Automatic Hoop Detection

RFID Hoops

Rotating Hoops

Robotic Frames

Multi-Axis Hoops
```

The logical model

must remain backward compatible.

---

# Thread Safety

Hoop definitions

are immutable.

Placement calculations

may execute concurrently

for independent documents.

---

# Performance

The Hoop System shall support

```text
Large Commercial Hoops

Multi-Hoop Projects

Real-Time Placement

Interactive Validation

Live Simulation
```

without modifying embroidery geometry.

---

# Domain Rules

The following always apply.

- Hoop dimensions are expressed in millimeters.
- The hoop defines manufacturing limits, not artwork limits.
- Embroidery must remain inside the selected hoop.
- Safe area validation occurs before export.
- Hoop placement never modifies original artwork.
- Coordinate normalization occurs relative to the hoop origin.
- Simulation executes using logical hoop definitions.
- Machine compilation maps logical hoops to machine-specific representations.
- Multi-hoop workflows are supported through logical planning.
- Hoop definitions remain machine-independent.

---

# Out of Scope

This document does not define

- machine frame mechanics
- physical clamp systems
- hoop hardware communication
- stitch generation
- embroidery file encoding

These are covered in other machine and architecture documents.

---

# Future Topics

Future machine documents expand

```text
Placement Engine

Multi-Hooping

Automatic Nesting

Hoop Libraries

Machine Calibration

Production Planning
```

---

# Acceptance Criteria

The Hoop System specification is complete when

✓ A machine-independent hoop abstraction is defined.

✓ Hoop geometry, dimensions, and origins are specified.

✓ Safe area and boundary validation are established.

✓ Placement and coordinate normalization are documented.

✓ Multi-hoop workflows are introduced.

✓ Simulation and machine compilation responsibilities are separated.

✓ Runtime events and validation errors are documented.

✓ Domain rules establish deterministic hoop behavior.

✓ Machine-specific hoop mappings are isolated behind machine profiles.

✓ The Hoop System provides the canonical manufacturing workspace abstraction for the embroidery platform.
