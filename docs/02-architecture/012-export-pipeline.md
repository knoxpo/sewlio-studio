# Architecture
## ARCH-012 Export Pipeline

**Document ID:** ARCH-012  
**Title:** Export Pipeline (Code Generation)  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Export & Encoding Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

For Embroidery Projects, the Export Pipeline converts **Machine IR** into one or more machine-readable embroidery file formats.

For future Weaving and Digital Printing Projects, domain exporters consume Loom IR or Print IR through the same shared export framework.

The Export Pipeline is **not** responsible for:

- Stitch generation
- Machine optimization
- Hoop validation
- Thread mapping
- Needle assignment
- Manufacturing decisions

Those responsibilities belong to the Machine Compiler.

The Export Pipeline is purely responsible for **code generation**.

---

# Philosophy

The Export Pipeline is the final stage of the compiler architecture.

```text
Geometry IR

↓

Digitizer Compiler

↓

Stitch IR

↓

Machine Compiler

↓

Machine IR

↓

Export Pipeline

↓

DST
PES
JEF
VP3
EXP
HUS
XXX
```

Each export format is an independent backend.

---

# Core Principles

## Format Independent

The embroidery Export Pipeline accepts only Machine IR.

It never consumes Geometry IR or Stitch IR.

---

## Stateless

Exporters never modify the project.

---

## Deterministic

Same Machine IR

↓

Same output bytes

Every time.

---

## Streaming

Large designs should never require the entire output file to exist in memory.

---

## Extensible

New export formats are registered.

Never hardcoded.

---

# High-Level Architecture

```text
Machine IR

↓

Export Manager

↓

Generator Registry

↓

Generator Backend

↓

Binary Stream

↓

Filesystem
```

---

# Export Pipeline

```text
Machine IR

↓

Pre-validation

↓

Generator Context

↓

Format Generator

↓

Binary Writer

↓

Verification

↓

Output File
```

---

# Export Manager

Coordinates export operations.

Responsible for

- Generator discovery
- Progress
- Cancellation
- Diagnostics
- Output management
- Multi-format export

Contains no encoding logic.

---

# Generator Registry

All generators are registered.

```text
Generator Registry

↓

DST Generator

↓

PES Generator

↓

JEF Generator

↓

VP3 Generator

↓

EXP Generator

↓

HUS Generator

↓

Plugin Generators
```

---

# Generator Interface

Every generator implements the same interface.

Responsibilities

- Accept Machine IR
- Validate support
- Encode instructions
- Write binary stream
- Produce diagnostics

---

# Generator Context

Every export receives

```text
Machine IR

↓

Generator Context
```

Contains

```text
Output Location

Generator Version

Machine Profile

Metadata

Encoding Options

Compression Options

Comments

Diagnostics

Cancellation Token
```

---

# Supported Formats

Initial

```text
DST

PES

JEF

VP3

EXP

HUS
```

Future

```text
PCS

XXX

SEW

EMD

U??

Custom OEM Formats
```

---

# Export Stages

## Stage 1

Pre-validation

Verifies

- Machine IR version
- Generator compatibility
- Output path
- Permissions

---

## Stage 2

Instruction Translation

Converts

Machine Commands

↓

Format Instructions

---

## Stage 3

Binary Encoding

Produces

Format-specific bytes.

No business logic.

---

## Stage 4

Streaming

Writes

Binary stream

↓

File

Supports very large designs.

---

## Stage 5

Verification

Checks

- file integrity
- checksum
- header
- footer
- generator success

---

# Binary Writer

Responsible for

- buffering
- endian conversion
- alignment
- padding
- checksum writing

Shared across generators.

---

# Metadata

Export may include

```text
Design Name

Author

Company

Machine

Generator Version

Creation Date

Comments
```

Only if supported by the format.

---

# Generator Diagnostics

Produces

```text
Info

Export completed.

----------------

Warning

Comment truncated.

----------------

Warning

Unsupported metadata ignored.

----------------

Error

Generator failed checksum validation.
```

---

# Multi-format Export

Supports

```text
Machine IR

↓

DST

↓

PES

↓

JEF

↓

VP3
```

Single compilation.

Multiple generators.

---

# Batch Export

Supports

```text
Project

↓

All Machine Profiles

↓

All Formats

↓

Output Folder
```

Useful for manufacturing workflows.

---

# Export Profiles

Workspace may define

```text
Production

Customer

Preview

Archive

Testing
```

Profiles determine

- formats
- metadata
- naming
- compression
- output location

---

# File Naming

Supports templates.

Examples

```text
{name}.dst

{name}_{machine}.pes

{date}_{version}.vp3
```

---

# Streaming Architecture

Large exports

```text
Machine IR

↓

Generator

↓

Binary Stream

↓

File
```

Memory usage remains bounded.

---

# Cancellation

Export supports

```text
Start

↓

Cancel

↓

Safe Stop

↓

Cleanup
```

Partially written files removed automatically.

---

# Progress Reporting

Generator reports

```text
Validation

10%

Encoding

45%

Streaming

80%

Verification

100%
```

UI displays unified progress.

---

# Verification

After generation

Checks

- headers
- trailers
- byte count
- checksum
- format consistency

Optional future

Re-import verification.

---

# Plugin Support

Plugins may register

```text
Generators

Metadata Writers

Verification Rules

Naming Rules
```

No core modifications required.

---

# AI Integration

AI may

Recommend

- preferred export format
- export profile
- naming
- metadata

AI never writes binary files.

---

# Performance Targets

Small Design

<100 ms

---

Medium Design

<500 ms

---

Large Design

<2 s

---

Streaming Memory

Constant

---

Multi-format Export

Parallel where possible.

---

# Thread Safety

Generators are

Stateless

Read-only

Parallel

Worker-thread friendly

---

# Security

Export never

- modifies the project
- changes Machine IR
- executes plugins outside the sandbox

Output paths validated before writing.

---

# Testing

Each generator requires

- Golden binary tests
- Compatibility tests
- Header validation
- Checksum tests
- Streaming tests
- Large design tests
- Corruption tests
- Performance benchmarks

---

# AI Agent Rules

Export owns

- binary encoding
- file generation
- streaming
- verification

Export never owns

- Geometry
- Stitch generation
- Machine optimization
- Rendering
- Simulation

---

# Architectural Constraints

1. Export consumes Machine IR only.
2. Export never modifies Machine IR.
3. One generator supports one format.
4. Binary encoding is isolated from manufacturing logic.
5. Generators are stateless.
6. Streaming is preferred over full-memory output.
7. Multi-format export reuses the same Machine IR.
8. Verification occurs after encoding.
9. Plugins extend through generator registration.
10. Export remains independently testable.

---

# Future Enhancements

- Cloud export providers
- Direct machine upload
- Network embroidery protocols
- Encrypted production packages
- Manufacturing manifests
- Digital signatures
- QR code job metadata
- Archive bundles
- Enterprise export policies
- Remote print queues

---

# Acceptance Criteria

The Export Pipeline is complete when

✓ Machine IR is converted into supported embroidery formats.

✓ Each format has an independent generator.

✓ Export remains stateless.

✓ Streaming minimizes memory usage.

✓ Multi-format export is supported.

✓ Verification ensures output integrity.

✓ Plugin generators can be registered.

✓ Large designs export efficiently.

✓ Binary encoding remains separate from manufacturing logic.

✓ The Export Pipeline is deterministic, modular, and independently testable.
