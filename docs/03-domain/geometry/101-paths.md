# Domain
## DOM-101 Paths

**Document ID:** DOM-101  
**Title:** Paths  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Geometry Domain Team

**Related Documents**

```text
DOM-000 Domain Overview
DOM-100 Coordinate System
DOM-102 Curves
DOM-103 Transformations
DOM-104 Bounding Boxes
DOM-105 Geometry Algorithms

ARCH-005 Document Model
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
```

---

# Purpose

This document defines the Path, the fundamental geometric primitive used throughout Sewlio Studio.

Nearly every editable object ultimately consists of one or more paths.

Paths are machine-independent mathematical descriptions of geometry.

---

# Philosophy

Everything begins with a path.

```text
Points

↓

Segments

↓

Path

↓

Shape

↓

Embroidery

↓

Machine Instructions
```

Embroidery is generated from paths—not pixels.

---

# Goals

The Path model shall provide

- Precise geometry
- Infinite scalability
- Mathematical correctness
- Deterministic editing
- Efficient rendering
- Reliable digitizing
- Platform independence

---

# Definition

A Path is an ordered sequence of connected geometric segments.

A path may contain

- lines
- Bézier curves
- arcs (future)
- splines (future)

A path is purely geometric.

It contains no embroidery information.

---

# Path Hierarchy

```text
Path

↓

Segments

↓

Points

↓

Coordinates
```

---

# Path Components

Every path consists of

```text
Vertices

Segments

Direction

Topology

Metadata
```

---

# Vertex

A vertex is a point where segments meet.

Properties

```text
Position

Handles (optional)

Selection

Metadata
```

Vertices are ordered.

---

# Segment

A segment connects two vertices.

Supported segment types

```text
Line

Quadratic Bézier

Cubic Bézier
```

Future

```text
Arc

Ellipse

NURBS

Spline
```

---

# Path Types

## Open Path

```text
A ---- B ---- C
```

Characteristics

- start point
- end point

Not automatically closed.

---

## Closed Path

```text
A

│      │

D ---- C
```

Start and end connect automatically.

Closed paths represent regions.

---

## Compound Path

Multiple paths acting as one.

Example

```text
Letter O

Outer Boundary

↓

Inner Hole
```

Compound paths support holes.

---

# Path Orientation

Closed paths have direction.

```text
Clockwise

Counter-clockwise
```

Orientation determines

- fills
- holes
- winding
- Boolean operations

Orientation is significant.

---

# Segment Ordering

Segments are ordered.

Example

```text
P0

↓

P1

↓

P2

↓

P3
```

Changing order changes geometry.

---

# Connectivity

Each segment connects exactly

```text
Start Vertex

↓

End Vertex
```

Disconnected segments belong to different paths.

---

# Continuity

Supported continuity

```text
C0

Position

C1

Tangent

C2

Curvature
```

Higher continuity produces smoother curves.

---

# Path Direction

Every path has direction.

```text
Start

↓

End
```

Direction affects

- stroke generation
- stitch direction
- sequencing
- travel optimization

---

# Length

A path has measurable length.

Computed from

```text
Segments

↓

Total Length
```

Length supports

- stitch spacing
- simulation
- animation

---

# Parameterization

Paths are parameterized.

```text
t

↓

0

↓

1
```

Allows

- interpolation
- sampling
- animation
- stitch generation

---

# Sampling

Paths may be sampled.

Produces

```text
Geometry

↓

Points

↓

Digitizer
```

Sampling precision is configurable.

---

# Flattening

Curved paths may be flattened.

```text
Bezier

↓

Polyline

↓

Approximation
```

Flattening never modifies original geometry.

---

# Simplification

Paths may be simplified.

Operations

```text
Merge

Reduce Points

Remove Collinear Vertices

Smooth
```

Simplification preserves shape within tolerance.

---

# Splitting

Paths may be split.

```text
Original

↓

Two Paths
```

Both paths remain valid.

---

# Joining

Compatible paths may be joined.

Requirements

- matching endpoints
- compatible direction
- compatible topology

---

# Offset Paths

A path may generate

```text
Positive Offset

Negative Offset
```

Used for

- outlines
- pull compensation
- borders

Offsets create new geometry.

---

# Stroke

Stroke is a visual representation.

Stroke properties

```text
Width

Cap

Join

Dash
```

Stroke is presentation only.

Not geometry.

---

# Fill

Closed paths define regions.

Fill depends on

```text
Topology

Orientation

Fill Rule
```

Fill is independent of embroidery fill.

---

# Fill Rules

Supported

```text
Non-Zero Winding

Even-Odd
```

Rules determine interior regions.

---

# Self-Intersection

Paths may self-intersect.

Example

```text
Figure Eight
```

Self-intersections require explicit handling during

- fills
- digitizing
- Boolean operations

---

# Boolean Operations

Supported

```text
Union

Difference

Intersection

Exclusive OR
```

Results always produce valid paths.

---

# Path Metadata

Paths may store

```text
Identifier

Name

Tags

Selection

Visibility

Locked
```

Metadata never changes geometry.

---

# Path Bounds

Every path computes

```text
Bounding Box

Bounding Circle

Length

Centroid
```

Cached when possible.

---

# Transformations

Paths support

```text
Translate

Rotate

Scale

Mirror

Shear
```

Original geometry remains mathematically valid.

---

# Tessellation

Paths may be tessellated.

Used by

```text
Rendering

Simulation

GPU

Selection
```

Tessellation is transient.

---

# Digitizing

Digitizers consume paths.

```text
Path

↓

Digitizer

↓

Embroidery Object
```

Paths themselves contain no stitch information.

---

# Simulation

Simulation operates on embroidery objects.

Never directly on paths.

---

# Serialization

Paths serialize

```text
Vertices

Segments

Topology

Metadata
```

No rendering information is stored.

---

# Numerical Stability

Algorithms should

- normalize directions
- preserve continuity
- avoid duplicate vertices
- maintain topology
- preserve winding

---

# Domain Rules

The following always apply.

- Paths are machine-independent.
- Paths contain only geometry.
- Segment ordering is significant.
- Closed paths define regions.
- Open paths define trajectories.
- Compound paths support holes.
- Transformations preserve topology.
- Sampling never modifies source geometry.
- Flattening creates temporary approximations.
- Embroidery is derived from paths.

---

# Out of Scope

This document does not define

- Bézier mathematics
- transformations
- Boolean algorithms
- rendering
- stitch generation

These are covered separately.

---

# Future Topics

Future documents expand

```text
Bezier Curves

Arc Segments

NURBS

Boolean Algorithms

Topology Editing

Parametric Paths
```

---

# Acceptance Criteria

The Path model is complete when

✓ Paths are defined as ordered geometric segment collections.

✓ Open, closed, and compound paths are supported.

✓ Segment ordering and direction are well-defined.

✓ Paths remain independent of embroidery.

✓ Sampling and flattening preserve original geometry.

✓ Fill rules and topology are specified.

✓ Transformations preserve mathematical correctness.

✓ Paths serialize deterministically.

✓ The model supports advanced CAD-style editing.

✓ Paths serve as the canonical geometric representation throughout the platform.
