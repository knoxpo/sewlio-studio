# Domain
## DOM-201 Running Stitch

**Document ID:** DOM-201  
**Title:** Running Stitch  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Embroidery Domain Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-209 Density
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Running Stitch, the most fundamental stitch type in machine embroidery.

Every other embroidery stitch can be viewed as an extension, repetition, or arrangement of running stitches.

Running Stitch is used for

- outlines
- detail work
- travel paths
- underlay
- decorative effects
- reinforcement

---

# Philosophy

A Running Stitch follows a path.

Unlike Satin or Fill stitches, it does not create coverage.

It creates a sewing trajectory.

```text
Geometry

↓

Path

↓

Running Stitch

↓

Machine
```

---

# Goals

Running Stitch generation shall provide

- Smooth path following
- Uniform spacing
- Deterministic generation
- High manufacturing quality
- Minimal distortion
- Machine independence

---

# Definition

A Running Stitch is a sequential series of stitches that follows the centerline of a geometric path.

Unlike fill stitches,

Running Stitch does not span an area.

It follows a single trajectory.

---

# Typical Applications

Running Stitch is commonly used for

```text
Outlines

Fine Details

Lettering

Travel Stitches

Decorative Lines

Sketch Embroidery

Underlay

Reinforcement

Connection Paths
```

---

# Characteristics

Running Stitch

```text
Single Thread Path

↓

Low Thread Consumption

↓

Fast Sewing

↓

Minimal Coverage
```

---

# Geometry

Input

```text
Path
```

Output

```text
Ordered Stitch Sequence
```

The generated stitches lie approximately on the source geometry.

---

# Stitch Generation

Pipeline

```text
Geometry

↓

Curve Evaluation

↓

Sampling

↓

Spacing

↓

Optimization

↓

Running Stitch
```

---

# Stitch Placement

Stitches are placed

```text
Along Path

↓

Uniform Distance
```

Spacing is measured along arc length.

---

# Stitch Spacing

Typical spacing

```text
1.5 mm

↓

4.0 mm
```

Very small details may require

```text
0.8 mm

↓

1.2 mm
```

Long decorative stitches may reach

```text
5–6 mm
```

Subject to machine capability.

---

# Adaptive Spacing

Spacing should adapt to curvature.

```text
Straight Line

↓

Larger Spacing

Curve

↓

Smaller Spacing
```

This improves visual quality.

---

# Maximum Stitch Length

Very long stitches

- snag easily
- loosen
- reduce quality

Machine profiles define

```text
Maximum Stitch Length
```

Long segments should be subdivided automatically.

---

# Minimum Stitch Length

Very short stitches

- weaken fabric
- increase thread buildup
- reduce efficiency

Algorithms should merge excessively short segments where practical.

---

# Path Following

Running Stitch follows

```text
Curve Centerline
```

No lateral displacement occurs.

---

# Curve Sampling

Sampling should preserve

- curvature
- corners
- continuity

Adaptive sampling is preferred.

---

# Corners

Sharp corners require

```text
Additional Stitches
```

Purpose

- improve corner definition
- reduce thread pull
- preserve geometry

---

# Curvature

High curvature regions require

```text
Higher Stitch Density
```

Flat regions require fewer stitches.

---

# Stitch Direction

Running Stitch follows

```text
Path Direction
```

Reversing the path reverses stitch order.

---

# Start Point

The first stitch begins at

```text
Path Start
```

unless sequencing optimization selects an alternate entry.

---

# End Point

Ends at

```text
Path End
```

unless closed-path optimization applies.

---

# Closed Paths

Closed paths

```text
Circle

Ellipse

Polygon
```

produce continuous running stitches.

Entry point selection is an optimization problem.

---

# Open Paths

Open paths begin and end at defined endpoints.

Travel planning considers neighboring embroidery objects.

---

# Stitch Density

Running Stitch density depends on

```text
Spacing
```

Unlike Fill stitches,

density is linear,

not area-based.

---

# Thread Consumption

Running Stitch consumes

approximately

```text
Path Length

+

Machine Overhead
```

It is among the most economical stitch types.

---

# Machine Speed

Running Stitch generally permits

```text
High Sewing Speed
```

Subject to

- stitch length
- curvature
- thread
- fabric

---

# Fabric Behavior

Running Stitch introduces

- minimal distortion
- minimal thread buildup
- low fabric stress

Making it ideal for lightweight fabrics.

---

# Decorative Running Stitch

Decorative variants include

```text
Bean Stitch

Triple Stitch

Sketch Stitch

Random Stitch
```

These remain logically derived from Running Stitch.

---

# Double Running Stitch

The path is sewn twice.

```text
Forward

↓

Backward
```

Applications

- reinforcement
- historical embroidery
- hand-sewn appearance

---

# Bean Stitch

Each stitch is repeated.

Example

```text
Forward

Back

Forward
```

Produces

- heavier lines
- stronger stitching
- decorative emphasis

---

# Triple Running Stitch

Each logical stitch is sewn multiple times.

Applications

```text
Heavy Outlines

Bold Details
```

---

# Underlay

Running Stitch commonly serves as

```text
Center Run Underlay
```

It stabilizes narrow satin columns.

---

# Travel Stitch

Running Stitch may be hidden beneath later embroidery.

Objective

```text
Minimize Visible Travel
```

Travel optimization belongs to sequencing.

---

# Optimization

Optimization considers

- stitch count
- path length
- travel
- trims
- machine efficiency

The visual path should remain unchanged.

---

# Quality Factors

Quality depends on

- spacing
- corner handling
- stitch length
- sequencing
- fabric
- thread tension

---

# Simulation

Simulation visualizes

- stitch order
- thread path
- sewing direction
- needle movement

Simulation never regenerates stitches.

---

# Machine Compilation

Machine compilation may

- subdivide long stitches
- insert tie-ins
- insert tie-offs
- insert trims
- insert jump commands

Logical Running Stitch remains unchanged.

---

# Thread Changes

Running Stitch itself does not require thread changes.

Thread changes occur only when

- color changes
- needle changes

---

# Domain Rules

The following always apply.

- Running Stitch follows the geometric centerline.
- Stitch spacing is measured along arc length.
- Adaptive spacing is preferred over fixed spacing.
- Long stitches are subdivided automatically.
- Short stitches should be merged where appropriate.
- Running Stitch is linear, not area-based.
- Running Stitch is suitable for outlines and detail work.
- Decorative variants derive from Running Stitch.
- Machine compilation may enrich the stitch sequence without changing the logical path.
- Running Stitch remains the foundational embroidery stitch type.

---

# Out of Scope

This document does not define

- Satin Stitch
- Fill Stitch
- Underlay algorithms
- Compensation
- Sequencing optimization
- Machine encoding

These are covered in subsequent documents.

---

# Future Topics

Future embroidery documents expand

```text
Satin Stitch

Fill Stitch

Underlay

Tie-In

Tie-Off

Travel Optimization

Density

Pull Compensation

Push Compensation
```

---

# Acceptance Criteria

The Running Stitch specification is complete when

✓ Running Stitch is defined as a centerline-following stitch type.

✓ Stitch generation from geometric paths is described.

✓ Adaptive spacing and corner handling are specified.

✓ Stitch length constraints are defined.

✓ Decorative variants are introduced.

✓ Fabric and manufacturing behavior are documented.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Domain rules establish consistent behavior across implementations.

✓ Running Stitch is established as the foundation for more advanced stitch types.

✓ The specification remains machine-independent and suitable for professional embroidery systems.
