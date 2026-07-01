# Domain
## DOM-205 Tie-In & Tie-Off

**Document ID:** DOM-205  
**Title:** Tie-In & Tie-Off  
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
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines Tie-In and Tie-Off, the mechanisms used to secure embroidery thread at the beginning and end of stitch sequences.

These operations are fundamental to producing durable, professional-quality embroidery.

Although they contribute very little to the visual appearance of a design, they have a major impact on

- durability
- thread security
- wash resistance
- manufacturing reliability

---

# Philosophy

Every thread must begin securely.

Every thread must end securely.

```text
Thread Start

↓

Tie-In

↓

Embroidery

↓

Tie-Off

↓

Trim (optional)
```

A professionally digitized design should never rely solely on thread tension to secure stitches.

---

# Goals

Tie management shall provide

- Secure thread anchoring
- Minimal visual impact
- Machine independence
- Durable embroidery
- Efficient production
- Predictable behavior

---

# Definition

Tie-In

A sequence of locking stitches performed before visible embroidery begins.

---

Tie-Off

A sequence of locking stitches performed after visible embroidery completes.

---

# Objectives

Tie operations exist to

- prevent unraveling
- secure thread tension
- improve wash durability
- prevent loose thread ends
- improve production quality

---

# Embroidery Lifecycle

```text
Thread Change

↓

Tie-In

↓

Embroidery

↓

Tie-Off

↓

Trim

↓

Next Color
```

Tie operations are part of thread management.

---

# When Tie-In Occurs

Tie-In is normally generated

- after thread changes
- after trims
- at embroidery start
- after long jumps
- after thread breaks

---

# When Tie-Off Occurs

Tie-Off is generated

- before trims
- before thread changes
- at embroidery completion
- before long jumps (machine dependent)

---

# Thread Locking

Thread locking prevents

```text
Loose Thread

↓

Unraveling
```

The locking method depends upon

- machine
- stitch type
- design
- user settings

---

# Lock Stitch

The most common locking method.

Consists of

```text
Small Forward Stitch

↓

Small Reverse Stitch

↓

Continue
```

Produces minimal visibility.

---

# Back Stitch Lock

Another common strategy.

```text
Forward

↓

Backward

↓

Forward
```

Provides excellent security.

---

# Micro Stitches

Very short stitches placed near the start or end.

Applications

```text
Fine Lettering

Small Objects

High Detail
```

Micro stitches reduce visible locking.

---

# Tie Patterns

Common tie patterns

```text
Forward Lock

Back Lock

Triangle Lock

Micro Lock

Programmable Lock
```

Machine profiles determine supported behavior.

---

# Number of Lock Stitches

Typical values

```text
2

↓

5 Lock Stitches
```

Depends upon

- thread
- fabric
- machine
- stitch type

---

# Lock Stitch Length

Typical values

```text
0.3 mm

↓

1.0 mm
```

Very short stitches provide better locking.

Excessively short stitches should be avoided.

---

# Stitch Direction

Tie stitches generally follow

```text
Primary Stitch Direction
```

to minimize visibility.

---

# Tie Location

Ideally placed

- beneath later stitches
- inside dense fill
- inside satin columns
- beneath appliqué

Visible locking should be minimized.

---

# Running Stitch

Running Stitch may use

```text
Small Lock Stitch

or

Back Stitch
```

depending on

- object size
- visibility
- fabric

---

# Satin Stitch

Satin Stitch almost always requires

```text
Tie-In

+

Tie-Off
```

The locks should be hidden beneath the satin.

---

# Fill Stitch

Fill Stitch normally hides tie operations naturally.

Locking is usually performed near the fill boundary.

---

# Underlay

Tie-In normally occurs before

```text
Underlay
```

The underlay itself further secures the thread.

---

# Decorative Stitches

Decorative embroidery may use

```text
Hidden Tie

Visible Tie

Artistic Lock
```

depending upon artistic intent.

---

# Thread Changes

Every thread change generally requires

```text
Tie-Off

↓

Trim

↓

Color Change

↓

Tie-In
```

unless machine-specific optimization is applied.

---

# Trims

Tie-Off usually precedes

```text
Trim
```

Thread should never be trimmed without securing it first.

---

# Jump Stitches

Long jump stitches may require

```text
Tie-Off

↓

Jump

↓

Tie-In
```

depending upon

- jump distance
- machine
- user settings

---

# Travel Stitch Interaction

If travel stitches remain hidden,

additional ties may be unnecessary.

Optimization determines whether locking is required.

---

# Fabric Influence

Fabric affects locking strategy.

### Stable Fabric

Requires

```text
Minimal Locking
```

---

### Stretch Fabric

Requires

```text
Additional Locking
```

to prevent movement.

---

### Towels

Often require

```text
Longer Lock

↓

Stronger Underlay
```

---

# Thread Influence

Thread characteristics

- weight
- material
- elasticity
- finish

affect lock effectiveness.

---

# Machine Influence

Machines differ in

- built-in tie commands
- trim behavior
- locking support
- minimum stitch length

The compiler adapts logical ties to machine capabilities.

---

# Visibility

Tie stitches should

- remain hidden
- avoid decorative surfaces
- avoid exposed edges

Visibility is considered a defect unless intentional.

---

# Quality Factors

Proper tie management improves

- wash durability
- abrasion resistance
- thread security
- manufacturing reliability

Poor tie management leads to

- loose thread
- unraveling
- customer complaints

---

# Optimization

Optimization aims to

- reduce unnecessary ties
- minimize trims
- hide locking stitches
- reduce machine time

without compromising durability.

---

# Machine Compilation

Logical ties are converted into

machine-specific commands.

Compilation may

- replace logical ties
- merge ties
- use native lock commands
- adjust stitch lengths

Logical behavior remains unchanged.

---

# Simulation

Simulation may optionally display

```text
Tie-In

Tie-Off
```

Professional mode should expose locking.

Consumer previews may hide them.

---

# Failure Modes

Missing Tie-In

```text
Loose Thread Start

Skipped Beginning

Thread Pull-Out
```

---

Missing Tie-Off

```text
Loose Thread End

Unraveling

Poor Wash Durability
```

---

Excessive Locking

```text
Visible Knots

Thread Buildup

Needle Damage

Unnecessary Production Time
```

---

# Domain Rules

The following always apply.

- Every embroidery sequence begins with a secure thread.
- Every embroidery sequence ends with a secure thread.
- Tie-In precedes visible embroidery.
- Tie-Off precedes trimming.
- Lock stitches should remain hidden whenever possible.
- Tie operations should minimize visual impact.
- Thread changes generally require both Tie-Off and Tie-In.
- Machine compilation may replace logical locking with native machine commands.
- Optimization may reduce unnecessary locking but must never compromise durability.
- Tie management is a structural operation, not a decorative one.

---

# Out of Scope

This document does not define

- trim algorithms
- jump stitch optimization
- sequencing algorithms
- machine command encoding
- thread tension control

These are covered in later documents.

---

# Future Topics

Future embroidery documents expand

```text
Trims

Jump Stitches

Sequencing

Density

Optimization

Machine Compilation
```

---

# Acceptance Criteria

The Tie-In & Tie-Off specification is complete when

✓ Tie-In and Tie-Off are defined as structural thread-management operations.

✓ Common locking methods are documented.

✓ Stitch-type-specific behavior is introduced.

✓ Fabric, thread, and machine influences are identified.

✓ Interaction with trims, jumps, and thread changes is defined.

✓ Quality improvements and failure modes are documented.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Optimization rules are established.

✓ Domain rules ensure durable embroidery across machine implementations.

✓ Tie management is established as an essential component of professional embroidery digitizing.
