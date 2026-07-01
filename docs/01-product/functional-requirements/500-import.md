# Functional Requirements
## FR-500 Import System

**Document ID:** FR-500  
**Title:** Import System  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Import Pipeline Team

**Primary Packages**

```text
Rust

import/
svg/
image/
geometry/
document/
assets/
validation/

↓

Flutter

import_ui/
asset_browser/
wizard/
preview/
```

---

# Purpose

The Import System is responsible for bringing external content into Sewlio Studio.

Import is the first step of many user workflows.

The system must be:

- Safe
- Deterministic
- Recoverable
- Non-destructive
- Extensible

Imported content should become native Sewlio Studio objects.

---

# Design Philosophy

Import should never be considered "opening" another format.

Import always means

```
External Data

↓

Parser

↓

Normalizer

↓

Validation

↓

Sewlio Studio Document Model
```

After import, the application no longer depends on the original file.

---

# Core Principles

## Non-destructive

Original files are never modified.

---

## Read-only

Importers never write back.

---

## Extensible

Every format is implemented independently.

---

## Recoverable

Import errors never corrupt projects.

---

## Incremental

Large imports should stream whenever practical.

---

# Import Pipeline

```text
User File

↓

File Detection

↓

Parser

↓

Validation

↓

Normalization

↓

Asset Generation

↓

Document Creation

↓

Canvas
```

---

# Import Categories

## MVP

SVG

PNG

JPEG

---

## Public Alpha

WEBP

GIF (static)

TIFF

---

## Professional

DXF

PDF (vector)

---

## Future

AI (Illustrator)

EPS

CDR (CorelDRAW)

EMF

WMF

PSD (reference)

Affinity formats (evaluation)

---

# Import Workflow

```text
Choose File

↓

Detect Type

↓

Validate

↓

Import Options

↓

Parse

↓

Normalize

↓

Create Objects

↓

Report

↓

Editor
```

---

# Import Wizard

The import wizard should be shown whenever user intervention is required.

Possible steps

- File preview
- Scaling
- Positioning
- SVG options
- Image options
- Unsupported element report

---

# File Detection

The system should detect

Extension

↓

MIME Type

↓

File Signature (Magic Bytes)

Validation should not rely solely on filename extensions.

---

# Supported SVG

## FR-501

Priority

Critical

---

Purpose

Import SVG artwork.

---

Supported

Paths

Groups

Rectangles

Ellipses

Lines

Polygons

Polylines

Transforms

Basic Text

Fill

Stroke

Opacity

---

Future

Filters

Masks

Patterns

Gradients

Symbols

---

Acceptance Criteria

✓ Geometry preserved

✓ Groups preserved

✓ Transforms preserved

✓ Unsupported features reported

✓ No application crash

---

# SVG Parsing

Parser should

Validate XML

Resolve transforms

Resolve groups

Convert coordinates

Normalize units

Resolve colors

---

SVG parser should not directly create Flutter objects.

It creates Rust geometry.

---

# SVG Units

Support

px

mm

cm

pt

pc

in

em (best effort)

---

Internal conversion

↓

Millimeters

---

# SVG Colors

Support

RGB

RGBA

HEX

Named Colors

CurrentColor

Opacity

---

Thread mapping happens later.

---

# SVG Text

MVP

Basic text.

---

Future

Font substitution

Text outlines

OpenType

Variable fonts

---

Missing fonts

↓

Warning

↓

Import continues

---

# Unsupported SVG

Examples

Filters

Animations

JavaScript

External CSS

Embedded video

---

Behavior

Warn

↓

Continue

---

Never fail entire import because of one unsupported feature.

---

# Image Import

## FR-502

Priority

Critical

---

Supported

PNG

JPEG

---

Imported as

Reference Image

---

Reference images

Cannot export.

Cannot digitize automatically.

Remain editable.

---

Properties

Opacity

Lock

Visibility

Transform

---

Acceptance Criteria

✓ Image displays correctly

✓ Stored inside project

✓ Editable transform

---

# Image Scaling

Supports

Original Size

Fit Hoop

Fit Artwork

Custom Scale

---

Future

DPI aware scaling.

---

# Transparency

PNG alpha

Supported.

---

JPEG

Opaque.

---

# Asset Management

Imported assets stored

```
assets/

image.png

logo.svg

photo.jpg
```

---

Projects remain portable.

Never reference original location.

---

# Duplicate Assets

Import identical asset

↓

Hash Comparison

↓

Reuse existing asset

↓

Or

Create duplicate (user option)

---

# Validation

Validation levels

Healthy

↓

Warning

↓

Recoverable

↓

Error

---

Examples

Corrupt SVG

↓

Error

---

Missing Image

↓

Error

---

Unsupported Filter

↓

Warning

---

# Import Report

Every import generates report.

Contains

Imported Objects

Warnings

Errors

Skipped Items

Time Taken

---

User may ignore report.

---

# Import Preview

Future

Preview before commit.

Allows

Scale

Position

Rotation

Layer

---

# Placement

Imported objects placed

Canvas Center

Default Layer

---

Future

User chooses layer.

---

# Layer Assignment

Options

Current Layer

New Layer

Imported Layer

---

# Coordinate Normalization

Convert all coordinates

↓

Millimeters

↓

Internal Geometry

---

Avoid cumulative floating-point errors.

---

# Geometry Cleanup

Optional future

Merge duplicate nodes

Simplify paths

Remove zero-length segments

Close nearly closed paths

---

MVP

Only validation.

---

# Batch Import

Future

Multiple SVGs

↓

Multiple layers

---

Directory import

Future.

---

# Clipboard Import

Supports

Paste SVG

Paste Image

Paste Vector

---

Future

System clipboard interoperability.

---

# Drag and Drop

Desktop

Supports

SVG

PNG

JPEG

Project

---

Dragging onto canvas

↓

Import

---

Dragging project

↓

Open Project

---

# Image Tracing

Future

Manual tracing

↓

Auto tracing

↓

AI tracing

---

Reference image never modified.

---

# PDF Import

Future

Extract vector paths.

Raster pages become reference images.

---

# DXF Import

Future

Mechanical embroidery workflows.

---

# Illustrator Import

Future

Preferred approach

Import exported PDF/SVG.

Native AI support evaluated separately.

---

# Font Import

Future

Load custom fonts.

Convert to vector.

---

# Performance Targets

SVG

10,000 paths

<500 ms

---

Large SVG

100 MB

Graceful progress

---

PNG

50 MB

<1 second

---

Import must remain asynchronous.

---

# Error Handling

Invalid XML

↓

Readable error

↓

Cancel

---

Unsupported Feature

↓

Warning

↓

Continue

---

Corrupt Image

↓

Readable error

↓

Cancel

---

Import interrupted

↓

Rollback

↓

Project unchanged

---

# Security

Never execute

JavaScript

Scripts

External references

Embedded code

---

External URLs ignored.

---

Import sandboxed.

---

# Accessibility

Import wizard

Keyboard

Touch

Stylus

Screen reader

High contrast

---

Import report

Fully accessible.

---

# AI Agent Rules

Import package owns

Parsing

Normalization

Validation

Asset creation

Import report

---

Import package never owns

Canvas

Flutter widgets

Digitization

Simulation

Export

---

Geometry package owns

Shapes

Curves

Transforms

---

Assets package owns

Storage

Deduplication

Metadata

---

# Testing

Unit

SVG parser

Image parser

Validation

Normalization

Asset storage

---

Golden

Known SVG

↓

Known Geometry

---

Integration

SVG

↓

Document

↓

Canvas

↓

Digitizer

---

Performance

Large SVG

Large image

Batch import

---

Regression

Previously supported SVGs continue importing identically.

---

# Acceptance Criteria

Import System is complete when

✓ SVG imports correctly

✓ PNG imports correctly

✓ JPEG imports correctly

✓ Assets become portable

✓ Unsupported features reported

✓ Import never corrupts project

✓ Import asynchronous

✓ Geometry normalized

✓ Tests pass

---

# Future Enhancements

- AI vectorization
- Background removal
- Auto cleanup
- PDF vector extraction
- DXF workflows
- Illustrator compatibility
- Batch asset library import
- Cloud asset references
- Smart duplicate detection
- Asset versioning
- Live linked assets
