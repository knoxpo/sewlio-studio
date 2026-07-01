# Domain
## DOM-213 Overlaps

**Document ID:** DOM-213  
**Title:** Overlaps  
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

This document defines Overlaps, the intentional intersection of embroidery objects used to eliminate visible gaps and compensate for the physical behavior of fabric and thread.

Unlike vector artwork, embroidery cannot rely on perfectly aligned boundaries.

Professional embroidery intentionally overlaps objects to ensure complete visual coverage after stitching.

---

# Philosophy

Geometry is exact.

Embroidery is physical.

```text
Object A

│

│  Perfect Alignment

│

Object B

↓

Thread Pull

↓

Visible Gap
```

Professional embroidery prevents gaps by creating controlled overlaps before manufacturing.

---

# Goals

The overlap system shall provide

- Complete visual coverage
- Hidden object transitions
- Reduced visible gaps
- Fabric-aware correction
- Machine independence
- Deterministic behavior

---

# Definition

An Overlap is the intentional extension of one embroidery object into another to compensate for thread pull, fabric movement, and manufacturing tolerances.

Overlaps are embroidery constructs.

They do not modify the original artwork.

---

# Why Overlaps Are Necessary

During embroidery

- stitches contract
- fabric moves
- thread compresses
- objects shift slightly

Without overlap,

perfect vector geometry frequently produces

```text
Visible Fabric

↓

Registration Errors

↓

Poor Appearance
```

---

# Overlap Pipeline

```text
Artwork

↓

Embroidery Objects

↓

Compensation

↓

Overlap Generation

↓

Stitch Generation

↓

Machine
```

Overlaps are generated after compensation but before final stitch generation.

---

# Overlap Types

Supported overlap categories

```text
Fill-to-Fill

Fill-to-Satin

Satin-to-Satin

Outline Overlap

Appliqué Overlap

Decorative Overlap

Automatic Overlap

Manual Overlap
```

---

# Fill-to-Fill

Adjacent fill regions slightly overlap.

Purpose

- eliminate visible seams
- improve coverage
- tolerate fabric movement

---

# Fill-to-Satin

A satin border overlaps an adjacent fill.

Applications

```text
Logos

Lettering

Patches
```

Produces crisp edges.

---

# Satin-to-Satin

Neighboring satin columns overlap slightly.

Used for

- connected lettering
- decorative borders
- monograms

---

# Outline Overlap

Outlines intentionally extend over

underlying fills.

Purpose

```text
Hide Registration Error
```

Outlines often act as visual masks.

---

# Appliqué Overlap

Border stitches intentionally overlap

fabric edges.

Purpose

- secure appliqué
- hide cutting tolerances
- improve durability

---

# Decorative Overlap

Some artistic embroidery intentionally

overlaps objects

to create

- depth
- layering
- shadow effects

These overlaps are aesthetic rather than corrective.

---

# Automatic Overlap

The digitizer automatically computes

overlap widths

based on

- stitch type
- fabric
- density
- production profile

Automatic overlap should be the default.

---

# Manual Overlap

Professional users may explicitly define

```text
Edge Overlap

Object Overlap

Profile Override
```

Manual values take precedence.

---

# Overlap Width

Typical values

```text
0.2 mm

↓

1.0 mm
```

Actual values depend upon

- stitch type
- thread
- fabric
- production profile

---

# Stitch Type Influence

---

## Running Stitch

Usually requires

little or no overlap.

---

## Satin Stitch

Requires moderate overlap,

particularly against fills.

---

## Fill Stitch

Frequently overlaps neighboring objects

to eliminate exposed fabric.

---

# Fabric Influence

Fabric movement largely determines

required overlap.

---

### Stable Woven

Requires

```text
Minimal Overlap
```

---

### Stretch Fabric

Requires

```text
Greater Overlap
```

to compensate for movement.

---

### Towels

Require

```text
Large Overlap
```

because pile hides boundaries.

---

### Caps

Require

additional overlap

to compensate for curved surfaces.

---

# Thread Influence

Thread thickness affects

visual edge coverage.

Thicker threads generally require

less geometric overlap.

Finer threads often require more.

---

# Density Interaction

Higher density

reduces visible gaps,

but excessive density

does not eliminate the need for overlap.

Density and overlap must be balanced.

---

# Pull Compensation Interaction

Pull compensation enlarges

individual embroidery objects.

Overlap should be calculated

after pull compensation

to avoid excessive expansion.

---

# Push Compensation Interaction

Push compensation modifies

ends and corners.

Overlap generation must account for

final compensated geometry.

---

# Corner Interaction

Corners are particularly vulnerable

to visible gaps.

Corner processing and overlap generation

must coordinate.

---

# Underlay Interaction

Underlay generally follows

the overlapped geometry.

This improves edge stability.

---

# Sequencing Interaction

Sequencing determines

which object visually covers another.

Example

```text
Fill

↓

Border
```

The later object typically conceals

the overlap region.

---

# Registration Tolerance

Overlaps compensate for

small machine inaccuracies.

Typical causes

```text
Fabric Stretch

Hoop Movement

Needle Deflection

Thread Pull
```

---

# Visual Masking

Borders frequently serve as

visual masks.

Small registration errors become invisible

beneath the border embroidery.

---

# Layered Embroidery

Intentional layering

uses overlaps

to create

```text
Foreground

↓

Background
```

without exposing fabric.

---

# Adaptive Overlap

Future implementations may vary overlap

according to

- object size
- fabric
- stitch angle
- local geometry

rather than using a constant width.

---

# Overlap Profiles

Reusable production profiles

may define

```text
Cap

Shirt

Jacket

Towel

Leather
```

including

- overlap
- compensation
- density
- underlay

---

# Quality Factors

Proper overlap produces

- seamless joins
- crisp borders
- accurate registration
- professional appearance

---

# Failure Modes

Insufficient overlap

```text
Visible Gaps

Fabric Show-through

Registration Errors

Broken Borders
```

---

Excessive overlap

```text
Thread Buildup

Bulging

Stiff Embroidery

Visible Ridge
```

---

Inconsistent overlap

```text
Uneven Borders

Variable Edge Width

Visual Artifacts
```

---

# Simulation

Professional simulation should optionally display

```text
Original Geometry

↓

Compensated Geometry

↓

Overlap Regions
```

This assists

- education
- debugging
- professional digitizing

Consumer previews may hide overlap visualization.

---

# Machine Compilation

Machine compilation preserves

logical overlap geometry.

It must not

- remove overlaps
- recompute overlaps
- reinterpret overlap intent

Its responsibility is machine translation.

---

# Domain Rules

The following always apply.

- Overlaps are intentional manufacturing corrections.
- Original artwork is never modified.
- Overlaps are computed after compensation.
- Satin and Fill objects generally require overlaps.
- Fabric movement influences overlap width.
- Density does not replace overlap.
- Sequencing determines visible overlap behavior.
- Underlay follows overlap geometry.
- Machine compilation preserves logical overlap intent.
- Proper overlaps eliminate visible registration gaps.

---

# Out of Scope

This document does not define

- compensation algorithms
- sequencing algorithms
- stitch generation mathematics
- machine encoding
- AI overlap optimization

These are covered elsewhere.

---

# Future Topics

Future embroidery documents expand

```text
Optimization

Manufacturing Profiles

AI Digitizing

Advanced Compensation

Production Analytics
```

---

# Acceptance Criteria

The Overlap specification is complete when

✓ Overlaps are defined as intentional embroidery corrections.

✓ Multiple overlap types are documented.

✓ Stitch-type-specific overlap behavior is established.

✓ Fabric, thread, density, and compensation interactions are defined.

✓ Automatic and manual overlap workflows are supported.

✓ Quality improvements and common failure modes are documented.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Domain rules establish deterministic, machine-independent behavior.

✓ Overlaps are established as a fundamental technique for eliminating registration errors.

✓ The overlap model supports professional embroidery digitizing and manufacturing workflows.
