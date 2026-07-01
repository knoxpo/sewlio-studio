# Domain
## DOM-105 Geometry Algorithms

**Document ID:** DOM-105  
**Title:** Geometry Algorithms  
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
DOM-104 Bounding Boxes

ARCH-008 Rendering Architecture
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-016 Performance Architecture
ARCH-027 Dependency Graph
```

---

# Purpose

This document defines the geometric algorithms that form the mathematical foundation of Sewlio Studio.

These algorithms operate exclusively on geometry.

They are independent of

- rendering
- embroidery
- simulation
- machine formats

Every subsystem relies upon these algorithms.

---

# Philosophy

Algorithms manipulate geometry.

They never manipulate embroidery.

```text
Geometry

↓

Geometry Algorithms

↓

Geometry

↓

Digitizer

↓

Embroidery
```

The geometry layer remains completely machine-independent.

---

# Goals

Geometry algorithms shall provide

- Mathematical correctness
- Deterministic behavior
- Numerical stability
- High precision
- Performance
- Platform independence
- CAD-grade robustness

---

# Categories

The geometry library consists of

```text
Measurements

Intersections

Containment

Topology

Simplification

Boolean Operations

Offsets

Sampling

Triangulation

Spatial Queries
```

---

# Distance Algorithms

Supported operations

```text
Point → Point

Point → Line

Point → Curve

Point → Path

Curve → Curve

Object → Object
```

Distance calculations use Euclidean geometry.

---

# Nearest Point

Determine the closest point on

```text
Line

Curve

Path

Shape
```

Used by

- snapping
- editing
- simulation
- digitizing

---

# Projection

Supported projections

```text
Point onto Line

Point onto Curve

Point onto Path
```

Projection is deterministic.

---

# Intersections

Supported

```text
Line-Line

Line-Curve

Curve-Curve

Path-Path

Shape-Shape
```

Intersection algorithms return

- intersection points
- overlap information
- topology changes

---

# Containment

Determine whether

```text
Point

↓

Inside Object
```

Supported for

- polygons
- compound paths
- regions

Containment respects fill rules.

---

# Winding Number

Supported winding rules

```text
Non-Zero

Even-Odd
```

Used for

- fills
- selections
- Boolean operations

---

# Convex Hull

Compute the smallest convex boundary surrounding geometry.

Applications

```text
Selection

Collision

Optimization

Spatial Index
```

---

# Bounding Algorithms

Generate

```text
AABB

OBB

Bounding Circle

Convex Hull
```

Bounding algorithms are incremental.

---

# Simplification

Reduce geometric complexity while preserving appearance.

Supported operations

```text
Vertex Reduction

Collinear Removal

Handle Optimization

Duplicate Removal
```

Shape preservation is mandatory.

---

# Smoothing

Smooth geometry while preserving topology.

Methods

```text
Bezier Smoothing

Corner Smoothing

Curve Relaxation
```

---

# Subdivision

Split geometry into smaller components.

Applications

```text
Rendering

Sampling

Digitizing

Simulation
```

Subdivision preserves shape.

---

# Flattening

Convert curves into polylines.

```text
Bezier

↓

Polyline
```

Tolerance controls approximation quality.

Source geometry remains unchanged.

---

# Sampling

Sample geometry into points.

Sampling modes

```text
Uniform

Adaptive

Curvature-Based
```

Adaptive sampling is preferred.

---

# Curve Evaluation

Evaluate

```text
Point

Tangent

Normal

Curvature
```

at any parameter.

Evaluation is deterministic.

---

# Offsetting

Generate parallel geometry.

Applications

```text
Outline

Border

Stroke

Pull Compensation
```

Offsets create new geometry.

---

# Boolean Operations

Supported operations

```text
Union

Intersection

Difference

Exclusive OR
```

Results must

- remain valid
- preserve topology
- avoid self-intersections where possible

---

# Topology Repair

Repair invalid geometry.

Examples

```text
Duplicate Vertices

Open Loops

Tiny Segments

Broken Paths
```

Repair operations preserve user intent whenever possible.

---

# Path Joining

Compatible paths may join.

Requirements

- matching endpoints
- compatible orientation
- compatible topology

---

# Path Splitting

Split geometry at

```text
Vertex

Intersection

Parameter

User Selection
```

Results remain valid paths.

---

# Orientation

Determine

```text
Clockwise

Counter-clockwise
```

Orientation influences

- fills
- offsets
- digitizing

---

# Area Calculation

Supported

```text
Polygon Area

Compound Area
```

Area is independent of stitch coverage.

---

# Centroid

Compute

```text
Center of Geometry
```

Applications

- transformations
- alignment
- snapping

---

# Length

Supported

```text
Curve Length

Path Length

Polyline Length
```

Used by

- measurements
- digitizing
- simulation

---

# Self-Intersection Detection

Detect

```text
Loops

Crossings

Cusps
```

Used before

- Boolean operations
- digitizing
- exports

---

# Tessellation

Generate polygon meshes.

Applications

```text
Rendering

GPU

Simulation
```

Tessellation is transient.

---

# Triangulation

Convert regions into triangles.

Algorithms should support

```text
Simple Polygons

Compound Paths

Holes
```

Triangulation preserves topology.

---

# Spatial Queries

Supported

```text
Nearest Neighbor

Overlap

Visibility

Region Search

Radius Search
```

Spatial queries use bounding structures.

---

# Numerical Robustness

Algorithms shall

- tolerate floating-point error
- normalize inputs
- avoid catastrophic cancellation
- minimize accumulated error
- remain deterministic

---

# Precision

Internal precision

```text
64-bit floating point
```

Tolerance comparisons

```text
ε = 0.001 mm
```

Configurable internally.

---

# Degenerate Geometry

Supported

```text
Point

Line

Zero Area Polygon

Duplicate Vertex
```

Degenerate geometry is handled gracefully.

---

# Performance

Algorithms should favor

```text
O(log n)

O(n)

O(n log n)
```

Avoid quadratic algorithms unless unavoidable.

---

# Parallel Processing

Suitable algorithms may execute in parallel.

Examples

```text
Sampling

Bounding

Triangulation

Simplification
```

Results must remain deterministic.

---

# Incremental Algorithms

Algorithms should recompute only affected regions.

Supported by

```text
Dependency Graph

↓

Task Scheduler
```

Incremental execution is preferred.

---

# Caching

Cached results include

```text
Bounds

Length

Area

Tessellation

Sampling
```

Caches invalidate automatically.

---

# Thread Safety

Algorithms must

- avoid shared mutable state
- support concurrent execution
- produce deterministic output

---

# Serialization

Geometry algorithms produce transient results.

Derived data

```text
Meshes

Bounds

Samples

Caches
```

are never serialized.

---

# Domain Rules

The following always apply.

- Algorithms operate on geometry only.
- Geometry remains immutable.
- Algorithms are deterministic.
- Floating-point tolerance is explicit.
- Derived geometry is transient.
- Boolean operations preserve valid topology.
- Adaptive sampling is preferred.
- Incremental computation is supported.
- Geometry algorithms remain machine-independent.
- Embroidery generation is not part of the geometry layer.

---

# Out of Scope

This document does not define

- embroidery algorithms
- stitch generation
- rendering pipelines
- machine compilation
- simulation algorithms

These belong to later domain and architecture documents.

---

# Future Topics

Future geometry capabilities

```text
NURBS

Constrained Geometry

Parametric Modeling

Mesh Editing

Surface Modeling

3D Geometry

GPU Geometry Processing

Computational Geometry Extensions
```

---

# Acceptance Criteria

The Geometry Algorithm library is complete when

✓ Core geometric operations are defined.

✓ Algorithms remain independent of embroidery.

✓ Numerical robustness requirements are specified.

✓ Boolean, offset, sampling, and topology operations are covered.

✓ Incremental computation is supported.

✓ Derived geometry remains transient.

✓ Thread-safe deterministic execution is required.

✓ Performance expectations are established.

✓ The library supports professional CAD-grade editing.

✓ Geometry algorithms serve as the mathematical foundation for all higher-level systems.
