# Domain
## DOM-701 Raster Import

**Document ID:** DOM-701  
**Title:** Raster Import  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Import & Conversion Team

**Related Documents**

```text
DOM-100 Coordinate System
DOM-104 Bounding Boxes
DOM-105 Geometry Algorithms

DOM-200 Stitch Theory

DOM-700 Vector Import

ARCH-009 Digitizer Pipeline
ARCH-012 Import Pipeline
ARCH-013 Plugin Architecture
ARCH-014 AI Runtime
ARCH-019 Error Handling
```

---

# Purpose

This document defines the Raster Import System used by Sewlio Studio.

The Raster Import System imports bitmap artwork into the document as editable raster assets.

Raster images are treated as source artwork for tracing, manual digitizing, AI-assisted analysis, and future vectorization.

Raster import never performs automatic embroidery generation.

---

# Philosophy

Raster artwork

is reference material,

not embroidery.

```text
Raster Image

↓

Import

↓

Image Asset

↓

Tracing

↓

Vector

↓

Digitizing

↓

Embroidery
```

Importing an image

must never

implicitly generate stitches.

---

# Goals

The Raster Import System shall provide

- High-quality image import
- Lossless asset preservation
- Efficient image management
- AI-ready image pipeline
- Extensible importer architecture
- Deterministic behavior

---

# Definition

Raster Import converts supported bitmap formats into internal image assets.

Imported images remain

```text
Editable

Positionable

Transformable

Referenceable
```

Images are not converted into vectors or stitches during import.

---

# Responsibilities

The Raster Import System performs

- image decoding
- metadata extraction
- color profile extraction
- orientation correction
- asset registration
- document placement

It does **not** perform

- vectorization
- auto-digitizing
- stitch generation
- image enhancement
- background removal

---

# Import Pipeline

```text
Raster File

↓

Image Decoder

↓

Raster Asset

↓

Document Placement

↓

Editor
```

Import always precedes

vectorization

or

digitizing.

---

# Supported Formats

Built-in support includes

```text
PNG

JPEG

TIFF

BMP

GIF

WebP

HEIF

AVIF
```

Additional formats

may be added

through plugins.

---

# Image Asset Model

Each imported image contains

```text
Identifier

Dimensions

Resolution

Color Space

Pixel Format

Orientation

Metadata

Source Reference
```

The image asset

is immutable.

---

# Pixel Formats

Supported formats

include

```text
RGB

RGBA

Grayscale

CMYK*

Indexed Color*

```

Internal processing

uses

RGBA.

---

# Color Spaces

Supported color spaces

```text
sRGB

Adobe RGB

Display P3

Linear RGB

CMYK*
```

Images are converted

into

the internal working color space.

---

# Resolution

Image resolution

includes

```text
Pixel Width

Pixel Height

DPI

Physical Size
```

Resolution

does not affect

geometry.

---

# Transparency

Raster images

may contain

```text
Alpha Channel

Transparency Mask

Fully Transparent Pixels
```

Transparency

is preserved.

---

# Orientation

Image orientation

is determined

using

```text
EXIF Metadata

Embedded Rotation

Manual Overrides
```

Orientation correction

occurs

during import.

---

# Metadata Import

Supported metadata

includes

```text
Author

Camera

Creation Date

Copyright

Comments

Color Profile

EXIF

XMP
```

Metadata

is optional.

---

# Placement

Imported images

are placed

within the document

using

```text
Position

Scale

Rotation

Opacity

Visibility
```

Placement

does not modify

the image asset.

---

# Transformations

Images support

```text
Translation

Rotation

Scaling

Mirroring

Cropping*
```

*Cropping is non-destructive.

Transforms

remain editable.

---

# Layer Integration

Raster assets

may be placed

inside

logical document layers.

Layer ordering

determines

rendering order.

---

# Reference Artwork

Imported raster images

are primarily intended

for

```text
Manual Tracing

AI Analysis

Vectorization

Reference

Background Artwork
```

They remain

independent

of embroidery objects.

---

# Vectorization

Raster images

may later

be converted

into vectors.

Vectorization

is a separate process

defined independently

of raster import.

---

# AI Integration

Raster images

may be analyzed

by future AI systems

for

```text
Object Detection

Artwork Cleanup

Background Removal

Color Reduction

Vector Suggestions

Embroidery Recommendations
```

AI analysis

never modifies

the original image.

---

# Image Cache

Decoded images

may be cached

to improve

editor responsiveness.

Caching

is transparent

to users.

---

# Resource Management

Large images

may be stored

using

streaming

or

tiled loading

to reduce

memory usage.

Resource management

is handled

by the Runtime.

---

# Validation

Validation checks

```text
Unsupported Format

Corrupt File

Invalid Metadata

Color Profile Errors

Oversized Images

Memory Limits
```

Import

should recover

whenever possible.

---

# Diagnostics

Import diagnostics

may report

```text
Unsupported Metadata

Resolution Warnings

Large Image Warning

Missing Color Profile

Transparency Issues
```

Diagnostics

never alter

the imported image.

---

# Extensibility

Additional raster formats

may be implemented

through

the Plugin System.

Each importer

implements

the common

Raster Import Interface.

---

# Thread Safety

Raster import

is isolated.

Multiple images

may be imported

concurrently.

Importers

must not

share mutable state.

---

# Performance

The Raster Import System

shall support

```text
Very Large Images

High-Resolution Artwork

Batch Import

Incremental Loading

Parallel Decoding
```

while maintaining

interactive editing.

---

# Domain Rules

The following always apply.

- Raster import never creates embroidery.
- Imported images remain immutable assets.
- Placement is independent of the image asset.
- Images remain editable through transforms.
- Vectorization is a separate process.
- AI analysis never modifies the original image.
- Import is deterministic.
- Image resources are managed independently from document geometry.
- Raster assets remain machine-independent.
- Import is independent of digitizing.

---

# Out of Scope

This document does not define

- vectorization
- background removal
- AI artwork enhancement
- raster-to-stitch conversion
- embroidery import

These are covered in later import documents.

---

# Future Topics

Future import documents expand

```text
Raster Vectorization

AI Cleanup

Background Removal

Cloud Image Libraries

Live Image Linking

Smart Cropping

Image Enhancement
```

---

# Acceptance Criteria

The Raster Import specification is complete when

✓ Raster import responsibilities are separated from vectorization and digitizing.

✓ Supported raster formats are documented.

✓ Image asset model and metadata handling are specified.

✓ Color space, resolution, transparency, and orientation handling are defined.

✓ Layer integration and transform behavior are documented.

✓ AI integration is introduced without modifying original assets.

✓ Validation and diagnostics workflows are specified.

✓ Plugin-based importer extensibility is established.

✓ Domain rules preserve immutable, machine-independent image assets.

✓ The Raster Import System provides the canonical entry point for all bitmap artwork entering Sewlio Studio.
