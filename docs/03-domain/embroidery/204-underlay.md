# Domain
## DOM-204 Underlay

**Document ID:** DOM-204  
**Title:** Underlay  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Embroidery Domain Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-201 Running Stitch
DOM-202 Satin Stitch
DOM-203 Fill Stitch
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

This document defines Underlay, one of the most important concepts in professional embroidery digitizing.

Underlay forms the structural foundation of embroidery.

It is sewn before the visible stitches to stabilize the fabric, improve stitch quality, reduce distortion, and enhance the final appearance.

Although invisible in the finished design, underlay is often the deciding factor between poor-quality and professional embroidery.

---

# Philosophy

Visible stitches create appearance.

Underlay creates structure.

```text
Fabric

↓

Underlay

↓

Top Stitch

↓

Finished Embroidery
```

Without a proper foundation, even perfectly digitized top stitches will produce poor embroidery.

---

# Goals

The Underlay system shall provide

- Fabric stabilization
- Thread support
- Reduced distortion
- Improved coverage
- Consistent stitch quality
- Machine independence

---

# Definition

Underlay is an embroidery layer sewn before the visible embroidery.

It is normally hidden beneath subsequent stitches.

Its purpose is structural rather than decorative.

---

# Objectives

Underlay exists to

- stabilize fabric
- anchor thread
- reduce movement
- support top stitches
- improve edge quality
- increase loft
- reduce fabric show-through
- improve durability

---

# Underlay Pipeline

```text
Geometry

↓

Embroidery Object

↓

Underlay Generation

↓

Top Stitch Generation

↓

Optimization

↓

Machine
```

Underlay is generated before visible embroidery.

---

# Underlay Characteristics

Good underlay

- is hidden
- uses less thread than the top stitch
- supports the design
- minimizes fabric distortion
- improves embroidery quality

---

# Common Underlay Types

Supported types

```text
Center Run

Edge Run

Double Edge

Zigzag

Grid

Tatami

Contour

Combination Underlay
```

Multiple underlays may be combined.

---

# Center Run Underlay

A Running Stitch sewn along the centerline.

```text
Center

↓

Running Stitch
```

Applications

- narrow satin columns
- lettering
- borders

Benefits

- stabilizes narrow objects
- minimizes thread use

---

# Edge Run Underlay

Running stitches placed near object edges.

```text
Edge

↓

Running Stitch
```

Applications

- satin columns
- decorative borders

Benefits

- sharp edges
- improved definition
- reduced pull

---

# Double Edge Underlay

Two edge runs.

```text
Left Edge

↓

Right Edge
```

Applications

```text
Wide Satin

Heavy Fabrics

High Density Designs
```

---

# Zigzag Underlay

Alternating stitches across the column.

```text
Left

↓

Right

↓

Left

↓

Right
```

Applications

- satin columns
- medium-width objects

Benefits

- loft
- stability
- thread support

---

# Grid Underlay

Two intersecting running stitch layers.

```text
Horizontal

+

Vertical
```

Applications

- large fill regions
- heavy fabrics

Benefits

- excellent stabilization
- reduced puckering

---

# Tatami Underlay

A lightweight fill beneath the visible fill.

Applications

- large embroidery
- unstable fabrics

Produces excellent coverage.

---

# Contour Underlay

Underlay follows object boundaries.

Applications

```text
Complex Shapes

Organic Artwork

Large Curved Regions
```

---

# Combination Underlay

Multiple underlays may be combined.

Example

```text
Center Run

↓

Edge Run

↓

Zigzag

↓

Top Satin
```

Combination underlays provide superior quality.

---

# Underlay Selection

Selection depends upon

- stitch type
- fabric
- thread
- density
- object width
- embroidery purpose

No single underlay fits every design.

---

# Satin Underlay

Common combinations

```text
Center Run

Edge Run

Double Edge

Zigzag
```

The digitizer selects the appropriate combination.

---

# Fill Underlay

Typical options

```text
Grid

Tatami

Contour

Light Running Stitch
```

Depends upon

- region size
- density
- fabric stability

---

# Running Stitch Underlay

Running Stitch often requires

```text
No Underlay
```

Unless

- decorative
- reinforcement
- unstable fabric

---

# Stitch Direction

Underlay direction should generally differ from the visible stitch direction.

Purpose

- improve stability
- reduce visible thread channels
- distribute stress

---

# Density

Underlay density is lower than visible embroidery.

Purpose

```text
Support

Not Coverage
```

Dense underlay increases stiffness unnecessarily.

---

# Spacing

Typical underlay spacing

```text
1 mm

↓

3 mm
```

Depends on

- fabric
- stitch type
- underlay style

---

# Offset

Edge underlay is usually offset inward.

Purpose

```text
Hide Underlay

Maintain Edge Quality
```

Typical offset

```text
0.2–0.5 mm
```

---

# Stitch Length

Typical values

```text
2 mm

↓

5 mm
```

Long enough for efficiency.

Short enough for stability.

---

# Fabric Influence

Fabric strongly affects underlay.

Examples

### Stable Woven Fabric

```text
Minimal Underlay
```

---

### Stretch Fabric

```text
More Underlay

Greater Stabilization
```

---

### Towels

```text
Heavy Underlay

High Loft
```

---

### Caps

Require

- stronger stabilization
- careful sequencing

---

# Thread Influence

Thread affects

- visibility
- coverage
- loft
- tension

Thicker thread often requires lighter underlay.

---

# Pull Compensation

Underlay works together with

```text
Pull Compensation
```

Neither replaces the other.

---

# Push Compensation

Proper underlay reduces push effects but does not eliminate them.

Push compensation remains necessary.

---

# Sequencing

Underlay is always sewn before

```text
Visible Embroidery
```

Multiple embroidery objects may share sequencing optimization.

---

# Travel Optimization

Adjacent underlay regions may share travel paths.

Optimization should reduce

- trims
- jumps
- thread waste

---

# Machine Speed

Underlay generally permits

```text
Higher Speed
```

than dense decorative stitching.

Machine limitations still apply.

---

# Thread Consumption

Underlay typically consumes

```text
10–40%

of Total Thread
```

depending on

- stitch type
- density
- fabric

---

# Failure Modes

Insufficient underlay

```text
Puckering

Poor Coverage

Edge Collapse

Fabric Show-through

Loose Stitches
```

---

Excessive underlay

```text
Stiff Design

Thread Buildup

Excessive Thickness

Longer Production Time
```

Proper balance is essential.

---

# Simulation

Simulation may optionally display

```text
Underlay

↓

Top Stitch
```

Developers and professional users benefit from underlay visualization.

End-user preview may hide it.

---

# Machine Compilation

Machine compilation preserves logical underlay.

It may

- optimize travel
- merge commands
- enforce machine limits

without changing underlay intent.

---

# Domain Rules

The following always apply.

- Underlay is sewn before visible embroidery.
- Underlay exists for structural support.
- Underlay should normally remain hidden.
- Different stitch types require different underlay strategies.
- Underlay density is lower than top-stitch density.
- Fabric selection influences underlay choice.
- Underlay complements, but does not replace, pull and push compensation.
- Combination underlays are valid and often preferred.
- Underlay should minimize fabric distortion.
- Machine compilation preserves logical underlay behavior.

---

# Out of Scope

This document does not define

- density calculation
- pull compensation algorithms
- sequencing optimization
- machine encoding
- stitch generation algorithms

These are defined in later documents.

---

# Future Topics

Future embroidery documents expand

```text
Tie-In

Tie-Off

Density

Pull Compensation

Push Compensation

Cornering

Optimization

Sequencing
```

---

# Acceptance Criteria

The Underlay specification is complete when

✓ Underlay is defined as the structural foundation of embroidery.

✓ Common underlay types are documented.

✓ Stitch-type-specific underlay strategies are introduced.

✓ Density, spacing, and offset concepts are defined.

✓ Fabric and thread influences are documented.

✓ Combination underlays are supported.

✓ Quality improvements and common failure modes are identified.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Domain rules establish consistent implementation behavior.

✓ Underlay is established as an essential component of professional embroidery digitizing.
