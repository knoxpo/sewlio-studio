# Domain
## DOM-305 Machine Limits

**Document ID:** DOM-305  
**Title:** Machine Limits  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Machine Runtime Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-206 Trims
DOM-207 Jump Stitches
DOM-300 Machine Model
DOM-301 Machine Coordinates
DOM-302 Needle System
DOM-303 Thread Changes
DOM-304 Hoop System

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline

FR-1400 Machine Support
```

---

# Purpose

This document defines the Machine Limits System used by Sewlio Studio.

Machine limits describe the physical and firmware constraints imposed by embroidery machines.

The logical embroidery model is intentionally unconstrained wherever possible. Machine limits are enforced during manufacturing validation and machine compilation.

---

# Philosophy

Every embroidery machine has limitations.

Professional embroidery software should produce

**portable embroidery**

while validating against

**machine-specific capabilities**.

```text
Embroidery Design

↓

Logical Machine

↓

Machine Limits

↓

Machine Compiler

↓

Machine File
```

Design first.

Machine validation second.

---

# Goals

The Machine Limits System shall provide

- Machine-independent embroidery design
- Machine-specific validation
- Deterministic compilation
- Accurate diagnostics
- Extensible machine profiles
- Safe manufacturing

---

# Definition

Machine Limits describe the maximum and minimum operating constraints of a specific embroidery machine.

Limits are provided by Machine Profiles.

The embroidery document itself never stores machine limits.

---

# Responsibilities

The Machine Limits System validates

- stitch dimensions
- hoop boundaries
- movement
- thread capacity
- needle capacity
- command support
- machine capabilities

It does **not** perform

- stitch generation
- optimization
- geometry modification

---

# Validation Pipeline

```text
Embroidery Objects

↓

Optimization

↓

Machine Validation

↓

Machine Compiler

↓

Export
```

Validation always precedes compilation.

---

# Machine Profile

Every machine profile exposes

```text
Capabilities

Limits

Supported Commands

Supported Formats
```

Limits are immutable characteristics of the profile.

---

# Coordinate Limits

Machine profiles define

```text
Maximum X

Minimum X

Maximum Y

Minimum Y
```

Embroidery outside these limits

is invalid.

---

# Hoop Limits

Supported hoops determine

```text
Maximum Embroidery Area
```

Validation ensures

the selected hoop

is compatible

with the selected machine.

---

# Stitch Length

Every machine defines

```text
Minimum Stitch Length

Maximum Stitch Length
```

Typical examples

```text
Minimum

≈ 0.3 mm

Maximum

≈ 12 mm
```

Values depend upon

the machine profile.

---

# Jump Distance

Machines define

maximum jump distance.

Example

```text
Maximum Jump

↓

100 mm
```

Longer jumps

must be

- split
- trimmed
- rejected

according to the profile.

---

# Needle Count

Profiles define

```text
Supported Needles
```

Examples

```text
1

6

10

12

15

18
```

Embroidery requiring

more logical needles

than supported

must be remapped

or rejected.

---

# Thread Capacity

Some machines limit

```text
Maximum Thread Colors
```

Validation verifies

that embroidery

fits within

machine capabilities.

---

# Color Changes

Profiles define

```text
Maximum Color Changes

Supported Color Commands

Automatic Changes
```

Unsupported operations

generate validation errors.

---

# Speed Limits

Machine profiles define

```text
Maximum Sewing Speed

Recommended Speed

Minimum Speed
```

Logical embroidery

remains speed-independent,

but recommendations

may be generated.

---

# Trim Support

Profiles specify

```text
Automatic Trim

Manual Trim

Unsupported
```

Compilation adapts

logical trims

to machine capabilities.

---

# Jump Support

Machines differ in

- jump implementation
- jump encoding
- jump limitations

Profiles define

supported behavior.

---

# Command Limits

Machine profiles define

supported logical commands.

Examples

```text
Trim

Jump

Pause

Stop

Color Change

Needle Change

Lock Stitch
```

Unsupported commands

must be transformed

or rejected.

---

# Memory Limits

Some machines limit

```text
Maximum Stitches

Maximum Commands

Maximum Colors

Maximum Design Size
```

Validation checks

export feasibility.

---

# File Format Limits

Embroidery formats

may impose additional limits.

Examples

```text
Coordinate Range

Command Count

Color Count

Binary Encoding
```

These limits

are validated

during compilation.

---

# Thread Type Support

Machines may support

```text
Standard

Metallic

Heavy Thread

Special Thread
```

Unsupported thread types

produce warnings

or errors.

---

# Hoop Compatibility

Each machine profile

defines

supported hoop models.

Unsupported hoop selections

prevent export.

---

# Feature Support

Machine capabilities

may include

```text
Sequins

Chenille

Laser

Cording

Automatic Threading

Thread Sensors
```

Unsupported features

must be reported

before compilation.

---

# Safety Limits

Profiles define

```text
Acceleration

Rapid Movement

Needle Clearance

Frame Margin
```

These limits

ensure

safe manufacturing.

---

# Soft Limits

Certain limits

generate warnings

rather than errors.

Examples

```text
Very Dense Embroidery

High Stitch Count

Long Runtime

Large Thread Usage
```

Soft limits

allow export

while notifying users.

---

# Hard Limits

Hard limits

prevent export.

Examples

```text
Outside Hoop

Unsupported Needle Count

Unsupported Commands

Invalid Coordinates

Machine Overflow
```

---

# Validation Severity

Validation messages

are categorized as

```text
Info

Warning

Error

Critical
```

Only

Error

and

Critical

prevent export.

---

# Runtime Validation

Simulation may optionally

validate limits

during execution.

This assists

debugging

and machine compatibility analysis.

---

# Machine Compilation

The compiler

uses machine limits

to

- validate
- adapt
- encode

embroidery.

Compilation

never changes

logical embroidery intent.

---

# Extensibility

Future machine limits

may include

```text
Power Limits

Network Limits

Multi-Head Limits

Smart Sensors

Camera Systems

Robotic Attachments
```

Profiles should evolve

without affecting

the document model.

---

# Thread Safety

Machine profiles

are immutable.

Validation

may execute

concurrently

across multiple exports.

---

# Performance

The validation system

shall support

```text
Millions of Stitches

Large Designs

Batch Export

Real-Time Validation

Incremental Validation
```

without modifying embroidery data.

---

# Domain Rules

The following always apply.

- Machine limits belong to machine profiles.
- Embroidery documents remain machine-independent.
- Validation always occurs before compilation.
- Hard limit violations prevent export.
- Soft limit violations generate warnings.
- Machine limits never modify embroidery geometry.
- Compilation respects machine capabilities.
- Simulation may optionally validate machine limits.
- Machine profiles are immutable.
- Validation behavior is deterministic.

---

# Out of Scope

This document does not define

- embroidery optimization
- stitch generation
- machine firmware
- USB communication
- motor control

These are covered in other architecture and machine documents.

---

# Future Topics

Future machine documents expand

```text
Capability Negotiation

Machine Diagnostics

Real-Time Validation

Cloud Machine Profiles

Firmware Compatibility

Production Analytics
```

---

# Acceptance Criteria

The Machine Limits specification is complete when

✓ Machine limits are defined independently of embroidery documents.

✓ Coordinate, stitch, hoop, needle, thread, and command limits are documented.

✓ Soft and hard validation limits are distinguished.

✓ Validation severity levels are defined.

✓ Machine profile responsibilities are established.

✓ Simulation and compilation responsibilities are separated.

✓ Extensibility for future machine capabilities is supported.

✓ Domain rules establish deterministic validation behavior.

✓ Machine-independent embroidery design is preserved.

✓ The Machine Limits System provides the authoritative validation layer before machine compilation.
