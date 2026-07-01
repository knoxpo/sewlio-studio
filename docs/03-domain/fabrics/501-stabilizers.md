# Domain
## DOM-501 Stabilizers

**Document ID:** DOM-501  
**Title:** Stabilizers  
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

DOM-302 Needle System
DOM-306 Machine Speed
DOM-308 Manufacturing

DOM-400 Thread Theory
DOM-404 Thread Weight

DOM-500 Fabric Theory

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the Stabilizer System used by Sewlio Studio.

Stabilizers are temporary or permanent support materials used during embroidery to improve fabric stability, reduce distortion, and produce consistent embroidery quality.

The Stabilizer System provides logical manufacturing guidance independent of specific stabilizer brands or manufacturers.

---

# Philosophy

The fabric is rarely sufficient by itself.

Stabilizers transform unstable fabric into a predictable embroidery surface.

```text
Fabric

+

Stabilizer

↓

Stable Foundation

↓

Embroidery
```

Professional embroidery quality depends as much on stabilization as on digitizing.

---

# Goals

The Stabilizer System shall provide

- Fabric stabilization guidance
- Manufacturing recommendations
- Machine-independent modeling
- Quality assurance
- Simulation support
- Extensible material definitions

---

# Definition

A Stabilizer is a temporary or permanent backing material placed beneath, above, or within the fabric to improve embroidery quality.

Stabilizers influence

- fabric stability
- stitch quality
- distortion
- registration
- durability

They do not become part of the logical embroidery design.

---

# Responsibilities

The Stabilizer System defines

- stabilizer types
- stabilization strategies
- material recommendations
- compatibility rules
- manufacturing guidance

It does **not** define

- embroidery geometry
- stitch generation
- machine mechanics
- inventory management

---

# Stabilization Pipeline

```text
Fabric

↓

Fabric Analysis

↓

Stabilizer Selection

↓

Manufacturing Planning

↓

Production
```

---

# Stabilizer Model

Each stabilizer contains

```text
Identifier

Display Name

Category

Material

Thickness

Strength

Removal Method

Metadata
```

---

# Stabilizer Categories

Supported stabilizer categories

include

```text
Cut Away

Tear Away

Wash Away

Heat Away

Adhesive

Film

Foam

Specialty

Custom
```

---

# Cut Away

Cut Away stabilizers

remain permanently

behind the embroidery.

Characteristics

```text
High Stability

Excellent Durability

Stretch Fabric Support

Permanent Backing
```

Typical applications

```text
T-Shirts

Polos

Sweatshirts

Knits

Stretch Fabrics
```

---

# Tear Away

Tear Away stabilizers

are removed

after embroidery.

Characteristics

```text
Easy Removal

Moderate Stability

General Purpose
```

Typical applications

```text
Woven Fabrics

Canvas

Denim

Light Jackets
```

---

# Wash Away

Wash Away stabilizers

dissolve

in water.

Characteristics

```text
Invisible Finish

Temporary Support

Fine Detail
```

Typical applications

```text
Freestanding Lace

Sheer Fabrics

Delicate Materials
```

---

# Heat Away

Heat Away stabilizers

disintegrate

under controlled heat.

Typical applications

```text
Velvet

Sensitive Materials

Specialty Fabrics
```

---

# Adhesive Stabilizers

Adhesive stabilizers

secure fabric

without hoop marks.

Applications

```text
Small Garments

Leather

Caps

Patches

Delicate Materials
```

---

# Water-Soluble Film

Water-soluble film

is placed

above the fabric.

Purpose

```text
Compress Fabric Pile

Improve Stitch Definition

Prevent Thread Sinking
```

Commonly used with

```text
Towels

Fleece

Velvet
```

---

# Foam

Embroidery foam

creates

raised embroidery.

Applications

```text
3D Puff

Caps

Sports Logos

Decorative Lettering
```

Foam is considered

a specialized stabilizing material.

---

# Stabilizer Properties

Each stabilizer defines

```text
Support Strength

Flexibility

Thickness

Removal Method

Recommended Fabrics

Durability
```

These properties

guide manufacturing.

---

# Fabric Interaction

Stabilizer selection

depends primarily on

fabric characteristics.

Examples

```text
Stretch Fabric

↓

Cut Away

Canvas

↓

Tear Away

Towel

↓

Cut Away

+

Top Film

Leather

↓

Adhesive
```

---

# Thread Interaction

Heavy threads

and dense embroidery

often require

stronger stabilization.

The stabilizer recommendation

may vary

with thread weight.

---

# Density Interaction

High stitch density

increases

fabric distortion.

Additional stabilization

may be recommended

for dense embroidery.

---

# Underlay Interaction

Underlay

and stabilizers

work together.

Examples

```text
Strong Stabilizer

↓

Reduced Underlay

Weak Stabilizer

↓

Additional Underlay
```

---

# Hooping Interaction

Stabilizers influence

recommended hooping techniques.

Examples

```text
Adhesive

↓

Float Method

Stretch Fabric

↓

Firm Support

Leather

↓

Minimal Compression
```

---

# Manufacturing Profiles

Manufacturing profiles

may specify

```text
Preferred Stabilizer

Number of Layers

Topper Usage

Backing Usage
```

Profiles improve

production consistency.

---

# Layering

Some projects

require

multiple stabilizers.

Example

```text
Fabric

↓

Cut Away

↓

Top Film

↓

Embroidery
```

Layering recommendations

are part of

manufacturing planning.

---

# Simulation

Simulation

may optionally visualize

```text
Backing

Topper

Foam

Fabric Support
```

Simulation

does not model

full material physics.

---

# Manufacturing

Manufacturing planning

uses stabilizer information

for

```text
Production Reports

Operator Instructions

Material Planning

Quality Assurance
```

---

# Operator Guidance

Manufacturing reports

may include

instructions such as

```text
Use Medium Cut Away

Apply Water-Soluble Topper

Float Fabric

Use Two Layers
```

These are recommendations,

not document properties.

---

# Validation

Validation checks

```text
Missing Recommendation

Fabric Compatibility

Density Support

Profile Consistency

Material Constraints
```

Validation

produces

warnings

or recommendations.

---

# Extensibility

Future stabilizer capabilities

may include

```text
Smart Stabilizers

RFID Materials

AI Selection

Digital Material Libraries

Thermal Stabilizers

Composite Backings
```

The logical model

must remain extensible.

---

# Thread Safety

Stabilizer definitions

are immutable.

Manufacturing planning

references

logical stabilizer profiles

without modification.

---

# Performance

The Stabilizer System

shall support

```text
Large Material Libraries

Batch Manufacturing

Interactive Recommendations

Real-Time Validation

Production Analytics
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Stabilizers improve fabric stability.
- Stabilizers are manufacturing materials.
- Stabilizer selection depends primarily on fabric properties.
- Stabilizers influence density, underlay, and quality recommendations.
- Stabilizers are not part of the embroidery document.
- Manufacturing planning generates stabilizer recommendations.
- Stabilizer definitions are immutable.
- Simulation may visualize stabilizers.
- Original embroidery geometry is unaffected by stabilizer selection.
- Validation occurs before manufacturing.

---

# Out of Scope

This document does not define

- stabilizer inventory
- supplier catalogs
- purchasing
- physical material simulation
- automated stabilizer application

These belong to future manufacturing and inventory modules.

---

# Future Topics

Future fabric documents expand

```text
Stabilizer Libraries

Material Catalogs

AI Material Selection

Production Analytics

Inventory Management

Digital Twin Materials

Automated Manufacturing
```

---

# Acceptance Criteria

The Stabilizer specification is complete when

✓ Stabilizers are defined as manufacturing support materials.

✓ Common stabilizer categories are documented.

✓ Fabric, thread, density, and underlay interactions are established.

✓ Manufacturing recommendations and operator guidance are specified.

✓ Layering and specialized stabilizers are introduced.

✓ Simulation and manufacturing responsibilities are separated.

✓ Validation workflows are documented.

✓ Domain rules establish deterministic stabilizer behavior.

✓ Stabilizer definitions remain immutable and machine-independent.

✓ The Stabilizer System provides the canonical stabilization model for embroidery manufacturing.
