# Domain
## DOM-901 AI Digitizing Rules

**Document ID:** DOM-901  
**Title:** AI Digitizing Rules  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** AI Digitizing Team

**Related Documents**

```text
DOM-101 Paths
DOM-102 Curves
DOM-105 Geometry Algorithms

DOM-200 Stitch Theory
DOM-201 Running Stitch
DOM-202 Satin Stitch
DOM-203 Fill Stitch
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-212 Cornering
DOM-213 Overlaps
DOM-214 Optimization

DOM-300 Machine Model
DOM-305 Machine Limits

DOM-400 Thread Theory
DOM-404 Thread Weight

DOM-500 Fabric Theory
DOM-501 Stabilizers
DOM-503 Fabric Stretch
DOM-505 Material Profiles

DOM-700 Vector Import
DOM-701 Raster Import
DOM-703 Normalization

DOM-900 AI Domain Knowledge

ARCH-009 Digitizer Pipeline
ARCH-014 AI Runtime
ARCH-021 Architecture Principles
```

---

# Purpose

These rules are embroidery-specific digitizing rules. Future weaving and printing AI modules must define their own canonical rules instead of reusing stitch terminology.

This document defines the AI Digitizing Rules used by Sewlio Studio.

The AI Digitizer transforms artwork into embroidery by applying explicit embroidery knowledge rather than relying solely on statistical prediction.

The objective is to produce embroidery that is explainable, deterministic, editable, and commercially manufacturable.

---

# Philosophy

AI should

digitize

like

an expert embroiderer.

```text
Artwork

↓

Domain Rules

↓

AI Reasoning

↓

Digitizing Plan

↓

Embroidery Objects
```

The AI

does not invent

embroidery.

It applies

known embroidery principles.

---

# Goals

The AI Digitizing Rules shall provide

- Explainable digitizing
- Deterministic recommendations
- Manufacturable embroidery
- Material-aware decisions
- Machine-aware planning
- Editable results

---

# Definition

Digitizing Rules

describe

how AI converts

geometry

into

embroidery objects.

Rules define

```text
Object Classification

Stitch Selection

Direction

Density

Underlay

Compensation

Sequencing

Optimization
```

---

# Responsibilities

The AI Digitizer performs

- artwork analysis
- object classification
- stitch planning
- parameter recommendation
- sequencing
- optimization guidance

It does **not** perform

- machine export
- rendering
- machine execution
- neural model training

---

# Digitizing Pipeline

```text
Artwork

↓

Geometry Analysis

↓

Object Classification

↓

Rule Evaluation

↓

Digitizing Plan

↓

Embroidery Objects
```

Every decision

is rule driven.

---

# Knowledge Sources

Rules originate from

```text
Embroidery Theory

Machine Rules

Fabric Profiles

Thread Profiles

Material Profiles

Commercial Best Practices
```

---

# Object Classification

AI first classifies

artwork

into

logical embroidery objects.

Examples

```text
Outline

Border

Fill Area

Lettering

Column

Detail

Decorative Element
```

Classification

precedes

stitch selection.

---

# Stitch Selection Rules

The AI selects

stitch families

using

object characteristics.

Examples

```text
Thin Outline

↓

Running Stitch

Medium Column

↓

Satin Stitch

Large Region

↓

Fill Stitch

Tiny Detail

↓

Running Stitch
```

Selection rules

remain configurable.

---

# Underlay Rules

Underlay

depends upon

```text
Fabric

Stitch Type

Density

Object Width

Thread Type
```

Examples

```text
Stretch Fabric

↓

Edge Walk + Zigzag

Stable Woven

↓

Center Walk

Foam

↓

Special Underlay
```

---

# Density Rules

Density

is determined by

```text
Fabric

Thread Weight

Object Size

Thread Type

Expected Coverage
```

AI recommends

safe commercial values,

not

maximum density.

---

# Pull Compensation Rules

Pull compensation

depends upon

```text
Fabric Stretch

Thread Tension

Stitch Direction

Object Width

Material Profile
```

Recommendations

derive

from

explicit rules.

---

# Push Compensation Rules

Push compensation

depends upon

```text
Fill Direction

Stitch Length

Corner Geometry

Layer Interaction
```

Push and pull

are evaluated

independently.

---

# Stitch Direction Rules

The AI determines

stitch direction

using

```text
Object Shape

Longest Axis

Visual Flow

Texture

Layer Order
```

Direction

may change

within

complex objects.

---

# Corner Rules

Corners

are classified

into

```text
Acute

Right

Obtuse

Rounded
```

Different corner types

receive

different stitch treatments.

---

# Overlap Rules

Overlaps

are recommended

to prevent

gaps

caused by

fabric movement.

Overlap size

depends upon

```text
Fabric

Density

Thread Weight

Object Type
```

---

# Sequencing Rules

Object order

is optimized

using

```text
Travel Distance

Thread Changes

Layer Dependencies

Registration

Manufacturing Quality
```

Sequencing

must remain

manufacturable.

---

# Jump Rules

AI attempts

to minimize

jump stitches.

Strategies include

```text
Object Reordering

Travel Stitch

Merge Objects

Local Optimization
```

Machine limits

are respected.

---

# Trim Rules

Trim recommendations

depend upon

```text
Jump Length

Machine Profile

Thread Type

Production Requirements
```

Trim behavior

is configurable.

---

# Lettering Rules

Text objects

use

specialized rules.

Examples

```text
Minimum Height

Column Width

Pull Compensation

Travel Paths

Entry Points
```

Lettering

is treated

separately

from

general geometry.

---

# Small Object Rules

Tiny objects

may require

```text
Simplification

Running Stitch

Reduced Density

Merged Objects
```

Commercial readability

takes precedence.

---

# Large Fill Rules

Large fills

require

```text
Underlay

Balanced Density

Travel Optimization

Angle Selection

Section Splitting
```

Large regions

should avoid

excessive thread buildup.

---

# Fabric Rules

Fabric influences

nearly every decision.

Material properties

include

```text
Stretch

Thickness

Pile

Stability

Recovery
```

AI

must consult

Material Profiles

before

digitizing.

---

# Thread Rules

Thread properties

influence

```text
Density

Coverage

Reflection

Consumption

Visibility
```

Different thread weights

produce

different recommendations.

---

# Machine Rules

Machine profiles

influence

```text
Maximum Stitch Length

Needle Size

Speed

Trim Support

Hoop Size
```

The AI

must remain

machine aware.

---

# Quality Rules

The AI evaluates

```text
Puckering Risk

Coverage

Registration

Travel Efficiency

Thread Consumption

Manufacturability
```

Quality predictions

include

confidence

and

reasoning.

---

# Explainability

Every recommendation

includes

```text
Decision

Evidence

Applied Rules

Confidence

Alternatives
```

Users

must understand

why

the recommendation

was made.

---

# User Overrides

Users

may override

AI decisions.

Overrides

never modify

canonical rules.

They modify

only

the current project.

---

# Learning

AI

may learn

preferred workflows

from users.

However,

learned preferences

never replace

embroidery rules.

---

# Validation

Digitizing validation

checks

```text
Missing Underlay

Unsafe Density

Large Jumps

Registration Risks

Machine Violations

Fabric Conflicts
```

Validation

occurs

before

embroidery generation.

---

# Diagnostics

The AI

may report

```text
High Density

High Pull Risk

Excessive Trims

Thread Waste

Machine Limitation

Low Confidence
```

Diagnostics

never modify

the design.

---

# Thread Safety

Rule evaluation

is stateless.

Multiple AI sessions

may execute

concurrently.

Knowledge

remains immutable.

---

# Performance

The AI Digitizer

shall support

```text
Large Artwork

Thousands of Objects

Real-Time Suggestions

Parallel Evaluation

Incremental Updates
```

without interrupting

editing.

---

# Domain Rules

The following always apply.

- AI digitizes using explicit embroidery rules.
- Object classification precedes stitch generation.
- Fabric profiles influence every major decision.
- Machine profiles constrain recommendations.
- Every recommendation is explainable.
- AI recommendations are deterministic for identical inputs.
- Users may override recommendations.
- Learned behavior never replaces canonical rules.
- Validation precedes embroidery generation.
- AI remains machine-independent.

---

# Out of Scope

This document does not define

- neural network architectures
- model training
- prompt engineering
- inference infrastructure
- export formats

These belong

to the AI Runtime

and

Machine Compiler.

---

# Future Topics

Future AI documents expand

```text
AI Auto Digitizer

AI Artwork Analyzer

AI Quality Inspector

AI Manufacturing Advisor

AI Style Transfer

Adaptive Learning

Collaborative AI
```

---

# Acceptance Criteria

The AI Digitizing Rules specification is complete when

✓ AI digitizing responsibilities are clearly defined.

✓ Rule-based object classification is documented.

✓ Stitch, density, underlay, compensation, and sequencing rules are specified.

✓ Fabric, thread, and machine-aware decision making is established.

✓ Explainability and user overrides are documented.

✓ Validation and diagnostics workflows are specified.

✓ Deterministic rule evaluation is established.

✓ Domain rules preserve manufacturable, editable embroidery.

✓ AI remains independent of model implementation.

✓ The AI Digitizing Rules provide the canonical decision framework for automated embroidery generation.
