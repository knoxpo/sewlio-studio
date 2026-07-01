# Domain
## DOM-602 Fabric Simulation

**Document ID:** DOM-602  
**Title:** Fabric Simulation  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Simulation & Physics Team

**Related Documents**

```text
DOM-103 Transformations

DOM-200 Stitch Theory
DOM-204 Underlay
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-214 Optimization

DOM-300 Machine Model
DOM-306 Machine Speed

DOM-400 Thread Theory
DOM-404 Thread Weight

DOM-500 Fabric Theory
DOM-501 Stabilizers
DOM-502 Puckering
DOM-503 Fabric Stretch
DOM-504 Distortion
DOM-505 Material Profiles

DOM-600 Thread Physics
DOM-601 Needle Motion

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-016 Performance Architecture
ARCH-023 Runtime Lifecycle
```

---

# Purpose

This document defines the Fabric Simulation System used by Sewlio Studio.

Fabric Simulation provides a visual approximation of how fabric responds during embroidery.

Unlike manufacturing, which produces physical embroidery, the simulation predicts deformation, stretching, compression, puckering, and surface appearance in real time to help users evaluate embroidery quality before production.

The objective is fast, deterministic, and visually realistic simulation—not finite element analysis.

---

# Philosophy

Embroidery modifies

both

thread

and

fabric.

```text
Needle Motion

↓

Thread Placement

↓

Fabric Response

↓

Visible Embroidery
```

Realistic embroidery preview requires simulating the substrate,

not only the stitches.

---

# Goals

The Fabric Simulation System shall provide

- Realistic fabric visualization
- Deterministic behavior
- Interactive performance
- Material-aware rendering
- Quality prediction
- Extensible simulation architecture

---

# Definition

Fabric Simulation models the visual and mechanical response of fabric during embroidery.

The simulation approximates

- stretch
- compression
- recovery
- puckering
- surface deformation
- support from stabilizers

without reproducing full textile physics.

---

# Responsibilities

Fabric Simulation models

- surface deformation
- material response
- visual distortion
- interaction with thread
- interaction with stabilizers

It does **not** model

- molecular physics
- textile mechanics
- finite element analysis
- machine hardware

---

# Simulation Pipeline

```text
Embroidery Objects

↓

Needle Motion

↓

Thread Physics

↓

Fabric Simulation

↓

Rendering

↓

Viewport
```

---

# Fabric Simulation Model

Each simulated fabric contains

```text
Identifier

Material Profile

Stretch State

Compression State

Recovery State

Surface Relief

Simulation Metadata
```

---

# Simulation Layers

Fabric simulation operates on

multiple logical layers.

```text
Fabric Surface

↓

Stabilizer Layer

↓

Thread Layer

↓

Lighting Layer

↓

Viewport
```

Each layer contributes

to the final appearance.

---

# Fabric Surface

The simulated surface

represents

the embroidery substrate.

Surface properties include

```text
Texture

Pile

Roughness

Thickness

Reflectance
```

---

# Stretch Simulation

Stretch is estimated

using

fabric mechanical properties.

Simulation approximates

```text
Directional Stretch

Recovery

Elasticity

Local Movement
```

No permanent document changes

occur.

---

# Compression Simulation

Embroidery compresses

the fabric surface.

Simulation estimates

```text
Localized Compression

Density Effects

Layer Compression

Raised Areas
```

Compression affects

rendered appearance.

---

# Recovery Simulation

Following deformation,

the simulated fabric

recovers

according to

its material profile.

Recovery is

deterministic

and approximate.

---

# Puckering Simulation

The simulation estimates

localized puckering

using

```text
Density

Thread Tension

Fabric Stretch

Underlay

Stabilizers
```

Puckering is visualized,

not physically simulated.

---

# Distortion Simulation

The simulation estimates

dimensional changes

caused by

```text
Stretch

Compression

Pull

Push

Registration Shift
```

Estimated distortion

is used

for quality preview.

---

# Stabilizer Interaction

Stabilizers

reduce

simulated fabric movement.

Examples

```text
Cut Away

↓

Reduced Stretch

Top Film

↓

Improved Surface

Foam

↓

Raised Relief
```

Support materials

modify

simulation behavior.

---

# Thread Interaction

Thread Physics

applies forces

to

the simulated fabric.

Simulation estimates

```text
Surface Compression

Pile Displacement

Coverage

Thread Sinking
```

---

# Needle Interaction

Needle penetration

creates

localized deformation.

Simulation visualizes

```text
Penetration Points

Compression

Recovery

Thread Seating
```

Needle motion

drives

fabric response.

---

# Layer Interaction

Multiple embroidery layers

produce

```text
Raised Areas

Compression

Shadowing

Surface Relief
```

Layer ordering

affects

final appearance.

---

# Lighting Interaction

Fabric appearance

depends upon

```text
Surface Normals

Texture

Material

Lighting

Thread Reflection
```

Fabric and thread

are rendered together.

---

# Material Profiles

Simulation behavior

is derived from

Material Profiles.

Properties include

```text
Stretch

Recovery

Compression

Surface Finish

Pile Height

Stability
```

Profiles

remain immutable.

---

# Simulation Quality

Supported quality levels

```text
Basic

Standard

Professional

Photorealistic

Experimental
```

Higher levels

provide greater realism

with increased GPU cost.

---

# Level of Detail

Simulation dynamically

adjusts fidelity

based on

```text
Zoom Level

GPU Performance

Viewport Size

Visible Region

User Settings
```

Only visible regions

receive

maximum detail.

---

# Quality Analysis

Fabric Simulation

supports prediction of

```text
Puckering

Distortion

Registration Errors

Coverage

Compression

Thread Visibility
```

Quality analysis

uses simulation data

without modifying

embroidery geometry.

---

# Camera Modes

Supported visualization

includes

```text
Flat Preview

Material Preview

Fabric Preview

Photorealistic Preview

Cross Section

Production View
```

Each mode

uses

the same

simulation data.

---

# Rendering

Rendering combines

```text
Fabric Surface

Thread Geometry

Lighting

Shadows

Relief

Materials
```

into

the final viewport image.

---

# Determinism

Given identical inputs,

Fabric Simulation

must always produce

identical outputs.

Random behavior

is prohibited.

---

# Validation

Validation checks

```text
Missing Material Profile

Unsupported Fabric

Invalid Simulation Parameters

Profile Conflicts

Rendering Limits
```

Validation

never modifies

embroidery data.

---

# Manufacturing

Fabric Simulation

does not participate

in machine compilation.

It exists solely

for

```text
Visualization

Quality Prediction

Preview

Education
```

Manufacturing

consumes

logical embroidery data,

not simulated fabric.

---

# Extensibility

Future capabilities

may include

```text
GPU Compute Simulation

Finite Element Approximation

Digital Twin

AI Material Prediction

Camera Calibration

Real-Time Material Capture
```

The simulation architecture

must remain extensible.

---

# Thread Safety

Fabric Simulation

is read-only.

Simulation state

is isolated

from embroidery documents.

Multiple simulations

may execute

concurrently.

---

# Performance

The Fabric Simulation System

shall support

```text
Millions of Stitches

GPU Rendering

Interactive Editing

Real-Time Updates

LOD Rendering

Parallel Simulation
```

while maintaining

responsive editing.

---

# Domain Rules

The following always apply.

- Fabric Simulation is a visualization system.
- Simulation approximates fabric behavior rather than reproducing exact textile physics.
- Material Profiles determine simulation characteristics.
- Thread Physics influences simulated fabric response.
- Simulation never modifies embroidery geometry.
- Manufacturing does not depend on simulation.
- Simulation is deterministic.
- Rendering quality is configurable.
- Simulation state is isolated from document state.
- Fabric simulation is machine-independent.

---

# Out of Scope

This document does not define

- finite element analysis
- molecular material simulation
- textile engineering models
- machine hardware dynamics
- real-time physical measurement

These belong to future advanced simulation systems.

---

# Future Topics

Future simulation documents expand

```text
Digital Twin

GPU Compute Physics

Finite Element Approximation

Material Scanning

AI Fabric Prediction

Photorealistic Rendering

Mixed Reality Simulation
```

---

# Acceptance Criteria

The Fabric Simulation specification is complete when

✓ Fabric Simulation is defined as a visualization and quality prediction system.

✓ Surface deformation, stretch, compression, recovery, and puckering are documented.

✓ Material, thread, stabilizer, and needle interactions are established.

✓ Layering, lighting, and rendering behavior are defined.

✓ Quality analysis integration is documented.

✓ Simulation and manufacturing responsibilities are separated.

✓ Deterministic simulation behavior is established.

✓ Thread safety and performance characteristics are specified.

✓ Domain rules establish immutable, machine-independent simulation behavior.

✓ The Fabric Simulation System provides the canonical fabric visualization model for the embroidery platform.
