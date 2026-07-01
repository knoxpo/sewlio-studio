# Domain
## DOM-600 Thread Physics

**Document ID:** DOM-600  
**Title:** Thread Physics  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Simulation & Physics Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-214 Optimization

DOM-300 Machine Model
DOM-306 Machine Speed
DOM-308 Manufacturing

DOM-400 Thread Theory
DOM-401 Thread Types
DOM-404 Thread Weight
DOM-405 Thread Consumption

DOM-500 Fabric Theory
DOM-502 Puckering
DOM-503 Fabric Stretch
DOM-504 Distortion

ARCH-010 Simulation Pipeline
ARCH-014 AI Runtime
ARCH-016 Performance Architecture
ARCH-023 Runtime Lifecycle
```

---

# Purpose

This document defines the Thread Physics Model used by Sewlio Studio.

Thread Physics models the mechanical and visual behavior of embroidery thread during simulation.

Unlike manufacturing, which produces real embroidery, the simulation engine predicts how thread behaves when interacting with fabric, neighboring stitches, and machine operations.

The purpose is not perfect physical accuracy, but realistic, deterministic, and interactive visualization.

---

# Philosophy

Embroidery is a mechanical process.

Thread behaves like a flexible material,

not a drawn line.

```text
Machine Motion

↓

Thread Motion

↓

Fabric Interaction

↓

Visible Embroidery
```

Simulation should reproduce the appearance and behavior of embroidery,

not merely display stitch vectors.

---

# Goals

The Thread Physics System shall provide

- Realistic visualization
- Deterministic simulation
- Interactive performance
- Material-aware rendering
- Quality prediction
- Extensible physics modeling

---

# Definition

Thread Physics is the simulation of thread behavior during embroidery.

The simulation models

- thread placement
- curvature
- tension
- compression
- overlap
- reflection

without reproducing full real-world physics.

---

# Responsibilities

Thread Physics models

- thread appearance
- thread deformation
- thread interaction
- material response
- rendering characteristics

It does **not** model

- machine motors
- servo systems
- electrical systems
- exact textile mechanics

---

# Simulation Pipeline

```text
Embroidery Objects

↓

Machine Commands

↓

Thread Physics

↓

Rendering

↓

Viewport
```

---

# Thread Physics Model

Each simulated thread contains

```text
Identifier

Material

Diameter

Elasticity

Tension

Curvature

Reflection

Metadata
```

---

# Thread Representation

Thread is represented

as a continuous physical strand,

not as disconnected line segments.

Simulation approximates

the physical volume

occupied by thread.

---

# Thread Diameter

Thread diameter

affects

```text
Coverage

Overlap

Relief

Visibility

Reflection
```

Diameter originates

from the Thread Weight System.

---

# Thread Curvature

Thread naturally bends

between stitch penetrations.

Curvature depends upon

```text
Stitch Length

Thread Elasticity

Fabric Compression

Tension
```

---

# Thread Tension

Thread remains

under tension

throughout embroidery.

Simulation approximates

tension effects

to improve realism.

Tension affects

```text
Straightness

Compression

Reflection

Pull
```

---

# Elasticity

Thread stretches

slightly

under load.

Elasticity influences

```text
Curvature

Pull

Recovery

Compression
```

Material-specific

elasticity

is obtained

from the Thread Profile.

---

# Thread Compression

Thread compresses

when layered

or stitched

at high density.

Compression influences

```text
Surface Relief

Coverage

Reflection

Visual Thickness
```

---

# Thread Recovery

Following deformation,

thread attempts

to recover

its natural shape.

Recovery is approximated

rather than physically simulated.

---

# Thread Reflection

Embroidery appearance

depends heavily upon

thread reflection.

Reflection depends on

```text
Material

Surface Finish

Viewing Angle

Lighting

Thread Direction
```

Simulation should reproduce

directional highlights.

---

# Material Interaction

Different thread materials

behave differently.

Examples

```text
Rayon

↓

High Gloss

Polyester

↓

Medium Gloss

Cotton

↓

Matte

Metallic

↓

Strong Reflection
```

Material behavior

is data-driven.

---

# Fabric Interaction

Thread interacts

with the fabric surface.

Fabric properties influence

```text
Compression

Sinking

Pile

Stretch

Support
```

Simulation uses

fabric profiles

to estimate

visible results.

---

# Stitch Interaction

Adjacent stitches

interact visually.

Examples

```text
Overlap

Compression

Relief

Coverage
```

The simulation

considers

neighbor relationships.

---

# Layer Interaction

Multiple embroidery layers

may produce

```text
Raised Areas

Thread Compression

Shadowing

Relief
```

Layer order

affects

visual appearance.

---

# Needle Penetration

Each stitch

creates

penetration points.

Simulation

may visualize

```text
Needle Entry

Needle Exit

Thread Path
```

Needle mechanics

are approximated.

---

# Tension Relaxation

After placement,

thread relaxes slightly.

Relaxation affects

```text
Final Curvature

Surface Shape

Visual Flow
```

The approximation

is deterministic.

---

# Pull Simulation

Thread tension

produces

localized pulling forces.

Simulation estimates

```text
Shrinkage

Alignment

Registration

Stress
```

These estimates

support quality analysis.

---

# Surface Relief

Embroidery creates

three-dimensional relief.

Simulation estimates

```text
Thread Height

Layer Thickness

Raised Satin

Foam Effects
```

Surface relief

improves realism.

---

# Lighting Model

Thread appearance

depends upon

```text
Light Direction

Viewing Direction

Material

Surface Finish

Normal Orientation
```

Simulation

uses physically inspired,

not fully physical,

lighting.

---

# Rendering Quality

Supported rendering modes

```text
Wireframe

Stitch

Material

Production Preview

Photorealistic Preview
```

Higher modes

require

additional computation.

---

# Physics Levels

Simulation supports

multiple fidelity levels.

```text
Basic

Standard

Professional

Experimental
```

Higher fidelity

improves realism

at increased cost.

---

# Performance Modes

Rendering quality

may adapt

according to

```text
Viewport Zoom

GPU Capability

Design Size

User Preferences
```

Simulation quality

scales dynamically.

---

# Quality Analysis

Thread Physics contributes

to

```text
Distortion

Puckering

Coverage

Visibility

Reflection

Thread Break Risk
```

Physics supports

quality estimation,

not manufacturing decisions.

---

# Simulation Determinism

Given identical inputs,

the Thread Physics System

must always produce

identical outputs.

No randomness

is permitted.

---

# Validation

Validation checks

```text
Unsupported Materials

Invalid Thread Profiles

Missing Material Data

Simulation Limits

Rendering Errors
```

Validation

never modifies

embroidery data.

---

# Manufacturing

Thread Physics

does not participate

in machine compilation.

It exists solely

for

```text
Simulation

Preview

Analysis

Visualization
```

---

# Extensibility

Future capabilities

may include

```text
GPU Physics

Dynamic Thread Relaxation

Volumetric Threads

Fiber Simulation

AI Material Models

Digital Twin Rendering
```

The simulation model

must remain extensible.

---

# Thread Safety

Thread Physics

is read-only.

Simulation state

is isolated

from embroidery data.

Multiple simulations

may execute

concurrently.

---

# Performance

The Thread Physics System

shall support

```text
Millions of Stitches

GPU Rendering

Real-Time Editing

LOD Rendering

Parallel Simulation
```

without affecting

editor responsiveness.

---

# Domain Rules

The following always apply.

- Thread Physics is a simulation system.
- Simulation approximates thread behavior rather than reproducing exact physics.
- Thread material influences appearance.
- Fabric properties influence simulated thread behavior.
- Simulation is deterministic.
- Thread Physics never modifies embroidery geometry.
- Manufacturing does not depend on Thread Physics.
- Rendering quality is configurable.
- Simulation state is isolated from document state.
- Physics calculations are machine-independent.

---

# Out of Scope

This document does not define

- finite element simulation
- machine dynamics
- motor mechanics
- textile engineering models
- computational fluid dynamics

These belong to future research and advanced simulation modules.

---

# Future Topics

Future simulation documents expand

```text
Fabric Physics

Volumetric Rendering

GPU Compute

Digital Twin

Fiber Simulation

Photorealistic Rendering

AI Simulation
```

---

# Acceptance Criteria

The Thread Physics specification is complete when

✓ Thread Physics is defined as a visualization and simulation system.

✓ Thread representation, tension, elasticity, curvature, and compression are documented.

✓ Material, fabric, stitch, and layer interactions are established.

✓ Reflection, lighting, and rendering modes are defined.

✓ Quality analysis integration is documented.

✓ Simulation and manufacturing responsibilities are separated.

✓ Deterministic simulation behavior is established.

✓ Thread safety and performance characteristics are specified.

✓ Domain rules establish immutable, machine-independent simulation behavior.

✓ The Thread Physics System provides the canonical physical simulation model for embroidery visualization.
