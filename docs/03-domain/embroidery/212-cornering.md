# Domain
## DOM-212 Cornering

**Document ID:** DOM-212  
**Title:** Cornering  
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
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-213 Overlaps
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines Cornering, the collection of techniques used to maintain embroidery quality when stitch paths change direction.

Corners are among the most challenging areas in embroidery because they concentrate

- thread
- needle penetrations
- fabric distortion
- pull forces

Proper corner handling is essential for producing sharp, clean embroidery.

---

# Philosophy

A corner is not simply two lines meeting.

It is a region where manufacturing behavior changes.

```text
Geometry

↓

Direction Change

↓

Corner Processing

↓

Stitch Generation

↓

Embroidery
```

Cornering should preserve the designer's intent while respecting the physical behavior of thread and fabric.

---

# Goals

The cornering system shall provide

- Sharp visual corners
- Minimal thread buildup
- Controlled distortion
- Smooth stitch flow
- Machine independence
- Deterministic generation

---

# Definition

Cornering is the process of modifying stitch generation around changes in geometric direction to maintain embroidery quality.

Corner processing occurs before final stitch generation.

---

# Corner Types

Supported corner categories

```text
Acute Corner

Right Angle

Obtuse Corner

Reflex Corner

Rounded Corner

Compound Corner

Curved Transition
```

Each category requires different handling.

---

# Acute Corner

Angle

```text
< 90°
```

Characteristics

- high stitch concentration
- increased pull
- greater risk of thread buildup

Usually requires additional compensation.

---

# Right Angle

Angle

```text
≈ 90°
```

The most common embroidery corner.

Requires balanced corner compensation.

---

# Obtuse Corner

Angle

```text
90°–180°
```

Typically experiences

- lower distortion
- smoother stitch transitions

Requires minimal correction.

---

# Reflex Corner

Angle

```text
> 180°
```

Common in

- lettering
- decorative shapes
- complex logos

Requires careful stitch sequencing.

---

# Rounded Corner

Geometry already contains curvature.

Algorithms should

- preserve curvature
- avoid unnecessary corner treatment

---

# Corner Pipeline

```text
Geometry

↓

Corner Detection

↓

Classification

↓

Compensation

↓

Stitch Planning

↓

Embroidery
```

---

# Corner Detection

The digitizer identifies

changes in path direction.

Detection considers

- angle
- curvature
- stitch type
- local geometry

---

# Stitch Direction

Corners frequently require

gradual stitch-angle transitions

rather than abrupt changes.

Smooth transitions improve

- appearance
- thread reflection
- machine performance

---

# Stitch Density

Without correction,

corners accumulate stitches.

The digitizer should

- redistribute stitches
- maintain consistent coverage
- avoid excessive penetration density

---

# Stitch Length

Corners often require

shorter stitches

to maintain accuracy.

Excessively short stitches should still respect machine limitations.

---

# Corner Compensation

Compensation adjusts geometry to

- preserve sharpness
- reduce collapse
- maintain dimensions

Corner compensation complements

- pull compensation
- push compensation

It does not replace them.

---

# Satin Stitch Corners

Satin Stitch is particularly sensitive.

Common techniques

```text
Angle Interpolation

Stitch Shortening

Density Redistribution

Split Corner

Miter Corner
```

Sharp satin corners require special treatment.

---

# Fill Stitch Corners

Fill generation should

- terminate rows cleanly
- redistribute row spacing
- avoid thread buildup

Fill rows should never terminate abruptly.

---

# Running Stitch Corners

Running Stitch generally requires

- adaptive spacing
- optional stitch insertion

to maintain geometric fidelity.

---

# Mitered Corner

A miter maintains

sharp geometric appearance

by adjusting stitch endpoints.

Applications

```text
Borders

Frames

Lettering
```

---

# Rounded Corner Conversion

Some production profiles may

replace extremely sharp corners

with small radii

to improve manufacturability.

This behavior should be configurable.

---

# Stitch Angle Interpolation

Instead of

```text
45°

↓

90°
```

the digitizer may generate

```text
45°

↓

55°

↓

65°

↓

75°

↓

90°
```

Smooth transitions improve embroidery quality.

---

# Underlay Interaction

Underlay must follow

the same corner strategy

as the visible embroidery.

Poor underlay cornering leads to

- visible distortion
- edge collapse

---

# Density Interaction

Corner density should remain

visually consistent

even if stitch placement changes.

Additional stitches should not create excessive bulk.

---

# Pull Compensation Interaction

Pull compensation affects

corner width.

Corner algorithms should operate

after pull compensation

to preserve intended geometry.

---

# Push Compensation Interaction

Push compensation affects

corner ends.

Corner processing must coordinate with push correction

to avoid overcompensation.

---

# Sequencing Interaction

Object sequencing influences

corner quality.

For example

```text
Fill

↓

Border
```

often produces

cleaner corners

than the reverse order.

---

# Fabric Influence

Fabric significantly affects corner behavior.

### Stable Woven

Produces

```text
Sharp Corners
```

with minimal correction.

---

### Stretch Fabric

Requires

- increased compensation
- stronger underlay
- conservative density

---

### High-Pile Fabrics

Corners require

- additional coverage
- stronger stabilization

to remain visible.

---

# Thread Influence

Thread properties influence

- corner sharpness
- reflection
- coverage
- bulk

Heavier threads often require

reduced corner density.

---

# Machine Influence

Machine capabilities influence

- minimum stitch length
- acceleration
- needle penetration accuracy

The compiler enforces machine limits

without altering logical corner intent.

---

# Decorative Corner Styles

Future versions may support

```text
Sharp

Rounded

Beveled

Mitered

Decorative

Programmable
```

allowing artistic control.

---

# Quality Factors

Well-constructed corners exhibit

- crisp geometry
- consistent density
- smooth stitch flow
- minimal distortion
- clean edges

---

# Failure Modes

Insufficient corner processing

```text
Rounded Corners

Collapsed Satin

Poor Definition

Visible Gaps
```

---

Excessive correction

```text
Bulging

Thread Buildup

Needle Damage

Heavy Appearance
```

---

Poor stitch interpolation

```text
Abrupt Reflection

Uneven Texture

Visible Angle Changes
```

---

# Simulation

Simulation should visualize

- stitch direction
- angle transitions
- density
- corner compensation

Professional simulation may highlight

corner regions separately.

---

# Machine Compilation

Machine compilation preserves

logical corner geometry.

It may

- subdivide long stitches
- enforce stitch limits
- optimize commands

without changing intended corner behavior.

---

# Domain Rules

The following always apply.

- Cornering is a geometric correction process.
- Corners are classified before stitch generation.
- Stitch density should remain visually consistent through corners.
- Satin Stitch requires specialized corner handling.
- Running and Fill stitches apply cornering differently.
- Pull and push compensation must coordinate with corner processing.
- Underlay follows the same logical corner strategy as top stitches.
- Machine compilation preserves logical corner intent.
- Corner algorithms should minimize thread buildup while preserving geometry.
- Corner quality is a primary indicator of professional digitizing.

---

# Out of Scope

This document does not define

- pull compensation algorithms
- push compensation algorithms
- stitch generation mathematics
- machine encoding
- AI optimization strategies

These are covered in later documents.

---

# Future Topics

Future embroidery documents expand

```text
Overlaps

Optimization

Fabric Profiles

AI Corner Optimization

Advanced Satin Algorithms
```

---

# Acceptance Criteria

The Cornering specification is complete when

✓ Cornering is defined as a dedicated embroidery correction process.

✓ Corner classification is established.

✓ Stitch-type-specific corner behavior is documented.

✓ Interaction with density, underlay, pull, and push compensation is specified.

✓ Fabric, thread, and machine influences are identified.

✓ Common correction techniques are documented.

✓ Quality objectives and failure modes are established.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Domain rules establish deterministic, machine-independent behavior.

✓ Cornering is established as a core quality-control process within the embroidery digitizing pipeline.
