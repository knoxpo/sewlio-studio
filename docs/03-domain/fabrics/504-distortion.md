# Domain
## DOM-504 Distortion

**Document ID:** DOM-504  
**Title:** Distortion  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Fabric & Materials Team

**Related Documents**

```text
DOM-103 Transformations

DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-212 Cornering
DOM-213 Overlaps
DOM-214 Optimization

DOM-400 Thread Theory
DOM-404 Thread Weight

DOM-500 Fabric Theory
DOM-501 Stabilizers
DOM-502 Puckering
DOM-503 Fabric Stretch

DOM-308 Manufacturing

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-016 Performance Architecture
```

---

# Purpose

This document defines the Distortion Model used by Sewlio Studio.

Distortion is the deviation of embroidered geometry from its intended design due to mechanical interactions between fabric, thread, needle, stabilization, and machine motion.

Unlike pull or push, distortion represents the combined effect of multiple embroidery forces acting throughout the manufacturing process.

The Distortion Model provides a framework for predicting, minimizing, and validating dimensional accuracy.

---

# Philosophy

Embroidery is not perfectly rigid.

Every stitch changes the fabric.

```text
Embroidery Forces

↓

Material Deformation

↓

Dimensional Change

↓

Distortion
```

Professional digitizing anticipates distortion before the first stitch is sewn.

---

# Goals

The Distortion Model shall provide

- Predictable dimensional analysis
- Quality validation
- Manufacturing guidance
- Simulation support
- Optimization input
- Extensible deformation modeling

---

# Definition

Distortion is the measurable deviation between the intended embroidery geometry and the manufactured embroidery.

Distortion results from the combined effects of

- pull
- push
- stretch
- compression
- thread tension
- stabilization
- machine execution

---

# Responsibilities

The Distortion Model evaluates

- dimensional deviation
- deformation risk
- affected regions
- quality metrics
- manufacturing recommendations

It does **not** perform

- physical simulation
- stitch generation
- machine control
- geometry editing

---

# Distortion Pipeline

```text
Artwork

↓

Embroidery

↓

Mechanical Analysis

↓

Distortion Analysis

↓

Optimization

↓

Manufacturing
```

---

# Distortion Model

Each analysis contains

```text
Risk Score

Affected Regions

Primary Causes

Estimated Deviation

Recommendations

Metadata
```

---

# Sources of Distortion

Distortion may result from

```text
Fabric Stretch

Thread Tension

High Density

Underlay

Stabilization

Needle Penetration

Hooping

Machine Motion

Large Satin Areas

Fill Compression
```

Distortion

is usually caused

by multiple factors.

---

# Types of Distortion

Supported distortion categories

```text
Linear Distortion

Angular Distortion

Compression

Expansion

Warping

Registration Shift

Global Distortion

Local Distortion
```

---

# Linear Distortion

Linear distortion

changes

object dimensions

along one axis.

Examples

```text
Narrowing

Lengthening

Shortening
```

---

# Angular Distortion

Angular distortion

changes

corners,

junctions,

and stitch directions.

Often visible

in lettering

and logos.

---

# Compression

Compression occurs

when stitch density

reduces

available fabric volume.

Compression

often precedes

puckering.

---

# Expansion

Expansion occurs

when surrounding stitches

push fabric outward.

Expansion

is commonly addressed

through push compensation.

---

# Warping

Warping describes

non-uniform

shape deformation.

Examples

```text
Curved Borders

Twisted Shapes

Uneven Filled Areas
```

---

# Registration Shift

Multiple embroidery objects

may become

misaligned

because of

cumulative distortion.

Examples

```text
Outline Offset

Border Misalignment

Fill Separation
```

---

# Global Distortion

Global distortion

affects

the entire embroidery design.

Common causes

```text
Poor Hooping

Weak Stabilizer

Stretch Fabric
```

---

# Local Distortion

Local distortion

affects

specific embroidery regions.

Examples

```text
Letter Corners

Satin Ends

Dense Fill Areas
```

---

# Fabric Interaction

Fabric properties

strongly influence

distortion.

Examples

```text
Stretch Knit

↓

High Risk

Canvas

↓

Low Risk

Leather

↓

Localized Distortion
```

---

# Thread Interaction

Thread characteristics

affect

compression

and

dimensional stability.

Examples

```text
Heavy Thread

↓

Higher Distortion

Fine Thread

↓

Lower Distortion
```

---

# Density Interaction

Higher density

increases

mechanical stress

and

dimensional change.

Density optimization

reduces distortion.

---

# Underlay Interaction

Proper underlay

improves

dimensional stability

by distributing

mechanical forces.

---

# Stabilizer Interaction

Proper stabilization

reduces

both local

and global

distortion.

Weak stabilization

increases

registration errors.

---

# Pull Compensation

Pull compensation

corrects

expected shrinkage

caused by

thread tension.

It is one component

of distortion control.

---

# Push Compensation

Push compensation

corrects

fabric expansion

at stitch boundaries.

---

# Stitch Direction

Alternating stitch directions

reduces

directional distortion.

Long parallel stitch fields

increase

dimensional change.

---

# Object Interaction

Adjacent embroidery objects

may influence

one another.

Examples

```text
Shared Borders

Overlapping Satin

Nested Fills
```

The optimizer

should consider

neighbor interactions.

---

# Quality Analysis

Distortion is classified as

```text
Negligible

Low

Moderate

High

Critical
```

Quality scoring

is deterministic.

---

# Prevention

Recommended mitigation

includes

```text
Improve Stabilization

Reduce Density

Increase Compensation

Improve Underlay

Adjust Stitch Direction

Reduce Satin Width

Improve Hooping
```

Multiple recommendations

may be combined.

---

# Optimization

Optimization

may reduce distortion

through

```text
Density Optimization

Compensation

Object Sequencing

Underlay Selection

Travel Optimization
```

Optimization

must preserve

artistic intent.

---

# Simulation

Simulation

may visualize

```text
Distortion Heat Map

Registration Shift

Compression Areas

Estimated Deformation

Stress Distribution
```

Simulation

provides

engineering estimates,

not

full physical simulation.

---

# Manufacturing

Manufacturing planning

uses distortion analysis

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
High Density

Poor Stabilization

Large Satin

Weak Underlay

Stretch Fabric

Registration Risk
```

Warnings

or errors

are produced

depending on

manufacturing policies.

---

# Reports

Quality reports

may include

```text
Distortion Score

Affected Objects

Estimated Deviation

Recommendations

Manufacturing Notes
```

Reports

are derived artifacts.

---

# Analytics

Future analytics

may include

```text
Historical Distortion

Machine Comparison

Fabric Performance

Material Analysis

AI Prediction
```

---

# Extensibility

Future capabilities

may include

```text
Finite Element Analysis

Digital Twin

Real-Time Sensors

AI Quality Prediction

Camera Validation

Physics Simulation
```

The logical model

must remain extensible.

---

# Thread Safety

Distortion analysis

is deterministic

and side-effect free.

Reports

are immutable

after generation.

Analysis

may execute

concurrently.

---

# Performance

The Distortion System

shall support

```text
Millions of Stitches

Large Designs

Incremental Analysis

Interactive Editing

Batch Manufacturing
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Distortion is a manufacturing quality metric.
- Distortion is the cumulative result of multiple embroidery forces.
- Fabric properties strongly influence distortion.
- Compensation reduces expected distortion.
- Stabilization improves dimensional stability.
- Analysis generates recommendations rather than geometry changes.
- Simulation estimates distortion.
- Reports are derived artifacts.
- Analysis is deterministic.
- Original embroidery geometry is never modified.

---

# Out of Scope

This document does not define

- finite element modeling
- machine calibration
- physical textile simulation
- real-time machine correction
- camera-based inspection

These belong to future simulation and manufacturing systems.

---

# Future Topics

Future fabric documents expand

```text
Digital Twin

Physics Simulation

Machine Learning

Camera Inspection

Real-Time Validation

AI Manufacturing

Production Analytics
```

---

# Acceptance Criteria

The Distortion specification is complete when

✓ Distortion is defined as cumulative embroidery deformation.

✓ Distortion categories and contributing factors are documented.

✓ Fabric, thread, density, underlay, stabilization, and compensation interactions are established.

✓ Risk classification and prevention strategies are specified.

✓ Simulation and manufacturing responsibilities are separated.

✓ Validation and reporting workflows are documented.

✓ Optimization guidance is introduced.

✓ Domain rules establish deterministic distortion analysis.

✓ Analysis remains machine-independent and immutable.

✓ The Distortion Model provides the canonical framework for dimensional quality assessment across the embroidery platform.
