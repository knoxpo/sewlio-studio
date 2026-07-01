# Domain
## DOM-210 Pull Compensation

**Document ID:** DOM-210  
**Title:** Pull Compensation  
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
DOM-204 Underlay
DOM-209 Density
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

This document defines Pull Compensation, one of the most important corrective techniques in professional embroidery digitizing.

During embroidery, thread tension pulls stitches toward their centerline, causing embroidered objects to become narrower than their original geometry.

Pull Compensation intentionally enlarges embroidery geometry before stitch generation so that the finished embroidery matches the intended design.

Without pull compensation, professional embroidery cannot maintain dimensional accuracy.

---

# Philosophy

Embroidery is not dimensionally accurate by default.

It is a physical manufacturing process.

```text
Digital Geometry

↓

Embroidery

↓

Thread Pull

↓

Smaller Result
```

Professional digitizing anticipates this behavior rather than correcting it afterward.

---

# Goals

The pull compensation system shall provide

- Dimensionally accurate embroidery
- Fabric-aware correction
- Thread-aware correction
- Predictable results
- Machine independence
- Deterministic generation

---

# Definition

Pull Compensation is the process of expanding embroidery geometry to compensate for thread tension that causes the finished embroidery to contract.

Compensation occurs **before stitch generation**.

---

# Physical Cause

During sewing,

thread tension causes stitches to pull toward their center.

```text
Original Width

──────────

↓

Thread Pull

↓

Narrower Result
```

The amount of pull depends on

- fabric
- thread
- density
- stitch angle
- stitch type

---

# Compensation Pipeline

```text
Geometry

↓

Compensation

↓

Stitch Generation

↓

Machine

↓

Finished Embroidery
```

Compensation modifies embroidery geometry,

not the original vector artwork.

---

# Compensation Direction

Pull compensation occurs

perpendicular to stitch direction.

Example

```text
Stitch Direction

↓

Horizontal

↓

Compensation

Vertical
```

This is a fundamental rule.

---

# Geometry Preservation

Original artwork always remains unchanged.

```text
Artwork

↓

Embroidery Geometry

↓

Pull Compensation

↓

Stitches
```

Compensation is applied only to embroidery objects.

---

# Stitch Types

Different stitch families require different compensation.

---

## Running Stitch

Running Stitch generally requires

```text
Minimal

or

No Pull Compensation
```

---

## Satin Stitch

Satin Stitch almost always requires pull compensation.

It is the stitch type most affected by thread tension.

---

## Fill Stitch

Fill Stitch usually requires

moderate compensation,

especially along exposed edges.

---

## Underlay

Underlay itself is generally not compensated.

Instead,

it supports compensated top stitches.

---

# Compensation Amount

Typical values

```text
0.1 mm

↓

0.5 mm
```

depending upon

- fabric
- thread
- stitch type
- object width

Professional users may override these values.

---

# Narrow Satin Columns

Narrow columns

experience proportionally greater pull.

They typically require

greater relative compensation.

---

# Wide Satin Columns

Wide satin columns

require less relative compensation,

although absolute compensation may increase slightly.

---

# Fill Regions

Compensation is generally applied

only to

```text
External Boundaries
```

Internal fill rows remain unchanged.

---

# Corners

Corners require special handling.

Blindly expanding corners produces

```text
Bulging

Overlap

Visible Artifacts
```

Corner compensation is defined separately.

---

# Curved Geometry

Curved objects require

smoothly varying compensation.

Abrupt geometric changes should be avoided.

---

# Holes

Internal holes

normally receive

inverse compensation.

Example

```text
Letter O

↓

Outer Boundary

Expanded

↓

Inner Hole

Reduced
```

This preserves the visual hole size.

---

# Fabric Influence

Fabric has the greatest influence on pull.

---

### Stable Woven

Requires

```text
Small Compensation
```

---

### Stretch Fabric

Requires

```text
Larger Compensation
```

---

### Towels

Require

```text
Aggressive Compensation

+

Strong Underlay
```

---

### Leather

Often requires

minimal pull compensation

but careful density adjustment.

---

# Thread Influence

Thread properties affect pull.

Examples

```text
Polyester

Rayon

Cotton

Metallic
```

Thicker threads generally require different compensation than finer threads.

---

# Density Interaction

Higher density

produces greater thread tension.

Therefore,

higher density often requires

greater pull compensation.

---

# Underlay Interaction

Effective underlay reduces

fabric movement,

thereby reducing required pull compensation.

Neither replaces the other.

---

# Stitch Angle Interaction

Compensation is always computed

relative to stitch angle,

not object orientation.

Changing stitch angle changes compensation direction.

---

# Object Width

Compensation may vary according to

```text
Column Width

↓

Required Expansion
```

Very small objects often require proportionally larger correction.

---

# Automatic Compensation

Automatic calculation considers

- stitch type
- density
- fabric
- thread
- object size
- production profile

Automatic compensation should be the default.

---

# Manual Compensation

Professional users may specify

```text
Global

Object

Edge

Profile
```

Manual values override automatic calculations.

---

# Compensation Profiles

Reusable profiles may exist for

```text
Caps

Jackets

Shirts

Towels

Stretch Fabric

Leather
```

Profiles encapsulate

- pull
- density
- underlay

together.

---

# Adaptive Compensation

Future implementations may vary compensation

within a single embroidery object.

Applications

```text
Variable Width Satin

Curved Borders

Artistic Embroidery
```

---

# Simulation

Simulation should optionally display

```text
Original Geometry

↓

Compensated Geometry
```

This aids

- education
- debugging
- professional digitizing

---

# Machine Compilation

Machine compilation preserves

already compensated geometry.

It must never apply pull compensation again.

---

# Quality Factors

Proper pull compensation produces

- accurate dimensions
- crisp edges
- professional lettering
- consistent borders
- improved registration

---

# Failure Modes

Insufficient compensation

```text
Narrow Letters

Collapsed Satin

Visible Fabric

Incorrect Dimensions
```

---

Excessive compensation

```text
Bulging

Rounded Corners

Object Overlap

Heavy Appearance
```

---

Inconsistent compensation

```text
Uneven Width

Poor Registration

Visible Size Variation
```

---

# Optimization

Optimization attempts to

- preserve intended geometry
- minimize distortion
- adapt to production profiles
- reduce manual tuning

Compensation should be predictable and repeatable.

---

# Domain Rules

The following always apply.

- Pull compensation is applied before stitch generation.
- Original artwork is never modified.
- Compensation occurs perpendicular to stitch direction.
- Satin Stitch generally requires pull compensation.
- Fabric has the strongest influence on compensation values.
- Density and underlay affect required compensation.
- Internal holes receive inverse compensation.
- Automatic compensation should be profile-driven.
- Machine compilation never reapplies pull compensation.
- Compensation exists to preserve the intended finished dimensions.

---

# Out of Scope

This document does not define

- push compensation
- density algorithms
- stitch generation
- thread physics simulation
- AI compensation optimization

These are covered in subsequent documents.

---

# Future Topics

Future embroidery documents expand

```text
Push Compensation

Cornering

Overlaps

Optimization

Fabric Profiles

AI Manufacturing Models
```

---

# Acceptance Criteria

The Pull Compensation specification is complete when

✓ Pull compensation is defined as geometric expansion before stitch generation.

✓ Physical causes of thread pull are documented.

✓ Compensation direction is specified relative to stitch angle.

✓ Stitch-type-specific behavior is defined.

✓ Fabric, thread, density, and underlay interactions are documented.

✓ Automatic and manual compensation workflows are supported.

✓ Quality improvements and failure modes are identified.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Domain rules establish deterministic, machine-independent behavior.

✓ Pull compensation is established as a fundamental corrective process for professional embroidery digitizing.
