# Domain
## DOM-403 Color Matching

**Document ID:** DOM-403  
**Title:** Color Matching  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Thread & Materials Team

**Related Documents**

```text
DOM-400 Thread Theory
DOM-401 Thread Types
DOM-402 Thread Colors

DOM-303 Thread Changes
DOM-308 Manufacturing

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
```

---

# Purpose

This document defines the Color Matching System used by Sewlio Studio.

Color matching converts logical embroidery colors into the closest available physical embroidery thread colors while preserving visual intent.

Because embroidery thread is manufactured in discrete colors rather than a continuous color spectrum, exact matches are not always possible.

---

# Philosophy

The artwork defines

the desired color.

Manufacturing determines

the closest achievable thread.

```text
Artwork Color

↓

Logical Thread Color

↓

Color Matching

↓

Physical Thread

↓

Manufacturing
```

The embroidery document remains independent of any commercial thread manufacturer.

---

# Goals

The Color Matching System shall provide

- Vendor-independent design
- Accurate color approximation
- Deterministic matching
- Commercial thread support
- Organization-specific libraries
- Extensible matching algorithms

---

# Definition

Color Matching is the process of selecting the most appropriate physical embroidery thread for a logical embroidery color.

Matching occurs during manufacturing planning.

The original design color is never modified.

---

# Responsibilities

The Color Matching System manages

- color comparison
- catalog lookup
- closest-match selection
- manufacturer mapping
- palette conversion
- validation

It does **not** manage

- thread inventory
- machine assignment
- stitch generation
- rendering

---

# Color Matching Pipeline

```text
Artwork Color

↓

Logical Color

↓

Matching Engine

↓

Thread Catalog

↓

Manufacturing Thread
```

---

# Matching Model

Each matching request contains

```text
Logical Color

Thread Type

Preferred Catalog

Matching Policy

Tolerance

Metadata
```

The result is

a manufacturing thread recommendation.

---

# Matching Levels

Matching results are classified as

```text
Exact Match

Closest Match

Approximate Match

No Acceptable Match
```

The matching level is reported to the user.

---

# Exact Match

An exact match exists

when the logical color

maps directly

to a thread catalog entry.

Example

```text
Logical Royal Blue

↓

Madeira 1243
```

---

# Closest Match

If no exact match exists,

the engine selects

the nearest available thread

within the acceptable tolerance.

---

# Approximate Match

Approximate matches

are used when

the nearest thread

still exceeds

the preferred tolerance.

The user may accept

or override

the recommendation.

---

# No Match

If no suitable thread exists,

the system reports

```text
No Acceptable Match
```

Possible actions

```text
Choose Alternative Catalog

Choose Custom Thread

Manual Override

Create Custom Mapping
```

---

# Matching Algorithms

Supported matching strategies

include

```text
Exact Lookup

Nearest Color

Perceptual Distance

Brand Mapping

Custom Rule Engine
```

The matching algorithm

is configurable.

---

# Color Spaces

The matching engine

operates on

device-independent

color spaces.

Supported spaces

```text
CIELAB

XYZ

sRGB

Display P3
```

CIELAB is preferred

for perceptual comparisons.

---

# Perceptual Matching

Perceptual matching

attempts to minimize

human-visible

color differences

rather than

numerical RGB differences.

This generally produces

better embroidery results.

---

# Color Difference

The system evaluates

the visual difference

between colors.

Supported metrics

```text
ΔE76

ΔE94

ΔE2000

Custom Metrics
```

The metric

is implementation-dependent.

---

# Matching Policies

Supported policies

```text
Exact Only

Closest

Perceptual

Corporate Palette

Brand Locked

Manual
```

Policies

guide

automatic matching.

---

# Thread Type Interaction

Matching considers

thread type.

Example

```text
Metallic Gold

↓

Metallic Catalog

Not

Polyester Catalog
```

Thread material

influences

available colors.

---

# Manufacturer Libraries

Supported library sources

include

```text
Madeira

Isacord

Gunold

Robison-Anton

Coats

Marathon

Custom
```

Libraries

are replaceable.

---

# Organization Libraries

Organizations

may maintain

their own

approved thread libraries.

Applications

```text
Corporate Branding

Customer Standards

Sports Teams

Government Standards
```

---

# Brand Locking

Manufacturing profiles

may require

specific brands.

Example

```text
Use Madeira Only

Use Isacord Only

Use Organization Library
```

Matching

respects

brand policies.

---

# Palette Matching

Entire embroidery designs

may be matched

to

an alternative palette.

Example

```text
Corporate Palette

↓

Commercial Thread Catalog

↓

Production Palette
```

Palette conversion

is deterministic.

---

# Manual Overrides

Users may override

automatic matching.

Overrides apply

to

```text
Single Color

Project

Organization

Manufacturing Profile
```

Manual mappings

take precedence.

---

# Color Groups

Objects sharing

the same logical color

must resolve

to

the same

manufacturing thread

unless explicitly overridden.

---

# Validation

Validation verifies

```text
Missing Catalog

Duplicate Mapping

Unavailable Thread

Invalid Color

Tolerance Failure
```

Warnings

or errors

are generated

depending on policy.

---

# Manufacturing

Manufacturing consumes

resolved thread colors

to generate

```text
Thread Plans

Needle Plans

Production Reports

Thread Lists
```

Matching completes

before manufacturing execution.

---

# Simulation

Simulation renders

logical colors,

not

catalog-specific thread IDs.

Optionally,

professional mode

may display

resolved manufacturing threads.

---

# Color Reports

The system may generate

matching reports

containing

```text
Logical Color

Matched Thread

Catalog Number

Matching Score

Difference

Warnings
```

Reports assist

production review.

---

# Extensibility

Future capabilities

may include

```text
Spectral Matching

AI Color Matching

Lighting Profiles

Camera Calibration

Automatic Brand Conversion

Cloud Thread Libraries
```

The logical model

must remain extensible.

---

# Thread Safety

Matching operations

are pure functions.

Color libraries

are immutable

during matching.

Matching may execute

concurrently.

---

# Performance

The Color Matching System

shall support

```text
Thousands of Colors

Large Catalogs

Batch Matching

Incremental Matching

Real-Time Suggestions
```

without modifying

embroidery documents.

---

# Domain Rules

The following always apply.

- Logical colors remain vendor-independent.
- Matching never modifies original design colors.
- Matching occurs during manufacturing planning.
- Thread type influences available color matches.
- Matching policies determine acceptable substitutions.
- Manual overrides take precedence over automatic matching.
- Objects sharing a logical color should resolve consistently.
- Simulation uses logical colors unless manufacturing preview is enabled.
- Color libraries are replaceable.
- Matching behavior is deterministic.

---

# Out of Scope

This document does not define

- ICC color management
- display calibration
- thread inventory
- rendering algorithms
- machine thread assignment

These are covered by future rendering, manufacturing, and machine documents.

---

# Future Topics

Future thread documents expand

```text
Thread Catalogs

Spectral Colors

ICC Profiles

AI Color Matching

Cloud Libraries

Material Rendering

Production Standards
```

---

# Acceptance Criteria

The Color Matching specification is complete when

✓ Color matching is defined independently of manufacturers.

✓ Matching levels and workflows are documented.

✓ Color spaces and perceptual matching concepts are established.

✓ Commercial and custom thread libraries are supported.

✓ Matching policies and manual overrides are specified.

✓ Manufacturing and simulation responsibilities are separated.

✓ Validation and reporting workflows are documented.

✓ Domain rules establish deterministic color matching behavior.

✓ Original design colors remain immutable.

✓ The Color Matching System provides the canonical bridge between logical colors and physical embroidery thread catalogs.
