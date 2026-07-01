# Domain
## DOM-500 Fabric Theory

**Document ID:** DOM-500  
**Title:** Fabric Theory  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Fabric & Materials Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-214 Optimization

DOM-400 Thread Theory
DOM-401 Thread Types
DOM-404 Thread Weight
DOM-405 Thread Consumption

DOM-308 Manufacturing

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Fabric Theory used by Sewlio Studio.

Fabric is the manufacturing substrate upon which embroidery is produced.

Unlike vector graphics, embroidery behavior is heavily influenced by fabric properties. Every stitch interacts with the fabric, causing movement, distortion, compression, and deformation.

The Fabric Theory provides a machine-independent model of fabric behavior for embroidery planning, simulation, and manufacturing.

---

# Philosophy

Embroidery is not stitched into empty space.

It is stitched into fabric.

```text
Thread

↓

Fabric

↓

Mechanical Interaction

↓

Finished Embroidery
```

Understanding fabric behavior is fundamental to professional digitizing.

---

# Goals

The Fabric Theory shall provide

- Machine-independent fabric modeling
- Predictable embroidery behavior
- Manufacturing guidance
- Simulation realism
- Optimization input
- Future physics support

---

# Definition

Fabric represents the physical material receiving embroidery stitches.

Fabric characteristics influence

- stitch quality
- pull
- push
- density
- underlay
- stabilization
- manufacturing recommendations

Fabric definitions are independent of machine and thread manufacturers.

---

# Responsibilities

Fabric Theory defines

- fabric properties
- deformation behavior
- stability
- elasticity
- interaction with thread
- interaction with stitches

It does **not** define

- artwork
- geometry
- machine motion
- embroidery file formats

---

# Fabric Pipeline

```text
Artwork

↓

Embroidery

↓

Fabric Profile

↓

Optimization

↓

Manufacturing
```

Fabric characteristics influence multiple stages of the embroidery pipeline.

---

# Fabric Model

Each logical fabric contains

```text
Identifier

Display Name

Category

Composition

Thickness

Elasticity

Stability

Surface Profile

Metadata
```

---

# Fabric Categories

Supported categories include

```text
Woven

Knitted

Stretch

Leather

Denim

Canvas

Felt

Terry Cloth

Silk

Synthetic

Technical

Custom
```

Additional categories

may be introduced

through plugins.

---

# Fabric Composition

Composition describes

the material makeup.

Examples

```text
100% Cotton

100% Polyester

Cotton Blend

Wool Blend

Leather

Synthetic Composite
```

Composition

influences

manufacturing recommendations.

---

# Thickness

Fabric thickness

affects

```text
Needle Selection

Thread Choice

Underlay

Density

Pull Compensation
```

Thicker fabrics

generally require

greater support.

---

# Elasticity

Elasticity measures

how easily

the fabric stretches

under load.

Examples

```text
Rigid

Low Stretch

Medium Stretch

High Stretch
```

Elasticity

strongly influences

compensation.

---

# Stability

Stability represents

the resistance

to movement

during embroidery.

Stable fabrics

produce

more predictable results.

---

# Surface Profile

Surface characteristics include

```text
Smooth

Textured

Pile

Looped

Brushed

Ribbed
```

Surface profile

affects

coverage

and

thread visibility.

---

# Fabric Density

Fabric density

describes

the compactness

of the weave

or knit.

Dense fabrics

typically support

higher stitch densities.

---

# Fabric Recovery

Recovery measures

how well

a fabric returns

to its original shape

after stretching.

Poor recovery

may permanently

distort embroidery.

---

# Fabric Compression

Embroidery compresses

fabric fibers.

Compression affects

```text
Coverage

Appearance

Density

Simulation
```

---

# Fabric Movement

Fabric moves

during embroidery

because of

```text
Needle Penetration

Thread Tension

Machine Motion

Hooping
```

Movement cannot

be completely eliminated.

---

# Pull Interaction

Fabric contributes

to

thread pull.

Stretch fabrics

typically require

greater

pull compensation.

---

# Push Interaction

Fabric compression

creates

push effects

at stitch ends

and corners.

Push compensation

depends partly

on fabric characteristics.

---

# Underlay Interaction

Different fabrics

require

different underlay strategies.

Examples

```text
Stable Fabric

↓

Minimal Underlay

Stretch Fabric

↓

Heavy Underlay

Terry Cloth

↓

High-Loft Underlay
```

---

# Density Interaction

Fabric determines

recommended stitch density.

Examples

```text
Leather

↓

Reduced Density

Canvas

↓

Standard Density

Stretch

↓

Moderate Density

Towels

↓

Higher Coverage
```

---

# Thread Interaction

Thread

and

fabric

must be compatible.

Examples

```text
Heavy Thread

↓

Heavy Fabric

Fine Thread

↓

Fine Fabric
```

Manufacturing planning

coordinates both.

---

# Needle Interaction

Fabric characteristics

influence

needle recommendations.

Examples

```text
Leather

↓

Leather Needle

Knits

↓

Ballpoint Needle

Denim

↓

Sharp Needle
```

Validation

uses

fabric profiles.

---

# Stabilizers

Many fabrics

require

additional stabilization.

Examples

```text
Cut Away

Tear Away

Wash Away

Heat Away

Adhesive
```

Fabric profiles

recommend

appropriate stabilizers.

---

# Hooping

Proper hooping

depends upon

fabric properties.

Examples

```text
Stretch

↓

Gentle Hooping

Leather

↓

Minimal Compression

Canvas

↓

Firm Hooping
```

Hooping recommendations

are manufacturing guidance.

---

# Manufacturing Profiles

Production profiles

may combine

```text
Fabric

Thread

Needle

Underlay

Density

Compensation
```

into reusable presets.

---

# Fabric Profiles

Examples

```text
T-Shirt

Polo Shirt

Cap

Jacket

Towel

Leather Patch

Canvas Bag

Denim
```

Profiles

simplify

professional digitizing.

---

# Simulation

Simulation should visualize

fabric effects

such as

```text
Stretch

Compression

Pile

Surface Texture

Embroidery Relief
```

Simulation

approximates

fabric behavior

without performing

full physics simulation.

---

# Manufacturing

Manufacturing planning

uses fabric properties

for

```text
Needle Selection

Thread Selection

Density

Underlay

Speed

Validation
```

---

# Validation

Validation checks

```text
Unsupported Fabric

Thread Compatibility

Needle Compatibility

Manufacturing Profile

Density Recommendation
```

Warnings

or errors

are generated

as appropriate.

---

# Extensibility

Future fabric capabilities

may include

```text
Fabric Scanning

AI Fabric Detection

Digital Twin

Moisture Properties

Thermal Properties

Physics Simulation
```

The logical model

must remain extensible.

---

# Thread Safety

Fabric definitions

are immutable.

Manufacturing planning

references

fabric profiles

without modification.

---

# Performance

The Fabric Theory System

shall support

```text
Large Fabric Libraries

Real-Time Simulation

Batch Manufacturing

Incremental Analysis

Interactive Editing
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Fabric is the embroidery substrate.
- Fabric properties influence manufacturing, not artwork.
- Fabric affects density, compensation, and underlay.
- Stabilizer recommendations derive from fabric characteristics.
- Fabric definitions are machine-independent.
- Simulation approximates fabric behavior.
- Manufacturing planning uses fabric profiles.
- Fabric definitions are immutable.
- Original embroidery geometry is never modified.
- Validation occurs before manufacturing.

---

# Out of Scope

This document does not define

- stabilizer inventory
- textile manufacturing
- physical fabric simulation
- machine hoop mechanics
- garment construction

These are covered in later fabric and manufacturing documents.

---

# Future Topics

Future fabric documents expand

```text
Fabric Types

Stabilizers

Hooping

Fabric Detection

Physics Simulation

Digital Twin

AI Material Recognition
```

---

# Acceptance Criteria

The Fabric Theory specification is complete when

✓ Fabric is defined as the embroidery substrate.

✓ Core fabric properties are documented.

✓ Fabric interactions with thread, density, compensation, and underlay are established.

✓ Fabric categories and profiles are introduced.

✓ Simulation and manufacturing responsibilities are separated.

✓ Validation and manufacturing guidance are documented.

✓ Fabric definitions remain immutable and machine-independent.

✓ Domain rules establish deterministic fabric behavior.

✓ Original embroidery geometry is unaffected by fabric definitions.

✓ The Fabric Theory provides the foundational material model for all embroidery manufacturing.
