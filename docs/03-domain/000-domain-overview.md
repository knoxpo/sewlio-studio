# Domain
## DOM-000 Domain Overview

**Document ID:** DOM-000  
**Title:** Domain Overview  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Product & Domain Team

**Related Documents**

```text
01-product/*
02-architecture/*

03-domain/*
```

---

# Purpose

This document defines the common vocabulary, concepts, and terminology used throughout Sewlio Studio.

It is the authoritative reference for understanding the embroidery domain.

All architecture, implementation, documentation, AI agents, plugins, and user interfaces must use these definitions consistently.

This document intentionally describes **the business domain**, not software implementation.

---

# Scope

This document defines:

- Core concepts
- Domain terminology
- Relationships
- Hierarchies
- Life cycle
- Manufacturing concepts
- Digital embroidery concepts

Implementation details belong in the Architecture section.

---

# Domain Philosophy

Sewlio Studio is built around one simple concept:

> A design evolves through multiple representations until it becomes machine instructions.

The lifecycle is

```text
Idea

↓

Design

↓

Geometry

↓

Embroidery

↓

Simulation

↓

Machine Instructions

↓

Physical Embroidery
```

Every stage adds information.

Nothing is discarded unnecessarily.

---

# Domain Hierarchy

```text
Workspace
    │
    ├── Projects
    │      │
    │      ├── Documents
    │      │      │
    │      │      ├── Layers
    │      │      │      │
    │      │      │      ├── Objects
    │      │      │      │      │
    │      │      │      │      ├── Geometry
    │      │      │      │      └── Embroidery
    │      │      │
    │      │      └── Assets
    │      │
    │      └── Resources
    │
    └── Preferences
```

---

# Core Concepts

## Workspace

A Workspace represents the user's working environment.

It contains

- preferences
- layouts
- windows
- panels
- recent files
- AI conversations
- temporary state

A Workspace is **not** a project.

---

## Project

A Project is the primary unit of work.

It contains

- one or more documents
- project metadata
- assets
- references
- manufacturing settings

A Project can be opened, saved, exported, and shared.

---

## Document

A Document represents one embroidery design.

A Project may contain multiple documents.

Examples

```text
Front Logo

Back Logo

Left Sleeve

Right Sleeve
```

Documents are independent but may share resources.

---

## Layer

A Layer organizes objects.

Layers provide

- visibility
- locking
- grouping
- ordering

Layers do not affect embroidery by themselves.

---

## Object

An Object is the smallest editable design element.

Examples

```text
Circle

Letter

Flower

Border

Logo

Image
```

Objects may contain

- geometry
- embroidery
- metadata

---

## Geometry

Geometry describes shape.

Examples

```text
Points

Lines

Curves

Paths

Polygons

Transforms
```

Geometry is machine-independent.

---

## Embroidery Object

An Embroidery Object represents stitchable content.

Examples

```text
Running Stitch

Satin

Fill

Motif

Bean Stitch
```

Embroidery Objects are generated from Geometry.

---

## Stitch

A Stitch is the smallest manufacturing instruction.

A stitch connects two points.

Properties include

- position
- length
- direction
- color
- needle
- machine flags

---

## Stitch Sequence

A Stitch Sequence is an ordered list of stitches.

It represents the sewing path.

Sequence order directly affects

- quality
- efficiency
- thread usage
- production time

---

## Thread

Thread represents embroidery material.

Properties

```text
Color

Brand

Weight

Material

Thickness

Finish
```

Thread affects manufacturing quality.

---

## Needle

A Needle is the physical tool used by the embroidery machine.

Needles may have

- size
- type
- assigned thread
- machine position

---

## Machine

A Machine executes embroidery.

Machine capabilities vary.

Examples

```text
Maximum Speed

Maximum Hoop

Needle Count

Supported Commands

Supported Formats
```

---

## Hoop

A Hoop defines the embroidery working area.

Constraints

- width
- height
- rotation
- safe sewing region

Designs must fit within hoop limits.

---

## Fabric

Fabric is the embroidery substrate.

Properties include

```text
Stretch

Thickness

Material

Weight

Stability
```

Fabric influences digitizing decisions.

---

## Stabilizer

A Stabilizer supports fabric during embroidery.

Examples

```text
Cut Away

Tear Away

Wash Away

Heat Away
```

Different fabrics require different stabilizers.

---

## Machine Profile

A Machine Profile describes machine capabilities.

Contains

- commands
- limits
- thread behavior
- hoop support
- format support

Machine Profiles are independent of projects.

---

## Thread Library

A Thread Library defines available thread colors.

Examples

```text
Madeira

Isacord

Robison-Anton

Brother

Gunold
```

Projects reference libraries rather than duplicating them.

---

## Simulation

Simulation visualizes embroidery before manufacturing.

Simulation is not manufacturing.

Simulation approximates

- stitch order
- needle motion
- thread appearance
- timing

---

## Export

Export transforms a design into machine-readable output.

Examples

```text
DST

PES

JEF

VP3

EXP

HUS
```

Export never modifies the design.

---

# Design Lifecycle

Every embroidery design progresses through stages.

```text
Concept

↓

Geometry

↓

Embroidery

↓

Optimization

↓

Simulation

↓

Machine Compilation

↓

Export

↓

Manufacturing
```

Each stage enriches the design.

---

# Coordinate Systems

The platform uses multiple coordinate spaces.

```text
Document Space

↓

Layer Space

↓

Object Space

↓

Machine Space

↓

Needle Space
```

Conversions are deterministic.

---

# Resources

Resources are reusable assets.

Examples

```text
Thread Libraries

Machine Profiles

Fonts

Templates

Images

Fabric Profiles
```

Projects reference resources.

Resources are managed independently.

---

# Assets

Assets belong to projects.

Examples

```text
Reference Images

Embedded Fonts

Custom Palettes

Imported Artwork
```

Assets may be embedded or linked.

---

# Manufacturing Concepts

Important manufacturing concepts include

- stitch density
- pull compensation
- push compensation
- underlay
- trims
- jump stitches
- tie-in
- tie-off
- sequencing
- travel optimization

These are explained in later documents.

---

# Quality

Embroidery quality depends on

- geometry
- stitch generation
- sequencing
- density
- thread
- fabric
- machine
- operator

Quality is a domain concern.

---

# Domain Relationships

```text
Geometry

↓

Embroidery Object

↓

Stitches

↓

Machine Instructions

↓

Embroidery Machine

↓

Fabric
```

Each stage depends on the previous one.

---

# Domain Rules

The following principles always apply.

- Geometry is independent of machines.
- Embroidery is generated from geometry.
- Machine instructions are generated from embroidery.
- Resources are shared.
- Projects reference resources.
- Simulation never changes the design.
- Export never changes the design.
- Manufacturing always follows stitch order.

---

# Shared Terminology

The following terms have precise meanings throughout the platform.

| Term | Definition |
|------|------------|
| Workspace | User working environment |
| Project | Collection of embroidery work |
| Document | One embroidery design |
| Layer | Organizational grouping |
| Object | Editable design element |
| Geometry | Mathematical shape |
| Embroidery Object | Stitchable representation |
| Stitch | Smallest manufacturing operation |
| Thread | Embroidery material |
| Needle | Machine sewing tool |
| Hoop | Embroidery work area |
| Machine | Manufacturing device |
| Simulation | Visual execution preview |
| Export | Machine file generation |
| Resource | Shared reusable asset |
| Asset | Project-owned content |

These definitions are normative.

---

# Out of Scope

This document does not define

- compiler algorithms
- rendering
- storage
- architecture
- plugin APIs
- runtime behavior

These belong to the Architecture section.

---

# Future Domain Areas

Future documents expand this overview.

```text
Geometry

Embroidery

Machine

Threads

Fabric

Simulation

Import

Export

AI Knowledge

Manufacturing
```

---

# Acceptance Criteria

The Domain Overview is complete when

✓ A common vocabulary exists for the entire platform.

✓ Product, Architecture, and Engineering documentation use consistent terminology.

✓ Domain concepts are independent of implementation.

✓ Relationships between major entities are defined.

✓ Manufacturing concepts are introduced.

✓ Resources and assets are distinguished.

✓ Projects, documents, geometry, embroidery, and machine concepts are clearly separated.

✓ AI agents can use this document as the canonical domain glossary.

✓ Future domain documents build upon these definitions.

✓ The platform has a stable and shared business language.
