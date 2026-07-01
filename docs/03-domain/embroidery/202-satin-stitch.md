# Domain
## DOM-202 Satin Stitch

**Document ID:** DOM-202  
**Title:** Satin Stitch  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Embroidery Domain Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-201 Running Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-208 Sequencing
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-212 Cornering
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Satin Stitch, one of the most important stitch types in machine embroidery.

Satin Stitch is primarily used to produce smooth, continuous thread coverage across narrow regions while creating a glossy appearance.

It is the preferred stitch type for

- text
- lettering
- borders
- narrow columns
- decorative outlines
- logos
- emblems
- monograms

---

# Philosophy

Unlike Running Stitch, which follows a path, Satin Stitch spans a region.

```text
Geometry

↓

Satin Column

↓

Needle Penetrations

↓

Machine
```

The quality of Satin embroidery depends on balancing

- appearance
- stability
- manufacturability

rather than simply covering geometry.

---

# Goals

The Satin Stitch system shall provide

- Smooth thread coverage
- Consistent stitch angle
- High visual quality
- Minimal distortion
- Predictable thread sheen
- Efficient manufacturing
- Machine independence

---

# Definition

A Satin Stitch is a sequence of alternating stitches that traverse between two opposing boundaries.

Rather than following the centerline, stitches travel across the width of the object.

---

# Geometry

Input

```text
Left Boundary

Right Boundary

Centerline (optional)
```

Output

```text
Alternating Stitch Sequence
```

---

# Typical Applications

Satin Stitch is used for

```text
Lettering

Monograms

Borders

Emblems

Logos

Decorative Elements

Narrow Shapes

Appliqué Borders
```

---

# Satin Column

The fundamental geometric representation is a Satin Column.

A Satin Column consists of

```text
Left Rail

↓

Centerline (optional)

↓

Right Rail
```

The rails define the sewing boundaries.

---

# Rails

Rails represent the outer edges of the column.

Properties

```text
Continuous

Non-intersecting

Ordered

Smooth
```

---

# Centerline

The centerline defines

- stitch progression
- sequencing
- stitch spacing

It does not define stitch endpoints.

---

# Stitch Generation

Pipeline

```text
Rails

↓

Centerline

↓

Spacing

↓

Needle Penetrations

↓

Satin Stitch
```

---

# Stitch Angle

Every satin stitch has an angle.

The stitch angle controls

- thread reflection
- appearance
- coverage
- distortion

The angle should change smoothly throughout the column.

---

# Stitch Direction

Satin stitches alternate

```text
Left

↓

Right

↓

Left

↓

Right
```

forming a zigzag pattern.

---

# Column Width

Column width determines suitability.

Typical range

```text
1 mm

↓

8 mm
```

Very narrow columns

```text
< 1 mm
```

may be converted to Running Stitch.

Very wide columns

```text
> 8 mm
```

are usually converted to Fill Stitch.

---

# Stitch Length

Each stitch spans

```text
Left Rail

↓

Right Rail
```

The span depends on

- column width
- compensation
- fabric
- machine limits

---

# Stitch Spacing

Spacing controls stitch density.

Typical spacing

```text
0.30 mm

↓

0.45 mm
```

Spacing varies according to

- thread
- fabric
- desired coverage

---

# Density

Higher density

- increases coverage
- increases sheen
- increases distortion

Lower density

- reduces thread
- improves flexibility
- may expose fabric

Density optimization is documented separately.

---

# Thread Reflection

One defining characteristic of Satin Stitch is directional light reflection.

Reflection depends upon

- stitch angle
- thread type
- lighting
- fabric

This produces the characteristic glossy appearance.

---

# Curved Satin

Curved columns require

- smooth angle interpolation
- adaptive spacing
- corner compensation

Abrupt changes reduce quality.

---

# Variable Width Columns

Columns may widen or narrow gradually.

Algorithms should

- preserve spacing
- preserve stitch quality
- avoid excessive stitch length variation

---

# Corner Handling

Sharp corners require

- shortening stitches
- increasing density
- angle smoothing
- corner compensation

Without correction

```text
Thread Buildup

Needle Holes

Distortion
```

may occur.

---

# Branching

Branches occur in

```text
Letters

Logos

Decorative Shapes
```

Branch points require sequencing optimization.

---

# Underlay

Satin Stitch almost always requires underlay.

Common types

```text
Center Run

Edge Run

Double Edge

Zigzag
```

Underlay improves

- stability
- loft
- coverage

---

# Pull Compensation

Thread tension causes satin columns to narrow.

Pull compensation widens geometry before stitch generation.

Purpose

```text
Desired Width

↓

Physical Width
```

---

# Push Compensation

Thread accumulation causes ends to expand.

Push compensation adjusts

- ends
- corners
- joins

---

# Start Point

Start position should minimize

- travel
- trims
- thread changes

Entry location is an optimization problem.

---

# End Point

Exit position should support

- neighboring objects
- sequencing
- travel optimization

---

# Fabric Behavior

Satin Stitch produces

- high thread tension
- high coverage
- moderate distortion

Fabric type significantly influences settings.

---

# Thread Consumption

Thread consumption depends upon

- column width
- density
- length
- compensation

Satin uses substantially more thread than Running Stitch.

---

# Machine Speed

Wide satin columns often require

```text
Reduced Sewing Speed
```

to improve quality.

Machine profiles may impose limits.

---

# Machine Limits

Machines define

- maximum stitch length
- maximum acceleration
- needle limitations

The compiler must respect machine capabilities.

---

# Quality Factors

Quality depends upon

- rail accuracy
- spacing
- density
- stitch angle
- underlay
- pull compensation
- sequencing
- thread
- fabric

---

# Failure Modes

Common issues

```text
Bird Nesting

Looping

Thread Breaks

Puckering

Poor Coverage

Thread Gaps

Needle Deflection
```

These should be minimized by proper digitizing.

---

# Simulation

Simulation visualizes

- stitch direction
- thread sheen
- coverage
- sewing order

Simulation does not alter stitch generation.

---

# Machine Compilation

Compilation may

- subdivide long stitches
- insert trims
- insert lock stitches
- enforce machine stitch limits

Logical Satin Stitch remains unchanged.

---

# Variants

Common Satin variants

```text
Standard Satin

Split Satin

Curved Satin

Variable Satin

Decorative Satin

Programmable Satin
```

Future algorithms may introduce additional variants.

---

# Domain Rules

The following always apply.

- Satin Stitch spans between opposing boundaries.
- Satin Stitch is intended for narrow regions.
- Stitch angle directly affects appearance.
- Density determines coverage.
- Underlay is normally required.
- Pull compensation is mandatory for quality production.
- Very narrow columns should become Running Stitch.
- Very wide columns should become Fill Stitch.
- Stitch spacing should remain consistent.
- Machine compilation may enrich but never redefine the logical Satin Stitch.

---

# Out of Scope

This document does not define

- underlay algorithms
- density calculations
- pull compensation algorithms
- sequencing optimization
- machine encoding

These are specified in later documents.

---

# Future Topics

Future embroidery documents expand

```text
Fill Stitch

Underlay

Density

Pull Compensation

Push Compensation

Cornering

Optimization

Sequencing
```

---

# Acceptance Criteria

The Satin Stitch specification is complete when

✓ Satin Stitch is defined as a column-spanning stitch type.

✓ Rails and centerline concepts are established.

✓ Stitch angle and spacing are specified.

✓ Column width recommendations are defined.

✓ Underlay and compensation requirements are introduced.

✓ Machine and fabric considerations are documented.

✓ Quality factors and failure modes are identified.

✓ Satin variants are recognized.

✓ Domain rules establish consistent implementation behavior.

✓ Satin Stitch is established as the primary stitch type for narrow filled regions.
