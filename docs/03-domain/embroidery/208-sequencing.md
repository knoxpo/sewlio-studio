# Domain
## DOM-208 Sequencing

**Document ID:** DOM-208  
**Title:** Sequencing  
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
DOM-209 Density
DOM-210 Pull Compensation
DOM-211 Push Compensation
DOM-212 Cornering
DOM-213 Overlaps
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines Embroidery Sequencing, the process of determining the order in which embroidery objects are manufactured.

Sequencing is one of the most significant factors affecting

- embroidery quality
- production speed
- thread usage
- trims
- jump stitches
- fabric distortion

A perfectly digitized design with poor sequencing will often produce poor embroidery.

---

# Philosophy

Embroidery is not only about *where* stitches are placed.

It is equally about *when* they are placed.

```text
Objects

↓

Sequencing

↓

Stitch Order

↓

Machine Execution

↓

Finished Embroidery
```

Sequencing transforms a collection of embroidery objects into a manufacturable workflow.

---

# Goals

The sequencing system shall provide

- High embroidery quality
- Efficient machine movement
- Minimal trims
- Minimal jump stitches
- Reduced distortion
- Deterministic execution
- Machine independence

---

# Definition

Sequencing determines the execution order of embroidery objects before machine compilation.

It operates on embroidery objects rather than individual machine commands.

---

# Sequencing Pipeline

```text
Embroidery Objects

↓

Dependencies

↓

Grouping

↓

Travel Optimization

↓

Thread Optimization

↓

Execution Order

↓

Machine Compiler
```

---

# Sequencing Levels

Sequencing occurs at multiple levels.

```text
Project

↓

Document

↓

Layer

↓

Embroidery Object

↓

Stitch Group

↓

Individual Stitch
```

Each level contributes to the final sewing order.

---

# Primary Objectives

A good sequence should minimize

```text
Thread Changes

Jump Stitches

Trims

Travel Distance

Fabric Distortion

Production Time
```

while preserving embroidery quality.

---

# Fundamental Rule

The logical design order is **not** necessarily the correct manufacturing order.

The digitizer may reorder objects to improve production quality.

---

# Embroidery Objects

Typical sequencing units

```text
Letter

Logo

Border

Fill Region

Outline

Appliqué

Motif
```

Each object is treated as an independent manufacturing task.

---

# Dependency Analysis

Some embroidery objects depend upon others.

Examples

```text
Underlay

↓

Top Stitch

Outline

↓

Detail

Background

↓

Foreground
```

Dependencies always take precedence over optimization.

---

# Mandatory Ordering

The following relationships are fixed.

```text
Tie-In

↓

Underlay

↓

Top Stitch

↓

Tie-Off

↓

Trim (if required)
```

This order is never violated.

---

# Layer Ordering

Layers define

logical editing order,

not necessarily manufacturing order.

Manufacturing optimization may reorder objects across layers when permitted.

User-configurable policies determine allowable reordering.

---

# Color Sequencing

Objects sharing the same thread color should generally be grouped.

Example

```text
Blue Objects

↓

Red Objects

↓

Black Objects
```

Grouping minimizes

```text
Color Changes
```

---

# Thread Changes

Each color transition typically introduces

```text
Tie-Off

↓

Trim

↓

Needle Change

↓

Tie-In
```

Reducing thread changes significantly improves production speed.

---

# Travel Optimization

Travel planning attempts to minimize

```text
Jump Distance
```

while maintaining quality.

Nearby objects should generally be embroidered consecutively.

---

# Jump Stitch Reduction

Whenever possible

```text
Object A

↓

Hidden Travel

↓

Object B
```

is preferred over

```text
Trim

↓

Jump

↓

Tie-In
```

provided appearance is unaffected.

---

# Trim Optimization

Sequencing attempts to reduce unnecessary trims.

However,

avoiding trims must never create unacceptable visible jump threads.

---

# Stitch Direction

Sequencing may consider stitch direction to

- reduce distortion
- improve appearance
- improve thread reflection

Direction consistency is particularly important for Satin Stitch.

---

# Fabric Distortion

Embroidery alters fabric during production.

Sequencing should distribute

```text
Stress

↓

Across Design
```

rather than concentrating it.

---

# Center-Out Strategy

Large fills often benefit from

```text
Center

↓

Outside
```

to reduce puckering.

---

# Outside-In Strategy

Borders and outlines are often embroidered

after

internal fills.

Example

```text
Fill

↓

Outline
```

to improve edge quality.

---

# Small-to-Large Strategy

Small details are often sewn

before

large surrounding fills,

particularly when they risk being distorted.

---

# Large-to-Small Strategy

Certain production workflows benefit from

```text
Background

↓

Foreground
```

Selection depends upon

- artwork
- stitch type
- distortion analysis

---

# Underlay Sequencing

Underlay always precedes

its corresponding visible embroidery.

Different objects may interleave underlay only if dependencies allow.

---

# Object Grouping

Related objects may form

```text
Sequence Groups
```

Examples

```text
Letter

↓

Outline

↓

Shadow

↓

Highlight
```

Groups improve manufacturing consistency.

---

# Branch Optimization

Lettering and decorative designs often contain branches.

Branch optimization minimizes

- retracing
- travel
- trims

while maintaining logical continuity.

---

# Island Sequencing

Large fills frequently contain

```text
Fill Island A

Fill Island B

Fill Island C
```

Island order should minimize machine movement.

---

# Entry Point Selection

Each object has one or more candidate entry points.

Selection considers

- previous object
- next object
- travel distance
- stitch direction

---

# Exit Point Selection

Exit location should

- reduce future travel
- minimize trims
- improve sequencing continuity

---

# Graph Representation

The sequencing problem may be modeled as

```text
Directed Graph

↓

Nodes

↓

Embroidery Objects

↓

Edges

↓

Travel Cost
```

Optimization seeks the lowest manufacturing cost while respecting dependencies.

---

# Cost Factors

The sequencing engine evaluates

```text
Travel Distance

Trim Cost

Thread Change Cost

Jump Cost

Distortion Cost

Time Cost
```

The weighting of these costs may be configurable.

---

# Optimization Constraints

Optimization must never violate

- dependency rules
- user locks
- explicit sequence constraints
- machine limitations

Quality constraints take precedence over performance.

---

# Manual Sequencing

Users may explicitly specify

```text
Object Order

Sequence Groups

Locked Order
```

Manual constraints override automatic optimization.

---

# Automatic Sequencing

Automatic sequencing evaluates

- geometry
- stitch type
- fabric
- thread
- travel
- dependencies

to determine an optimized execution order.

---

# Simulation

Simulation visualizes

```text
Execution Order

↓

Needle Movement

↓

Thread Progress
```

Professional mode should display

- object numbering
- travel lines
- trims
- jumps

---

# Machine Compilation

Machine compilation preserves the logical sequence.

It may

- merge commands
- optimize movement
- adapt to machine capabilities

without changing sequencing intent.

---

# Failure Modes

Poor sequencing

```text
Excessive Trims

Visible Jump Threads

Fabric Distortion

Thread Waste

Long Production Time
```

---

Improper dependency ordering

```text
Visible Underlay

Poor Coverage

Outline Misalignment

Registration Errors
```

---

Over-aggressive optimization

```text
Broken Visual Intent

Difficult Editing

Unexpected Sewing Order
```

---

# Domain Rules

The following always apply.

- Sequencing determines manufacturing order.
- Dependencies always override optimization.
- Underlay precedes visible embroidery.
- Tie operations occur before and after embroidery sequences.
- Objects sharing thread colors should generally be grouped.
- Hidden travel is preferred over visible jumps.
- Sequencing should minimize trims, jumps, and thread changes.
- Fabric distortion must be considered during sequencing.
- Manual sequencing constraints override automatic optimization.
- Machine compilation preserves logical sequencing intent.

---

# Out of Scope

This document does not define

- graph search algorithms
- optimization heuristics
- machine command encoding
- stitch generation algorithms
- thread tension control

These are covered in the Architecture documents.

---

# Future Topics

Future embroidery documents expand

```text
Density

Pull Compensation

Push Compensation

Cornering

Optimization

AI-Assisted Sequencing

Manufacturing Profiles
```

---

# Acceptance Criteria

The Sequencing specification is complete when

✓ Sequencing is defined as the determination of embroidery execution order.

✓ Multi-level sequencing hierarchy is established.

✓ Dependencies and mandatory ordering rules are defined.

✓ Travel, trim, jump, and thread optimization goals are specified.

✓ Manual and automatic sequencing are distinguished.

✓ Fabric distortion and manufacturing quality are incorporated into sequencing decisions.

✓ Simulation and machine compilation responsibilities are separated.

✓ Domain rules establish deterministic, machine-independent sequencing behavior.

✓ Optimization constraints preserve embroidery quality.

✓ Sequencing is established as the central manufacturing planning stage of the embroidery pipeline.
