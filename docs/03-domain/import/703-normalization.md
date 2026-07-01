# Domain
## DOM-703 Normalization

**Document ID:** DOM-703  
**Title:** Normalization  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Import & Data Pipeline Team

**Related Documents**

```text
DOM-100 Coordinate System
DOM-101 Paths
DOM-103 Transformations

DOM-700 Vector Import
DOM-701 Raster Import
DOM-702 Embroidery Import

ARCH-009 Digitizer Pipeline
ARCH-012 Import Pipeline
ARCH-019 Error Handling
ARCH-021 Architecture Principles
ARCH-027 Dependency Graph
```

---

# Purpose

This document defines the Normalization System used by Sewlio Studio.

Normalization converts imported data into the canonical internal representation used throughout the platform.

Every importer—whether vector, raster, embroidery, or future formats—must pass through normalization before the data becomes available to the editor or runtime.

Normalization guarantees that all internal systems operate on a single, deterministic data model.

---

# Philosophy

Many formats,

one representation.

```text
External Format

↓

Import

↓

Normalization

↓

Canonical Model

↓

Editor

↓

Runtime
```

Every subsystem

operates on

normalized data,

never on

format-specific structures.

---

# Goals

The Normalization System shall provide

- Canonical data representation
- Deterministic conversion
- Format independence
- Consistent validation
- Data preservation
- Extensible transformation pipeline

---

# Definition

Normalization is the process of converting imported data into Sewlio Studio's canonical internal model.

Normalization removes

format-specific differences

while preserving

logical meaning.

---

# Responsibilities

The Normalization System performs

- coordinate normalization
- unit conversion
- transform normalization
- metadata normalization
- color normalization
- identifier generation
- structural normalization

It does **not** perform

- optimization
- auto-digitizing
- simulation
- rendering
- manufacturing

---

# Normalization Pipeline

```text
Imported Data

↓

Intermediate Representation

↓

Normalization

↓

Canonical Model

↓

Validation

↓

Editor
```

Normalization always occurs

before validation.

---

# Canonical Model

All imported content

is converted

into one of

the internal models.

```text
Geometry Model

Embroidery Model

Raster Asset Model

Metadata Model
```

These models

are independent

of file formats.

---

# Normalization Stages

The pipeline

consists of

```text
Structure

Coordinates

Units

Transforms

Colors

Metadata

Identifiers

Validation Preparation
```

Each stage

operates independently.

---

# Structure Normalization

Structure normalization

converts

format-specific hierarchies

into

logical document structures.

Examples

```text
Layers

Groups

Objects

Assets

Embroidery Blocks
```

---

# Coordinate Normalization

Coordinates

are converted

into

the internal coordinate system.

Normalization includes

```text
Origin

Axis Direction

Orientation

Precision
```

All geometry

uses

the same coordinate system.

---

# Unit Normalization

Supported source units

include

```text
Millimeters

Inches

Pixels

Points

Centimeters
```

Internally,

Sewlio Studio

uses

millimeters.

---

# Transform Normalization

Imported transforms

are normalized

into

a common matrix representation.

Supported transforms

```text
Translation

Rotation

Scaling

Shearing

Affine Matrix
```

Nested transforms

remain deterministic.

---

# Color Normalization

Colors

are converted

into

logical color definitions.

Normalization includes

```text
Color Space

Alpha

Palette

Profiles
```

Vendor-specific

color definitions

are preserved

as metadata.

---

# Identifier Generation

Every imported object

receives

a globally unique

internal identifier.

Identifiers

are immutable

throughout

the document lifetime.

---

# Metadata Normalization

Metadata

is normalized

into

a common schema.

Supported metadata

includes

```text
Author

Application

Version

Creation Date

Modification Date

Comments

Custom Properties
```

Unknown metadata

is preserved

whenever possible.

---

# Precision Normalization

Numerical values

are normalized

using

the platform's

standard precision.

Normalization

avoids

cumulative

floating-point errors.

---

# Geometry Repair

Minor geometry issues

may be repaired

during normalization.

Examples

```text
Duplicate Vertices

Zero-Length Segments

Invalid Winding

Broken Paths

Tiny Gaps
```

Repairs

must be deterministic.

---

# Embroidery Normalization

Embroidery data

is normalized

into

```text
Logical Coordinates

Thread Events

Machine Commands

Embroidery Objects
```

Machine-specific

representations

are removed.

---

# Raster Normalization

Raster assets

are normalized

using

```text
Color Space

Orientation

Resolution

Pixel Format

Metadata
```

Image pixels

remain unchanged.

---

# Extension Preservation

Unknown

or proprietary data

must be preserved

whenever possible.

Extensions become

```text
Opaque Metadata

Extension Records

Plugin Data
```

Normalization

must never

silently discard

recoverable information.

---

# Validation Preparation

Normalization prepares

data for

later validation.

Examples

```text
Resolved References

Generated IDs

Canonical Units

Consistent Structures
```

Validation itself

occurs afterward.

---

# Determinism

Normalization

must always produce

identical results

for identical inputs.

No randomness

is permitted.

---

# Diagnostics

Normalization

may report

```text
Recovered Data

Repaired Geometry

Unknown Extensions

Precision Changes

Unsupported Features
```

Diagnostics

never modify

the normalized output.

---

# Version Compatibility

Older formats

are normalized

using

compatibility adapters.

Internal models

remain stable

across platform versions.

---

# Extensibility

New normalization stages

may be introduced

through

the Plugin Architecture.

Stages operate

on

the canonical

intermediate representation.

---

# Thread Safety

Normalization

is stateless.

Multiple imports

may normalize

concurrently.

No shared mutable state

is permitted.

---

# Performance

The Normalization System

shall support

```text
Large Documents

Millions of Objects

Incremental Processing

Parallel Execution

Streaming Pipelines
```

without blocking

editor responsiveness.

---

# Domain Rules

The following always apply.

- Every imported document must be normalized.
- Internal systems consume only canonical models.
- Normalization is deterministic.
- Coordinate systems are unified.
- Units are standardized.
- Identifiers are immutable.
- Recoverable information is preserved.
- Unknown extensions are retained whenever possible.
- Normalization never performs optimization.
- Canonical models remain format-independent.

---

# Out of Scope

This document does not define

- optimization
- digitizing
- simulation
- rendering
- machine compilation

These belong to later processing stages.

---

# Future Topics

Future import documents expand

```text
Incremental Normalization

Streaming Import

Cloud Synchronization

Schema Evolution

Cross-Version Migration

AI Data Cleanup

Distributed Import
```

---

# Acceptance Criteria

The Normalization specification is complete when

✓ Normalization responsibilities are clearly separated from import and optimization.

✓ Canonical internal models are established.

✓ Coordinate, unit, transform, color, and metadata normalization are documented.

✓ Structure normalization and identifier generation are defined.

✓ Extension preservation and geometry repair are specified.

✓ Deterministic behavior is established.

✓ Validation preparation responsibilities are documented.

✓ Plugin-based extensibility is supported.

✓ Domain rules guarantee a format-independent canonical representation.

✓ The Normalization System provides the mandatory bridge between every importer and every downstream subsystem.
