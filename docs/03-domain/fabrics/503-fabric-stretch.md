# Domain
## DOM-503 Fabric Stretch

**Document ID:** DOM-503  
**Title:** Fabric Stretch  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Fabric & Materials Team

**Related Documents**

```text
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-214 Optimization

DOM-400 Thread Theory
DOM-404 Thread Weight

DOM-500 Fabric Theory
DOM-501 Stabilizers
DOM-502 Puckering

DOM-308 Manufacturing

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Fabric Stretch Model used by Sewlio Studio.

Fabric stretch describes the ability of a fabric to deform under tension and recover after the applied force is removed.

Stretch is one of the primary factors affecting embroidery quality and directly influences pull compensation, underlay, stabilization, density, and manufacturing recommendations.

---

# Philosophy

Fabric is not rigid.

Every stitch pulls on the fabric.

```text
Thread

↓

Fabric Stretch

↓

Fabric Deformation

↓

Embroidery Result
```

Professional digitizing compensates for expected fabric movement before embroidery begins.

---

# Goals

The Fabric Stretch Model shall provide

- Fabric-aware digitizing
- Predictable deformation analysis
- Manufacturing recommendations
- Simulation support
- Quality validation
- Future physics integration

---

# Definition

Fabric Stretch represents the elastic deformation characteristics of a fabric when subjected to embroidery forces.

Stretch affects

- embroidery dimensions
- stitch appearance
- registration
- pull compensation
- stabilization

Stretch is a material property,

not a machine property.

---

# Responsibilities

The Fabric Stretch Model defines

- stretch characteristics
- directional stretch
- recovery behavior
- manufacturing guidance
- quality recommendations

It does **not** define

- embroidery geometry
- stitch generation
- machine mechanics
- fabric inventory

---

# Stretch Pipeline

```text
Fabric Profile

↓

Stretch Analysis

↓

Compensation Planning

↓

Optimization

↓

Manufacturing
```

---

# Stretch Model

Each fabric profile contains

```text
Stretch Classification

Stretch Direction

Elasticity

Recovery

Stability

Metadata
```

---

# Stretch Classification

Supported classifications

```text
Rigid

Low Stretch

Medium Stretch

High Stretch

Extreme Stretch
```

These classifications

guide manufacturing planning.

---

# Directional Stretch

Fabric may stretch differently

along different directions.

Supported directions

```text
Warp

Weft

Bias

Omnidirectional
```

Directionality

influences stitch orientation.

---

# Warp Stretch

Warp stretch

occurs

along the fabric length.

Many woven fabrics

have relatively low

warp stretch.

---

# Weft Stretch

Weft stretch

occurs

across the fabric width.

Many fabrics

stretch more

in the weft direction.

---

# Bias Stretch

Bias stretch

occurs

at approximately

45 degrees

to the weave.

Bias typically exhibits

greater elasticity

than warp or weft.

---

# Omnidirectional Stretch

Knitted fabrics

often stretch

in multiple directions.

Examples

```text
T-Shirts

Sportswear

Performance Fabrics
```

These fabrics

require additional stabilization.

---

# Elasticity

Elasticity measures

how easily

the fabric stretches.

Higher elasticity

produces greater

embroidery distortion.

---

# Recovery

Recovery describes

how effectively

the fabric returns

to its original dimensions

after deformation.

Examples

```text
Excellent

Good

Moderate

Poor
```

Poor recovery

may permanently distort

embroidery.

---

# Stretch Influence

Stretch affects

```text
Pull

Push

Density

Underlay

Registration

Puckering
```

All are considered

during manufacturing planning.

---

# Pull Compensation

Stretch fabrics

typically require

greater pull compensation.

Example

```text
Rigid Fabric

↓

Minimal Compensation

Stretch Fabric

↓

Additional Compensation
```

---

# Push Compensation

Highly elastic fabrics

may also require

additional push compensation,

especially around

corners

and

satin terminations.

---

# Underlay Interaction

Stretch fabrics

benefit from

stronger underlay.

Examples

```text
Edge Walk

↓

Center Walk

↓

Zigzag

↓

Tatami Base
```

The optimal combination

depends on

fabric type.

---

# Density Interaction

Stretch fabrics

generally require

slightly reduced

stitch density

to minimize compression.

Higher density

increases

distortion risk.

---

# Thread Interaction

Heavy thread

combined with

high-stretch fabric

may significantly increase

fabric movement.

Thread selection

should consider

fabric elasticity.

---

# Stabilizer Interaction

Proper stabilization

reduces

fabric movement.

Examples

```text
High Stretch

↓

Cut Away

↓

Heavy Stabilization

Low Stretch

↓

Tear Away
```

Multiple stabilizers

may be recommended.

---

# Stitch Direction

Changing stitch direction

may reduce

stretch-related distortion.

Alternating stitch angles

helps distribute

mechanical forces.

---

# Lettering

Small lettering

is particularly sensitive

to fabric stretch.

Stretch fabrics

may require

larger lettering,

lighter density,

or additional underlay.

---

# Satin Stitch

Wide satin stitches

experience greater

edge distortion

on elastic fabrics.

Width limitations

may be recommended.

---

# Fill Stitch

Balanced fill angles

help reduce

directional stretching

across large embroidery areas.

---

# Hooping Interaction

Proper hooping

minimizes

fabric movement

without introducing

pre-stress.

Examples

```text
Over-Hooped

↓

Permanent Distortion

Loose Hooping

↓

Fabric Movement
```

---

# Manufacturing Profiles

Manufacturing profiles

may define

fabric-specific

stretch strategies.

Examples

```text
Sportswear

Stretch Knit

Performance Fabric

Compression Garments
```

---

# Validation

Validation checks

```text
Unsupported Stretch

Insufficient Stabilization

Excessive Density

Large Satin Width

Poor Underlay

Risk of Distortion
```

Warnings

or recommendations

are generated.

---

# Simulation

Simulation

may visualize

```text
Estimated Stretch

Distortion Zones

Recovery

Stress Areas
```

Simulation provides

an approximation,

not a full

physics simulation.

---

# Quality Analysis

Stretch contributes

to overall

quality scoring.

Examples

```text
Low Risk

Moderate Risk

High Risk

Critical Risk
```

Quality analysis

combines stretch

with other factors.

---

# Manufacturing

Manufacturing planning

uses stretch information

for

```text
Compensation

Density

Needles

Stabilizers

Speed

Operator Guidance
```

---

# Analytics

Future analytics

may include

```text
Stretch Maps

Directional Analysis

Fabric Classification

Machine Learning

Automatic Detection
```

---

# Extensibility

Future capabilities

may include

```text
Fabric Scanning

Camera Detection

Digital Twin

Finite Element Analysis

AI Material Recognition

Real-Time Prediction
```

The logical model

must remain extensible.

---

# Thread Safety

Stretch analysis

is deterministic

and side-effect free.

Fabric profiles

remain immutable.

Analysis

may execute

concurrently.

---

# Performance

The Fabric Stretch System

shall support

```text
Large Designs

Interactive Editing

Incremental Analysis

Real-Time Validation

Batch Manufacturing
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Stretch is a fabric property.
- Stretch influences compensation and stabilization.
- Directional stretch is significant for embroidery quality.
- Stretch recommendations do not modify artwork directly.
- Manufacturing planning consumes stretch information.
- Simulation estimates stretch effects.
- Fabric profiles remain immutable.
- Stretch analysis is deterministic.
- Original embroidery geometry is preserved.
- Validation occurs before manufacturing.

---

# Out of Scope

This document does not define

- finite element simulation
- real-time fabric sensing
- physical textile simulation
- garment construction
- machine tension control

These belong to future simulation and manufacturing systems.

---

# Future Topics

Future fabric documents expand

```text
Fabric Physics

Digital Twin

AI Fabric Recognition

Dynamic Compensation

Real-Time Simulation

Production Analytics

Automatic Material Detection
```

---

# Acceptance Criteria

The Fabric Stretch specification is complete when

✓ Fabric stretch is defined as a material property.

✓ Stretch classifications and directional stretch are documented.

✓ Elasticity and recovery behaviors are established.

✓ Interactions with compensation, density, underlay, and stabilizers are defined.

✓ Simulation and manufacturing responsibilities are separated.

✓ Validation and quality analysis workflows are documented.

✓ Stretch-aware manufacturing recommendations are specified.

✓ Domain rules establish deterministic stretch behavior.

✓ Fabric profiles remain immutable and machine-independent.

✓ The Fabric Stretch Model provides the canonical framework for analyzing embroidery deformation caused by elastic fabrics.
