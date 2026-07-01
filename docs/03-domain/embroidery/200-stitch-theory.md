# Domain
## DOM-200 Stitch Theory

**Document ID:** DOM-200  
**Title:** Stitch Theory  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Embroidery Domain Team

**Related Documents**

```text
DOM-000 Domain Overview

DOM-201 Running Stitch
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
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

This document defines the theoretical foundations of embroidery stitching.

Every embroidery design ultimately becomes a sequence of stitches executed by an embroidery machine.

Understanding stitches is fundamental to

- digitizing
- simulation
- optimization
- manufacturing
- quality analysis
- machine compilation

This document establishes the terminology and concepts used throughout the embroidery subsystem.

---

# Philosophy

Embroidery is not artwork.

Embroidery is manufacturing.

A stitch is not merely a visual element.

A stitch is a physical operation performed by a sewing machine using thread, fabric, and a needle.

```text
Geometry

↓

Digitizing

↓

Stitches

↓

Machine Commands

↓

Physical Embroidery
```

---

# Goals

The stitch model shall provide

- Machine independence
- Manufacturing accuracy
- Predictable behavior
- Deterministic generation
- Simulation compatibility
- Optimization support

---

# What is a Stitch?

A stitch is the smallest manufacturing operation produced by an embroidery machine.

Each stitch consists of

```text
Needle Penetration

↓

Thread Movement

↓

Needle Penetration
```

A stitch connects two consecutive needle penetrations.

---

# Stitch Lifecycle

```text
Geometry

↓

Embroidery Object

↓

Generated Stitch

↓

Optimized Stitch

↓

Machine Stitch

↓

Physical Stitch
```

Each stage enriches the stitch.

---

# Stitch Components

Every stitch contains

```text
Start Position

End Position

Length

Direction

Needle

Thread Color

Machine Flags
```

---

# Stitch Position

Each stitch has

```text
X

Y
```

Coordinates exist in Stitch Space.

Machine conversion occurs later.

---

# Stitch Direction

Direction is determined by

```text
Start Point

↓

End Point
```

Direction influences

- thread appearance
- stitch quality
- pull
- sequencing

---

# Stitch Length

Length is

```text
Distance

(Start, End)
```

Measured in millimeters.

Length directly affects

- quality
- machine speed
- thread tension
- durability

---

# Recommended Stitch Lengths

Typical values

```text
Running Stitch

1.5–4.0 mm

Satin

0.4–7.0 mm

Fill

2.0–5.0 mm
```

Actual limits depend upon

- machine
- fabric
- thread
- design

---

# Stitch Angle

A stitch has orientation.

Angle influences

- reflection
- thread sheen
- fill appearance
- fabric distortion

Stitch angle is independent of path direction.

---

# Stitch Sequence

Embroidery is an ordered sequence.

```text
S1

↓

S2

↓

S3

↓

S4
```

Changing sequence changes

- manufacturing
- trims
- travel
- appearance

---

# Needle Penetration

Every stitch creates two penetrations.

```text
Entry

↓

Exit
```

Needle penetrations affect

- fabric stability
- distortion
- wear

---

# Stitch Density

Density represents

```text
Number of stitches

↓

Per unit area
```

Higher density

- stronger coverage
- more thread
- more distortion

Lower density

- lighter coverage
- faster sewing
- less stability

---

# Stitch Spacing

Spacing is the distance between adjacent stitches.

Spacing affects

- coverage
- appearance
- manufacturing time

---

# Stitch Types

Primary stitch families

```text
Running Stitch

Satin Stitch

Fill Stitch

Motif Stitch

Bean Stitch

Manual Stitch
```

Each serves a different manufacturing purpose.

---

# Stitch Objects

A Stitch Object generates many stitches.

Examples

```text
Satin Column

↓

Hundreds of stitches

Fill Region

↓

Thousands of stitches
```

Users edit objects—not individual stitches.

---

# Manual Stitches

Individual stitches may be created manually.

Applications

- corrections
- artistic embroidery
- special effects

Manual stitches bypass automatic generation.

---

# Jump Stitches

A jump stitch is

```text
Needle Move

Without Sewing
```

No thread is intentionally laid down.

Jump stitches increase production time.

---

# Trim

Trim cuts the thread.

```text
Thread

↓

Trim

↓

New Thread Start
```

Trim commands are machine-dependent.

---

# Tie-In

Tie-in secures thread at the beginning.

Purpose

- prevent unraveling
- improve durability

---

# Tie-Off

Tie-off secures thread at the end.

Purpose

- prevent loose thread
- improve wash durability

---

# Travel Stitches

Travel stitches move between embroidery regions.

Goal

```text
Minimal Visibility
```

Travel planning is an optimization problem.

---

# Underlay

Underlay prepares fabric.

Functions

- stabilization
- support
- loft
- coverage

Underlay precedes visible stitches.

---

# Stitch Order

Order determines

- machine efficiency
- trims
- thread changes
- quality

Order is one of the most important aspects of digitizing.

---

# Stitch Path

The stitch path is the physical sewing route.

Objectives

- minimize travel
- minimize trims
- minimize distortion
- maximize quality

---

# Stitch Groups

Related stitches form groups.

Examples

```text
Letter

Border

Logo

Fill Region

Outline
```

Groups simplify editing.

---

# Thread Changes

A stitch sequence may contain

```text
Color Change

↓

Needle Change

↓

Continue
```

Thread changes are machine operations.

---

# Stitch Attributes

Each stitch may carry

```text
Needle

Thread

Color

Speed Hint

Flags

Locking

Jump

Trim
```

Attributes are resolved during machine compilation.

---

# Physical Effects

Every stitch changes fabric.

Effects include

```text
Pull

Push

Compression

Stretch

Distortion
```

These are unavoidable.

Digitizing compensates for them.

---

# Stitch Quality

Quality depends upon

- stitch length
- spacing
- sequence
- angle
- density
- fabric
- thread
- machine

No single parameter determines quality.

---

# Stitch Optimization

Optimization aims to reduce

```text
Travel

Thread Usage

Time

Trims

Thread Changes
```

Without sacrificing appearance.

---

# Simulation

Simulation approximates

```text
Needle Motion

Thread Path

Thread Coverage

Machine Execution
```

Simulation never modifies stitches.

---

# Machine Compilation

Machine compilation converts

```text
Logical Stitch

↓

Machine Stitch
```

May insert

- trims
- jumps
- machine commands

---

# Stitch Precision

Internal precision

```text
64-bit floating point
```

Machine precision

Depends on

```text
Machine Format
```

Precision reduction occurs only during export.

---

# Domain Rules

The following always apply.

- A stitch is the smallest manufacturing operation.
- Stitches are ordered.
- Stitch order affects quality.
- Geometry is not stitches.
- Stitch objects generate stitches.
- Simulation never changes stitches.
- Machine compilation may enrich stitches.
- Stitch generation is deterministic.
- Physical embroidery always follows stitch order.
- Manufacturing constraints override visual preferences when necessary.

---

# Out of Scope

This document does not define

- individual stitch algorithms
- fill generation
- satin generation
- underlay generation
- compensation algorithms

These are covered by subsequent documents.

---

# Future Topics

Subsequent documents define

```text
Running Stitch

Satin Stitch

Fill Stitch

Underlay

Tie-In

Tie-Off

Density

Compensation

Optimization

Sequencing
```

---

# Acceptance Criteria

The Stitch Theory document is complete when

✓ The stitch is defined as the fundamental manufacturing operation.

✓ The relationship between geometry, stitches, and manufacturing is established.

✓ Stitch components and properties are defined.

✓ Stitch sequencing and physical behavior are introduced.

✓ Stitch quality factors are identified.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Common embroidery terminology is standardized.

✓ Domain rules are established for all future embroidery documents.

✓ The document serves as the foundation for every stitch type.

✓ All subsequent embroidery specifications build upon this theory.
