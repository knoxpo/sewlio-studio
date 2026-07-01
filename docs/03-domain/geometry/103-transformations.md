# Domain
## DOM-103 Transformations

**Document ID:** DOM-103  
**Title:** Transformations  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Geometry Domain Team

**Related Documents**

```text
DOM-000 Domain Overview
DOM-100 Coordinate System
DOM-101 Paths
DOM-102 Curves
DOM-104 Bounding Boxes
DOM-105 Geometry Algorithms

ARCH-005 Document Model
ARCH-008 Rendering Architecture
ARCH-009 Digitizer Pipeline
ARCH-027 Dependency Graph
```

---

# Purpose

This document defines the geometric transformation model used throughout Sewlio Studio.

Transformations modify the position, orientation, and size of geometry without altering its mathematical definition.

Transformations are fundamental to editing, rendering, simulation, and manufacturing.

---

# Philosophy

Geometry is immutable.

Transforms describe how geometry is positioned.

```text
Geometry

+

Transform

↓

Visible Object
```

The original geometry is never modified by transformations.

---

# Goals

The transformation system shall provide

- Deterministic behavior
- High numerical precision
- Non-destructive editing
- Hierarchical composition
- Efficient rendering
- Machine independence
- Reversible operations

---

# Transformation Model

Every visible object is represented as

```text
Object

↓

Geometry

+

Transform

↓

Rendered Object
```

The transform belongs to the object.

The geometry remains unchanged.

---

# Supported Transformations

Current

```text
Translation

Rotation

Scaling

Reflection

Shearing
```

Future

```text
Perspective

Warp

Envelope

Mesh Warp

Free Transform
```

---

# Transformation Hierarchy

```text
Project

↓

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

Each level contributes its own transformation.

The final transform is the composition of all parent transforms.

---

# Translation

Translation changes position.

Properties

```text
X Offset

Y Offset
```

Translation preserves

- size
- orientation
- topology
- curvature

---

# Rotation

Rotation changes orientation.

Properties

```text
Angle

Pivot
```

Rotation preserves

- shape
- size
- topology
- distances

---

# Scaling

Scaling changes size.

Properties

```text
Scale X

Scale Y

Pivot
```

Types

```text
Uniform

Non-uniform
```

Uniform scaling preserves proportions.

---

# Reflection

Reflection mirrors geometry.

Supported axes

```text
Horizontal

Vertical

Arbitrary Axis (future)
```

Reflection reverses orientation.

---

# Shearing

Shearing skews geometry.

Properties

```text
Shear X

Shear Y
```

Shearing preserves area but changes angles.

---

# Transformation Matrix

Internally every transformation is represented by an affine matrix.

```text
Translation

↓

Rotation

↓

Scale

↓

Shear

↓

Affine Matrix
```

Matrix representation is an implementation detail.

The domain model remains transformation-oriented.

---

# Affine Transformations

Supported operations are affine.

Affine transformations preserve

- straight lines
- parallel lines
- topology

Affine transformations do not preserve

- angles
- lengths
- areas (unless applicable)

---

# Pivot Point

Transformations operate around a pivot.

Examples

```text
Object Center

Selection Center

Custom Point

Document Origin
```

Changing the pivot changes the result.

---

# Transformation Order

Operations are evaluated in a deterministic order.

```text
Scale

↓

Rotate

↓

Translate
```

Order is significant.

Changing order produces different geometry.

---

# Composite Transformations

Multiple transformations combine into one.

```text
Scale

↓

Rotate

↓

Translate

↓

Composite Transform
```

Composite transforms reduce computational overhead.

---

# Local Transform

Each object owns a local transform.

```text
Geometry

↓

Local Transform
```

The local transform is independent of parent objects.

---

# World Transform

The world transform is computed by combining

```text
Document

↓

Layer

↓

Group

↓

Object
```

World transforms are computed dynamically.

---

# Identity Transform

The identity transformation performs no modification.

Equivalent to

```text
Translation

(0,0)

Rotation

0°

Scale

(1,1)
```

Identity is the default state.

---

# Inverse Transform

Every reversible transformation provides an inverse.

```text
Transform

↓

Inverse

↓

Original Geometry
```

Inverse transforms enable

- hit testing
- selection
- editing
- snapping

---

# Transformation Composition

Transforms compose mathematically.

```text
Transform A

↓

Transform B

↓

Transform C

↓

Final Transform
```

Composition is associative.

---

# Transformation Decomposition

Composite transforms may be decomposed into

```text
Translation

Rotation

Scale

Shear
```

Decomposition supports editing and serialization.

---

# Nested Objects

Child objects inherit parent transforms.

Example

```text
Group

↓

Rotate

↓

Child Object

↓

Translate
```

The effective transform is the composition of both.

---

# Selection Transform

Selections may apply temporary transforms.

```text
Selection

↓

Preview

↓

Commit
```

Preview never modifies geometry.

---

# Interactive Editing

During editing

```text
Geometry

↓

Transform Preview

↓

User Confirmation

↓

Commit
```

Interactive previews remain temporary.

---

# Constraints

Transformations may be constrained.

Examples

```text
Snap Angle

Grid

Guides

Aspect Ratio

Center
```

Constraints affect interaction only.

---

# Precision

Transformations use

```text
64-bit floating point
```

Accumulated error should be minimized.

---

# Numerical Stability

Repeated transformations should avoid

- cumulative drift
- repeated decomposition
- unnecessary recomputation

Canonical transforms should be preserved whenever possible.

---

# Bounding Updates

Transformations invalidate

```text
Bounding Box

Bounding Circle

Spatial Index
```

Geometry itself remains unchanged.

---

# Rendering

Rendering evaluates transforms dynamically.

Geometry is never duplicated solely because of transformation.

---

# Digitizing

Digitizers operate on transformed geometry.

The original object geometry remains editable.

---

# Simulation

Simulation uses transformed stitch geometry.

Simulation never modifies transformation data.

---

# Serialization

Transforms serialize independently from geometry.

Stored properties

```text
Translation

Rotation

Scale

Shear

Pivot
```

Geometry remains unchanged.

---

# Domain Rules

The following always apply.

- Geometry is immutable.
- Transformations define object placement.
- Object transforms never rewrite source geometry.
- Parent transforms propagate to children.
- Transformation order is deterministic.
- Identity transforms are valid transforms.
- Rendering evaluates transforms dynamically.
- Export applies transforms before machine compilation.
- Simulation uses transformed geometry.
- Transformations remain machine-independent.

---

# Out of Scope

This document does not define

- matrix mathematics
- GPU transformation pipelines
- rendering optimization
- animation systems
- constraint solvers

These belong to the Architecture section.

---

# Future Topics

Future documents expand

```text
Parametric Constraints

Free Transform

Mesh Warp

Perspective

Envelope Editing

Animation Transforms
```

---

# Acceptance Criteria

The Transformation model is complete when

✓ Translation, rotation, scaling, reflection, and shearing are defined.

✓ Geometry remains immutable.

✓ Object transforms are independent of geometry.

✓ Parent-child transformation inheritance is specified.

✓ Transformation order is deterministic.

✓ Composite and inverse transformations are supported.

✓ Interactive editing uses temporary transforms.

✓ Serialization separates geometry from transforms.

✓ Rendering, simulation, and digitizing consistently consume transformed geometry.

✓ The transformation model supports professional CAD-grade editing.
