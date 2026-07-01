# Domain
## DOM-402 Thread Colors

**Document ID:** DOM-402  
**Title:** Thread Colors  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Thread & Materials Team

**Related Documents**

```text
DOM-400 Thread Theory
DOM-401 Thread Types

DOM-208 Sequencing
DOM-302 Needle System
DOM-303 Thread Changes
DOM-308 Manufacturing

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
```

---

# Purpose

This document defines the Thread Color System used by Sewlio Studio.

Thread color represents the visual identity of embroidery thread while remaining independent of thread material, machine configuration, and commercial thread manufacturers.

The color system provides a unified abstraction for design, simulation, manufacturing, and export.

---

# Philosophy

A thread color represents

**appearance**,

not

**manufacturing resources**.

```text
Artwork Color

↓

Thread Color

↓

Thread Assignment

↓

Needle Assignment

↓

Machine
```

Colors belong to the embroidery design.

Needles and threads belong to manufacturing.

---

# Goals

The Thread Color System shall provide

- Vendor-independent colors
- Consistent visual appearance
- Accurate simulation
- Manufacturing portability
- Color library integration
- Future color management

---

# Definition

A Thread Color is a logical color assigned to embroidery objects.

Thread colors describe visual appearance independently of

- thread type
- machine
- needle
- manufacturer

---

# Responsibilities

Thread Colors define

- visual color
- color identity
- color naming
- color libraries
- color matching

They do **not** define

- thread material
- needle assignment
- thread inventory
- machine commands

---

# Color Pipeline

```text
Artwork

↓

Logical Colors

↓

Thread Assignment

↓

Needle Assignment

↓

Machine
```

Color remains logical until manufacturing planning.

---

# Color Model

Each Thread Color contains

```text
Identifier

Display Name

Color Value

Color Space

Optional Library Reference

Metadata
```

---

# Color Identity

Each color has

a stable logical identifier.

Example

```text
thread.red.primary

thread.blue.navy

thread.gold.metallic
```

Identifiers remain

independent of

commercial catalogs.

---

# Display Name

Examples

```text
Black

White

Royal Blue

Scarlet Red

Forest Green

Gold
```

Display names

are localized

without affecting identity.

---

# Color Value

The logical system

stores device-independent

color values.

Supported color spaces

```text
sRGB

Display P3

CIELAB

XYZ
```

Internal rendering

should use

a high-precision color representation.

---

# Color Spaces

Sewlio Studio distinguishes

```text
Display Color

↓

Simulation Color

↓

Manufacturing Color
```

Each serves

a different purpose.

---

# Display Color

Display colors

are optimized

for

```text
Editor

Palette

Preview

UI
```

---

# Simulation Color

Simulation colors

combine

```text
Base Color

Reflection

Material Finish

Lighting
```

to approximate

real embroidery appearance.

---

# Manufacturing Color

Manufacturing colors

map

logical colors

to

commercial thread catalogs.

Example

```text
Royal Blue

↓

Madeira 1243

↓

Isacord 3910

↓

Gunold 5678
```

The embroidery document

stores

only the logical color.

---

# Color Libraries

Supported library types

```text
Built-In

Commercial

Organization

Project

Custom
```

Libraries

map

logical colors

to vendor catalogs.

---

# Commercial Libraries

Examples

```text
Madeira

Isacord

Gunold

Robison-Anton

Coats

Marathon
```

Libraries

are optional

and replaceable.

---

# Custom Libraries

Organizations

may create

their own

color libraries.

Examples

```text
Corporate Branding

School Colors

Sports Teams

Customer Collections
```

---

# Color Matching

Color matching

attempts to find

the closest

commercial thread

for a logical color.

Matching may use

```text
RGB

CIELAB

ΔE

Catalog Rules
```

---

# Color Accuracy

Perfect color matching

is not always possible.

The system

may provide

```text
Exact Match

Closest Match

Approximate Match
```

with

matching confidence.

---

# Color Groups

Objects sharing

the same logical color

form

```text
Color Groups
```

Color groups

drive

thread planning

and sequencing.

---

# Thread Type Interaction

The same logical color

may exist

for multiple thread types.

Example

```text
Royal Blue

↓

Polyester

↓

Rayon

↓

Cotton
```

Material selection

does not change

logical color identity.

---

# Needle Interaction

Thread colors

are assigned

to needles

during manufacturing.

Embroidery objects

never reference

needle numbers.

---

# Manufacturing

Manufacturing uses

thread colors

to generate

```text
Thread Plan

Needle Assignment

Color Changes

Production Reports
```

---

# Thread Changes

Changing

logical thread colors

produces

thread transitions

within the manufacturing plan.

The optimizer

attempts to minimize

color changes.

---

# Color Profiles

Future profiles

may define

```text
Brand Identity

Print Matching

Corporate Palette

Accessibility

Color Policies
```

Profiles

guide

automatic color mapping.

---

# Rendering

Simulation should render

thread colors

using

```text
Material

Reflection

Lighting

Thread Direction

Surface Texture
```

Flat RGB rendering

is insufficient

for professional previews.

---

# Accessibility

Future versions

may support

```text
High Contrast

Color Blind Modes

Pattern Overlay

Alternative Visualization
```

Accessibility

affects UI,

not manufacturing.

---

# Color Metadata

Optional metadata

may include

```text
Brand

Catalog

Batch

Supplier

Availability

Notes
```

Metadata

does not affect

logical identity.

---

# Validation

Validation checks

```text
Missing Color

Missing Library Mapping

Duplicate Identity

Invalid Color Value
```

Validation

occurs

during manufacturing planning.

---

# Extensibility

Future color capabilities

may include

```text
Spectral Colors

Multi-Color Thread

Gradient Thread

Photo Embroidery

AI Color Matching

Cloud Libraries
```

The logical model

must remain extensible.

---

# Thread Safety

Thread Color definitions

are immutable.

Color libraries

may be updated

without modifying

embroidery documents.

---

# Performance

The Thread Color System

shall support

```text
Large Color Libraries

Thousands of Colors

Commercial Catalogs

Real-Time Rendering

Batch Manufacturing
```

without affecting

embroidery geometry.

---

# Domain Rules

The following always apply.

- Thread colors define appearance, not material.
- Logical colors are vendor-independent.
- Thread colors are independent of needle assignments.
- Manufacturing maps logical colors to commercial thread catalogs.
- Color groups determine thread transitions.
- Simulation renders colors using material properties.
- Color libraries are replaceable.
- Thread Color definitions are immutable.
- Original embroidery geometry is unaffected by color definitions.
- Machine compilation preserves logical color intent.

---

# Out of Scope

This document does not define

- thread inventory
- spool management
- machine threading
- embroidery rendering algorithms
- ICC color management

These are covered in future thread, rendering, and manufacturing documents.

---

# Future Topics

Future thread documents expand

```text
Thread Libraries

Brand Catalogs

Color Matching

ICC Profiles

Spectral Rendering

AI Color Selection

Material Rendering
```

---

# Acceptance Criteria

The Thread Colors specification is complete when

✓ Thread colors are defined independently of thread materials.

✓ Logical color identities and color spaces are documented.

✓ Display, simulation, and manufacturing color representations are distinguished.

✓ Commercial thread libraries are abstracted behind logical colors.

✓ Color matching and validation workflows are established.

✓ Thread, needle, and manufacturing interactions are documented.

✓ Rendering and accessibility considerations are introduced.

✓ Domain rules establish deterministic color behavior.

✓ Color definitions remain immutable and vendor-independent.

✓ The Thread Color System provides the canonical color abstraction for the embroidery platform.
