# Architecture
## ARCH-015 Import Pipeline

**Document ID:** ARCH-015  
**Title:** Import Pipeline  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Import Engine Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-002 Data Flow
ARCH-003 Command System
ARCH-005 Document Model
ARCH-009 Digitizer Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
ARCH-013 Plugin Architecture
```

---

# Purpose

The Import Pipeline is responsible for converting external file formats into the platform's internal **Geometry IR**, **Stitch IR**, or **Project Model**, depending on the source format.

Import is the inverse of Export.

It is the first compiler in the platform.

---

# Philosophy

The Import Pipeline never edits an existing project directly.

Instead, it compiles external data into internal representations that can be:

- Previewed
- Validated
- Merged
- Imported
- Rejected

The user always remains in control.

---

# Compiler Chain

```text
External File

↓

File Detection

↓

Parser

↓

Import IR

↓

Normalization

↓

Validation

↓

Internal IR

↓

Import Commands

↓

Project
```

---

# Supported Import Types

The Import Pipeline supports multiple import categories.

## Project Import

```text
.embproj
```

Produces

```text
Project Model
```

---

## Geometry Import

```text
SVG

DXF

PDF

AI (future)

EPS (future)
```

Produces

```text
Geometry IR
```

---

## Raster Import

```text
PNG

JPEG

WEBP

BMP

TIFF
```

Produces

```text
Image Assets
```

Raster images are not digitized automatically.

---

## Embroidery Import

```text
DST

PES

JEF

VP3

EXP

HUS

PCS

XXX
```

Produces

```text
Stitch IR
```

Not Geometry IR.

---

## Asset Import

```text
Thread Libraries

Machine Profiles

Templates

Fabric Profiles

Plugins
```

Produces platform resources.

---

# Design Principles

## Read Only

Import never modifies source files.

---

## Deterministic

Same input

↓

Same IR

---

## Non-destructive

Imported data is previewed before insertion.

---

## Recoverable

Failed imports never modify projects.

---

## Extensible

Plugins may register new importers.

---

# High-Level Architecture

```text
Import Manager

↓

Importer Registry

↓

Importer

↓

Parser

↓

Import IR

↓

Normalizer

↓

Validator

↓

Importer Commands
```

---

# Import Manager

Coordinates all imports.

Responsible for

- format detection
- importer selection
- progress
- cancellation
- diagnostics
- preview generation

Contains no parser logic.

---

# Importer Registry

Importers register themselves.

```text
Registry

↓

SVG Importer

↓

DST Importer

↓

PDF Importer

↓

PNG Importer

↓

Plugin Importers
```

---

# Import Context

Every import receives

```text
Source File

Workspace

Project

Preferences

Machine Profile

Thread Library
```

Importers never access UI state.

---

# File Detection

Detection uses

```text
Extension

↓

Magic Bytes

↓

Signature

↓

Importer Selection
```

Extensions alone are never trusted.

---

# Parsing Stage

Each importer parses into Import IR.

```text
SVG

↓

SVG Parser

↓

Import IR
```

The parser never creates project objects.

---

# Import IR

Import IR is a temporary representation.

Contains

```text
Objects

Layers

Metadata

Images

Transforms

Colors

Warnings
```

Import IR is disposable.

---

# Normalization

Converts Import IR into platform conventions.

Examples

- Coordinate normalization
- Unit conversion
- Layer normalization
- Color normalization
- Font normalization
- Metadata normalization

---

# Validation

Validation checks

```text
Unsupported Features

Corrupt Data

Missing Assets

Invalid Geometry

Version Compatibility

Security Rules
```

Produces diagnostics.

---

# Preview Generation

Every importer should generate a preview.

```text
Import IR

↓

Preview Scene

↓

Render

↓

User Preview
```

The user may choose

- Import
- Cancel
- Configure

---

# Import Options

Importers may expose options.

Examples

## SVG

```text
Scale

Flatten Transforms

Convert Text

Import Hidden Layers
```

---

## Raster

```text
Scale

DPI

Transparency

Color Reduction
```

---

## Embroidery

```text
Thread Mapping

Machine Mapping

Color Mapping

Preserve Stops

Import Trims
```

---

# Merge Strategy

User chooses

```text
Replace

Merge

Append

New Layer

New Project
```

Import never assumes.

---

# Geometry Import

Produces

```text
Geometry IR

↓

Commands

↓

Document
```

No stitches are generated.

Digitizer runs separately.

---

# Embroidery Import

Produces

```text
Stitch IR

↓

Commands

↓

Project
```

Original stitch information is preserved whenever possible.

Geometry reconstruction is optional.

---

# Raster Import

Produces

```text
Image Asset

↓

Asset Registry

↓

Workspace
```

Image digitization is a separate workflow.

---

# Asset Import

Resources become managed resources.

Examples

```text
Thread Libraries

Machine Profiles

Fabric Profiles

Templates
```

Imported through the Resource Manager.

---

# Command Integration

Import never mutates the project directly.

Workflow

```text
Import

↓

Commands

↓

Command Bus

↓

Project
```

Undo works automatically.

---

# Diagnostics

Import diagnostics include

```text
Unsupported Feature

Missing Font

Missing Thread

Corrupt Data

Version Mismatch

Security Warning

Recovery Suggestion
```

---

# Security

Import validates

- file signatures
- schema versions
- plugin trust
- malformed data
- archive traversal
- oversized files

Unsafe files are rejected.

---

# Cancellation

Supports

```text
Open

↓

Parsing

↓

Cancel

↓

Cleanup
```

No partial project state remains.

---

# Progress

Progress stages

```text
Detection

↓

Parsing

↓

Normalization

↓

Validation

↓

Preview

↓

Ready
```

---

# Plugin Integration

Plugins may register

```text
New Importers

Validators

Normalizers

Preview Providers

Import Options
```

Import Manager discovers them automatically.

---

# Performance Targets

```text
Detection

<20 ms

Small SVG

<100 ms

Medium SVG

<500 ms

Large Project

<3 s

Preview

Background

Cancellation

Immediate
```

---

# Thread Safety

Importers are

Read-only

Parallel

Worker-thread friendly

Deterministic

---

# Testing

Each importer requires

- parser tests
- malformed input tests
- version compatibility tests
- normalization tests
- preview tests
- cancellation tests
- performance benchmarks
- golden import fixtures

---

# AI Integration

AI may assist with

- thread mapping
- color mapping
- import settings
- unsupported feature explanations
- geometry cleanup suggestions

AI never parses files.

---

# AI Agent Rules

Import owns

- parsing
- normalization
- validation
- preview generation
- command generation

Import never owns

- digitizing
- rendering
- export
- simulation
- machine compilation

---

# Architectural Constraints

1. Importers never modify source files.
2. Every importer produces Import IR first.
3. Validation occurs before project mutation.
4. Import generates Commands only.
5. Geometry and embroidery import paths remain separate.
6. Preview is generated before commit.
7. Plugin importers use the same framework.
8. Import is independently testable.
9. Import is deterministic.
10. Import integrates with Undo/Redo through the Command Bus.

---

# Future Enhancements

- Streaming imports
- Cloud imports
- URL imports
- ZIP package imports
- Batch imports
- AI-assisted geometry cleanup
- OCR-assisted embroidery templates
- CAD interoperability
- Manufacturing package import
- Incremental project merging

---

# Acceptance Criteria

The Import Pipeline is complete when

✓ External formats are parsed into Import IR.

✓ Geometry, embroidery, raster, project, and asset imports are supported through dedicated importers.

✓ Validation occurs before project mutation.

✓ Preview is available before committing changes.

✓ Import integrates with the Command Bus.

✓ Plugin importers can be registered dynamically.

✓ Import operations are cancellable, deterministic, and independently testable.

✓ Unsupported or unsafe files are rejected gracefully.

✓ Import preserves as much source information as possible.

✓ Import remains fully separated from digitizing, rendering, and export.
