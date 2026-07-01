# Domain
## DOM-601 Needle Motion

**Document ID:** DOM-601  
**Title:** Needle Motion  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Simulation & Physics Team

**Related Documents**

```text
DOM-103 Transformations

DOM-200 Stitch Theory
DOM-201 Running Stitch
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing

DOM-300 Machine Model
DOM-301 Machine Coordinates
DOM-302 Needle System
DOM-303 Thread Changes
DOM-306 Machine Speed
DOM-307 Machine Commands

DOM-500 Fabric Theory
DOM-503 Fabric Stretch

DOM-600 Thread Physics

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-023 Runtime Lifecycle
```

---

# Purpose

This document defines the Needle Motion Simulation used by Sewlio Studio.

Needle Motion simulates the movement of embroidery needles during machine execution.

Unlike the Machine Compiler, which generates executable machine commands, the Needle Motion System provides a visual and analytical representation of machine operation for preview, debugging, education, diagnostics, and manufacturing verification.

---

# Philosophy

The embroidery machine does not draw lines.

It performs

a sequence of

needle penetrations.

```text
Machine Commands

↓

Needle Motion

↓

Thread Placement

↓

Embroidery Formation
```

The simulation should reproduce how the machine behaves,

not merely how the design appears.

---

# Goals

The Needle Motion System shall provide

- Accurate machine visualization
- Deterministic playback
- Manufacturing verification
- Educational visualization
- Debugging support
- Extensible simulation

---

# Definition

Needle Motion represents the simulated movement of embroidery needles during execution.

Simulation includes

- needle positioning
- penetration
- retraction
- thread placement
- color changes
- trim operations

Simulation does not execute real machine hardware.

---

# Responsibilities

Needle Motion simulates

- needle movement
- penetration timing
- thread placement
- machine sequencing
- playback

It does **not** control

- motors
- servos
- sensors
- physical hardware

---

# Simulation Pipeline

```text
Embroidery IR

↓

Machine Commands

↓

Needle Motion

↓

Thread Physics

↓

Rendering
```

---

# Needle Motion Model

Each simulated needle contains

```text
Needle ID

Position

State

Current Thread

Current Color

Penetration State

Metadata
```

---

# Motion States

The needle exists in

one of the following states

```text
Idle

Travel

Descending

Penetrating

Lowest Point

Retracting

Trim

Thread Change

Completed
```

State transitions

are deterministic.

---

# Motion Lifecycle

A typical embroidery stitch

follows

```text
Travel

↓

Needle Down

↓

Fabric Penetration

↓

Thread Capture

↓

Needle Up

↓

Travel
```

The sequence repeats

for every stitch.

---

# Needle Position

Simulation tracks

needle position

within

machine coordinates.

Coordinates remain

independent of

screen coordinates.

---

# Needle Penetration

Penetration occurs

when the needle

passes through

the fabric.

Simulation records

```text
Entry Point

Exit Point

Time

Associated Stitch
```

Penetration

creates

thread anchoring.

---

# Needle Retraction

After penetration,

the needle retracts,

allowing

thread tightening

and

fabric recovery.

Simulation approximates

the timing.

---

# Travel Motion

Travel occurs

between consecutive stitches.

Travel may represent

```text
Running Stitch

Jump

Color Change

Trim Movement
```

Travel itself

does not penetrate

the fabric.

---

# Jump Motion

Jump movements

occur

without stitching.

Simulation visualizes

```text
Travel Path

Needle Position

Thread Path

Jump Length
```

Users may optionally

hide jump visualization.

---

# Trim Motion

Trim operations

interrupt

normal stitching.

Simulation visualizes

```text
Thread Cut

Needle Stop

Restart Point
```

Trim events

are discrete operations.

---

# Thread Changes

Thread changes

temporarily suspend

needle motion.

Simulation displays

```text
Needle Stop

Color Change

Needle Resume
```

The thread transition

is animated.

---

# Multi-Needle Machines

Machines

may contain

multiple needles.

Simulation tracks

```text
Active Needle

Inactive Needles

Current Thread

Needle Index
```

Only one needle

is active

at a time

for conventional machines.

---

# Multi-Head Machines

Multiple embroidery heads

execute

the same design

simultaneously.

Simulation

may display

```text
Individual Heads

Synchronized Motion

Shared Timeline
```

Each head

maintains

its own state.

---

# Timing

Playback timing

is derived from

```text
Machine Speed

Travel Distance

Thread Change

Trim Delay
```

Timing

is deterministic.

---

# Playback Modes

Supported playback

includes

```text
Real Time

Fast

Slow Motion

Frame Advance

Step-by-Step
```

Playback speed

does not alter

simulation results.

---

# Camera Tracking

The viewport

may follow

```text
Needle

Current Stitch

Current Object

Entire Design
```

Camera behavior

is configurable.

---

# Machine Coordinates

Needle motion

is simulated

using

machine coordinates,

not document coordinates.

Coordinate conversion

occurs

before simulation.

---

# Thread Interaction

Needle motion

creates

thread placement.

Thread Physics

receives

needle events

to construct

visible thread geometry.

---

# Fabric Interaction

Needle penetration

interacts

with the fabric profile.

Simulation estimates

```text
Compression

Stretch

Penetration

Recovery
```

Full textile simulation

is outside scope.

---

# Synchronization

Needle Motion

must remain synchronized

with

```text
Machine Commands

Thread Physics

Rendering

Playback Timeline

Diagnostics
```

Synchronization

is frame-independent.

---

# Diagnostics

Simulation assists

with

```text
Unexpected Jumps

Trim Locations

Color Changes

Sequencing Errors

Needle Path Review
```

Diagnostics

never modify

embroidery data.

---

# Simulation Modes

Supported visualization

includes

```text
Needle Only

Needle + Thread

Machine View

X-Ray View

Manufacturing View
```

---

# Quality Analysis

Needle Motion

supports

```text
Travel Analysis

Trim Analysis

Needle Count

Machine Efficiency

Production Review
```

---

# Manufacturing

Needle Motion

is a visualization layer.

Manufacturing

consumes

machine commands,

not simulated motion.

---

# Validation

Validation checks

```text
Invalid Motion

Impossible State

Unsupported Machine

Coordinate Overflow

Synchronization Failure
```

Simulation

fails safely

without modifying

machine commands.

---

# Extensibility

Future capabilities

may include

```text
Servo Animation

Needle Flex

Machine Vibration

Collision Detection

Digital Twin

VR Manufacturing
```

The simulation model

must remain extensible.

---

# Thread Safety

Needle Motion

is read-only.

Simulation state

is isolated

from embroidery documents.

Multiple simulations

may execute

concurrently.

---

# Performance

The Needle Motion System

shall support

```text
Millions of Stitches

GPU Rendering

Interactive Playback

Frame Scrubbing

Parallel Simulation
```

without affecting

editor responsiveness.

---

# Domain Rules

The following always apply.

- Needle Motion is a simulation system.
- Needle Motion is derived from machine commands.
- Needle penetration defines stitch placement.
- Travel motion does not create stitches.
- Thread changes temporarily suspend stitching.
- Needle Motion never modifies embroidery data.
- Simulation is deterministic.
- Rendering consumes simulated motion.
- Manufacturing remains independent of simulation.
- Playback timing is configurable without affecting simulation accuracy.

---

# Out of Scope

This document does not define

- servo control
- motor physics
- machine firmware
- hardware communication
- real-time CNC control

These belong to machine firmware and hardware integration.

---

# Future Topics

Future simulation documents expand

```text
Digital Twin Machines

Machine Animation

Servo Simulation

Collision Detection

Machine Diagnostics

VR Simulation

Remote Manufacturing
```

---

# Acceptance Criteria

The Needle Motion specification is complete when

✓ Needle motion is defined as a visualization and analysis system.

✓ Motion states and lifecycle are documented.

✓ Penetration, travel, trims, and thread changes are specified.

✓ Multi-needle and multi-head support is introduced.

✓ Playback modes and timing behavior are defined.

✓ Diagnostics and quality analysis responsibilities are documented.

✓ Simulation and manufacturing responsibilities are separated.

✓ Domain rules establish deterministic needle motion behavior.

✓ Simulation remains read-only and machine-independent.

✓ The Needle Motion System provides the canonical animation model for embroidery machine execution.
