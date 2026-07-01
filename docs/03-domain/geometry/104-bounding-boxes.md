# Domain
## DOM-104 Bounding Boxes

**Document ID:** DOM-104  
**Title:** Bounding Boxes  
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
DOM-103 Transformations
DOM-105 Geometry Algorithms

ARCH-005 Document Model
ARCH-008 Rendering Architecture
ARCH-016 Performance Architecture
ARCH-027 Dependency Graph
```

---

# Purpose

This document defines the spatial bounding system used throughout Sewlio Studio.

Bounding volumes provide efficient spatial approximation of geometry without modifying the underlying objects.

Bounding information accelerates nearly every subsystem including

- rendering
- hit testing
- selection
- snapping
- viewport culling
- collision detection
- simulation
- dependency analysis

Bounding volumes never replace geometry.

They are optimization structures.

---

# Philosophy

Geometry describes shape.

Bounding volumes describe space.

```text
Geometry

↓

Bounding Volume

↓

Spatial Queries
```

Every geometric object has one or more bounding volumes.

---

# Goals

The bounding system shall provide

- Fast spatial queries
- Efficient rendering
- Deterministic calculations
- Incremental updates
- Machine independence
- Hierarchical bounds
- Multiple bounding types

---

# Bounding Hierarchy

```text
Workspace

↓

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

Each level owns its own bounding volume.

Parent bounds contain all children.

---

# Bounding Types

Supported

```text
Axis-Aligned Bounding Box (AABB)

Oriented Bounding Box (OBB)

Bounding Circle

Bounding Sphere (future)

Convex Hull

Selection Bounds

Viewport Bounds
```

Different systems choose the most appropriate representation.

---

# Axis-Aligned Bounding Box (AABB)

The primary bounding representation.

Properties

```text
Minimum X

Minimum Y

Maximum X

Maximum Y
```

Advantages

- inexpensive
- fast intersection
- simple updates
- cache friendly

Used throughout the Runtime.

---

# Oriented Bounding Box (OBB)

A bounding box aligned with object orientation.

Properties

```text
Center

Width

Height

Rotation
```

Useful for

- rotated selections
- collision detection
- advanced editing

More expensive than AABB.

---

# Bounding Circle

Defined by

```text
Center

Radius
```

Advantages

- inexpensive distance checks
- rotationally invariant
- useful for broad-phase testing

---

# Convex Hull

Smallest convex polygon enclosing geometry.

Advantages

- tighter approximation
- improved collision testing

Used when precision is required.

---

# Selection Bounds

Selection bounds enclose

```text
Selected Objects

↓

Combined Bounds
```

Used for

- resize handles
- transformation widgets
- alignment
- distribution

---

# Viewport Bounds

Represents the visible region.

```text
Camera

↓

Viewport

↓

Visible Bounds
```

Used for

- culling
- rendering
- interaction

---

# Bounding Properties

Every bounding volume provides

```text
Width

Height

Center

Area

Perimeter

Extents
```

These values are computed automatically.

---

# Bounding Center

Center

```text
(min + max) / 2
```

Used for

- transformations
- snapping
- alignment
- viewport focus

---

# Extents

Half-size representation.

```text
Center

+

Half Width

+

Half Height
```

Efficient for intersection testing.

---

# Bounding Area

Bounding area is approximate.

It is not the same as object area.

Bounding area is used only for optimization.

---

# Hierarchical Bounds

Parent objects compute

```text
Union

↓

Child Bounds
```

Example

```text
Group

↓

Object A

Object B

Object C

↓

Combined Bounds
```

Hierarchy updates incrementally.

---

# Empty Bounds

Empty objects produce

```text
Empty Bounding Volume
```

Empty bounds remain valid.

---

# Infinite Bounds

Infinite bounds are prohibited.

Very large geometry remains finite.

---

# Dynamic Updates

Whenever geometry changes

```text
Geometry

↓

Bounding Volume

↓

Parent Bounds

↓

Spatial Index
```

Updates propagate automatically.

---

# Dirty Tracking

Bounding volumes participate in the Dependency Graph.

States

```text
Clean

Dirty

Recomputing
```

Bounding recomputation is incremental.

---

# Bounding Cache

Bounding calculations may be cached.

Cache invalidation occurs when

- geometry changes
- transformation changes
- topology changes

Rendering never invalidates bounds.

---

# Transformation Effects

Transformations affect

```text
World Bounds
```

Not

```text
Local Bounds
```

Local geometry remains unchanged.

---

# Local Bounds

Computed in Object Space.

Never affected by parent transforms.

---

# World Bounds

Computed after all transformations.

Used by

- rendering
- selection
- viewport
- simulation

---

# Hit Testing

Bounding volumes provide broad-phase testing.

```text
Pointer

↓

Bounding Test

↓

Geometry Test
```

Exact geometry testing occurs only after bounding intersection.

---

# Selection

Selection occurs in two stages.

```text
Bounding Test

↓

Precise Geometry Test
```

This minimizes expensive geometry calculations.

---

# Snapping

Bounding centers may be snap targets.

Examples

```text
Center

Corner

Midpoint

Edge
```

Snapping never modifies bounds.

---

# Viewport Culling

Rendering begins with

```text
Viewport Bounds

↓

Visible Objects

↓

Rendering
```

Invisible objects are skipped.

---

# Collision Detection

Collision occurs in phases.

```text
Bounding Test

↓

Precise Geometry Test
```

Bounding volumes accelerate collision detection.

---

# Simulation

Simulation uses bounds for

- visibility
- interaction
- optimization

Simulation never modifies bounding volumes.

---

# Spatial Index

Bounding volumes populate the spatial index.

Future implementations may use

```text
QuadTree

R-Tree

BVH

Uniform Grid
```

Spatial indexing is transparent to consumers.

---

# Numerical Precision

Bounding calculations use

```text
64-bit floating point
```

Values remain deterministic.

---

# Degenerate Bounds

Examples

```text
Point

Line

Zero Area
```

Degenerate bounds remain valid.

---

# Serialization

Bounding volumes are

```text
Transient
```

They are recomputed after loading.

Projects never persist cached bounds.

---

# Performance Targets

```text
AABB Calculation

O(n)

Intersection

O(1)

Union

O(1)

Cache Lookup

O(1)

Hierarchy Update

Incremental
```

---

# Domain Rules

The following always apply.

- Every geometric object has a bounding volume.
- Bounding volumes never replace geometry.
- AABB is the default representation.
- Parent bounds contain all descendants.
- World bounds include transformations.
- Local bounds ignore parent transformations.
- Bounds participate in dirty propagation.
- Bounding caches are transient.
- Selection uses broad-phase then precise testing.
- Serialization never stores cached bounds.

---

# Out of Scope

This document does not define

- spatial indexing algorithms
- rendering culling implementation
- collision algorithms
- GPU acceleration

These belong to the Architecture section.

---

# Future Topics

Future documents expand

```text
Spatial Indexes

QuadTrees

BVH

Collision Detection

Visibility Systems

GPU Culling
```

---

# Acceptance Criteria

The Bounding System is complete when

✓ Every geometric object has at least one bounding volume.

✓ AABB is defined as the canonical bounding representation.

✓ Local and world bounds are clearly distinguished.

✓ Hierarchical bounding propagation is specified.

✓ Bounding updates integrate with the Dependency Graph.

✓ Selection, rendering, and hit testing use bounding volumes for broad-phase optimization.

✓ Bounding volumes remain transient and deterministic.

✓ Spatial queries are accelerated without modifying geometry.

✓ The model supports scalable CAD-grade editing.

✓ Bounding volumes serve as the foundation for spatial optimization throughout the platform.
