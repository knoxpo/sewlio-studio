# Domain
## DOM-303 Thread Changes

**Document ID:** DOM-303  
**Title:** Thread Changes  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Machine Runtime Team

**Related Documents**

```text
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-300 Machine Model
DOM-302 Needle System
DOM-304 Hoop System

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
```

---

# Purpose

This document defines the Thread Change System used by the logical embroidery machine.

Thread changes represent transitions between thread colors or thread types during embroidery execution.

The logical system abstracts manufacturer-specific implementations while preserving deterministic manufacturing behavior.

---

# Philosophy

A thread change is a manufacturing transition,

not merely a color switch.

```text
Current Thread

↓

Secure Current Thread

↓

Trim

↓

Select New Thread

↓

Secure New Thread

↓

Continue Sewing
```

Every thread transition should preserve embroidery quality while minimizing production time.

---

# Goals

The Thread Change System shall provide

- Machine-independent thread transitions
- Deterministic execution
- Accurate simulation
- Efficient manufacturing
- Capability validation
- Extensible machine support

---

# Definition

A Thread Change is the logical operation of ending embroidery with one thread and continuing embroidery using another thread.

The operation is independent of

- machine manufacturer
- needle numbering
- embroidery file format

---

# Responsibilities

The Thread Change System manages

- thread transitions
- thread selection
- needle coordination
- execution sequencing
- runtime state
- machine validation

It does **not** manage

- stitch generation
- thread inventory
- geometry
- embroidery optimization

---

# Thread Change Pipeline

```text
Embroidery Objects

↓

Color Resolution

↓

Thread Planning

↓

Thread Change

↓

Machine Commands

↓

Machine Compiler
```

---

# Thread Lifecycle

Every thread follows

```text
Assigned

↓

Selected

↓

Active

↓

Released
```

Only one thread is active during stitching.

---

# Thread Change Sequence

The logical sequence is

```text
Tie-Off

↓

Trim

↓

Needle Selection

↓

Thread Activation

↓

Tie-In

↓

Continue Embroidery
```

Every machine profile translates this sequence into native commands.

---

# Thread Identity

Threads are identified logically.

Example

```text
Thread-01

Thread-02

Thread-03
```

Thread identifiers are independent of

needle numbers

or machine slots.

---

# Thread Colors

Each logical thread contains

```text
Color

Name

Catalog

Material

Weight
```

Color changes reference

logical thread identities,

not machine commands.

---

# Thread Types

Supported thread types include

```text
Rayon

Polyester

Cotton

Metallic

Silk

Glow

Specialty
```

Future thread types

may extend this list.

---

# Thread Selection

The runtime selects

the required thread

using

```text
Embroidery Object

↓

Logical Thread

↓

Assigned Needle
```

Selection is deterministic.

---

# Needle Coordination

Thread changes are coordinated

through the Needle System.

The embroidery document

never references

physical needles directly.

---

# Color Groups

Embroidery objects sharing

the same thread

form

```text
Color Groups
```

Grouping minimizes

thread changes.

---

# Thread Optimization

The optimizer attempts to

- reduce thread changes
- merge compatible groups
- preserve dependencies

Thread optimization

must never alter

the artistic intent.

---

# Manual Thread Changes

Professional users may

explicitly insert

thread changes.

Applications

```text
Manual Effects

Special Thread

Operator Instructions

Production Stops
```

Manual operations override

automatic planning.

---

# Automatic Thread Changes

Automatic planning

determines thread transitions

based on

- embroidery objects
- color groups
- sequencing
- machine profile

Automatic behavior

should be deterministic.

---

# Single-Needle Machines

For single-needle machines

thread changes require

```text
Machine Stop

↓

Manual Thread Replacement

↓

Resume
```

The logical workflow remains identical.

---

# Multi-Needle Machines

Multi-needle machines perform

```text
Needle Selection

↓

Continue Sewing
```

without manual intervention.

---

# Duplicate Thread Assignments

Multiple needles

may contain

the same thread.

The runtime selects

the optimal needle

according to

the production profile.

---

# Machine Stops

Certain thread changes

may require

```text
Pause

↓

Operator Action

↓

Resume
```

Examples

```text
Single Needle

Special Thread

Manual Sequin Device
```

---

# Thread Validation

Before execution

the system validates

```text
Required Thread

Assigned Needle

Supported Material

Machine Capability
```

Missing assignments

prevent export.

---

# Thread Compatibility

Machine profiles define

supported thread capabilities.

Examples

```text
Metallic

Heavy Thread

Fine Thread

Special Device
```

Unsupported combinations

produce validation errors.

---

# Runtime Events

The Thread Change System emits

```text
Thread Selected

Thread Changed

Thread Released

Thread Missing

Thread Fault
```

These events integrate

with the Event System.

---

# Simulation

Professional simulation should display

```text
Current Thread

Current Color

Thread Change Events

Needle Selection
```

Consumer previews

may display

only visible color transitions.

---

# Machine Compilation

The compiler converts

logical thread changes

into

machine-specific operations.

Examples

```text
Color Change

Needle Select

Stop

Pause

Thread Change Command
```

The logical workflow

remains unchanged.

---

# Error Conditions

Common errors

```text
Missing Thread

Invalid Assignment

Unsupported Thread

Needle Conflict

Capability Failure

Machine Capacity Exceeded
```

Errors prevent

successful compilation

or execution.

---

# Extensibility

Future thread capabilities

may include

```text
Automatic Thread Detection

RFID Thread Recognition

Thread Consumption Tracking

Smart Spools

Automatic Threading

Inventory Integration
```

The logical model

must remain backward compatible.

---

# Thread Safety

Thread definitions

are immutable

during planning.

Execution state

is isolated

within the runtime.

---

# Performance

The Thread Change System shall support

```text
Large Color Palettes

Commercial Multi-Needle Machines

Rapid Color Planning

Real-Time Simulation
```

without affecting embroidery geometry.

---

# Domain Rules

The following always apply.

- Thread changes are logical manufacturing operations.
- Embroidery objects reference logical thread identities.
- Thread changes always preserve embroidery coordinates.
- Thread transitions coordinate with the Needle System.
- Automatic planning should minimize thread changes.
- Manual thread changes override automatic planning.
- Validation occurs before compilation.
- Simulation executes logical thread changes.
- Machine compilation translates logical operations into native machine commands.
- Thread management remains independent of embroidery geometry.

---

# Out of Scope

This document does not define

- thread inventory management
- thread physics
- stitch generation
- embroidery file encoding
- machine communication

These are covered by other domain and architecture documents.

---

# Future Topics

Future machine documents expand

```text
Thread Inventory

Smart Thread Systems

Automatic Thread Detection

Production Analytics

Material Management

Machine Diagnostics
```

---

# Acceptance Criteria

The Thread Changes specification is complete when

✓ A machine-independent thread transition model is defined.

✓ Thread lifecycle and logical workflow are documented.

✓ Interaction with the Needle System is established.

✓ Automatic and manual thread changes are supported.

✓ Single-needle and multi-needle workflows are distinguished.

✓ Validation, simulation, and machine compilation responsibilities are separated.

✓ Runtime events and error conditions are documented.

✓ Domain rules establish deterministic thread management behavior.

✓ Physical machine implementations remain isolated behind machine profiles.

✓ The Thread Change System provides a portable manufacturing abstraction across all supported embroidery machines.
