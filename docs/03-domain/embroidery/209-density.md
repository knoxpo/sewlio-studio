# Domain
## DOM-209 Density

**Document ID:** DOM-209  
**Title:** Density  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Embroidery Domain Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-201 Running Stitch
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-212 Cornering
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines stitch density, one of the most critical parameters in machine embroidery.

Density determines how much thread is placed into a given region of fabric and directly influences

- coverage
- appearance
- thread consumption
- fabric distortion
- production time
- embroidery durability

Proper density selection separates professional embroidery from poor-quality embroidery.

---

# Philosophy

More stitches do **not** necessarily produce better embroidery.

The objective is to use

**the minimum amount of thread necessary to achieve the desired visual and structural result.**

```text
Geometry

↓

Density Planning

↓

Stitch Generation

↓

Embroidery
```

---

# Goals

The density system shall provide

- Predictable coverage
- Fabric-specific behavior
- Thread-specific adjustment
- Consistent visual quality
- Machine independence
- Deterministic generation

---

# Definition

Density describes how closely embroidery stitches are placed together.

Depending on stitch type,

density may represent

```text
Linear Spacing

or

Area Coverage
```

---

# Density Types

Supported density models

```text
Running Stitch Density

Satin Density

Fill Density

Underlay Density

Decorative Density
```

Each stitch family defines density differently.

---

# Running Stitch Density

Running Stitch density is determined by

```text
Distance

Between Consecutive Stitches
```

Typical values

```text
1.5 mm

↓

4.0 mm
```

Smaller spacing increases stitch count.

---

# Satin Density

Satin density is determined by

```text
Distance

Between Adjacent Needle Penetrations
```

Typical values

```text
0.30 mm

↓

0.45 mm
```

This is often called

```text
Row Spacing
```

---

# Fill Density

Fill density is determined by

```text
Distance

Between Fill Rows
```

Typical values

```text
0.35 mm

↓

0.50 mm
```

The actual value depends upon

- fabric
- thread
- pattern
- desired appearance

---

# Underlay Density

Underlay is intentionally lighter.

Typical spacing

```text
1.0 mm

↓

3.0 mm
```

Underlay exists for support,

not coverage.

---

# Density Units

Internally,

density is represented as

```text
Millimeters

Between Stitch Rows
```

Rather than

```text
Stitches per Inch
```

This keeps the system metric and machine-independent.

---

# Coverage

Higher density produces

```text
More Thread

↓

Greater Coverage
```

Lower density produces

```text
Less Thread

↓

Visible Fabric
```

Coverage is influenced by

- thread diameter
- stitch angle
- fabric color
- underlay

---

# Stitch Count

Density directly affects

```text
Total Stitch Count
```

Higher density

↓

More stitches

↓

Longer production time

↓

More thread consumption

---

# Fabric Influence

Fabric significantly influences density.

### Stable Woven

Supports

```text
Higher Density
```

---

### Stretch Fabric

Requires

```text
Lower Density

+

Additional Underlay
```

---

### Towels

Require

```text
Lower Density

+

Heavy Underlay
```

to prevent excessive pile compression.

---

### Thin Fabrics

Require

```text
Reduced Density
```

to prevent puckering.

---

# Thread Influence

Thread diameter affects density.

Example

```text
40 wt Thread

↓

Standard Density

30 wt Thread

↓

Lower Density

60 wt Thread

↓

Higher Density
```

The objective is constant visual coverage.

---

# Stitch Type Influence

Different stitch types require different density.

```text
Running

↓

Low

Satin

↓

Medium

Fill

↓

Variable
```

Density is never universal.

---

# Object Width

Wide satin columns require

```text
Reduced Density
```

to avoid excessive thread buildup.

Very narrow columns may require

slightly higher density.

---

# Fill Pattern Influence

Pattern affects perceived density.

Examples

```text
Tatami

↓

Uniform

Random Fill

↓

Variable

Motif Fill

↓

Pattern Dependent
```

---

# Stitch Angle Influence

Thread reflection changes with angle.

Different angles may require

slight density adjustment

to maintain consistent appearance.

---

# Underlay Interaction

Proper underlay often allows

```text
Reduced Top Density
```

while maintaining coverage.

Underlay and density should be optimized together.

---

# Pull Compensation Interaction

Pull compensation widens geometry.

Density must be recalculated

after compensation,

not before.

---

# Push Compensation Interaction

Push compensation changes geometry at

- corners
- ends
- boundaries

Density should remain visually consistent after adjustment.

---

# Adaptive Density

Density should vary according to

- object size
- curvature
- stitch angle
- fabric
- embroidery purpose

Uniform density is not always optimal.

---

# Gradient Density

Future versions may support

```text
High Density

↓

Medium Density

↓

Low Density
```

within a single embroidery object.

Applications

- artistic embroidery
- realistic shading
- textured fills

---

# Density Profiles

The system should support reusable profiles.

Examples

```text
Light Fabric

Heavy Fabric

Cap

Jacket

Towel

Leather
```

Profiles adjust

- density
- underlay
- compensation

together.

---

# Automatic Density

Automatic density selection considers

- stitch type
- fabric
- thread
- object width
- embroidery style

Professional users may override automatic values.

---

# Manual Density

Users may explicitly define

```text
Spacing

Coverage

Profile
```

Manual values override automatic recommendations.

---

# Simulation

Simulation should visualize

- stitch spacing
- coverage
- thread buildup
- estimated appearance

Simulation never modifies density.

---

# Machine Compilation

Machine compilation preserves logical density.

It may

- subdivide long stitches
- enforce machine limitations
- adjust movement commands

without changing intended coverage.

---

# Quality Factors

Proper density produces

- smooth coverage
- minimal distortion
- efficient production
- professional appearance

---

# Failure Modes

Density too high

```text
Thread Buildup

Puckering

Thread Breaks

Needle Heating

Stiff Embroidery

Long Production Time
```

---

Density too low

```text
Fabric Show-through

Poor Coverage

Weak Embroidery

Visible Gaps

Poor Appearance
```

---

Inconsistent density

```text
Uneven Reflection

Irregular Texture

Visible Pattern Changes
```

---

# Optimization

Optimization attempts to

- minimize thread usage
- reduce stitch count
- preserve appearance
- reduce distortion

Density optimization is a multi-objective problem.

---

# Domain Rules

The following always apply.

- Density defines stitch spacing, not stitch count directly.
- Density is stitch-type dependent.
- Fabric influences density selection.
- Thread weight influences density selection.
- Underlay and density should be optimized together.
- Pull compensation precedes density calculation.
- Density should remain visually consistent across similar objects.
- Automatic density may be overridden by the user.
- Machine compilation preserves logical density intent.
- Higher density is not inherently better embroidery.

---

# Out of Scope

This document does not define

- pull compensation algorithms
- stitch generation algorithms
- machine encoding
- thread physics
- AI optimization strategies

These are specified in later documents.

---

# Future Topics

Future embroidery documents expand

```text
Pull Compensation

Push Compensation

Cornering

Optimization

Fabric Profiles

AI Density Optimization
```

---

# Acceptance Criteria

The Density specification is complete when

✓ Density is defined independently for Running, Satin, Fill, and Underlay stitches.

✓ Density units and measurement methods are established.

✓ Fabric and thread influences are documented.

✓ Interaction with underlay and compensation is defined.

✓ Automatic and manual density control are supported.

✓ Common quality issues and failure modes are identified.

✓ Simulation and machine compilation responsibilities are separated.

✓ Domain rules establish deterministic, machine-independent behavior.

✓ Density optimization objectives are specified.

✓ Density is established as a core parameter governing embroidery quality and manufacturability.
