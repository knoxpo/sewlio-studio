# Domain
## DOM-800 Machine Intermediate Representation (MIR)

**Document ID:** DOM-800  
**Title:** Machine Intermediate Representation (MIR)  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Export & Compiler Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing

DOM-300 Machine Model
DOM-301 Machine Coordinates
DOM-302 Needle System
DOM-303 Thread Changes
DOM-305 Machine Limits
DOM-307 Machine Commands

ARCH-011 Machine Compiler
ARCH-015 Import Pipeline
ARCH-021 Architecture Principles
ARCH-027 Dependency Graph
ARCH-029 Build System
```

---

# Purpose

This document defines the Machine Intermediate Representation (MIR) used by Sewlio Studio.

The MIR is the canonical machine-oriented representation produced by the Machine Compiler before exporting to vendor-specific embroidery formats.

Every embroidery export target (DST, PES, JEF, VP3, etc.) is generated from the MIR rather than directly from the embroidery document.

---

# Philosophy

Compile once.

Export many.

```text
Embroidery Document

↓

Machine Compiler

↓

Machine IR

↓

DST

PES

JEF

VP3

EXP

...
```

The compiler understands embroidery.

Exporters understand file formats.

---

# Goals

The Machine IR shall provide

- Machine-independent command representation
- Deterministic compilation
- Vendor-neutral export
- Efficient optimization
- Shared export pipeline
- Extensible compiler architecture

---

# Definition

Machine IR (MIR) is the canonical machine execution model used by all exporters.

The MIR represents

```text
Machine Commands

Machine Coordinates

Thread Events

Needle Events

Timing

Execution Metadata
```

The MIR contains

no vendor-specific encoding.

---

# Responsibilities

The MIR represents

- executable machine instructions
- machine events
- coordinate movement
- thread operations
- execution order

It does **not** represent

- artwork
- vector geometry
- editing state
- simulation
- rendering

---

# Compilation Pipeline

```text
Embroidery Document

↓

Optimization

↓

Machine Compiler

↓

Machine IR

↓

Format Exporter

↓

Machine File
```

Machine IR

is mandatory

for every export.

---

# Machine IR Model

Each MIR document contains

```text
Header

Machine Profile

Command Stream

Resources

Metadata

Diagnostics
```

---

# Header

The MIR header

contains

```text
Version

Compiler Version

Target Profile

Timestamp

Identifier

Flags
```

Headers

are format-independent.

---

# Machine Profile

The MIR references

a logical machine profile.

Examples

```text
Maximum Speed

Maximum Hoop

Needle Count

Supported Commands

Capabilities
```

Profiles

are machine-neutral

until export.

---

# Command Stream

The MIR consists of

an ordered sequence

of commands.

Examples

```text
Move

Stitch

Jump

Trim

Stop

Needle Change

Thread Change

End
```

Execution order

is immutable.

---

# Command Structure

Every command contains

```text
Opcode

Arguments

Flags

Sequence Number

Metadata
```

Commands

are immutable

after compilation.

---

# Coordinates

All movement

uses

canonical

machine coordinates.

Coordinates

are normalized

before export.

---

# Stitch Commands

A stitch command

contains

```text
Position

Needle

Thread

Flags
```

No vendor encoding

is present.

---

# Jump Commands

Jump commands

represent

needle movement

without stitching.

They are

logical operations

within the MIR.

---

# Trim Commands

Trim commands

represent

thread cutting.

Timing

is determined

during export

if required

by the target format.

---

# Thread Changes

Thread changes

are explicit events.

Each event references

```text
Thread ID

Color

Needle

Metadata
```

Vendor-specific

thread handling

is deferred

to exporters.

---

# Needle Changes

Machines supporting

multiple needles

represent

needle selection

using explicit

Needle Change commands.

---

# Stop Commands

Stop commands

pause

machine execution.

They are preserved

throughout

the export pipeline.

---

# End Command

Every MIR

terminates

with

a single

End command.

---

# Resources

Resources

referenced by MIR

include

```text
Thread Table

Needle Table

Machine Profile

Hoop Profile
```

Resources

are logical,

not encoded.

---

# Metadata

Supported metadata

includes

```text
Design Name

Author

Compiler Version

Creation Date

Project ID

Custom Properties
```

Metadata

may or may not

be exported,

depending on

the target format.

---

# Diagnostics

Compilation diagnostics

may attach

to MIR objects.

Examples

```text
Trim Added

Jump Optimized

Unsupported Feature

Machine Warning

Export Warning
```

Diagnostics

never affect

execution semantics.

---

# Validation

The MIR

must be valid

before export.

Validation checks

```text
Missing End

Invalid Command

Coordinate Overflow

Unsupported Needle

Thread Mismatch

Machine Limits
```

Invalid MIR

cannot be exported.

---

# Optimization

Optimization

occurs

before

MIR generation.

Exporters

must not

rewrite

execution semantics.

Only encoding

may change.

---

# Determinism

Given identical

embroidery documents

and

machine profiles,

the compiler

must always produce

identical MIR.

---

# Export Independence

Every exporter

consumes

the same MIR.

```text
Machine IR

├── DST Exporter

├── PES Exporter

├── JEF Exporter

├── VP3 Exporter

├── EXP Exporter

└── Plugin Exporters
```

Exporters

never access

editor objects.

---

# Plugin Architecture

New exporters

are implemented

through

the Export Plugin API.

Plugins

consume

the MIR,

never

the editor document.

---

# Streaming

The MIR

supports

streaming generation.

Large embroidery designs

need not

be fully buffered

before export.

---

# Thread Safety

The MIR

is immutable.

Multiple exporters

may consume

the same MIR

simultaneously.

---

# Performance

The MIR

shall support

```text
Millions of Commands

Streaming Compilation

Parallel Export

Incremental Compilation

Batch Export
```

without duplicating

compiler work.

---

# Domain Rules

The following always apply.

- Every export passes through the MIR.
- MIR is machine-independent.
- MIR is vendor-neutral.
- Exporters never access editor data directly.
- Command streams are immutable.
- Exporters encode; they do not optimize.
- MIR generation is deterministic.
- Validation occurs before export.
- Plugin exporters consume the same MIR.
- MIR is the canonical representation of machine execution.

---

# Out of Scope

This document does not define

- vendor-specific binary encoding
- embroidery editing
- digitizing
- rendering
- machine firmware

These are defined in their respective documents.

---

# Future Topics

Future export documents expand

```text
Incremental Compilation

Streaming Export

Cloud Compilation

Remote Machines

Compiler Optimizations

Distributed Export

Digital Twin Machines
```

---

# Acceptance Criteria

The Machine Intermediate Representation specification is complete when

✓ MIR responsibilities are clearly separated from editing and exporting.

✓ MIR document structure is defined.

✓ Canonical command stream is documented.

✓ Machine profiles and resources are established.

✓ Validation and diagnostics behavior are specified.

✓ Deterministic compiler behavior is established.

✓ Export independence is guaranteed.

✓ Plugin-based exporter architecture is supported.

✓ Domain rules establish immutable, machine-independent execution semantics.

✓ The Machine IR provides the canonical execution model for every embroidery export format.
