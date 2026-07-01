# Domain
## DOM-302 Needle System

**Document ID:** DOM-302  
**Title:** Needle System  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Machine Runtime Team

**Related Documents**

```text
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-300 Machine Model
DOM-301 Machine Coordinates
DOM-303 Thread System
DOM-304 Hoop System

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
```

---

# Purpose

This document defines the logical Needle System used by Sewlio Studio.

The Needle System models the collection of embroidery needles available to the logical machine and manages their relationship with thread, colors, and embroidery execution.

It provides a machine-independent abstraction over the physical needle systems used by commercial embroidery machines.

---

# Philosophy

The logical machine works with

**logical needles**,

not physical hardware.

```text
Embroidery Objects

↓

Thread Colors

↓

Logical Needles

↓

Machine Compiler

↓

Physical Needles
```

This abstraction enables a single embroidery design to execute on machines with different needle configurations.

---

# Goals

The Needle System shall provide

- Machine independence
- Deterministic needle selection
- Flexible thread assignment
- Capability validation
- Accurate simulation
- Extensible machine support

---

# Definition

A Logical Needle represents a thread delivery channel available to the embroidery machine.

A logical needle is identified independently of

- physical needle position
- machine manufacturer
- embroidery format

---

# Responsibilities

The Needle System manages

- needle inventory
- thread assignment
- color assignment
- active needle selection
- needle changes
- capability validation

It does **not** manage

- stitch generation
- thread physics
- geometry
- machine communication

---

# Needle Pipeline

```text
Embroidery Objects

↓

Color Resolution

↓

Needle Assignment

↓

Machine Commands

↓

Machine Compiler
```

---

# Needle Model

Each logical needle contains

```text
Identifier

Display Name

Assigned Thread

Assigned Color

Status

Capabilities
```

Needles remain stable throughout execution.

---

# Needle Identifier

Every needle has

a unique logical identifier.

Example

```text
Needle-01

Needle-02

Needle-03
```

Logical identifiers never depend on machine numbering.

---

# Needle States

A needle exists in one of

```text
Available

Active

Reserved

Disabled

Missing

Fault
```

Only one needle is active at a time.

---

# Active Needle

The machine maintains

```text
Current Active Needle
```

All stitches use the active needle until

a needle change occurs.

---

# Needle Assignment

Embroidery objects reference

logical thread colors,

not needles.

Needle assignment occurs

during manufacturing planning.

Example

```text
Blue Thread

↓

Needle 3
```

This separation improves portability.

---

# Needle Capacity

Machine profiles define

the maximum supported needles.

Examples

```text
Single Needle

6 Needles

10 Needles

12 Needles

15 Needles

18 Needles
```

Logical embroidery is independent of this limit.

---

# Single-Needle Machines

Single-needle machines

support

```text
One Active Needle
```

Color changes require

manual thread replacement.

The logical machine models this

without changing embroidery data.

---

# Multi-Needle Machines

Multi-needle machines

assign

different threads

to different needles.

Color changes become

needle selection operations.

---

# Needle Change

A logical needle change consists of

```text
Tie-Off

↓

Trim

↓

Select Needle

↓

Tie-In

↓

Continue
```

The compiler translates this sequence

into machine-specific commands.

---

# Needle Selection

Selection is based on

```text
Required Thread

↓

Assigned Needle
```

If multiple needles contain

the same thread,

selection follows

the production profile.

---

# Needle Mapping

Machine profiles maintain

a mapping between

```text
Logical Needle

↓

Physical Needle
```

This mapping is compiler-specific.

The document never stores

physical machine numbering.

---

# Needle Availability

Before execution,

the runtime validates

- required needles
- thread assignments
- machine capacity

Missing assignments

prevent export.

---

# Thread Association

Each needle references

exactly one active thread.

A thread may be reassigned

between production runs,

but not during execution.

---

# Color Association

Needles inherit color

from the assigned thread.

Needles themselves

do not own colors.

---

# Capability System

Needles may expose

capabilities such as

```text
Standard

Metallic

Heavy Thread

Special Device

Disabled
```

Capability validation

occurs before compilation.

---

# Needle Groups

Future machine profiles

may organize needles into

```text
Primary

Secondary

Special Purpose
```

Groups assist

automatic assignment.

---

# Automatic Assignment

The system should automatically assign

needles

using

- thread color
- production profile
- machine profile
- user preferences

Automatic assignment

should be deterministic.

---

# Manual Assignment

Professional users may

override automatic mapping.

Manual assignments remain

until explicitly changed.

---

# Duplicate Threads

Multiple needles

may contain

the same thread.

Applications

```text
Redundant Thread

Reduced Change Time

Production Optimization
```

The optimizer selects

the preferred needle.

---

# Needle Validation

Validation verifies

```text
Assigned Thread

Supported Capability

Available Needle

Machine Capacity

Valid Mapping
```

Validation occurs

before export.

---

# Simulation

Simulation executes

logical needle changes.

Professional simulation should display

```text
Current Needle

Current Thread

Needle Change Events
```

Consumer previews

may hide needle information.

---

# Runtime Events

The Needle System emits

```text
Needle Selected

Needle Changed

Needle Disabled

Needle Fault

Needle Restored
```

These integrate

with the Event System.

---

# Machine Compilation

The compiler converts

logical needle changes

into

manufacturer-specific commands.

Examples

```text
Needle Select

Color Change

Thread Change

Stop Command
```

Logical needle identities

remain unchanged.

---

# Error Conditions

Common errors

```text
Missing Needle

Missing Thread

Invalid Assignment

Unsupported Capability

Needle Fault

Machine Capacity Exceeded
```

Errors prevent

successful compilation

or execution.

---

# Extensibility

Future needle capabilities

may include

```text
Automatic Threading

Needle Sensors

Break Detection

Twin Needle

Special Attachments

Smart Needles
```

The logical model

must evolve

without breaking compatibility.

---

# Thread Safety

Needle definitions

are immutable

during planning.

Execution state

is isolated

within the runtime.

---

# Performance

The Needle System shall support

```text
Large Thread Palettes

Many Machine Profiles

Rapid Needle Assignment

Real-Time Simulation
```

without affecting embroidery geometry.

---

# Domain Rules

The following always apply.

- Logical needles are machine-independent.
- Embroidery objects reference thread colors, not needles.
- Needle assignment occurs during manufacturing planning.
- Only one logical needle is active at a time.
- Needle changes preserve machine coordinates.
- Machine profiles map logical needles to physical needles.
- Validation occurs before compilation.
- Simulation executes logical needle operations.
- Machine compilation translates logical needle commands into native commands.
- Needle state is independent of embroidery geometry.

---

# Out of Scope

This document does not define

- thread properties
- thread inventory
- machine communication
- embroidery file encoding
- physical motor control

These are covered in subsequent machine documents.

---

# Future Topics

Future machine documents expand

```text
Thread System

Thread Inventory

Needle Calibration

Needle Wear

Automatic Threading

Real-Time Monitoring

Machine Diagnostics
```

---

# Acceptance Criteria

The Needle System specification is complete when

✓ A machine-independent logical needle abstraction is defined.

✓ Needle lifecycle and state model are established.

✓ Thread and color relationships are documented.

✓ Automatic and manual needle assignment workflows are supported.

✓ Needle validation and capability handling are specified.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Runtime events and error conditions are documented.

✓ Domain rules establish deterministic needle behavior.

✓ Physical machine numbering is isolated behind machine profiles.

✓ The Needle System provides a portable abstraction for all supported embroidery machines.
