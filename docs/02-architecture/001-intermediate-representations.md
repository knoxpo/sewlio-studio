# Architecture
## ARCH-001 Intermediate Representations (IR)

**Document ID:** ARCH-001  
**Title:** Intermediate Representations (IR)  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (Foundation)

**Owner:** Core Architecture Team

---

# Purpose

Intermediate Representations (IRs) are the **canonical data contracts** between every major subsystem inside Sewlio Studio.

Rather than allowing importers, editors, digitizers, simulators, exporters, AI, and plugins to communicate directly, every subsystem communicates through a well-defined IR.

This provides:

- Separation of concerns
- Testability
- Replaceable algorithms
- Stable plugin APIs
- Stable AI APIs
- Better performance
- Easier parallel development
- Clear ownership

Every Rust crate and Flutter package ultimately depends on the contracts defined in this document.

---

# Design Philosophy

Sewlio Studio is implemented as a compiler.

Like LLVM, Clang, Swift, Rust, or TypeScript, the application transforms data through multiple stages.

```text
Raw File

↓

Import IR

↓

Geometry IR

↓

Stitch IR

↓

Playback IR
          \
           \
            Machine IR

↓

Simulation
Export
```

Each stage becomes progressively closer to production-ready embroidery instructions.

---

# IR Principles

Every IR must satisfy the following rules.

## Immutable

IRs are immutable.

Modifications always produce a new version.

---

## Versioned

Every IR has a schema version.

```text
Geometry IR

Version

1.0
```

Migration must never occur implicitly.

---

## Serializable

Every IR must be serializable.

Serialization format is independent from runtime representation.

---

## Deterministic

Given identical input,

the same IR must always be produced.

---

## Platform Independent

IRs never depend on

Flutter

Tauri

Desktop

Mobile

Web

---

## Machine Independent

Until Machine IR,

no representation contains

DST

PES

JEF

VP3

EXP

or any vendor-specific instruction.

---

## Plugin Safe

Plugins communicate through IRs.

Never through internal data structures.

---

## AI Safe

AI tools operate on IRs.

AI never manipulates private runtime state.

---

# Overview

Sewlio Studio defines five official IRs.

| IR | Purpose |
|-----|---------|
| Import IR | Normalize imported content |
| Geometry IR | Editable vector document |
| Stitch IR | Machine-independent embroidery |
| Playback IR | Simulation timeline |
| Machine IR | Machine instruction model |

---

# Data Flow

```text
Raw Input

↓

Import IR

↓

Geometry IR

↓

Stitch Compiler

↓

Stitch IR

├──────────────┐
│              │
▼              ▼

Playback     Machine

IR           IR

▼              ▼

Simulation   Export
```

---

# Import IR

## Purpose

Normalize every imported format into one common representation.

Importers should never create document objects.

Instead,

they generate Import IR.

---

## Supported Sources

```text
SVG

PDF

PNG

JPEG

DXF

AI

Future Formats
```

---

## Responsibilities

Import IR contains

- Shapes
- Groups
- Paths
- Images
- Metadata
- Colors
- Layers
- Text
- Transformations

No embroidery information exists here.

---

## Ownership

Importer package.

---

## Consumers

Geometry Builder

Validation

Import Preview

---

## Producers

SVG Importer

PDF Importer

DXF Importer

Plugin Importers

---

## Lifetime

Temporary.

Destroyed after Geometry IR creation.

---

## Validation

Checks

- Invalid geometry
- Missing assets
- Invalid transforms
- Unsupported primitives

---

# Geometry IR

## Purpose

Geometry IR is the editable document.

Everything the user edits exists here.

---

## Responsibilities

Stores

- Shapes
- Bezier paths
- Text
- Groups
- Layers
- Images
- Guides
- Constraints
- Transformations
- Metadata

---

Does NOT contain

Machine instructions

Needle commands

Simulation frames

Playback timing

---

## Ownership

Geometry package.

---

## Producers

Import Builder

Geometry Commands

AI Commands

Plugin Commands

---

## Consumers

Canvas

Digitizer

Selection

Inspector

History

Validation

---

## Lifetime

Entire project lifetime.

---

## Validation

Checks

Open paths

Invalid curves

Invalid transforms

Duplicate IDs

Broken references

---

# Geometry Object Model

```text
Document

↓

Layers

↓

Groups

↓

Objects

↓

Geometry
```

---

# Stitch IR

## Purpose

Machine-independent embroidery representation.

This is the heart of the application.

Every embroidery algorithm outputs Stitch IR.

---

## Responsibilities

Contains

Running Stitches

Fill Stitches

Satin

Underlay

Jump

Trim

Color Change

Tie In

Tie Off

Stops

Metadata

---

Does NOT contain

DST bytes

PES commands

Needle indexes

Machine encoding

---

## Ownership

Digitizer package.

---

## Producers

Digitizer Compiler

AI Stitch Generator

Plugin Stitch Algorithms

---

## Consumers

Simulation

Export

Statistics

Validation

Thread Analysis

Machine Compiler

---

## Lifetime

Project lifetime.

---

## Validation

Checks

Invalid jumps

Broken stitch sequence

Missing thread

Invalid density

Machine-independent errors

---

# Stitch Object Model

```text
Embroidery Object

↓

Stitch Sequence

↓

Commands

↓

Metadata
```

---

# Playback IR

## Purpose

Optimized representation for simulation.

Generated from Stitch IR.

---

## Responsibilities

Stores

Timeline

Frames

Needle Position

Camera

Playback Speed

HUD Events

Statistics

Animation Events

---

Playback IR should never modify Stitch IR.

---

## Ownership

Simulation package.

---

## Producers

Playback Compiler.

---

## Consumers

Flutter Renderer

Timeline

Statistics

Video Export

Future Streaming

---

## Lifetime

Cacheable.

Can be regenerated.

---

## Validation

Checks

Broken frames

Negative timestamps

Missing events

Timeline consistency

---

# Playback Pipeline

```text
Stitch IR

↓

Playback Compiler

↓

Playback IR

↓

Renderer
```

---

# Machine IR

## Purpose

Machine-independent hardware representation.

Machine IR bridges Stitch IR and binary export formats.

---

## Responsibilities

Stores

Needle Commands

Thread Mapping

Machine Stops

Jump Commands

Trim Commands

Machine Metadata

Hoop

Needle Assignments

Machine Constraints

---

Does NOT contain

DST binary

PES binary

JEF binary

---

## Ownership

Machine package.

---

## Producers

Machine Compiler.

---

## Consumers

DST Exporter

PES Exporter

JEF Exporter

VP3 Exporter

EXP Exporter

Plugin Exporters

---

## Lifetime

Temporary.

Generated during export.

---

## Validation

Checks

Machine limits

Needle count

Thread mapping

Unsupported commands

Hoop size

---

# Machine Pipeline

```text
Stitch IR

↓

Machine Compiler

↓

Machine IR

↓

Format Encoder

↓

Binary File
```

---

# IR Relationships

```text
Import IR

↓

Geometry IR

↓

Stitch IR

├──────────────┐

▼              ▼

Playback IR   Machine IR
```

Geometry never depends on Machine IR.

Playback never depends on Export.

Export never depends on Simulation.

---

# Ownership Matrix

| IR | Owner |
|------|----------------|
| Import IR | Import Package |
| Geometry IR | Geometry Package |
| Stitch IR | Digitizer Package |
| Playback IR | Simulation Package |
| Machine IR | Machine Package |

No package owns another package's IR.

---

# Serialization

Each IR supports

Binary

Internal serialization

Debug JSON

Testing fixtures

Future network serialization

---

# Versioning

Each IR has

```text
Major

Minor

Patch

Schema Version
```

Breaking schema changes require migration.

---

# Migration

Older IR

↓

Migration

↓

Validation

↓

Current IR

Migration must never occur silently.

---

# Memory Model

## Geometry IR

Long-lived.

Resident in memory.

---

## Stitch IR

Long-lived.

Resident in memory.

---

## Playback IR

Disposable cache.

---

## Machine IR

Generated on demand.

---

## Import IR

Temporary.

Destroyed after import.

---

# Performance Goals

Import IR generation

<200 ms

---

Geometry operations

Immediate

---

Digitizer

Background

---

Playback generation

Background

---

Machine compilation

<500 ms

---

# Thread Safety

Every IR is

Read-safe

Thread-safe

Immutable after publication

Worker-thread friendly

---

# Testing Strategy

Every IR requires

Unit tests

Serialization tests

Migration tests

Validation tests

Golden fixtures

Performance benchmarks

---

# AI Rules

AI may

Read IR

Generate Commands

Generate new IR through Commands

---

AI may NOT

Modify runtime state

Modify memory directly

Patch IR structures

---

# Plugin Rules

Plugins may

Read IR

Generate Commands

Produce Import IR

Produce Stitch IR

Consume Machine IR

---

Plugins may not

Mutate existing IR directly.

---

# Architectural Constraints

1. Geometry IR never contains stitches.
2. Stitch IR never contains machine bytes.
3. Playback IR never contains editable geometry.
4. Machine IR never contains rendering information.
5. Import IR never becomes persistent project state.
6. Every transformation between IRs is deterministic.
7. Every transformation is testable independently.
8. Every IR has one authoritative owner.
9. Every IR has independent validation.
10. IR schemas evolve through ADRs only.

---

# Future IRs

Possible future additions

```text
Fabric IR

↓

Material simulation

----------------

Optimization IR

↓

Compiler optimization

----------------

Manufacturing IR

↓

Production planning

----------------

AI Context IR

↓

Prompt generation

----------------

Cloud Sync IR

↓

Synchronization
```

These are intentionally excluded from the initial architecture to keep the core pipeline focused.

---

# Acceptance Criteria

The IR architecture is complete when

✓ Every subsystem communicates through defined IRs.

✓ Importers produce Import IR only.

✓ Geometry editing operates solely on Geometry IR.

✓ Digitizer produces Stitch IR.

✓ Simulation consumes Playback IR.

✓ Export consumes Machine IR.

✓ Plugins interact through IR contracts.

✓ AI interacts through Commands and IRs.

✓ All IRs are versioned, validated, and independently testable.

✓ No subsystem bypasses the defined IR pipeline.
