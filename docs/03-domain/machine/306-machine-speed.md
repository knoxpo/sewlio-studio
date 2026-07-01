# Domain
## DOM-306 Machine Speed

**Document ID:** DOM-306  
**Title:** Machine Speed  
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
DOM-300 Machine Model
DOM-301 Machine Coordinates
DOM-305 Machine Limits

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
ARCH-016 Performance Architecture
```

---

# Purpose

This document defines the Machine Speed Model used by Sewlio Studio.

Machine speed represents the rate at which the logical embroidery machine executes manufacturing operations.

The logical model separates desired manufacturing behavior from the physical speed capabilities of individual embroidery machines.

---

# Philosophy

Speed is a manufacturing characteristic,

not a property of the embroidery design.

```text
Embroidery Design

↓

Machine Planning

↓

Speed Planning

↓

Machine Execution
```

The same embroidery design should execute correctly on both slow hobby machines and high-speed industrial machines.

---

# Goals

The Machine Speed System shall provide

- Machine-independent speed planning
- Predictable production estimates
- Safe manufacturing
- Accurate simulation
- Machine profile compatibility
- Deterministic execution

---

# Definition

Machine Speed defines the desired execution rate of embroidery operations during manufacturing.

Logical speed is independent of

- machine manufacturer
- firmware
- file format

Physical execution speed is determined by the selected machine profile.

---

# Responsibilities

The Machine Speed System manages

- logical sewing speed
- speed profiles
- operation-specific speeds
- production estimation
- runtime state
- capability validation

It does **not** manage

- motor control
- firmware acceleration
- stitch generation
- embroidery geometry

---

# Speed Pipeline

```text
Embroidery Objects

↓

Manufacturing Planning

↓

Speed Planning

↓

Machine Commands

↓

Machine Compiler

↓

Machine Execution
```

---

# Speed Units

Logical speed is represented as

```text
Stitches Per Minute (SPM)
```

Example

```text
400 SPM

600 SPM

850 SPM

1200 SPM
```

Internal planning always uses logical SPM.

---

# Logical Speed

Logical speed represents

the intended production speed

before machine-specific adjustments.

The logical model does not assume

any specific hardware capability.

---

# Machine Speed

Each machine profile defines

```text
Maximum Speed

Recommended Speed

Minimum Speed
```

The compiler validates

requested speeds

against these limits.

---

# Speed Profiles

Reusable profiles include

```text
Draft

Standard

Quality

Production

Maximum
```

Profiles configure

operation-specific speeds.

---

# Operation Types

Different machine operations

may execute

at different speeds.

Examples

```text
Stitch

Jump

Trim

Color Change

Needle Change

Pause
```

---

# Stitch Speed

Normal embroidery stitches

typically execute

at the highest

continuous sewing speed.

Actual values depend upon

- stitch type
- machine profile
- production profile

---

# Jump Speed

Jump movements

often execute faster

than sewing operations

because thread formation

is not required.

Some machines,

however,

use identical movement speeds.

---

# Trim Speed

Trim operations

temporarily interrupt

continuous sewing.

Their execution time

is determined by

the machine profile.

---

# Needle Change Speed

Needle changes

introduce

manufacturing delays.

The runtime models

these as

logical state transitions

rather than stitch operations.

---

# Color Change Speed

Color changes

may involve

```text
Trim

↓

Needle Change

↓

Thread Engagement

↓

Resume
```

Production estimation

includes this transition time.

---

# Speed Planning

The planner selects

appropriate speeds

using

```text
Machine Profile

↓

Operation Type

↓

Production Profile

↓

User Preferences
```

Planning is deterministic.

---

# Automatic Speed Selection

Automatic planning

considers

- stitch density
- stitch type
- jump frequency
- production profile
- machine capabilities

Users may override

automatic decisions.

---

# Manual Speed Override

Professional users

may explicitly assign

```text
Global Speed

Object Speed

Operation Speed
```

Overrides remain

logical

until compilation.

---

# Speed Constraints

Machine profiles define

safe operating ranges.

Examples

```text
Maximum Satin Speed

Maximum Metallic Speed

Maximum Jump Speed
```

Validation occurs

before export.

---

# Thread Influence

Certain thread types

require

reduced sewing speeds.

Examples

```text
Metallic

Glow

Heavy Thread

Silk
```

Speed planning

should account

for thread characteristics.

---

# Fabric Influence

Fabric may affect

recommended speed.

Examples

```text
Leather

Stretch Fabric

Towels

Caps
```

Certain materials

benefit from

slower execution.

---

# Stitch Type Influence

Different stitch families

may recommend

different speeds.

Examples

```text
Running Stitch

Fast

Satin Stitch

Moderate

Fill Stitch

Standard
```

Profiles define

recommended values.

---

# Production Profiles

Production profiles

combine

```text
Speed

Density

Compensation

Underlay

Optimization
```

into reusable manufacturing presets.

---

# Estimated Runtime

Production estimation

uses

```text
Total Stitches

+

Jump Time

+

Trim Time

+

Needle Changes

+

Color Changes

↓

Estimated Duration
```

Estimates remain

machine-profile dependent.

---

# Simulation

Simulation

may execute

at

```text
Real Time

Scaled Time

Unlimited Speed

Step-by-Step
```

Simulation speed

does not affect

logical machine speed.

---

# Runtime State

The runtime maintains

```text
Current Speed

Target Speed

Operation Type

Execution Mode
```

These values

may change

during execution.

---

# Machine Compilation

The compiler

translates

logical speed

into

machine-specific commands

or metadata

when supported.

Machines lacking

speed control

simply ignore

logical speed settings.

---

# Error Conditions

Common speed validation errors

```text
Unsupported Speed

Exceeds Machine Limit

Invalid Speed Profile

Unsupported Thread Speed

Capability Conflict
```

Errors prevent

unsafe exports.

---

# Performance

Speed planning

shall support

```text
Large Designs

Millions of Stitches

Batch Export

Real-Time Simulation
```

without modifying

embroidery geometry.

---

# Extensibility

Future capabilities

may include

```text
Adaptive Speed

AI Speed Optimization

Thermal Management

Needle Cooling

Dynamic Speed Curves

Machine Learning Profiles
```

The logical model

should evolve

without breaking compatibility.

---

# Domain Rules

The following always apply.

- Speed is a manufacturing property, not a design property.
- Logical speed is expressed in stitches per minute.
- Machine profiles define physical speed limits.
- Different operations may execute at different speeds.
- Automatic speed planning should be deterministic.
- User overrides take precedence over automatic planning.
- Simulation speed is independent of logical machine speed.
- Machine compilation adapts logical speed to machine capabilities.
- Validation occurs before compilation.
- Speed planning never modifies embroidery geometry.

---

# Out of Scope

This document does not define

- motor acceleration
- servo control
- firmware timing
- electrical control systems
- hardware motion planning

These belong to the machine runtime and firmware domains.

---

# Future Topics

Future machine documents expand

```text
Acceleration Profiles

Motion Planning

Thermal Monitoring

Adaptive Manufacturing

Machine Telemetry

Real-Time Optimization
```

---

# Acceptance Criteria

The Machine Speed specification is complete when

✓ Logical machine speed is defined independently of hardware.

✓ Speed units and operation-specific behavior are established.

✓ Speed profiles and planning workflows are documented.

✓ Machine, fabric, thread, and stitch-type influences are identified.

✓ Automatic and manual speed planning are supported.

✓ Runtime estimation and simulation behavior are specified.

✓ Machine compilation responsibilities are separated from logical planning.

✓ Domain rules establish deterministic speed behavior.

✓ Machine-specific speed capabilities remain isolated behind machine profiles.

✓ The Machine Speed System provides the canonical production-speed model for the embroidery platform.
