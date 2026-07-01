# Domain
## DOM-700 Vector Import

**Document ID:** DOM-700  
**Title:** Vector Import  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Import & Conversion Team

**Related Documents**

```text
DOM-100 Coordinate System
DOM-101 Paths
DOM-102 Curves
DOM-103 Transformations
DOM-104 Bounding Boxes
DOM-105 Geometry Algorithms

DOM-200 Stitch Theory

ARCH-009 Digitizer Pipeline
ARCH-012 Import Pipeline
ARCH-013 Plugin Architecture
ARCH-019 Error Handling
ARCH-029 Build System
```

---

# Purpose

This document defines the Vector Import System used by Sewlio Studio.

The Vector Import System converts external vector artwork into the platform's internal vector representation.

Imported vectors become editable geometric objects that can later be digitized into embroidery objects.

The import process is completely independent from embroidery generation.

---

# Philosophy

Importing

is not digitizing.

```text
Vector File

↓

Import

↓

Geometry

↓

Editing

↓

Digitizing

↓

Embroidery
```

Vector import preserves artwork.

Digitizing creates stitches.

These are separate responsibilities.

---

# Goals

The Vector Import System shall provide

- High-fidelity vector import
- Lossless geometry conversion
- Editable vector objects
- Extensible importer architecture
- Deterministic parsing
- Format-independent geometry

---

# Definition

Vector Import converts supported vector formats into the internal Geometry Model.

The resulting document contains

```text
Paths

Curves

Shapes

Groups

Layers

Colors

Transforms

Metadata
```

No embroidery information

is created during import.

---

# Responsibilities

The Vector Import System performs

- file parsing
- geometry conversion
- coordinate conversion
- style extraction
- layer construction
- metadata extraction

It does **not** perform

- auto-digitizing
- stitch generation
- optimization
- machine compilation

---

# Import Pipeline

```text
Vector File

↓

File Parser

↓

Intermediate Representation

↓

Geometry Conversion

↓

Internal Document

↓

Editor
```

Import always precedes

digitizing.

---

# Supported Formats

Built-in support includes

```text
SVG

PDF (Vector)

EPS

AI*

DXF

CGM

WMF

EMF
```

*AI support is limited to publicly documented vector content.

Additional formats

may be provided

through plugins.

---

# Import Architecture

Each file format

implements

a dedicated importer.

```text
Importer

↓

Parser

↓

IR Builder

↓

Geometry Converter

↓

Document Builder
```

Importers

share

the same output model.

---

# Intermediate Representation

Every importer

produces

a common

Import Intermediate Representation (IIR).

The IIR contains

```text
Geometry

Styles

Layers

Transforms

Metadata

Resources
```

The editor

never consumes

format-specific data.

---

# Geometry Conversion

Supported geometry

includes

```text
Lines

Polylines

Bezier Curves

Quadratic Curves

Circular Arcs

Elliptical Arcs

Compound Paths
```

All geometry

is converted

into

the internal geometry model.

---

# Shape Conversion

Primitive shapes

are normalized.

Examples

```text
Rectangle

Circle

Ellipse

Polygon

Star

Rounded Rectangle
```

Each primitive

becomes

editable geometry.

---

# Coordinate Conversion

Imported coordinates

are converted

into

the document coordinate system.

Conversion includes

```text
Units

Origin

Axis Direction

Scale

Precision
```

The original coordinates

remain available

for diagnostics.

---

# Unit Conversion

Supported units

include

```text
Millimeters

Inches

Pixels

Points

Picas

Centimeters
```

Internally,

Sewlio Studio

uses

millimeters.

---

# Transform Conversion

Imported transforms

are preserved.

Supported transforms

```text
Translation

Rotation

Scaling

Shearing

Matrix Transform
```

Transforms

may optionally

be flattened

during import.

---

# Layer Import

Layers

are imported

as logical document layers.

Layer hierarchy

is preserved

when possible.

---

# Group Import

Groups

are converted

into

logical object groups.

Nested groups

remain intact.

---

# Style Import

Supported styles

include

```text
Fill Color

Stroke Color

Stroke Width

Opacity

Gradient*

Pattern*

Visibility
```

*Gradients and patterns

may be approximated

depending on format.

Styles

are editable.

---

# Text Import

Supported text

includes

```text
Unicode Text

Position

Transform

Alignment

Font Reference
```

Text remains editable

whenever possible.

If required,

text may be converted

into paths.

---

# Image References

Vector documents

may reference

embedded

or linked images.

Images become

document assets

without modification.

Raster images

are not converted

into embroidery.

---

# Metadata Import

Imported metadata

may include

```text
Document Name

Author

Creation Date

Modification Date

Application

Comments

Custom Properties
```

Metadata

is optional.

---

# Precision

Geometry conversion

must preserve

numerical precision.

Import shall avoid

unnecessary

loss of accuracy.

---

# Color Preservation

Imported colors

must preserve

their original values.

Supported color models

```text
RGB

RGBA

CMYK*

Spot Colors*

```

Internal conversion

uses

RGBA.

---

# Unsupported Features

Unsupported features

must never

prevent import.

Examples

```text
Blend Modes

Live Effects

Procedural Shapes

Application Metadata

Plugins
```

The importer

shall produce

warnings,

not failures,

when possible.

---

# Validation

Validation checks

```text
Corrupt File

Unsupported Version

Invalid Geometry

Missing Resources

Transform Errors

Encoding Errors
```

Import

should recover

whenever possible.

---

# Diagnostics

Import diagnostics

may report

```text
Warnings

Ignored Features

Geometry Repairs

Precision Loss

Unsupported Objects
```

Diagnostics

never modify

imported geometry.

---

# Extensibility

New importers

may be added

through

the Plugin System.

Each importer

implements

the common

Importer Interface.

---

# Thread Safety

Import operations

are isolated.

Multiple files

may be imported

concurrently.

Importers

must not

share mutable state.

---

# Performance

The Vector Import System

shall support

```text
Large Documents

Thousands of Layers

Millions of Curves

Incremental Parsing

Parallel Import
```

while maintaining

responsive editing.

---

# Domain Rules

The following always apply.

- Import is independent of digitizing.
- Imported geometry remains editable.
- All formats convert into a common geometry model.
- Importers are deterministic.
- Styles are preserved whenever possible.
- Unsupported features generate diagnostics rather than failures.
- Import never generates stitches.
- Geometry precision is preserved.
- Import is machine-independent.
- Imported documents remain format-neutral after conversion.

---

# Out of Scope

This document does not define

- auto-digitizing
- raster tracing
- embroidery import
- machine file parsing
- AI-assisted vector cleanup

These are covered in later import documents.

---

# Future Topics

Future import documents expand

```text
Raster Import

Embroidery Import

AI Vector Cleanup

Batch Import

Cloud Import

Live File Linking

Version Synchronization
```

---

# Acceptance Criteria

The Vector Import specification is complete when

✓ Vector import responsibilities are clearly separated from digitizing.

✓ Supported vector formats are documented.

✓ Geometry, transform, layer, and style conversion are specified.

✓ Coordinate and unit conversion are defined.

✓ Validation and diagnostics behavior is documented.

✓ Intermediate Representation architecture is established.

✓ Plugin-based importer extensibility is specified.

✓ Deterministic, lossless import behavior is established.

✓ Domain rules preserve editable, machine-independent geometry.

✓ The Vector Import System provides the canonical entry point for all vector artwork entering Sewlio Studio.
