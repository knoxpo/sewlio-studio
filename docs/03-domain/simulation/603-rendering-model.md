# Domain
## DOM-603 Rendering Model

**Document ID:** DOM-603  
**Title:** Rendering Model  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Rendering & Visualization Team

**Related Documents**

```text
DOM-100 Coordinate System
DOM-103 Transformations

DOM-300 Machine Coordinates

DOM-400 Thread Theory
DOM-401 Thread Types
DOM-402 Thread Colors
DOM-404 Thread Weight

DOM-500 Fabric Theory
DOM-505 Material Profiles

DOM-600 Thread Physics
DOM-601 Needle Motion
DOM-602 Fabric Simulation

ARCH-010 Simulation Pipeline
ARCH-016 Performance Architecture
ARCH-023 Runtime Lifecycle
ARCH-028 Observability
```

---

# Purpose

This document defines the Rendering Model used by Sewlio Studio.

The Rendering Model converts the logical embroidery simulation into high-quality visual output for editing, previewing, manufacturing verification, and presentation.

Unlike the simulation systems, which compute embroidery behavior, the Rendering Model is responsible only for visualization.

---

# Philosophy

Rendering should display

what the embroidery

will look like,

not merely

what data exists.

```text
Embroidery Data

↓

Simulation

↓

Rendering

↓

Viewport
```

The renderer is a visualization engine,

not a geometry engine.

---

# Goals

The Rendering Model shall provide

- High-quality visualization
- Real-time interaction
- GPU-first rendering
- Deterministic output
- Scalable performance
- Extensible rendering architecture

---

# Definition

The Rendering Model converts simulation data into pixels displayed within the editor viewport.

Rendering combines

- embroidery geometry
- thread materials
- fabric materials
- lighting
- shadows
- camera configuration

to produce the final image.

---

# Responsibilities

The Rendering Model performs

- scene rendering
- lighting
- shading
- material rendering
- visibility determination
- viewport presentation

It does **not** perform

- stitch generation
- simulation
- optimization
- manufacturing

---

# Rendering Pipeline

```text
Embroidery Document

↓

Simulation Scene

↓

Rendering Scene

↓

GPU Rendering

↓

Viewport
```

Simulation always precedes rendering.

---

# Rendering Scene

The rendering scene contains

```text
Embroidery Geometry

Thread Instances

Fabric Surface

Lighting

Camera

Environment

Overlays
```

The scene is immutable

during a render pass.

---

# Scene Graph

The renderer organizes

the scene using

a hierarchical Scene Graph.

```text
Scene

├── Camera
├── Fabric
├── Embroidery
│   ├── Objects
│   ├── Thread Geometry
│   └── Simulation Data
├── Lighting
├── Overlays
└── Diagnostics
```

The Scene Graph

does not own

document data.

---

# Rendering Objects

Renderable objects include

```text
Fabric

Thread

Needle

Machine

Selection

Guides

Measurements

Debug Visualizations
```

Each renderer

is independent.

---

# Material System

Rendering uses

logical material definitions.

Materials describe

```text
Color

Reflectance

Roughness

Metallicity

Opacity

Emission

Normal Mapping
```

Material properties

originate from

domain objects,

not GPU resources.

---

# Thread Rendering

Thread rendering

visualizes

```text
Thread Width

Curvature

Reflection

Layering

Compression

Surface Relief
```

Thread appearance

is derived from

Thread Physics.

---

# Fabric Rendering

Fabric rendering

visualizes

```text
Surface Texture

Stretch

Compression

Pile

Lighting

Surface Relief
```

Fabric appearance

is derived from

Fabric Simulation.

---

# Lighting Model

Lighting simulates

illumination of

the embroidery scene.

Supported light types

```text
Directional

Point

Spot

Ambient

Environment
```

Lighting

is deterministic.

---

# Shadow Model

Shadows improve

depth perception.

Supported shadows

```text
Thread Shadows

Fabric Shadows

Object Shadows

Ambient Occlusion
```

Shadow quality

depends upon

render settings.

---

# Camera Model

Rendering supports

configurable cameras.

Supported modes

```text
Orthographic

Perspective

Isometric

Manufacturing View

Presentation View
```

Camera state

is independent

of document state.

---

# Projection

The renderer converts

simulation coordinates

into

screen coordinates

using

```text
Projection

View Matrix

Transform Matrix
```

Projection

never modifies

embroidery geometry.

---

# Rendering Modes

Supported viewport modes

```text
Wireframe

Stitch View

Thread View

Material View

Production Preview

Photorealistic Preview

Diagnostic View
```

Each mode

shares

the same

simulation data.

---

# Diagnostic Rendering

The renderer

may visualize

```text
Travel Paths

Jump Stitches

Needle Motion

Distortion

Density

Puckering

Thread Direction
```

Diagnostic overlays

do not alter

scene rendering.

---

# Overlay System

Overlays include

```text
Grid

Hoop

Selection

Bounding Boxes

Measurements

Guides

Debug Layers
```

Overlays

render separately

from

embroidery materials.

---

# Layer Ordering

Rendering order

is deterministic.

```text
Background

↓

Fabric

↓

Embroidery

↓

Machine

↓

Overlays

↓

User Interface
```

Each layer

has a defined purpose.

---

# Transparency

Rendering supports

```text
Alpha Blending

Material Opacity

Overlay Transparency

Ghost Rendering
```

Transparency

is configurable.

---

# Level of Detail

Rendering dynamically adjusts

scene complexity

using

```text
Zoom Level

Visible Region

GPU Capability

Object Count

Viewport Size
```

Invisible geometry

is not rendered.

---

# Culling

The renderer

uses

```text
View Frustum Culling

Object Culling

Layer Culling

Occlusion Culling

Instance Culling
```

to reduce

GPU workload.

---

# Instancing

Repeated geometry

should use

GPU instancing.

Examples

```text
Running Stitches

Fill Patterns

Thread Segments

Repeated Objects
```

Instancing

reduces

draw calls.

---

# GPU Resources

GPU-managed resources

include

```text
Buffers

Textures

Shaders

Materials

Framebuffers

Pipelines
```

Logical document objects

never own

GPU resources.

---

# Shader Pipeline

Rendering shaders

may include

```text
Thread Shader

Fabric Shader

Lighting Shader

Shadow Shader

Selection Shader

Post Processing
```

Shaders

are modular.

---

# Post Processing

Optional effects

include

```text
Anti-Aliasing

Tone Mapping

Bloom

Depth of Field

Color Correction

Ambient Occlusion
```

Effects

are configurable.

---

# Rendering Quality

Supported quality presets

```text
Low

Medium

High

Ultra

Professional
```

Quality

affects

visual fidelity,

not simulation.

---

# Rendering Performance

The renderer

targets

```text
Interactive Editing

Real-Time Preview

Large Designs

Multi-Monitor

GPU Acceleration
```

Performance

is prioritized

over

photorealistic accuracy.

---

# Rendering Determinism

Given identical

simulation data,

camera,

lighting,

and settings,

the renderer

must produce

identical output.

---

# Resource Lifetime

GPU resources

are managed

independently

from

embroidery documents.

Resources are

```text
Created

Cached

Reused

Released
```

through

the Resource Manager.

---

# Thread Safety

Rendering is

read-only.

Simulation data

is immutable

during rendering.

Multiple viewports

may render

the same document

simultaneously.

---

# Validation

Validation checks

```text
Missing Materials

Missing Shaders

GPU Limits

Invalid Scene Graph

Unsupported Features
```

Rendering failures

must not affect

document integrity.

---

# Manufacturing

The Rendering Model

is completely independent

of

machine compilation

and

manufacturing.

Rendering exists solely

for

```text
Visualization

Preview

Diagnostics

Presentation
```

---

# Extensibility

Future capabilities

may include

```text
Path Tracing

Ray Tracing

GPU Compute Rendering

VR

AR

HDR

Cloud Rendering

AI Denoising
```

The renderer

must remain extensible.

---

# Domain Rules

The following always apply.

- Rendering consumes simulation data.
- Rendering never modifies embroidery data.
- Simulation precedes rendering.
- GPU resources are separate from document resources.
- Materials define appearance, not geometry.
- Rendering is deterministic.
- Rendering quality is configurable.
- Multiple viewports may render concurrently.
- Manufacturing is independent of rendering.
- Rendering remains machine-independent.

---

# Out of Scope

This document does not define

- embroidery simulation
- machine execution
- stitch generation
- physics computation
- GPU driver implementation

These belong to their respective simulation and runtime systems.

---

# Future Topics

Future rendering documents expand

```text
Physically Based Rendering

Ray Tracing

GPU Compute

Virtual Reality

Augmented Reality

Cloud Rendering

Neural Rendering
```

---

# Acceptance Criteria

The Rendering Model specification is complete when

✓ Rendering responsibilities are clearly separated from simulation.

✓ Scene Graph and rendering pipeline are defined.

✓ Material, lighting, shadow, and camera systems are documented.

✓ Layer ordering, overlays, and diagnostic rendering are established.

✓ GPU resource management and shader architecture are specified.

✓ Level-of-detail and performance strategies are documented.

✓ Deterministic rendering behavior is established.

✓ Thread safety and validation requirements are specified.

✓ Domain rules establish immutable, machine-independent rendering behavior.

✓ The Rendering Model provides the canonical visualization architecture for Sewlio Studio.
