# Domain
## DOM-100 Coordinate System

**Document ID:** DOM-100  
**Title:** Coordinate System  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Geometry Domain Team

**Related Documents**

```text
DOM-000 Domain Overview
DOM-101 Paths
DOM-102 Curves
DOM-103 Transformations
DOM-104 Bounding Boxes
DOM-105 Geometry Algorithms

ARCH-005 Document Model
ARCH-008 Rendering Architecture
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the coordinate systems used throughout Sewlio Studio.

Every geometric operation, rendering operation, digitizing algorithm, simulation, and machine export is based upon these coordinate systems.

The coordinate model is independent of any embroidery machine.

---

# Philosophy

Geometry exists independently of manufacturing.

The embroidery machine is merely one consumer of geometry.

```text
Geometry

↓

Embroidery

↓

Machine

↓

Physical World
```

Geometry should never be constrained by machine limitations.

---

# Goals

The coordinate system shall provide

- Mathematical consistency
- Machine independence
- High precision
- Deterministic transforms
- Multiple coordinate spaces
- Predictable conversions
- Infinite design space

---

# Coordinate Spaces

The platform defines several coordinate spaces.

```text
World Space

↓

Document Space

↓

Layer Space

↓

Object Space

↓

Geometry Space

↓

Stitch Space

↓

Machine Space
```

Each serves a different purpose.

---

# World Space

World Space represents the global editing environment.

Characteristics

- infinite
- double precision
- machine independent

Objects from multiple documents may coexist.

---

# Document Space

Every document owns its own coordinate system.

Origin

```text
(0,0)
```

Units

```text
Millimeters
```

Document Space is the primary design space.

---

# Layer Space

Layers inherit Document Space.

Layers introduce

- visibility
- organization
- grouping

Layers never modify coordinates.

---

# Object Space

Each object owns a local coordinate system.

```text
Object

↓

Local Origin

↓

Transform

↓

Document
```

Moving an object changes its transform—not its geometry.

---

# Geometry Space

Geometry is defined relative to Object Space.

Examples

```text
Points

Curves

Paths

Shapes
```

Geometry remains immutable.

---

# Stitch Space

After digitization

```text
Geometry

↓

Stitches
```

Every stitch has

- x
- y
- direction
- length

Stitch Space remains machine-independent.

---

# Machine Space

Machine Space represents physical embroidery coordinates.

Machine Space depends on

- hoop
- origin
- manufacturer
- machine limits

Machine Space is generated during compilation.

---

# Coordinate Hierarchy

```text
World

↓

Document

↓

Object

↓

Geometry

↓

Stitches

↓

Machine
```

Every transformation moves downward.

---

# Units

The canonical unit is

```text
Millimeters (mm)
```

All internal calculations use millimeters.

User interfaces may display

```text
Millimeters

Inches

Pixels
```

Internally everything converts to millimeters.

---

# Precision

Geometry uses

```text
64-bit floating point
```

Reasons

- precision
- stability
- CAD-quality editing
- accurate transformations

Machine export performs precision reduction when required.

---

# Coordinate Origin

Document origin

```text
(0,0)
```

Located at

```text
Upper-left of document workspace
```

Positive directions

```text
+X →

+Y ↓
```

This matches Flutter rendering conventions.

Machine exporters convert to machine-specific origins.

---

# Infinite Canvas

The design canvas is conceptually infinite.

There are no artificial document boundaries.

Practical limits depend on

- rendering
- memory
- machine capabilities

---

# Coordinate Range

Recommended limits

```text
±10,000 mm
```

Internal math supports substantially larger ranges.

Applications may restrict editing for usability.

---

# Point

A point represents an exact location.

```text
(x, y)
```

Properties

- immutable
- dimensionless
- precise

---

# Vector

Vectors represent displacement.

Properties

```text
Magnitude

Direction
```

Vectors are not positions.

---

# Direction

Directions are measured

```text
0°

↓

Positive X
```

Rotation

```text
Counter-clockwise
```

Internally

```text
Radians
```

User interfaces may display degrees.

---

# Distance

Distance is always Euclidean.

Between

```text
Point A

↓

Point B
```

Measured in millimeters.

---

# Angle

Angles are normalized

```text
0°

↓

360°
```

Equivalent

```text
0

↓

2π
```

Negative angles normalize automatically.

---

# Bounding Coordinates

Every object defines

```text
Minimum X

Maximum X

Minimum Y

Maximum Y
```

Bounding information accelerates

- rendering
- selection
- collision
- simulation

---

# Transformations

Coordinates are transformed through matrices.

Supported operations

```text
Translation

Rotation

Scaling

Reflection

Shear
```

Transformation order is deterministic.

---

# Nested Coordinates

Example

```text
Document

↓

Layer

↓

Group

↓

Object

↓

Geometry
```

Every child inherits parent transformations.

---

# Coordinate Conversion

Example

```text
Object Space

↓

Document Space

↓

Machine Space
```

Conversions are reversible until machine compilation.

---

# Grid System

The editor supports

```text
Cartesian Grid

Snap Grid

Guide Grid

Construction Grid
```

Grids affect editing only.

Geometry remains continuous.

---

# Snap System

Supported snapping

```text
Grid

Point

Line

Curve

Intersection

Guide

Object
```

Snapping modifies user interaction.

Not stored geometry.

---

# Coordinate Constraints

Coordinates may be constrained by

```text
Machine Hoop

User Guides

Document Rules

Simulation
```

Geometry itself remains unconstrained.

---

# Machine Conversion

During compilation

```text
Millimeters

↓

Machine Units

↓

Format Encoding
```

Examples

```text
DST

0.1 mm

PES

Machine Native

JEF

Machine Native
```

Conversion occurs only during export.

---

# Rendering Coordinates

Rendering uses

```text
World

↓

Viewport

↓

Screen

↓

Pixels
```

Rendering precision is independent of geometry precision.

---

# Simulation Coordinates

Simulation operates entirely in

```text
Stitch Space
```

Simulation never modifies original geometry.

---

# Numerical Stability

Algorithms should

- avoid accumulated error
- minimize repeated transformations
- normalize angles
- normalize matrices
- preserve precision

---

# Coordinate Equality

Floating-point equality uses tolerance.

Never compare coordinates directly.

Instead

```text
Distance

< ε
```

Recommended default

```text
0.001 mm
```

---

# Serialization

Coordinates serialize as

```text
64-bit floating point
```

Locale-independent

Precision preserved.

---

# Domain Rules

The following always apply.

- Geometry uses millimeters.
- Internal precision is 64-bit floating point.
- Object transforms never mutate geometry.
- Machine coordinates are derived—not edited.
- Rendering coordinates are temporary.
- Coordinate conversions are deterministic.
- Geometry remains machine-independent.
- Simulation never changes coordinates.
- Export performs final coordinate conversion.

---

# Out of Scope

This document does not define

- paths
- Bézier curves
- transformations
- bounding boxes
- stitch generation
- rendering algorithms

These are covered in subsequent documents.

---

# Future Topics

Subsequent documents expand

```text
Paths

Curves

Transforms

Bounding Boxes

Boolean Operations

Geometry Algorithms
```

---

# Acceptance Criteria

The Coordinate System is complete when

✓ All coordinate spaces are clearly defined.

✓ Internal units are standardized to millimeters.

✓ Geometry remains independent of machines.

✓ Object transformations preserve original geometry.

✓ Coordinate conversions are deterministic.

✓ Precision requirements are specified.

✓ Rendering, simulation, and machine coordinates are distinguished.

✓ Floating-point comparison rules are defined.

✓ The coordinate model supports future CAD-grade editing.

✓ This document serves as the canonical reference for all geometric calculations.
