# Domain
## DOM-400 Thread Theory

**Document ID:** DOM-400  
**Title:** Thread Theory  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Thread & Materials Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-209 Density
DOM-210 Pull Compensation
DOM-214 Optimization

DOM-302 Needle System
DOM-303 Thread Changes
DOM-306 Machine Speed
DOM-308 Manufacturing

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines the theoretical foundation of embroidery thread within Sewlio Studio.

Thread is the primary manufacturing material of embroidery.

Understanding thread behavior is essential for producing predictable, high-quality embroidery across different fabrics, machines, and production environments.

---

# Philosophy

Embroidery is the controlled placement of thread.

Everything visible in embroidery is ultimately the result of thread behavior.

```text
Geometry

↓

Stitches

↓

Thread

↓

Embroidery
```

A digitizer manipulates thread—not pixels, vectors, or machine commands.

---

# Goals

The Thread Theory model shall provide

- Material independence
- Predictable embroidery behavior
- Manufacturing realism
- Simulation support
- Optimization guidance
- Machine independence

---

# Definition

Thread is the physical material deposited by an embroidery machine to produce decorative and functional embroidery.

Within Sewlio Studio, thread is represented as a logical material independent of any manufacturer or machine.

---

# Responsibilities

Thread theory defines

- thread properties
- visual appearance
- manufacturing behavior
- interaction with fabric
- interaction with stitches
- simulation characteristics

It does **not** define

- machine mechanics
- needle motion
- stitch generation
- embroidery geometry

---

# Thread Pipeline

```text
Artwork

↓

Embroidery Objects

↓

Stitch Generation

↓

Thread Planning

↓

Machine Execution

↓

Finished Embroidery
```

---

# Thread Model

Every logical thread contains

```text
Identifier

Name

Color

Material

Weight

Finish

Manufacturer (optional)

Catalog Number (optional)
```

Thread identity remains

independent of machine assignment.

---

# Thread as Material

Thread is treated as

a manufacturing material,

not merely a color.

Its physical properties influence

- appearance
- durability
- density
- compensation
- production speed

---

# Thread Structure

Commercial embroidery thread consists of

```text
Fibers

↓

Yarns

↓

Twisted Thread

↓

Finished Spool
```

Sewlio Studio models

the finished thread,

not its internal fiber construction.

---

# Thread Materials

Supported logical materials include

```text
Rayon

Polyester

Cotton

Silk

Metallic

Wool

Nylon

Glow-in-the-Dark

Conductive

Specialty
```

Future materials

may extend this list.

---

# Thread Weight

Thread weight influences

```text
Coverage

Strength

Density

Reflection

Machine Speed
```

Typical embroidery weights

include

```text
30 wt

40 wt

60 wt

90 wt
```

The logical model

stores weight

without assuming

specific manufacturers.

---

# Thread Diameter

Thread diameter

affects

- stitch coverage
- density
- overlap
- pull compensation

Thicker threads generally require

lower stitch density.

---

# Thread Color

Thread color is

a logical property.

It consists of

```text
Color Value

Display Name

Catalog Reference

Optional Brand Mapping
```

Color selection

is independent of

machine needle assignment.

---

# Thread Finish

Threads may have

different finishes.

Examples

```text
Matte

Gloss

Silk

Metallic

Fluorescent

Reflective
```

Finish affects

simulation

but not geometry.

---

# Thread Strength

Strength represents

the ability of a thread

to resist breakage.

It influences

- machine speed
- stitch length
- manufacturing reliability

---

# Thread Elasticity

Elasticity determines

how thread behaves

under tension.

Higher elasticity

may increase

pull effects.

---

# Thread Tension

Thread tension

is primarily

a machine characteristic,

but thread properties

influence

its behavior.

Simulation may model

relative tension effects.

---

# Thread Reflection

Embroidery appearance

depends heavily upon

thread reflection.

Reflection varies according to

```text
Thread Material

Finish

Stitch Direction

Lighting
```

Simulation should support

realistic thread reflection.

---

# Coverage

Coverage describes

how much fabric

is visually hidden

by the thread.

Coverage depends upon

```text
Thread Diameter

Density

Stitch Type

Layering
```

---

# Density Interaction

Thread thickness

directly affects

recommended stitch density.

Examples

```text
Thin Thread

↓

Higher Density

Thick Thread

↓

Lower Density
```

---

# Pull Compensation Interaction

Thread properties

influence

pull compensation.

Elastic threads

typically require

greater compensation.

---

# Underlay Interaction

Underlay supports

the visible thread.

Certain thread types

benefit from

heavier underlay

for improved coverage.

---

# Stitch Type Interaction

Different stitch families

use thread differently.

Examples

```text
Running Stitch

Low Coverage

Satin Stitch

High Reflection

Fill Stitch

High Coverage
```

---

# Fabric Interaction

Thread behavior depends upon

fabric properties.

Examples

```text
Stretch Fabric

↓

Higher Movement

Leather

↓

Less Compression

Towel

↓

Pile Coverage
```

Manufacturing profiles

coordinate

thread

and fabric.

---

# Needle Interaction

Thread compatibility

depends upon

needle size,

needle type,

and machine profile.

Validation occurs

during manufacturing planning.

---

# Speed Interaction

Certain threads

require reduced sewing speeds.

Examples

```text
Metallic

Silk

Heavy Cotton
```

Production profiles

should account

for thread limitations.

---

# Wear

Thread deteriorates

during production

due to

```text
Friction

Heat

Tension

Needle Penetration
```

Future simulation

may estimate

thread wear.

---

# Thread Consumption

Manufacturing estimates

thread usage

using

```text
Stitch Length

Thread Type

Tie-In

Tie-Off

Trims

Jumps
```

Consumption estimates

support production planning.

---

# Thread Libraries

Thread definitions

may originate from

```text
Brand Libraries

Manufacturer Catalogs

Custom Libraries

Organization Libraries
```

The document stores

logical references,

not vendor-specific implementations.

---

# Simulation

Simulation should visualize

```text
Color

Reflection

Coverage

Layering

Material Finish
```

Simulation

should not require

machine-specific thread data.

---

# Manufacturing

Manufacturing uses

thread information

for

```text
Needle Assignment

Runtime Estimation

Material Consumption

Speed Planning

Validation
```

---

# Extensibility

Future thread capabilities

may include

```text
Smart Thread

RFID Thread

Conductive Thread

Optical Fiber

Temperature Reactive

Biodegradable Materials
```

The logical model

must remain backward compatible.

---

# Thread Safety

Thread definitions

are immutable.

Runtime state

maintains

only

the currently active thread.

---

# Performance

The Thread System

shall support

```text
Large Thread Libraries

Commercial Color Charts

Real-Time Simulation

Material Analysis

Batch Manufacturing
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Thread is a manufacturing material.
- Thread identity is independent of machine assignment.
- Thread properties influence embroidery quality.
- Thread color is independent of needle selection.
- Density recommendations depend upon thread thickness.
- Manufacturing planning uses thread properties.
- Simulation visualizes thread appearance.
- Thread definitions are immutable.
- Machine compilation preserves logical thread identity.
- Original embroidery geometry is unaffected by thread definitions.

---

# Out of Scope

This document does not define

- thread inventory
- spool management
- machine threading
- thread break detection
- machine communication

These are covered in subsequent thread and machine documents.

---

# Future Topics

Future thread documents expand

```text
Thread Libraries

Color Management

Material Profiles

Thread Consumption

Brand Mapping

Thread Inventory

Smart Materials
```

---

# Acceptance Criteria

The Thread Theory specification is complete when

✓ Thread is defined as a logical manufacturing material.

✓ Thread structure, properties, and materials are documented.

✓ Interactions with stitches, density, compensation, underlay, and fabric are established.

✓ Simulation and manufacturing responsibilities are defined.

✓ Thread libraries and logical identities are introduced.

✓ Material extensibility is supported.

✓ Domain rules establish deterministic thread behavior.

✓ Thread definitions remain machine-independent and immutable.

✓ Original embroidery geometry is unaffected by thread properties.

✓ Thread Theory provides the foundational material model for the embroidery platform.
