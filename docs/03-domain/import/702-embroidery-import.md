# Domain
## DOM-702 Embroidery Import

**Document ID:** DOM-702  
**Title:** Embroidery Import  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Import & Conversion Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-201 Running Stitch
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing

DOM-300 Machine Model
DOM-301 Machine Coordinates
DOM-302 Needle System
DOM-303 Thread Changes
DOM-307 Machine Commands

DOM-400 Thread Theory
DOM-402 Thread Colors

ARCH-011 Machine Compiler
ARCH-012 Import Pipeline
ARCH-013 Plugin Architecture
ARCH-019 Error Handling
```

---

# Purpose

This document defines the Embroidery Import System used by Sewlio Studio.

The Embroidery Import System imports existing embroidery machine files into the internal embroidery document model.

Unlike vector import, embroidery import begins with already-digitized stitch data rather than artwork.

The goal is to preserve the original embroidery as faithfully as possible while exposing as much editable information as can be reconstructed.

---

# Philosophy

Importing embroidery

does not recreate

the original design.

```text
Embroidery File

↓

Import

↓

Embroidery IR

↓

Editing

↓

Optimization

↓

Export
```

Machine files contain

manufacturing instructions,

not authoring information.

Some information

cannot be recovered.

---

# Goals

The Embroidery Import System shall provide

- Accurate stitch reconstruction
- Machine-independent representation
- Editable embroidery objects
- Lossless machine command preservation
- Extensible format support
- Deterministic import behavior

---

# Definition

Embroidery Import converts machine embroidery files into the Embroidery Intermediate Representation (EIR).

Imported data may include

```text
Stitches

Commands

Colors

Needles

Trims

Jumps

Metadata

Machine Information
```

Import never reconstructs

the original vector artwork.

---

# Responsibilities

The Embroidery Import System performs

- file parsing
- stitch decoding
- command reconstruction
- color reconstruction
- machine normalization
- metadata extraction

It does **not** perform

- auto-vectorization
- artwork reconstruction
- design recreation
- optimization

---

# Import Pipeline

```text
Embroidery File

↓

Format Parser

↓

Embroidery IR

↓

Normalization

↓

Internal Document

↓

Editor
```

---

# Supported Formats

Built-in support includes

```text
DST

PES

PEC

JEF

EXP

VP3

HUS

XXX

PCS

SEW

U01

TBF

PHC

GNC
```

Additional formats

may be implemented

through plugins.

---

# Embroidery Intermediate Representation

All embroidery formats

are converted

into

a common

Embroidery Intermediate Representation (EIR).

The EIR contains

```text
Stitch Stream

Machine Commands

Thread Changes

Needle Changes

Metadata

Timing

Machine Coordinates
```

The editor

never consumes

format-specific structures.

---

# Stitch Reconstruction

Each imported stitch

contains

```text
Position

Type

Length

Direction

Flags

Metadata
```

Original stitch order

is preserved.

---

# Command Reconstruction

Supported commands

include

```text
Stitch

Jump

Trim

Stop

Color Change

Needle Change

End
```

Unknown commands

remain preserved

as opaque extensions.

---

# Color Import

Thread colors

are reconstructed

from

```text
Embedded Palette

Thread Catalog

Format Metadata

Default Palette
```

Color mappings

may be approximate.

---

# Thread Mapping

Imported thread references

are converted

into

logical thread colors.

Vendor-specific

thread identifiers

remain available

as metadata.

---

# Machine Coordinates

Machine-specific coordinates

are converted

into

the internal

coordinate system.

Normalization includes

```text
Units

Origin

Axis Direction

Precision
```

---

# Machine Metadata

Machine information

may include

```text
Manufacturer

Model

Hoop

Version

Capabilities
```

Metadata

is optional.

---

# Timing Information

When available,

the importer

extracts

```text
Stitch Timing

Machine Speed

Estimated Runtime
```

Timing

is informational.

---

# Sequence Preservation

Original embroidery sequence

must remain

unchanged.

Examples

```text
Stitch Order

Thread Changes

Trim Order

Machine Stops
```

Import

does not optimize

execution.

---

# Object Reconstruction

Some embroidery formats

contain

logical objects.

When available,

the importer

reconstructs

```text
Blocks

Color Groups

Layers

Sections
```

Otherwise,

only the stitch stream

is available.

---

# Editable Objects

Where reconstruction

is impossible,

the editor

treats

the embroidery

as

```text
Stitch Objects
```

rather than

high-level artwork.

---

# Machine Extensions

Many embroidery formats

contain

manufacturer-specific

extensions.

Unknown extensions

must be preserved

whenever possible.

The importer

must never

silently discard

recognized data.

---

# Metadata Import

Supported metadata

includes

```text
Design Name

Author

Creation Date

Thread Catalog

Machine Brand

Comments
```

Metadata

is optional.

---

# Validation

Validation checks

```text
Corrupt File

Invalid Commands

Unsupported Version

Coordinate Overflow

Unknown Sections

Incomplete Stitch Stream
```

Import

should recover

whenever possible.

---

# Diagnostics

Import diagnostics

may report

```text
Unsupported Commands

Recovered Sections

Unknown Extensions

Palette Warnings

Precision Loss
```

Diagnostics

never modify

imported embroidery.

---

# Editing

Imported embroidery

remains editable

at the stitch level.

Higher-level editing

depends upon

available reconstruction.

---

# Optimization

Imported embroidery

may later

be optimized

through

the Optimization Pipeline.

Optimization

is never performed

during import.

---

# Extensibility

Additional embroidery formats

may be implemented

through

the Plugin System.

Each importer

implements

the common

Embroidery Import Interface.

---

# Thread Safety

Embroidery import

is isolated.

Multiple files

may be imported

concurrently.

Importers

must not

share mutable state.

---

# Performance

The Embroidery Import System

shall support

```text
Millions of Stitches

Large Commercial Designs

Batch Import

Incremental Parsing

Parallel Import
```

while maintaining

responsive editing.

---

# Domain Rules

The following always apply.

- Import never recreates original artwork.
- Imported stitch order is preserved.
- All embroidery formats convert into the Embroidery Intermediate Representation.
- Unknown commands are preserved whenever possible.
- Import never performs optimization.
- Imported embroidery remains editable at the stitch level.
- Import is deterministic.
- Machine-specific data is normalized.
- Import remains machine-independent after conversion.
- Embroidery documents remain format-neutral after import.

---

# Out of Scope

This document does not define

- embroidery optimization
- stitch regeneration
- vector reconstruction
- AI reverse digitizing
- machine execution

These are covered in later documents.

---

# Future Topics

Future import documents expand

```text
AI Reverse Digitizing

Object Reconstruction

Vector Recovery

Batch Migration

Cloud Import

Live Machine Synchronization

Design Intelligence
```

---

# Acceptance Criteria

The Embroidery Import specification is complete when

✓ Embroidery import responsibilities are separated from optimization and editing.

✓ Supported embroidery formats are documented.

✓ Stitch, command, and machine normalization are specified.

✓ Embroidery Intermediate Representation (EIR) is established.

✓ Sequence preservation and editable stitch reconstruction are defined.

✓ Metadata, diagnostics, and validation workflows are documented.

✓ Plugin-based importer extensibility is specified.

✓ Deterministic, machine-independent import behavior is established.

✓ Domain rules preserve original manufacturing intent.

✓ The Embroidery Import System provides the canonical entry point for all embroidery machine files entering Sewlio Studio.
