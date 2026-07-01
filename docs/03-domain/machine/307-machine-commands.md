# Domain
## DOM-307 Machine Commands

**Document ID:** DOM-307  
**Title:** Machine Commands  
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
DOM-302 Needle System
DOM-303 Thread Changes
DOM-304 Hoop System
DOM-305 Machine Limits
DOM-306 Machine Speed

ARCH-003 Command System
ARCH-004 Event System
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
ARCH-023 Runtime Lifecycle
```

---

# Purpose

This document defines the logical Machine Command System used by Sewlio Studio.

Machine Commands represent the universal instruction set executed by the logical embroidery machine.

They are independent of

- embroidery file formats
- machine manufacturers
- firmware implementations
- communication protocols

Machine Commands form the executable intermediate representation between optimized embroidery data and machine-specific output.

---

# Philosophy

The embroidery machine should execute

logical commands,

not manufacturer-specific instructions.

```text
Embroidery Objects

↓

Optimization

↓

Machine Commands

↓

Machine Compiler

↓

DST

PES

JEF

...
```

Machine commands represent manufacturing intent.

The compiler determines implementation.

---

# Goals

The Machine Command System shall provide

- Machine-independent execution
- Deterministic behavior
- Accurate simulation
- Portable compilation
- Extensible instruction set
- Stable execution semantics

---

# Definition

A Machine Command is a logical instruction executed by the Machine Runtime.

Commands describe

what the machine should do,

not

how a particular machine performs it.

---

# Responsibilities

Machine Commands describe

- movement
- stitching
- jumps
- trims
- thread transitions
- execution control
- runtime state

They do **not** perform

- optimization
- geometry generation
- machine encoding
- firmware communication

---

# Command Pipeline

```text
Artwork

↓

Embroidery Objects

↓

Optimization

↓

Machine Commands

↓

Machine Runtime

↓

Machine Compiler

↓

Machine File
```

---

# Command Stream

A completed embroidery design becomes

an ordered sequence of

```text
Machine Commands
```

Example

```text
Move

↓

Tie-In

↓

Stitch

↓

Jump

↓

Trim

↓

Needle Change

↓

Continue

↓

Stop
```

Execution order is deterministic.

---

# Command Categories

Machine commands belong to

```text
Movement

Stitching

Thread

Machine

Execution

Diagnostics
```

---

# Movement Commands

Movement commands reposition

the logical machine.

Supported commands

```text
Move

Jump

Home

MoveTo

MoveRelative
```

Movement alone

does not create embroidery.

---

# Stitch Commands

Stitch commands create embroidery.

Supported commands

```text
Stitch

Lock Stitch

Running Stitch

Satin Segment

Fill Segment
```

Higher-level stitch commands

may expand into

primitive stitches.

---

# Thread Commands

Thread commands manage

thread transitions.

Supported commands

```text
Tie-In

Tie-Off

Trim

Needle Change

Thread Change
```

These commands

modify runtime state.

---

# Machine Commands

Machine commands affect

logical machine behavior.

Supported commands

```text
Pause

Resume

Stop

End Design

Begin Design

Set Speed
```

---

# Execution Commands

Execution commands

control runtime flow.

Examples

```text
Begin

End

Wait

Checkpoint

Abort
```

Future runtimes

may support

advanced execution control.

---

# Diagnostics Commands

Special commands

may exist

for simulation

and debugging.

Examples

```text
Marker

Label

Breakpoint

Comment

Metadata
```

These commands

are ignored

during compilation

unless explicitly supported.

---

# Primitive Commands

Primitive commands

cannot be decomposed further.

Examples

```text
Move

Stitch

Jump

Trim

Pause
```

The Machine Runtime executes

only primitive commands.

---

# Composite Commands

Composite commands

expand into

multiple primitive commands.

Example

```text
Thread Change

↓

Tie-Off

↓

Trim

↓

Needle Change

↓

Tie-In
```

Expansion occurs

before runtime execution.

---

# Command Parameters

Every command

contains

```text
Identifier

Type

Parameters

Timestamp (optional)

Metadata

Flags
```

The parameter set

depends on

command type.

---

# Command Metadata

Commands may include

optional metadata

such as

```text
Object Identifier

Layer

Thread

Color

Simulation Marker

Diagnostics
```

Metadata does not

affect execution.

---

# Execution Context

Commands execute

within

the Machine Runtime context.

Context contains

```text
Current Position

Current Needle

Current Thread

Current Speed

Execution State
```

Commands modify

runtime state

through defined transitions.

---

# Command Validation

Before execution

each command

is validated for

```text
Valid Parameters

Machine Capability

Execution Order

Runtime State
```

Invalid commands

prevent compilation.

---

# Command Ordering

Commands execute

strictly

in sequence.

Example

```text
Move

↓

Tie-In

↓

Stitch

↓

Tie-Off

↓

Trim
```

Reordering

changes manufacturing behavior.

---

# Command Dependencies

Some commands

require

previous commands.

Examples

```text
Tie-In

↓

Stitch

Trim

↓

Tie-Off
```

Dependency validation

prevents invalid execution.

---

# Runtime State Changes

Each command

may update

```text
Coordinates

Needle

Thread

Speed

Machine State
```

Commands are the only

mechanism

for changing

logical machine state.

---

# Command Events

Every command

may emit

runtime events.

Examples

```text
Command Started

Command Completed

Command Failed

Command Skipped
```

These integrate

with the Event System.

---

# Simulation

Simulation executes

the same

Machine Command stream

used by

machine compilation.

Simulation should never

interpret embroidery geometry directly.

---

# Machine Compilation

The compiler converts

logical commands

into

manufacturer-specific commands.

Example

```text
Logical Trim

↓

DST Trim

PES Trim

JEF Trim
```

Logical command semantics

remain unchanged.

---

# Extensibility

Future command types

may include

```text
Laser

Camera

Sequins

Chenille

Cording

IoT Commands

Network Commands
```

New commands

should extend

the instruction set

without affecting

existing behavior.

---

# Thread Safety

Machine Commands

are immutable.

Execution state

is maintained separately

by the Machine Runtime.

Multiple simulations

may execute

the same command stream

concurrently.

---

# Performance

The command system

shall support

```text
Millions of Commands

Real-Time Execution

Streaming Compilation

Incremental Execution

Parallel Simulation
```

without modifying

command semantics.

---

# Domain Rules

The following always apply.

- Machine Commands are machine-independent.
- Commands describe manufacturing intent.
- Primitive commands are the executable unit of the runtime.
- Composite commands expand into primitive commands before execution.
- Commands execute sequentially.
- Commands are immutable.
- Runtime state changes only through command execution.
- Simulation executes the same logical command stream as compilation.
- Machine compilation preserves logical command semantics.
- Command metadata never affects execution behavior.

---

# Out of Scope

This document does not define

- binary embroidery file encoding
- firmware instructions
- USB communication
- machine networking
- physical motor control

These belong to the Machine Compiler and Runtime implementations.

---

# Future Topics

Future machine documents expand

```text
Machine Runtime

Streaming Execution

Live Machine Control

Command Recording

Execution Replay

Distributed Manufacturing
```

---

# Acceptance Criteria

The Machine Commands specification is complete when

✓ A universal logical instruction set is defined.

✓ Command categories and responsibilities are established.

✓ Primitive and composite commands are distinguished.

✓ Command parameters, metadata, and execution context are documented.

✓ Validation and dependency rules are specified.

✓ Simulation and machine compilation responsibilities are separated.

✓ Runtime state transitions are command-driven.

✓ Commands are immutable and machine-independent.

✓ The instruction set is extensible without breaking compatibility.

✓ Machine Commands serve as the executable intermediate representation of the embroidery manufacturing pipeline.
