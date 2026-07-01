# Domain
## DOM-102 Curves

**Document ID:** DOM-102  
**Title:** Curves  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Geometry Domain Team

**Related Documents**

```text
DOM-000 Domain Overview
DOM-100 Coordinate System
DOM-101 Paths
DOM-103 Transformations
DOM-104 Bounding Boxes
DOM-105 Geometry Algorithms

ARCH-005 Document Model
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
```

---

# Purpose

This document defines the mathematical curve primitives supported by Sewlio Studio.

Curves are the foundation of vector geometry.

They describe smooth, scalable, machine-independent shapes from which embroidery is generated.

Curves are never stitches.

They are mathematical descriptions that later become embroidery.

---

# Philosophy

Curves represent intent.

Stitches represent manufacturing.

```text
Designer

↓

Curve

↓

Geometry

↓

Digitizer

↓

Stitches

↓

Machine
```

Curves remain editable throughout the design lifecycle.

---

# Goals

The curve system shall provide

- Mathematical precision
- Infinite scalability
- Smooth editing
- Deterministic evaluation
- Efficient rendering
- Accurate digitization
- Platform independence

---

# Supported Curve Types

Current

```text
Line

Quadratic Bézier

Cubic Bézier
```

Future

```text
Circular Arc

Ellipse

Spline

NURBS

Catmull-Rom

B-Spline
```

---

# Curve Hierarchy

```text
Curve

↓

Control Points

↓

Parameterization

↓

Evaluation

↓

Geometry
```

---

# Line Segment

A line segment is the simplest curve.

Defined by

```text
Start Point

End Point
```

Properties

- constant direction
- linear interpolation
- exact length

---

# Quadratic Bézier

Defined by

```text
Start Point

Control Point

End Point
```

Characteristics

- one control handle
- smooth curvature
- inexpensive evaluation

Suitable for

- simple illustrations
- lettering
- lightweight geometry

---

# Cubic Bézier

Defined by

```text
Start Point

Control Point A

Control Point B

End Point
```

Characteristics

- two handles
- flexible shaping
- industry standard
- SVG compatible

Primary curve type for Sewlio Studio.

---

# Control Points

Control points influence curvature.

They do not necessarily lie on the curve.

Types

```text
Anchor

Handle

Control
```

---

# Anchor Points

Anchors define curve endpoints.

Properties

```text
Position

Selection

Metadata
```

Anchors always lie on the curve.

---

# Handles

Handles determine

- tangent
- curvature
- smoothness

Handles may be

```text
Symmetric

Mirrored

Independent
```

---

# Handle Modes

## Symmetric

```text
←────●────→
```

Equal length.

Opposite direction.

Produces smooth curves.

---

## Mirrored

Opposite direction.

Independent length.

Useful for variable curvature.

---

## Independent

Both handles move independently.

Maximum flexibility.

---

# Parameterization

Every curve is parameterized.

```text
t

↓

0

↓

1
```

Allows

- evaluation
- interpolation
- sampling
- subdivision

---

# Evaluation

Curves evaluate continuously.

Example

```text
t = 0.25

↓

Point
```

Evaluation is deterministic.

---

# Tangent

Every curve defines a tangent.

```text
Curve

↓

Tangent Vector
```

Tangents influence

- stitch direction
- offset generation
- normals

---

# Normal

Normal vectors are perpendicular to tangents.

Used for

```text
Offsets

Borders

Simulation

Stroke Expansion
```

---

# Curvature

Curvature measures directional change.

High curvature

```text
Sharp Turn
```

Low curvature

```text
Gentle Curve
```

Curvature influences digitizing quality.

---

# Arc Length

Curves have measurable length.

Length is approximated numerically.

Applications

```text
Stitch Spacing

Animation

Simulation

Measurements
```

---

# Subdivision

Curves may be subdivided.

```text
Original Curve

↓

Two Curves
```

Subdivision preserves shape.

---

# Flattening

Curves may be approximated.

```text
Bezier

↓

Polyline
```

Flattening tolerance is configurable.

Original curves remain unchanged.

---

# Sampling

Curves may be sampled.

Produces

```text
Curve

↓

Points

↓

Digitizer
```

Sampling density depends on

- curvature
- zoom
- tolerance

---

# Adaptive Sampling

Adaptive sampling increases precision where needed.

```text
Flat Region

↓

Few Samples

Curved Region

↓

More Samples
```

Improves quality while reducing computation.

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

Higher continuity produces smoother transitions.

---

# Joining Curves

Compatible curves may join.

Requirements

- matching endpoints
- compatible tangents
- compatible continuity

---

# Splitting Curves

Curves may split at any parameter.

```text
Bezier

↓

t = 0.5

↓

Two Béziers
```

Both remain mathematically equivalent.

---

# Offsetting

Curves support offset generation.

Applications

```text
Outline

Border

Pull Compensation

Stroke Expansion
```

Offsets generate new curves.

---

# Approximation

Curves may approximate

```text
Circle

Ellipse

Spline
```

Approximation accuracy is configurable.

---

# Numerical Stability

Algorithms should

- minimize floating-point error
- preserve continuity
- normalize tangents
- avoid degenerate handles

---

# Degenerate Curves

Degenerate examples

```text
Zero Length

Coincident Handles

Duplicate Anchors
```

Such curves remain valid but may require simplification.

---

# Self-Intersection

Curves may self-intersect.

Applications must detect

```text
Loops

Cusps

Figure Eight
```

Self-intersections affect

- fills
- Boolean operations
- digitizing

---

# Rendering

Rendering evaluates curves continuously.

Rasterization occurs after evaluation.

Rendering never alters source geometry.

---

# Digitizing

Digitizers consume evaluated geometry.

```text
Curve

↓

Sampled Points

↓

Embroidery
```

Digitizers never operate directly on Bézier equations.

---

# Simulation

Simulation uses stitch geometry.

Simulation never modifies source curves.

---

# Serialization

Curves serialize

```text
Anchor Points

Handles

Segment Type

Metadata
```

No rendering cache is stored.

---

# Domain Rules

The following always apply.

- Curves are machine-independent.
- Cubic Bézier curves are the primary editable primitive.
- Curves remain editable after digitizing.
- Handles influence shape but are not part of the curve.
- Curves are evaluated continuously.
- Sampling never modifies source geometry.
- Flattening produces temporary approximations.
- Digitizers consume sampled geometry.
- Rendering evaluates curves dynamically.
- Export never serializes Bézier curves directly.

---

# Out of Scope

This document does not define

- Boolean operations
- path topology
- transformations
- stitch generation
- rendering implementation

These are covered elsewhere.

---

# Future Topics

Future geometry documents expand

```text
Circular Arcs

Ellipses

NURBS

Splines

Parametric Curves

Curve Editing Algorithms
```

---

# Acceptance Criteria

The Curve model is complete when

✓ Supported curve types are clearly defined.

✓ Cubic Bézier curves are established as the primary editable primitive.

✓ Curve parameterization and evaluation are deterministic.

✓ Tangents, normals, and curvature are defined.

✓ Adaptive sampling and flattening preserve source geometry.

✓ Curve continuity is specified.

✓ Digitizing and rendering responsibilities are separated.

✓ Serialization preserves mathematical accuracy.

✓ The model supports professional CAD-quality editing.

✓ Curves remain the canonical representation of smooth geometry throughout the platform.
