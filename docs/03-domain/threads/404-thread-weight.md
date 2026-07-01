# Domain
## DOM-404 Thread Weight

**Document ID:** DOM-404  
**Title:** Thread Weight  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Thread & Materials Team

**Related Documents**

```text
DOM-400 Thread Theory
DOM-401 Thread Types
DOM-402 Thread Colors
DOM-403 Color Matching

DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-209 Density
DOM-210 Pull Compensation
DOM-214 Optimization

DOM-306 Machine Speed
DOM-308 Manufacturing

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Thread Weight System used by Sewlio Studio.

Thread weight is one of the most important physical characteristics of embroidery thread. It influences stitch density, coverage, machine speed, needle selection, compensation, durability, and overall embroidery quality.

The Thread Weight System provides a machine-independent representation of thread thickness and manufacturing behavior.

---

# Philosophy

Thread weight determines

how much thread occupies

each stitch.

```text
Thread Weight

↓

Coverage

↓

Density

↓

Embroidery Quality
```

Selecting the correct thread weight is essential for predictable embroidery.

---

# Goals

The Thread Weight System shall provide

- Machine-independent thread sizing
- Manufacturing guidance
- Density recommendations
- Simulation support
- Validation rules
- Future extensibility

---

# Definition

Thread Weight represents the relative thickness of embroidery thread.

Thread weight influences

- stitch coverage
- density
- machine speed
- needle selection
- thread consumption
- embroidery appearance

Thread weight is independent of

thread color

and

thread manufacturer.

---

# Responsibilities

Thread Weight defines

- thread thickness
- manufacturing recommendations
- density guidance
- speed guidance
- needle compatibility
- simulation characteristics

It does **not** define

- thread color
- material type
- inventory
- machine assignment

---

# Thread Weight Pipeline

```text
Thread Definition

↓

Thread Weight

↓

Manufacturing Planning

↓

Machine Planning

↓

Production
```

---

# Weight Model

Each thread weight contains

```text
Identifier

Display Name

Weight Number

Relative Diameter

Coverage Factor

Recommended Uses

Metadata
```

---

# Standard Weights

Common embroidery weights include

```text
12 wt

20 wt

30 wt

40 wt

50 wt

60 wt

75 wt

90 wt
```

Additional weights

may be defined

through custom profiles.

---

# Weight Convention

Embroidery thread weight

follows

the textile convention.

```text
Lower Number

↓

Thicker Thread

Higher Number

↓

Thinner Thread
```

Example

```text
30 wt

Thicker

↓

40 wt

↓

60 wt

↓

90 wt

Thinner
```

---

# Typical Applications

```text
12 wt

Decorative Embroidery

Heavy Stitching

--------------------------------

30 wt

Large Satin

Decorative Logos

--------------------------------

40 wt

Commercial Embroidery

General Purpose

--------------------------------

60 wt

Lettering

Fine Detail

--------------------------------

90 wt

Micro Lettering

Miniature Designs
```

---

# Relative Diameter

The logical model

stores

a normalized

diameter factor

rather than

manufacturer-specific measurements.

Example

```text
40 wt

↓

Diameter Factor

1.0
```

The exact factor

is implementation-defined.

---

# Coverage

Thicker threads

provide

greater visual coverage.

```text
Thicker Thread

↓

Higher Coverage

↓

Lower Density

↓

Fewer Stitches
```

---

# Density Interaction

Thread weight

directly influences

recommended stitch density.

Examples

```text
30 wt

↓

Lower Density

40 wt

↓

Standard Density

60 wt

↓

Higher Density
```

Density recommendations

may be overridden.

---

# Underlay Interaction

Heavier threads

often require

less underlay.

Fine threads

may require

additional structural support.

---

# Pull Compensation

Thread weight

affects

pull compensation.

Thicker threads

typically require

slightly increased

compensation

to preserve dimensions.

---

# Needle Compatibility

Recommended needle size

depends upon

thread weight.

Example

```text
90 wt

↓

Small Needle

40 wt

↓

Standard Needle

12 wt

↓

Large Needle
```

Needle recommendations

are validated

during manufacturing planning.

---

# Machine Speed

Heavier threads

typically require

reduced sewing speeds.

Example

```text
12 wt

↓

Slow

40 wt

↓

Standard

90 wt

↓

Fast
```

Machine profiles

determine

actual operating limits.

---

# Stitch Type Interaction

Different stitch types

respond differently

to thread weight.

Examples

```text
Running Stitch

Supports Most Weights

--------------------------------

Satin Stitch

Sensitive to Weight

--------------------------------

Fill Stitch

Weight Influences Density
```

---

# Fabric Interaction

Thread weight

should complement

fabric characteristics.

Examples

```text
Heavy Denim

↓

Heavy Thread

Fine Silk

↓

Fine Thread

Towel

↓

Heavy Thread
```

Manufacturing profiles

coordinate

thread

and

fabric.

---

# Thread Consumption

Thread consumption

depends upon

```text
Stitch Length

Thread Weight

Tie-In

Tie-Off

Trim Count
```

Heavier threads

consume

more material

per stitch.

---

# Simulation

Simulation should represent

thread weight through

```text
Thread Width

Coverage

Surface Relief

Light Reflection
```

Thread weight

must affect

visual appearance.

---

# Manufacturing

Manufacturing planning

uses thread weight

for

```text
Density

Needle Selection

Machine Speed

Thread Consumption

Warnings
```

---

# Validation

Validation checks

```text
Unsupported Weight

Needle Compatibility

Machine Compatibility

Thread Type Compatibility

Manufacturing Profile
```

Validation

generates

warnings

or errors

as appropriate.

---

# Weight Profiles

Organizations

may define

standardized

thread-weight policies.

Examples

```text
Commercial

Luxury

Micro Lettering

Heavy Decorative

Industrial
```

Profiles

simplify

production planning.

---

# Extensibility

Future weight capabilities

may include

```text
Variable Diameter

Composite Threads

Adaptive Weight

Smart Materials

Nano Fibers
```

The logical model

must remain extensible.

---

# Thread Safety

Thread Weight definitions

are immutable.

Runtime state

references

logical definitions

without modification.

---

# Performance

The Thread Weight System

shall support

```text
Large Material Libraries

Real-Time Simulation

Manufacturing Analysis

Batch Production

Interactive Editing
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Thread weight defines thread thickness.
- Lower weight numbers represent thicker threads.
- Thread weight is independent of color.
- Thread weight influences density recommendations.
- Manufacturing planning uses thread weight for needle and speed selection.
- Simulation visualizes thread width and coverage.
- Thread Weight definitions are immutable.
- Original embroidery geometry is unaffected by thread weight.
- Machine compilation preserves logical thread weight.
- Validation occurs before manufacturing execution.

---

# Out of Scope

This document does not define

- commercial spool sizes
- thread inventory
- machine threading
- supplier packaging
- physical diameter measurements

These are covered in future manufacturing and inventory documents.

---

# Future Topics

Future thread documents expand

```text
Thread Consumption

Thread Inventory

Material Profiles

Commercial Catalogs

AI Material Selection

Production Cost Analysis
```

---

# Acceptance Criteria

The Thread Weight specification is complete when

✓ Thread weight is defined independently of thread manufacturers.

✓ Standard embroidery weight classes are documented.

✓ Weight interactions with density, underlay, compensation, and speed are established.

✓ Needle and fabric compatibility are specified.

✓ Simulation and manufacturing responsibilities are separated.

✓ Validation workflows are documented.

✓ Organization-specific weight profiles are supported.

✓ Domain rules establish deterministic thread-weight behavior.

✓ Thread Weight definitions remain immutable.

✓ The Thread Weight System provides the canonical representation of thread thickness within the embroidery platform.
