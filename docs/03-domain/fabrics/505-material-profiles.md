# Domain
## DOM-505 Material Profiles

**Document ID:** DOM-505  
**Title:** Material Profiles  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Fabric & Materials Team

**Related Documents**

```text
DOM-204 Underlay
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-214 Optimization

DOM-400 Thread Theory
DOM-401 Thread Types
DOM-404 Thread Weight

DOM-500 Fabric Theory
DOM-501 Stabilizers
DOM-502 Puckering
DOM-503 Fabric Stretch
DOM-504 Distortion

DOM-308 Manufacturing

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-013 Plugin Architecture
```

---

# Purpose

This document defines the Material Profile System used by Sewlio Studio.

A Material Profile represents a complete set of embroidery recommendations and manufacturing parameters for a particular material or garment.

Rather than repeatedly configuring density, underlay, compensation, stabilizers, needles, and thread selections, users can select a predefined Material Profile that encapsulates proven embroidery practices.

---

# Philosophy

Professional embroidery

is driven by materials,

not only by stitches.

```text
Material

↓

Recommended Settings

↓

Embroidery Planning

↓

Manufacturing
```

Material Profiles capture manufacturing knowledge and make it reusable.

---

# Goals

The Material Profile System shall provide

- Reusable manufacturing presets
- Consistent embroidery quality
- Simplified digitizing
- Material-aware optimization
- Extensible profile libraries
- Vendor-independent recommendations

---

# Definition

A Material Profile is an immutable collection of embroidery recommendations associated with a specific material, garment, or manufacturing scenario.

A profile may influence

- density
- underlay
- compensation
- stabilizers
- thread
- needle
- speed
- validation

without modifying the embroidery geometry.

---

# Responsibilities

Material Profiles define

- recommended settings
- manufacturing defaults
- quality recommendations
- validation thresholds
- production guidance

They do **not** define

- artwork
- embroidery geometry
- stitch generation
- machine instructions

---

# Material Profile Pipeline

```text
Embroidery Design

↓

Material Profile

↓

Optimization

↓

Manufacturing Planning

↓

Machine Compilation
```

---

# Material Profile Model

Each Material Profile contains

```text
Identifier

Display Name

Category

Target Materials

Recommended Settings

Validation Rules

Metadata
```

---

# Profile Categories

Supported categories include

```text
Fabric

Garment

Accessory

Industrial

Specialty

Organization

Custom
```

---

# Built-In Profiles

Sewlio Studio provides

reference profiles

for common materials.

Examples

```text
T-Shirt

Polo Shirt

Sweatshirt

Denim Jacket

Leather Patch

Canvas Bag

Cap

Towel

Silk

Performance Wear
```

---

# Fabric Association

Each profile

references one or more

Fabric Profiles.

Example

```text
Stretch Knit

↓

Sportswear Profile

Canvas

↓

Canvas Bag Profile
```

---

# Thread Recommendations

Profiles may define

preferred

```text
Thread Type

Thread Weight

Thread Finish

Material Rules
```

Example

```text
Performance Wear

↓

Polyester 40 wt

Luxury Garments

↓

Silk 60 wt
```

---

# Needle Recommendations

Profiles define

recommended

```text
Needle Type

Needle Size

Needle Point
```

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

---

# Stabilizer Recommendations

Profiles specify

recommended stabilization.

Examples

```text
Stretch Fabric

↓

Medium Cut Away

Towel

↓

Heavy Cut Away

+

Water-Soluble Topper

Leather

↓

Adhesive Backing
```

---

# Density Recommendations

Profiles define

recommended density ranges.

Example

```text
Fine Silk

↓

Lower Density

Canvas

↓

Standard Density

Leather

↓

Reduced Density
```

Density remains

user-overridable.

---

# Underlay Recommendations

Profiles recommend

appropriate underlay combinations.

Examples

```text
Edge Walk

Center Walk

Zigzag

Tatami Base

Double Zigzag
```

Selection depends

on the material.

---

# Compensation Recommendations

Profiles define

default

```text
Pull Compensation

Push Compensation

Corner Compensation
```

Recommendations

may vary

by stitch type.

---

# Speed Recommendations

Profiles may recommend

```text
Machine Speed

Thread Speed

Maximum Satin Speed

Production Profile
```

Machine capabilities

remain authoritative.

---

# Quality Rules

Profiles define

acceptable quality limits.

Examples

```text
Maximum Density

Maximum Satin Width

Minimum Underlay

Stretch Threshold

Puckering Risk
```

These rules

support validation.

---

# Validation Policies

Profiles specify

validation behavior.

Examples

```text
Strict

Standard

Relaxed

Professional

Industrial
```

Policy selection

affects warnings,

not geometry.

---

# Manufacturing Guidance

Profiles provide

operator recommendations.

Examples

```text
Float Fabric

Use Two Stabilizers

Reduce Speed

Use Ballpoint Needle

Apply Topper
```

These recommendations

appear

in manufacturing reports.

---

# Profile Inheritance

Profiles may inherit

from other profiles.

Example

```text
Fabric Profile

↓

Garment Profile

↓

Organization Profile

↓

Project Override
```

Only overridden values

change.

---

# Organization Profiles

Organizations

may define

standardized

production profiles.

Examples

```text
Corporate Branding

Sports Apparel

Medical Textiles

Luxury Fashion

Industrial Products
```

These profiles

improve consistency.

---

# Project Overrides

Projects

may override

specific recommendations

without modifying

the original profile.

Example

```text
Base Profile

↓

Increase Pull Compensation

↓

Project Profile
```

---

# Simulation

Simulation

may display

active material recommendations,

including

```text
Thread

Needle

Stabilizer

Density

Compensation
```

Simulation

does not alter

profile definitions.

---

# Manufacturing

Manufacturing planning

uses Material Profiles

to configure

```text
Optimization

Validation

Production Reports

Operator Instructions
```

---

# Validation

Validation checks

```text
Incomplete Profile

Conflicting Rules

Unsupported Material

Missing Recommendations

Invalid Overrides
```

Validation

occurs

before manufacturing.

---

# Libraries

Profiles may originate from

```text
Built-In Library

Organization Library

Plugin Library

Marketplace

Cloud Library

Custom Library
```

The profile format

is standardized.

---

# Versioning

Each profile

contains

```text
Identifier

Version

Compatibility

Author

Revision

Timestamp
```

Profiles

are immutable

after publication.

---

# Extensibility

Future capabilities

may include

```text
AI Material Detection

Automatic Profile Selection

Cloud Synchronization

Digital Twin Materials

Marketplace Profiles

Machine Learning
```

The profile system

must remain extensible.

---

# Thread Safety

Material Profiles

are immutable.

Multiple manufacturing jobs

may safely reference

the same profile

concurrently.

---

# Performance

The Material Profile System

shall support

```text
Thousands of Profiles

Organization Libraries

Cloud Synchronization

Batch Manufacturing

Real-Time Recommendations
```

without affecting

embroidery geometry.

---

# Domain Rules

The following always apply.

- Material Profiles are manufacturing presets.
- Profiles never modify embroidery geometry directly.
- Profiles provide recommendations rather than mandatory settings.
- Project overrides do not modify the original profile.
- Manufacturing planning consumes profile recommendations.
- Validation uses profile-defined rules.
- Material Profiles are immutable.
- Profile inheritance is deterministic.
- Profiles remain machine-independent.
- Original embroidery documents remain portable.

---

# Out of Scope

This document does not define

- inventory management
- purchasing
- commercial material catalogs
- machine calibration
- cloud synchronization protocols

These belong to future manufacturing and platform documents.

---

# Future Topics

Future material documents expand

```text
Cloud Libraries

Marketplace Profiles

AI Material Recognition

Digital Twin Materials

Organization Standards

Automatic Profile Selection

Enterprise Libraries
```

---

# Acceptance Criteria

The Material Profiles specification is complete when

✓ Material Profiles are defined as reusable manufacturing presets.

✓ Profile structure and responsibilities are documented.

✓ Thread, needle, stabilizer, density, underlay, and compensation recommendations are specified.

✓ Validation policies and manufacturing guidance are established.

✓ Profile inheritance and project overrides are supported.

✓ Library, versioning, and extensibility mechanisms are defined.

✓ Simulation and manufacturing responsibilities are separated.

✓ Domain rules establish deterministic profile behavior.

✓ Profiles remain immutable and machine-independent.

✓ The Material Profile System provides the canonical manufacturing knowledge base for the embroidery platform.
