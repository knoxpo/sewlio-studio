# Domain
## DOM-300 Machine Model

**Document ID:** DOM-300  
**Title:** Machine Model  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Machine Runtime Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-214 Optimization

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline

FR-1400 Machine Support
```

---

# Purpose

This document defines the logical embroidery machine model used throughout Sewlio Studio.

The Machine Model provides a machine-independent abstraction of embroidery hardware.

It separates embroidery logic from machine-specific implementations, allowing the same embroidery design to be compiled for many different embroidery machine formats.

---

# Philosophy

Sewlio Studio models

**what a machine does**

—not—

**how a specific machine implements it.**

```text
Embroidery Design

↓

Logical Machine

↓

Machine Compiler

↓

Brother

Janome

Tajima

Melco

Barudan

...
```

The logical machine is the universal manufacturing model.

---

# Goals

The machine model shall provide

- Machine independence
- Deterministic execution
- Extensible capabilities
- Hardware abstraction
- Accurate simulation
- Portable compilation

---

# Definition

The Machine Model represents a virtual embroidery machine capable of executing logical embroidery operations.

It is not tied to

- file formats
- manufacturers
- firmware
- communication protocols

---

# Responsibilities

The logical machine is responsible for

- executing stitches
- changing needles
- changing thread colors
- trimming thread
- jumping
- moving the embroidery frame
- reporting machine state

It is **not** responsible for

- digitizing
- geometry
- embroidery optimization
- UI

---

# Machine Pipeline

```text
Artwork

↓

Embroidery Objects

↓

Optimization

↓

Machine Model

↓

Machine Compiler

↓

Machine File
```

---

# Machine Components

The logical machine consists of

```text
Needle System

Thread System

Frame System

Movement System

Command Processor

Machine State

Capabilities

Runtime
```

---

# Machine State

The machine maintains

```text
Current Position

Current Needle

Current Color

Current Speed

Frame Position

Thread State

Execution State
```

The state changes only through logical machine commands.

---

# Coordinate System

The logical machine operates in

```text
Machine Coordinates
```

derived from the embroidery design.

The compiler converts these coordinates into machine-specific representations.

---

# Needle

The logical machine exposes

```text
Needle

Identifier

Color

Thread Assignment

Status
```

Needles are logical entities.

Physical needle numbering is machine-specific.

---

# Thread

Each thread contains

```text
Color

Brand

Weight

Material

Catalog Identifier
```

Thread properties are independent of machine implementation.

---

# Color Changes

Logical color changes consist of

```text
Tie-Off

↓

Trim

↓

Needle Change

↓

Tie-In
```

The compiler maps this sequence to the target machine.

---

# Frame

The frame represents

the embroidery workspace.

Properties

```text
Width

Height

Origin

Safe Area

Maximum Travel
```

---

# Hoop

The logical hoop defines

```text
Embroidery Region
```

Supported hoop definitions include

```text
Rectangular

Circular

Custom
```

Hoop compatibility is validated before export.

---

# Movement System

The movement subsystem controls

```text
Needle Position

Frame Movement

Jump Movement

Travel
```

Logical movement is continuous.

Physical movement depends on machine capabilities.

---

# Stitch Execution

Every logical stitch follows

```text
Move

↓

Needle Down

↓

Needle Up

↓

Next Position
```

The logical machine models manufacturing,

not motor control.

---

# Jump Execution

Logical jump

```text
Move

Without Stitch
```

The implementation varies by machine.

---

# Trim Execution

Logical trim

```text
Secure Thread

↓

Cut Thread
```

Machines implement trimming differently.

---

# Needle Change

Needle changes modify

```text
Current Needle

Current Thread
```

The compiler determines the appropriate machine command.

---

# Speed

Logical speed represents

```text
Desired Manufacturing Speed
```

Actual speed depends upon

- machine
- stitch type
- firmware
- user settings

---

# Machine Capabilities

Capabilities describe

what a machine supports.

Examples

```text
Automatic Trim

Thread Sensors

Maximum Speed

Needle Count

Maximum Stitch Length

Maximum Jump

Color Changes

Laser Pointer

Sequin Device

Chenille

Cording
```

Capabilities are descriptive,

not prescriptive.

---

# Capability Detection

Every machine profile exposes

```text
Supported

Unsupported

Optional
```

features.

Compilation validates against these capabilities.

---

# Machine Profiles

Examples

```text
Brother

Tajima

Barudan

Melco

Janome

Happy

ZSK

SWF

Ricoma
```

Profiles extend

the logical machine.

---

# Execution States

The machine transitions through

```text
Idle

Loaded

Ready

Running

Paused

Stopped

Completed

Error
```

Simulation and runtime use the same state model.

---

# Error States

Common logical errors

```text
Thread Break

Needle Break

Frame Limit

Trim Failure

Unknown Command

Machine Stop
```

Machine-specific diagnostics are mapped onto logical errors.

---

# Runtime Events

The machine emits events such as

```text
Started

Paused

Resumed

Stopped

Needle Changed

Trim Performed

Thread Break

Completed
```

These events integrate with the Event System.

---

# Command Processing

The logical machine consumes

```text
Machine Commands
```

Examples

```text
Move

Stitch

Jump

Trim

Color Change

Pause

Stop
```

The command processor validates execution order.

---

# Validation

Before execution,

the machine validates

- hoop size
- stitch limits
- needle availability
- thread assignments
- machine capabilities

Invalid jobs should fail before export.

---

# Simulation

The Simulation Pipeline executes

the logical machine,

not a specific hardware device.

Simulation should reproduce

- movement
- stitching
- trims
- jumps
- color changes

using the same logical command stream.

---

# Machine Compiler

The Machine Compiler converts

```text
Logical Machine Commands

↓

Machine-Specific Commands
```

The logical model is never altered during compilation.

---

# Export

Export serializes

compiled machine commands

into

```text
DST

PES

JEF

EXP

VP3

...

```

The logical machine remains file-format independent.

---

# Extensibility

Future capabilities may include

```text
Sequins

Chenille

Cording

Laser Alignment

Camera Systems

Automatic Thread Feed

Bobbin Monitoring

Network Machines
```

The logical model should evolve

without breaking existing machine profiles.

---

# Thread Safety

The logical machine is immutable during planning.

Execution state is isolated from design data.

Simulation and compilation may execute concurrently.

---

# Performance

The machine model should support

```text
Millions of Stitches

Large Hoop Sizes

Multi-Needle Machines

Real-Time Simulation
```

without modifying embroidery data.

---

# Domain Rules

The following always apply.

- The logical machine is machine-independent.
- Machine profiles extend, but do not replace, the logical model.
- Original embroidery data is never modified by the machine.
- Simulation executes the logical machine.
- Compilation translates logical commands into machine commands.
- Machine capabilities determine export validity.
- Logical execution is deterministic.
- Validation occurs before machine compilation.
- Runtime state is separate from design data.
- The logical machine represents manufacturing behavior, not hardware implementation.

---

# Out of Scope

This document does not define

- machine file formats
- firmware implementation
- serial communication
- USB protocols
- network communication
- physical motor control

These belong to the Machine Compiler and Runtime Architecture.

---

# Future Topics

Future machine documents expand

```text
Machine Commands

Machine Profiles

Capability System

Machine Runtime

Machine Communication

Thread Management

Hoop Management

Real-Time Monitoring
```

---

# Acceptance Criteria

The Machine Model specification is complete when

✓ A machine-independent embroidery machine abstraction is defined.

✓ Machine components and responsibilities are established.

✓ Machine state and execution lifecycle are documented.

✓ Logical machine commands are introduced.

✓ Capabilities and machine profiles are distinguished.

✓ Simulation and compilation responsibilities are separated.

✓ Validation and export interactions are defined.

✓ Domain rules establish deterministic machine behavior.

✓ The model supports multiple embroidery machine manufacturers.

✓ The Machine Model serves as the universal manufacturing abstraction for the entire embroidery platform.
