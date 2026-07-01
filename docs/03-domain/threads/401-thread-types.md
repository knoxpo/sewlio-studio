# Domain
## DOM-401 Thread Types

**Document ID:** DOM-401  
**Title:** Thread Types  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Thread & Materials Team

**Related Documents**

```text
DOM-400 Thread Theory
DOM-209 Density
DOM-210 Pull Compensation
DOM-214 Optimization

DOM-302 Needle System
DOM-303 Thread Changes
DOM-306 Machine Speed
DOM-308 Manufacturing

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the logical thread types supported by Sewlio Studio.

Different thread materials exhibit different manufacturing characteristics, visual appearance, durability, and machine behavior.

The Thread Type system models these differences while remaining independent of any specific manufacturer or commercial thread catalog.

---

# Philosophy

A thread type is more than a color.

It is a manufacturing material with unique physical and visual characteristics.

```text
Thread Type

↓

Material Properties

↓

Manufacturing Behavior

↓

Finished Embroidery
```

Selecting the proper thread type is as important as selecting the correct stitch type.

---

# Goals

The Thread Type System shall provide

- Material abstraction
- Machine independence
- Manufacturing realism
- Accurate simulation
- Production guidance
- Future extensibility

---

# Definition

A Thread Type defines the physical characteristics of an embroidery thread.

It influences

- appearance
- density
- speed
- durability
- compensation
- manufacturing recommendations

Thread types are logical definitions and are independent of manufacturers.

---

# Responsibilities

Thread Types define

- material behavior
- physical properties
- visual properties
- manufacturing constraints
- simulation appearance

They do **not** define

- colors
- inventory
- spool management
- needle assignment

---

# Thread Type Pipeline

```text
Thread Definition

↓

Thread Type

↓

Manufacturing Profile

↓

Machine Planning

↓

Production
```

---

# Supported Thread Types

The logical system supports

```text
Rayon

Polyester

Cotton

Silk

Metallic

Wool

Nylon

Glow

Reflective

Conductive

Specialty

Custom
```

Future versions

may extend this list.

---

# Rayon

Rayon is

the traditional embroidery thread.

Characteristics

```text
Excellent Shine

Smooth Finish

Moderate Strength

Professional Appearance
```

Typical applications

```text
Logos

Decorative Embroidery

Fashion
```

---

# Polyester

Polyester is

the most common

commercial embroidery thread.

Characteristics

```text
High Strength

Excellent Color Fastness

UV Resistant

Chemical Resistant

Low Break Rate
```

Typical applications

```text
Commercial Production

Uniforms

Outdoor Products
```

---

# Cotton

Cotton thread provides

a natural appearance.

Characteristics

```text
Matte Finish

Soft Texture

Lower Reflection

Traditional Appearance
```

Typical applications

```text
Vintage Designs

Quilting

Craft Embroidery
```

---

# Silk

Silk thread provides

premium appearance.

Characteristics

```text
Exceptional Luster

Fine Diameter

Smooth Surface

Luxury Finish
```

Typical applications

```text
Luxury Garments

High-End Decoration

Art Embroidery
```

---

# Metallic

Metallic thread contains

reflective metallic fibers.

Characteristics

```text
High Reflection

Lower Flexibility

Higher Break Risk

Slower Manufacturing
```

Typical applications

```text
Decorative Borders

Premium Logos

Holiday Designs
```

Requires reduced

machine speed.

---

# Wool

Wool thread produces

soft textured embroidery.

Characteristics

```text
High Volume

Soft Surface

Low Reflection

Decorative Texture
```

Often requires

special machine settings.

---

# Nylon

Nylon provides

excellent strength

and abrasion resistance.

Characteristics

```text
Strong

Flexible

Durable

Industrial
```

Typical applications

```text
Technical Textiles

Industrial Products

Outdoor Equipment
```

---

# Glow Thread

Glow thread

stores light energy

and emits

visible light

in darkness.

Characteristics

```text
Photoluminescent

Special Material

Reduced Speed
```

---

# Reflective Thread

Reflective thread

returns light

toward its source.

Applications

```text
Safety Apparel

Sportswear

Industrial Clothing
```

---

# Conductive Thread

Conductive thread

supports

electrical conductivity.

Applications

```text
Wearables

Smart Textiles

Sensors

Electronics
```

Future manufacturing

may support

conductive embroidery workflows.

---

# Specialty Threads

Specialty threads include

```text
Fire Resistant

Water Soluble

Elastic

Textured

Decorative

Experimental
```

The system

supports

custom material definitions.

---

# Material Properties

Each thread type defines

```text
Strength

Elasticity

Diameter

Density Factor

Reflectance

Wear Resistance

Recommended Speed

Recommended Needle
```

These properties

guide manufacturing.

---

# Visual Properties

Thread appearance includes

```text
Gloss

Matte

Metallic

Texture

Reflection

Transparency
```

Simulation

should reproduce

visual differences.

---

# Manufacturing Properties

Thread types influence

```text
Machine Speed

Density

Compensation

Needle Selection

Underlay

Production Profile
```

Manufacturing planning

uses these properties

automatically.

---

# Density Recommendations

Examples

```text
Metallic

↓

Lower Density

Polyester

↓

Standard Density

Cotton

↓

Slightly Higher Density
```

Recommendations

may be overridden.

---

# Speed Recommendations

Examples

```text
Polyester

Fast

Rayon

Standard

Metallic

Slow

Silk

Moderate
```

Machine profiles

determine

actual speeds.

---

# Needle Recommendations

Certain thread types

recommend

specific needle types.

Examples

```text
Metallic

↓

Metallic Needle

Heavy Thread

↓

Large Needle

Fine Silk

↓

Small Needle
```

Validation

may generate warnings.

---

# Fabric Compatibility

Each thread type

may recommend

preferred fabrics.

Example

```text
Polyester

↓

Most Fabrics

Cotton

↓

Natural Fabrics

Metallic

↓

Stable Fabrics
```

Compatibility

assists

production planning.

---

# Simulation

Simulation should visualize

```text
Gloss

Reflection

Texture

Material Finish

Coverage
```

Material behavior

should remain

machine-independent.

---

# Manufacturing

Manufacturing planning

uses thread types

for

```text
Speed

Needles

Profiles

Thread Consumption

Warnings
```

---

# Thread Libraries

Commercial libraries

may map

brand-specific threads

to

logical thread types.

Examples

```text
Madeira

Isacord

Robison-Anton

Gunold

Coats
```

The logical system

remains vendor-neutral.

---

# Extensibility

Future thread types

may include

```text
Optical Fiber

Carbon Fiber

Biodegradable

Smart Thread

Nano Fiber

Medical Thread
```

The logical model

must remain extensible.

---

# Thread Safety

Thread Type definitions

are immutable.

Runtime state

references

logical thread definitions

without modification.

---

# Performance

The Thread Type System

shall support

```text
Large Material Libraries

Commercial Catalogs

Real-Time Simulation

Material Analysis

Batch Manufacturing
```

without affecting

embroidery geometry.

---

# Domain Rules

The following always apply.

- Thread types define material behavior.
- Thread types are independent of color.
- Thread types are independent of manufacturers.
- Material properties influence manufacturing.
- Simulation visualizes material characteristics.
- Manufacturing planning uses thread recommendations.
- Thread type definitions are immutable.
- Vendor libraries map to logical thread types.
- Machine compilation preserves logical material identity.
- Embroidery geometry is independent of thread type definitions.

---

# Out of Scope

This document does not define

- thread inventory
- spool tracking
- machine threading
- thread break detection
- commercial color catalogs

These are covered by later thread and manufacturing documents.

---

# Future Topics

Future thread documents expand

```text
Thread Libraries

Color Catalogs

Thread Inventory

Material Profiles

Consumption Analysis

Commercial Brand Integration

AI Material Selection
```

---

# Acceptance Criteria

The Thread Types specification is complete when

✓ Logical thread types are defined independently of manufacturers.

✓ Common embroidery materials are documented.

✓ Material, visual, and manufacturing properties are specified.

✓ Density, speed, and needle recommendations are established.

✓ Fabric compatibility is introduced.

✓ Simulation and manufacturing responsibilities are separated.

✓ Commercial thread libraries are abstracted behind logical types.

✓ Material extensibility is supported.

✓ Domain rules establish deterministic material behavior.

✓ The Thread Type System provides the canonical material classification model for the embroidery platform.
