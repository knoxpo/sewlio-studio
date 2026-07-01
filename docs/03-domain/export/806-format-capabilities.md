# Domain
## DOM-806 Export Format Capabilities

**Document ID:** DOM-806  
**Title:** Export Format Capabilities  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Export & Compiler Team

**Related Documents**

```text
DOM-300 Machine Model
DOM-303 Thread Changes
DOM-304 Hoops
DOM-305 Machine Limits
DOM-307 Machine Commands

DOM-402 Thread Colors

DOM-800 Machine Intermediate Representation (MIR)
DOM-801 DST Export
DOM-802 PES Export
DOM-803 JEF Export
DOM-804 VP3 Export
DOM-805 EXP Export

ARCH-011 Machine Compiler
ARCH-013 Plugin Architecture
ARCH-019 Error Handling
ARCH-021 Architecture Principles
```

---

# Purpose

This document defines the Export Format Capability Model used by Sewlio Studio.

Different embroidery formats support different features.

Some formats only store stitches.

Others preserve thread information, hoop definitions, metadata, and machine-specific capabilities.

The Capability Model provides a unified way for exporters to advertise supported features and for the compiler to make deterministic export decisions.

---

# Philosophy

Compile once.

Adapt per format.

```text
Machine IR

↓

Capability Evaluation

↓

Exporter

↓

Target Format
```

Export behavior

is driven

by capabilities,

not

hardcoded logic.

---

# Goals

The Capability Model shall provide

- Format-independent feature negotiation
- Deterministic export behavior
- Consistent diagnostics
- Future format extensibility
- Shared exporter infrastructure
- Capability-based validation

---

# Definition

A Format Capability Profile

describes

what an embroidery format

can

and

cannot

represent.

Capabilities

control

serialization,

validation,

diagnostics,

and

feature preservation.

---

# Responsibilities

The Capability Model defines

- supported features
- unsupported features
- optional features
- validation requirements
- exporter behavior

It does **not** define

- binary encoding
- file structures
- embroidery optimization
- machine execution

---

# Export Pipeline

```text
Machine IR

↓

Capability Resolver

↓

Capability Profile

↓

Exporter

↓

Target Format
```

Every exporter

uses

a capability profile.

---

# Capability Profile

Each profile contains

```text
Format Identifier

Version

Supported Features

Limitations

Machine Constraints

Metadata

Compatibility Rules
```

Profiles

are immutable.

---

# Capability Categories

Capabilities are grouped into

```text
Commands

Threads

Needles

Hoops

Metadata

Geometry

Execution

Resources

Extensions
```

Each category

is evaluated

independently.

---

# Command Capabilities

Supported command capabilities

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

Formats

may support

only a subset.

---

# Thread Capabilities

Thread capabilities

include

```text
Thread Table

Thread Name

Manufacturer

Catalog Number

RGB Color

Thread Index
```

Examples

```text
DST

↓

No Thread Table

PES

↓

Rich Thread Information

VP3

↓

Rich Thread Information

EXP

↓

Color Changes Only
```

Capability profiles

define

the exact support level.  [oai_citation:0‡Embroidize](https://embroidize.com/resources/embroidery-file-formats-explained?utm_source=chatgpt.com)

---

# Metadata Capabilities

Metadata support

may include

```text
Design Name

Author

Comments

Creation Date

Application

Custom Properties
```

Some formats

preserve

most metadata,

others preserve

little or none.

---

# Hoop Capabilities

Supported hoop information

may include

```text
Hoop Size

Work Area

Origin

Rotation

Safe Area
```

Examples

```text
JEF

↓

Hoop Definitions

VP3

↓

Hoop Definitions

DST

↓

No Hoop Information
```

Capability profiles

declare

supported fields.  [oai_citation:1‡MaggieFrames](https://www.maggieframes.com/blogs/embroidery-blogs/embroidery-files-format-mastery-compatibility-conversion-and-optimization?utm_source=chatgpt.com)

---

# Color Capabilities

Color support

may include

```text
Thread Palette

RGB

Catalog Colors

Thread Order

Thread Metadata
```

Formats differ

significantly

in

color handling.

---

# Geometry Capabilities

Geometry capabilities

describe

whether a format

stores

```text
Stitch Stream

Objects

Layers

Vector Geometry

Curves
```

Most embroidery formats

store

only

stitch execution.

---

# Machine Capabilities

Machine-related capabilities

may include

```text
Multiple Needles

Thread Count

Maximum Hoop

Machine Commands

Special Functions
```

Capability profiles

remain

logical,

not hardware-specific.

---

# Extension Capabilities

Some formats

allow

vendor extensions.

Extensions may include

```text
Private Records

Custom Metadata

Application Data

Future Fields
```

Unsupported extensions

remain

outside

the Machine IR.

---

# Capability Levels

Each feature

is classified as

```text
Unsupported

Supported

Supported with Restrictions

Vendor Extension

Unknown
```

These values

drive

export behavior.

---

# Capability Resolution

Before export,

the compiler

evaluates

every feature

required

by

Machine IR.

```text
Required Feature

↓

Capability Lookup

↓

Supported?

↓

Serialize

or

Generate Diagnostic
```

---

# Feature Downgrades

If a format

cannot represent

a feature,

the exporter

may

```text
Approximate

Omit

Translate

Reject
```

Behavior

must be

deterministic.

---

# Diagnostics

Capability mismatches

generate diagnostics.

Examples

```text
Metadata Lost

Thread Table Unsupported

Needle Change Ignored

Hoop Information Removed

Vendor Extension Omitted
```

Diagnostics

never modify

Machine IR.

---

# Validation

Validation checks

```text
Unsupported Feature

Invalid Capability

Version Mismatch

Missing Requirement

Capability Conflict
```

Validation

occurs

before serialization.

---

# Capability Matrix

Every exporter

provides

a capability profile.

Example

| Capability | DST | PES | JEF | VP3 | EXP |
|------------|-----|-----|-----|-----|-----|
| Stitch Stream | ✓ | ✓ | ✓ | ✓ | ✓ |
| Jump Commands | ✓ | ✓ | ✓ | ✓ | ✓ |
| Trim Commands | Limited | ✓ | ✓ | ✓ | ✓ |
| Thread Table | ✗ | ✓ | Partial | ✓ | ✗ |
| Thread Colors | Limited | ✓ | ✓ | ✓ | Limited |
| Hoop Definitions | ✗ | ✓ | ✓ | ✓ | ✗ |
| Rich Metadata | ✗ | ✓ | Partial | ✓ | ✗ |
| Layers | ✗ | ✗ | ✗ | ✗ | ✗ |
| Vector Geometry | ✗ | ✗ | ✗ | ✗ | ✗ |
| Vendor Extensions | ✗ | Version Dependent | Limited | ✓ | ✗ |

This matrix

is illustrative.

Actual capabilities

are defined

by

Capability Profiles.  [oai_citation:2‡MaggieFrames](https://www.maggieframes.com/blogs/embroidery-blogs/embroidery-files-format-mastery-compatibility-conversion-and-optimization?utm_source=chatgpt.com)

---

# Versioning

Capability Profiles

are versioned.

```text
Format

↓

Version

↓

Capabilities
```

Examples

```text
PES v6

PES v10

VP3

DST

EXP
```

Different versions

may expose

different capabilities.

---

# Plugin Architecture

Plugin exporters

provide

their own

Capability Profiles.

The compiler

does not

hardcode

format behavior.

---

# Runtime Selection

Export targets

are selected

using

Capability Profiles,

not

format names.

Example

```text
User Requests

↓

Best Matching Exporter

↓

Capability Validation

↓

Export
```

---

# Thread Safety

Capability Profiles

are immutable.

Multiple exporters

may safely

share

the same profile

concurrently.

---

# Performance

Capability evaluation

shall support

```text
Real-Time Validation

Batch Export

Parallel Export

Streaming Export

Large Projects
```

with

constant-time

feature lookup.

---

# Domain Rules

The following always apply.

- Every exporter has exactly one Capability Profile.
- Export behavior is capability-driven.
- Capability Profiles are immutable.
- Unsupported features generate diagnostics.
- Exporters never modify Machine IR.
- Capability evaluation is deterministic.
- Version-specific behavior belongs to Capability Profiles.
- Plugin exporters declare their own capabilities.
- Validation occurs before serialization.
- Machine IR remains format-independent.

---

# Out of Scope

This document does not define

- binary serialization
- individual file specifications
- machine firmware
- embroidery editing
- optimization

These belong

to their respective documents.

---

# Future Topics

Future export documents expand

```text
Capability Negotiation

Cloud Export Targets

Dynamic Machine Profiles

Enterprise Export

AI Format Selection

Remote Manufacturing

Capability Discovery APIs
```

---

# Acceptance Criteria

The Export Format Capabilities specification is complete when

✓ Capability Profiles are defined.

✓ Capability categories are documented.

✓ Feature negotiation behavior is established.

✓ Capability levels are specified.

✓ Validation and diagnostics responsibilities are documented.

✓ Version-specific capability handling is supported.

✓ Plugin-defined capability profiles are introduced.

✓ Deterministic capability evaluation is established.

✓ Domain rules preserve immutable Machine IR semantics.

✓ The Capability Model provides the canonical feature negotiation mechanism for every export format.
