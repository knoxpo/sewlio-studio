# Domain
## DOM-301 Machine Coordinates

**Document ID:** DOM-301  
**Title:** Machine Coordinates  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Machine Runtime Team

**Related Documents**

```text
DOM-100 Coordinate System
DOM-103 Transformations
DOM-200 Stitch Theory
DOM-300 Machine Model

ARCH-005 Document Model
ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
```

---

# Purpose

This document defines the Machine Coordinate System used by the logical machine during embroidery execution.

Machine coordinates represent the physical positions executed by an embroidery machine after all geometric processing, embroidery generation, and manufacturing optimizations have completed.

They form the final spatial representation before machine-specific encoding.

---

# Philosophy

Design coordinates represent intent.

Machine coordinates represent execution.

```text
Artwork

↓

Geometry

↓

Embroidery

↓

Machine Coordinates

↓

Machine Format

↓

Physical Machine
```

Machine coordinates are independent of any specific embroidery file format.

---

# Goals

The coordinate system shall provide

- Machine independence
- High numerical precision
- Deterministic execution
- Consistent simulation
- Reliable compilation
- Hardware abstraction

---

# Definition

Machine Coordinates describe the logical position of the embroidery needle relative to the embroidery hoop during execution.

They are expressed in physical units before conversion into machine-specific units.

---

# Coordinate Pipeline

```text
Artwork Coordinates

↓

Geometry Coordinates

↓

Embroidery Coordinates

↓

Machine Coordinates

↓

Machine Compiler

↓

DST / PES / JEF / ...
```

Each stage progressively approaches physical manufacturing.

---

# Coordinate Space

The logical machine operates in

```text
2D Cartesian Space
```

Axes

```text
X

Horizontal

Y

Vertical
```

Coordinates are expressed in millimeters.

---

# Origin

The logical origin is

```text
(0,0)
```

The origin is established by

the selected hoop and document configuration.

The machine compiler translates this origin to the target machine.

---

# Units

Internal unit

```text
Millimeters
```

No machine-specific unit is used within the logical machine.

Unit conversion occurs only during compilation.

---

# Precision

Internal precision

```text
64-bit Floating Point
```

Precision reduction occurs only when exporting to a machine format.

---

# Coordinate Types

The machine model uses

```text
Absolute Coordinates

Relative Coordinates

Machine Coordinates
```

Absolute and relative representations are logical.

Machine formats determine their physical encoding.

---

# Absolute Coordinates

Each position is measured from

```text
Machine Origin
```

Example

```text
(125.40, 82.15)
```

Useful for

- simulation
- diagnostics
- visualization

---

# Relative Coordinates

Each position is measured from

the previous stitch.

Example

```text
Previous

↓

ΔX

ΔY
```

Many embroidery formats encode movement this way.

Relative conversion occurs during compilation.

---

# Needle Position

The logical machine maintains

```text
Current X

Current Y
```

Every machine command updates this state.

---

# Stitch Coordinates

Every stitch contains

```text
Start Position

End Position
```

The machine executes movement between these positions.

---

# Jump Coordinates

Jump commands move

the needle

without creating embroidery.

Jump coordinates follow the same coordinate system as stitches.

---

# Trim Position

Trim operations occur

at the current machine position.

Trims do not change coordinates.

---

# Color Change Position

Color changes preserve

the current coordinate.

Needle position remains unchanged.

---

# Hoop Coordinates

Machine coordinates are constrained by

```text
Hoop Boundary
```

Embroidery outside the hoop is invalid.

Validation occurs before export.

---

# Safe Area

The machine profile defines

```text
Safe Sewing Area
```

Designs exceeding this area

must fail validation.

---

# Maximum Travel

Each machine profile defines

maximum travel limits.

Examples

```text
Maximum X

Maximum Y

Maximum Jump

Maximum Stitch Length
```

The compiler validates

all machine coordinates.

---

# Coordinate Transformations

Machine coordinates result from

```text
Object Transformations

↓

Compensation

↓

Optimization

↓

Machine Placement
```

The machine itself performs

no additional geometric transformation.

---

# Coordinate Normalization

Before compilation

coordinates are normalized

to

- hoop origin
- machine origin
- export profile

Normalization is deterministic.

---

# Frame Movement

Physical embroidery machines move

the embroidery frame,

not the needle.

The logical machine abstracts this distinction.

Machine coordinates always represent

needle-relative embroidery positions.

---

# Simulation

Simulation executes

the logical machine coordinates directly.

No machine-specific coordinate conversion

occurs during simulation.

---

# Coordinate Validation

Validation ensures

```text
Inside Hoop

Valid Stitch Length

Valid Jump Distance

Supported Travel

Finite Coordinates
```

Invalid coordinates prevent export.

---

# Coordinate Constraints

Coordinates shall never contain

```text
NaN

Infinity

Undefined

Overflow
```

Every coordinate must remain finite.

---

# Coordinate Accuracy

Logical coordinates preserve

full geometric precision

until the export stage.

Machine-specific rounding occurs

only once.

---

# Machine Conversion

During compilation

machine coordinates become

machine-specific values.

Examples

```text
Millimeters

↓

Machine Units

↓

Binary Encoding
```

Each machine profile defines

its own conversion rules.

---

# Stitch Ordering

Coordinates are interpreted

according to stitch order.

Two identical coordinate sets

with different execution order

represent different embroidery.

---

# Coordinate Cache

Machine coordinates are

derived data.

They may be cached

for

- simulation
- rendering
- export

Caches are invalidated

when embroidery changes.

---

# Incremental Updates

Only modified embroidery objects

should regenerate

machine coordinates.

Supported by

```text
Dependency Graph

↓

Task Scheduler
```

---

# Thread Safety

Coordinate generation

must be deterministic

and thread-safe.

Independent embroidery objects

may compute coordinates in parallel.

---

# Performance

The coordinate system shall support

```text
Millions of Stitches

Large Hoop Sizes

Multi-Needle Designs

Real-Time Simulation
```

without loss of precision.

---

# Domain Rules

The following always apply.

- Machine coordinates are expressed in millimeters.
- Original artwork coordinates are never modified.
- Machine coordinates are derived after embroidery generation.
- Simulation operates directly on logical machine coordinates.
- Export performs the only machine-specific coordinate conversion.
- Every coordinate must remain finite.
- Hoop validation occurs before export.
- Coordinate generation is deterministic.
- Incremental coordinate regeneration is preferred.
- Machine coordinates remain independent of embroidery file formats.

---

# Out of Scope

This document does not define

- binary machine encoding
- coordinate compression
- firmware coordinate systems
- USB communication
- motor control

These belong to the Machine Compiler and Runtime Architecture.

---

# Future Topics

Future machine documents expand

```text
Machine Commands

Movement Planning

Acceleration Profiles

Real-Time Streaming

Machine Synchronization

Firmware Integration
```

---

# Acceptance Criteria

The Machine Coordinates specification is complete when

✓ The logical machine coordinate system is defined.

✓ Coordinate units and precision are established.

✓ Absolute and relative coordinate concepts are distinguished.

✓ Hoop constraints and validation are specified.

✓ Simulation and machine compilation responsibilities are separated.

✓ Coordinate normalization and transformation stages are documented.

✓ Thread-safe incremental coordinate generation is supported.

✓ Domain rules establish deterministic coordinate behavior.

✓ Machine-specific conversion is deferred to compilation.

✓ Machine coordinates serve as the canonical execution-space representation for all embroidery machines.
