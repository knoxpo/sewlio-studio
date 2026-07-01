# Domain
## DOM-203 Fill Stitch

**Document ID:** DOM-203  
**Title:** Fill Stitch  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Embroidery Domain Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-201 Running Stitch
DOM-202 Satin Stitch
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-208 Sequencing
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-212 Cornering
DOM-213 Overlaps
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Fill Stitch, the primary stitch type used to embroider large regions.

Unlike Running Stitch, which follows a path, or Satin Stitch, which spans narrow columns, Fill Stitch efficiently covers broad areas with a controlled stitch pattern.

Fill Stitch is responsible for the majority of stitches in most embroidery designs.

---

# Philosophy

Fill Stitch is not simply "many stitches."

It is a controlled sewing strategy that balances

- coverage
- stability
- appearance
- manufacturing efficiency

```text
Geometry

↓

Fill Region

↓

Fill Pattern

↓

Stitches

↓

Machine
```

---

# Goals

The Fill Stitch system shall provide

- Uniform coverage
- Fabric stability
- Predictable appearance
- Efficient manufacturing
- Low distortion
- Configurable artistic styles
- Machine independence

---

# Definition

A Fill Stitch consists of multiple rows of stitches arranged according to a defined fill pattern to completely cover a closed embroidery region.

Unlike Satin Stitch,

Fill Stitch is area-based.

---

# Typical Applications

Fill Stitch is used for

```text
Large Logos

Backgrounds

Solid Shapes

Decorative Regions

Patches

Appliqué Fill

Artwork

Emblems
```

---

# Fill Region

Input geometry

```text
Closed Boundary

↓

Fill Region
```

The region must be valid.

Self-intersections should be resolved before fill generation.

---

# Fill Pipeline

```text
Geometry

↓

Region Analysis

↓

Pattern Generation

↓

Row Generation

↓

Stitch Generation

↓

Optimization

↓

Machine
```

---

# Fill Rows

Fill consists of multiple rows.

```text
Row 1

↓

Row 2

↓

Row 3
```

Rows collectively produce coverage.

---

# Stitch Direction

Every fill has a dominant stitch angle.

The angle influences

- appearance
- thread sheen
- distortion
- structural stability

---

# Fill Angle

Typical fill angles

```text
0°

30°

45°

60°

90°
```

Adjacent regions often use different angles.

---

# Row Direction

Rows are generated perpendicular to the stitch angle.

Example

```text
Fill Angle

45°

↓

Rows

135°
```

---

# Stitch Length

Typical values

```text
2 mm

↓

5 mm
```

Depends upon

- fabric
- thread
- machine
- fill pattern

---

# Row Spacing

Row spacing determines density.

Typical spacing

```text
0.35 mm

↓

0.50 mm
```

Spacing is configurable.

---

# Density

Density controls

```text
Coverage

Thread Usage

Stiffness

Manufacturing Time
```

Higher density

- better coverage
- more thread
- greater distortion

Lower density

- lighter embroidery
- faster sewing
- reduced stability

---

# Fill Patterns

Supported patterns

```text
Tatami Fill

Random Fill

Wave Fill

Motif Fill

Cross Fill

Brick Fill

Contour Fill

Spiral Fill (future)
```

Tatami Fill is the default.

---

# Tatami Fill

Tatami consists of

```text
Parallel Rows

+

Needle Penetration Variation
```

Benefits

- uniform coverage
- reduced visible rows
- excellent stability

---

# Random Fill

Random Fill intentionally varies

- stitch positions
- row spacing
- penetration points

Applications

```text
Natural Textures

Artistic Effects

Organic Designs
```

---

# Motif Fill

Motif Fill replaces standard rows with repeating decorative patterns.

Examples

```text
Leaves

Stars

Hearts

Geometric Motifs
```

---

# Contour Fill

Rows follow the shape.

```text
Boundary

↓

Internal Contours

↓

Stitches
```

Ideal for

- animals
- faces
- artistic embroidery

---

# Fill Islands

Complex regions may split into

```text
Island A

Island B

Island C
```

Each island generates independently before sequencing.

---

# Hole Handling

Fill regions may contain holes.

Example

```text
Letter O

↓

Outer Region

↓

Inner Void
```

No stitches are generated inside holes.

---

# Entry Point

Entry location should minimize

- travel
- trims
- jumps

Entry is selected during optimization.

---

# Exit Point

Exit location should favor

- adjacent embroidery objects
- efficient sequencing

---

# Underlay

Fill Stitch typically requires underlay.

Common types

```text
Edge Run

Center Walk

Grid

Zigzag
```

Underlay

- stabilizes fabric
- improves coverage
- reduces distortion

---

# Pull Compensation

Fill Stitch contracts after sewing.

Pull compensation enlarges the embroidery region before stitch generation.

---

# Push Compensation

Thread buildup affects

- corners
- edges
- terminations

Push compensation corrects these effects.

---

# Edge Handling

Edges require

- clean termination
- consistent spacing
- overlap control

Edge quality largely determines visual quality.

---

# Corner Handling

Corners may require

- stitch shortening
- adaptive spacing
- row redistribution

Purpose

```text
Reduce Thread Buildup
```

---

# Travel Optimization

Fill generation should minimize

- unnecessary jumps
- trims
- long travel paths

Without changing visual appearance.

---

# Pattern Rotation

Patterns may rotate independently of geometry.

Applications

```text
Visual Contrast

Structural Strength

Artistic Design
```

---

# Multi-Angle Fill

Large regions may use multiple angles.

Example

```text
45°

↓

90°

↓

135°
```

Applications

- texture
- distortion control
- artistic appearance

---

# Fabric Behavior

Fill Stitch creates

- high thread coverage
- significant fabric compression
- moderate-to-high distortion

Fabric selection influences

- density
- underlay
- stitch angle

---

# Thread Consumption

Fill Stitch consumes more thread than

- Running Stitch
- Satin Stitch (for equivalent area)

Consumption depends upon

- density
- pattern
- region size

---

# Machine Speed

Large fill regions generally sew at

```text
Moderate Speed
```

High-density fills may require slower sewing.

---

# Failure Modes

Common problems

```text
Puckering

Thread Buildup

Visible Rows

Fabric Gaps

Poor Edge Quality

Excessive Distortion

Thread Breaks
```

Proper digitizing minimizes these issues.

---

# Simulation

Simulation visualizes

- stitch order
- fill direction
- thread coverage
- sewing progress

Simulation never changes fill generation.

---

# Machine Compilation

Compilation may

- enforce stitch limits
- insert trims
- insert jumps
- optimize commands

Logical Fill Stitch remains unchanged.

---

# Fill Variants

Supported variants

```text
Tatami

Random

Motif

Contour

Cross

Decorative

Programmable
```

Future releases may introduce additional patterns.

---

# Domain Rules

The following always apply.

- Fill Stitch covers closed regions.
- Fill Stitch is area-based.
- Fill direction affects appearance and distortion.
- Density determines thread coverage.
- Underlay is generally required.
- Pull compensation is applied before stitch generation.
- Holes remain unstitched.
- Pattern selection should balance appearance and manufacturing.
- Machine compilation may optimize execution but not alter the logical fill.
- Fill Stitch is the primary embroidery method for large regions.

---

# Out of Scope

This document does not define

- underlay generation
- density algorithms
- pull compensation algorithms
- sequencing optimization
- machine encoding

These are specified in later documents.

---

# Future Topics

Future embroidery documents expand

```text
Underlay

Tie-In

Tie-Off

Density

Pull Compensation

Push Compensation

Cornering

Optimization
```

---

# Acceptance Criteria

The Fill Stitch specification is complete when

✓ Fill Stitch is defined as the primary area-coverage stitch.

✓ Fill regions and row generation are specified.

✓ Fill angle, row spacing, and density are defined.

✓ Common fill patterns are documented.

✓ Hole handling and fill islands are supported.

✓ Underlay and compensation requirements are introduced.

✓ Fabric and machine considerations are documented.

✓ Quality factors and common failure modes are identified.

✓ Domain rules establish consistent implementation behavior.

✓ Fill Stitch is established as the foundation for all large-area embroidery within the platform.
