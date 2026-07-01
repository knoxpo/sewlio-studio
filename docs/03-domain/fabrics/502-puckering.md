# Domain
## DOM-502 Puckering

**Document ID:** DOM-502  
**Title:** Puckering  
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
DOM-212 Cornering
DOM-214 Optimization

DOM-400 Thread Theory
DOM-404 Thread Weight

DOM-500 Fabric Theory
DOM-501 Stabilizers

DOM-308 Manufacturing

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Puckering Model used by Sewlio Studio.

Puckering is one of the most common embroidery quality defects. It occurs when embroidery stitches introduce compressive forces that deform the surrounding fabric, producing visible wrinkles, ripples, or distortion.

The Puckering Model enables Sewlio Studio to predict, minimize, and validate puckering through digitizing and manufacturing recommendations.

---

# Philosophy

Embroidery applies force,

not just thread.

```text
Thread

↓

Fabric Compression

↓

Fabric Movement

↓

Puckering
```

Good digitizing minimizes fabric deformation while preserving embroidery quality.

---

# Goals

The Puckering Model shall provide

- Predictable quality analysis
- Manufacturing guidance
- Fabric-aware validation
- Simulation support
- Optimization input
- Extensible deformation modeling

---

# Definition

Puckering is the localized deformation of fabric caused by embroidery-induced compression, thread tension, and stitch density.

Puckering is a manufacturing phenomenon,

not a geometry problem.

---

# Responsibilities

The Puckering Model evaluates

- puckering risk
- contributing factors
- prevention strategies
- quality metrics
- manufacturing recommendations

It does **not** perform

- physical simulation
- stitch generation
- machine motion control

---

# Puckering Pipeline

```text
Embroidery

↓

Fabric Analysis

↓

Puckering Analysis

↓

Optimization

↓

Manufacturing
```

---

# Puckering Model

Each analysis contains

```text
Risk Score

Affected Region

Primary Causes

Severity

Recommendations

Metadata
```

---

# Causes of Puckering

Puckering commonly results from

```text
High Stitch Density

Thread Tension

Fabric Stretch

Poor Stabilization

Insufficient Underlay

Large Satin Areas

Improper Hooping

Heavy Thread
```

Multiple causes

may contribute simultaneously.

---

# Fabric Compression

Every stitch compresses

the surrounding fabric.

Compression accumulates

as stitch density increases.

---

# Thread Tension

Thread tension

creates

continuous pulling forces.

Excessive tension

increases

fabric deformation.

---

# Stitch Density

Higher stitch density

produces

greater compression.

Example

```text
High Density

↓

Higher Compression

↓

Greater Puckering Risk
```

---

# Satin Stitch Influence

Large satin stitches

are particularly prone

to puckering.

Risk increases with

```text
Width

Length

Density
```

Proper underlay

reduces this risk.

---

# Fill Stitch Influence

Dense fill patterns

may compress

large fabric areas.

Balanced stitch angles

help distribute forces.

---

# Underlay Interaction

Underlay improves

load distribution.

Examples

```text
Proper Underlay

↓

Reduced Puckering

No Underlay

↓

Higher Risk
```

---

# Stabilizer Interaction

Proper stabilization

significantly reduces

puckering.

Examples

```text
Stretch Fabric

+

Weak Stabilizer

↓

High Risk

Stable Fabric

+

Cut Away

↓

Low Risk
```

---

# Fabric Interaction

Certain fabrics

are naturally

more susceptible.

Examples

```text
Stretch Knit

↓

High Risk

Silk

↓

High Risk

Canvas

↓

Low Risk

Denim

↓

Low Risk
```

---

# Thread Weight Interaction

Heavy threads

produce

greater compressive forces.

Fine threads

generally reduce

puckering risk.

---

# Pull Compensation

Proper pull compensation

helps maintain

design dimensions

and reduces

localized stress.

---

# Push Compensation

Push compensation

improves

stitch termination

and reduces

fabric bunching

at stitch ends.

---

# Hooping Influence

Improper hooping

is a major cause

of puckering.

Examples

```text
Loose Fabric

↓

Movement

↓

Puckering

Over-Tight Fabric

↓

Pre-Stress

↓

Distortion
```

Proper hoop tension

is essential.

---

# Design Influence

Certain design characteristics

increase risk.

Examples

```text
Large Solid Areas

Dense Lettering

Heavy Borders

Overlapping Satin

Tiny Filled Shapes
```

---

# Risk Levels

Risk is classified as

```text
Very Low

Low

Moderate

High

Critical
```

Risk evaluation

is deterministic.

---

# Risk Factors

Analysis considers

```text
Fabric

Thread

Density

Underlay

Stabilizer

Needle

Hooping

Stitch Type
```

Risk factors

may be weighted

by manufacturing profiles.

---

# Prevention

Recommended mitigation

includes

```text
Reduce Density

Improve Underlay

Increase Compensation

Select Better Stabilizer

Reduce Satin Width

Change Stitch Direction

Improve Hooping
```

Multiple recommendations

may apply.

---

# Optimization

Optimization

may reduce puckering by

```text
Density Adjustment

Stitch Redistribution

Travel Optimization

Underlay Selection

Compensation Tuning
```

Optimization

must preserve

design intent.

---

# Simulation

Simulation

may visualize

```text
Risk Heat Map

Compressed Regions

Potential Distortion

High Stress Areas
```

This is an approximation,

not a physics simulation.

---

# Manufacturing

Manufacturing planning

uses puckering analysis

to generate

```text
Warnings

Recommendations

Operator Guidance

Quality Reports
```

---

# Validation

Validation checks

```text
Excessive Density

Unsupported Fabric

Insufficient Underlay

Weak Stabilization

Large Satin Width

High Compression
```

Warnings

or errors

may be generated.

---

# Reports

Quality reports

may include

```text
Risk Score

Affected Objects

Recommended Fixes

Fabric Notes

Manufacturing Notes
```

Reports

are derived artifacts.

---

# Analytics

Future analytics

may measure

```text
Compression Index

Fabric Distortion

Historical Defects

Production Quality

Machine Comparison
```

---

# Extensibility

Future capabilities

may include

```text
Finite Element Analysis

Digital Twin

AI Quality Prediction

Fabric Scanning

Machine Learning

Real-Time Monitoring
```

The logical model

must remain extensible.

---

# Thread Safety

Puckering analysis

is a pure function.

Reports

are immutable

after generation.

Analysis

may execute

concurrently.

---

# Performance

The Puckering System

shall support

```text
Large Designs

Millions of Stitches

Interactive Editing

Real-Time Validation

Incremental Analysis
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Puckering is a manufacturing quality defect.
- Puckering results from accumulated mechanical forces.
- Fabric properties strongly influence puckering risk.
- Density, underlay, and stabilization are primary mitigation tools.
- Analysis generates recommendations, not geometry modifications.
- Optimization preserves artistic intent.
- Simulation visualizes estimated risk.
- Reports are derived artifacts.
- Analysis is deterministic.
- Original embroidery geometry is never modified.

---

# Out of Scope

This document does not define

- finite element simulation
- machine tension calibration
- real-time sensor feedback
- physical fabric simulation
- automated machine correction

These belong to future simulation and manufacturing systems.

---

# Future Topics

Future fabric documents expand

```text
Fabric Physics

Quality Prediction

Digital Twin

AI Manufacturing

Machine Learning

Production Analytics

Real-Time Quality Monitoring
```

---

# Acceptance Criteria

The Puckering specification is complete when

✓ Puckering is defined as a manufacturing quality defect.

✓ Major causes of puckering are documented.

✓ Fabric, thread, density, underlay, and stabilizer interactions are established.

✓ Risk classification and prevention strategies are defined.

✓ Simulation and manufacturing responsibilities are separated.

✓ Validation and reporting workflows are documented.

✓ Optimization guidance is introduced.

✓ Domain rules establish deterministic puckering analysis.

✓ Analysis remains machine-independent and immutable.

✓ The Puckering Model provides the canonical framework for embroidery quality assessment related to fabric deformation.
