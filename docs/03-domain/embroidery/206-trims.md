# Domain
## DOM-206 Trims

**Document ID:** DOM-206  
**Title:** Trims  
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
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines Trim operations used during embroidery manufacturing.

A Trim instructs the embroidery machine to cut the thread before beginning another embroidery sequence.

Proper trim management directly affects

- production speed
- embroidery quality
- thread waste
- operator intervention
- machine efficiency

Trims are manufacturing operations rather than visual embroidery elements.

---

# Philosophy

A trim represents a deliberate interruption of thread continuity.

```text
Embroidery

↓

Tie-Off

↓

Trim

↓

Thread Change or Travel

↓

Tie-In

↓

Continue Embroidery
```

A trim should only occur when it improves manufacturing quality.

Unnecessary trims increase production time.

---

# Goals

The trim system shall provide

- Secure thread management
- Minimal visible loose threads
- Efficient manufacturing
- Machine independence
- Predictable behavior
- Integration with sequencing optimization

---

# Definition

A Trim is a machine operation that cuts the embroidery thread after it has been secured.

A trim does not generate embroidery.

It is a manufacturing command.

---

# Objectives

Trim operations exist to

- eliminate long loose threads
- prepare for color changes
- separate embroidery regions
- improve appearance
- reduce manual cleanup

---

# Embroidery Lifecycle

```text
Tie-Off

↓

Trim

↓

Jump

↓

Tie-In

↓

Continue Sewing
```

Trims are part of thread management.

---

# When Trims Occur

Trims are commonly generated

- before color changes
- after embroidery completion
- before long travel
- after isolated embroidery objects
- after long jump stitches
- after thread break recovery

---

# When Trims Should Be Avoided

Avoid trims when

- travel can remain hidden
- neighboring objects are nearby
- continuous sewing improves quality
- machine efficiency benefits from thread continuity

Every trim introduces production overhead.

---

# Logical Trim

Within Sewlio Studio,

a trim is represented as a logical operation.

```text
Logical Trim
```

It expresses user or digitizer intent.

---

# Physical Trim

During compilation,

logical trims become

```text
Machine Trim Command
```

Implementation varies by machine manufacturer.

---

# Trim Pipeline

```text
Embroidery Objects

↓

Sequencing

↓

Trim Planning

↓

Machine Compilation

↓

Machine Trim Commands
```

---

# Trim Decision

A trim decision considers

- travel distance
- visibility
- stitch type
- thread color
- object relationship
- machine capability

Trim generation is an optimization problem.

---

# Travel Threshold

Most embroidery systems define

```text
Maximum Jump Distance

↓

Trim Required
```

Example

```text
Jump < Threshold

↓

No Trim

Jump > Threshold

↓

Trim
```

Thresholds are configurable.

---

# Automatic Trims

The digitizer may automatically generate trims when

- travel exceeds limits
- thread would become visible
- manufacturing quality would decrease

---

# Manual Trims

Users may explicitly request trims.

Applications

```text
Decorative Effects

Special Production Requirements

Machine Constraints

Custom Manufacturing
```

Manual trims override automatic optimization unless explicitly disabled.

---

# Color Changes

A color change generally follows

```text
Tie-Off

↓

Trim

↓

Needle Change

↓

Tie-In
```

Some machines perform trimming automatically during color changes.

---

# Jump Stitch Interaction

Long jump stitches often require trimming.

Example

```text
Object A

↓

Trim

↓

Jump

↓

Object B
```

Short hidden jumps generally do not.

---

# Tie-Off Interaction

Every trim should normally be preceded by

```text
Tie-Off
```

Thread should never be trimmed without first being secured.

---

# Tie-In Interaction

After trimming,

the next embroidery sequence normally begins with

```text
Tie-In
```

---

# Stitch Types

### Running Stitch

Running Stitch frequently avoids trims when

- travel is hidden
- objects remain connected

---

### Satin Stitch

Satin commonly requires trims because

- thread visibility is obvious
- isolated lettering is common

---

### Fill Stitch

Fill objects often trim between distant regions.

Large connected fills usually remain continuous.

---

# Thread Waste

Every trim produces

```text
Thread Tail

↓

Thread Waste
```

Excessive trimming increases

- material cost
- cleanup
- production time

---

# Tail Length

Machines leave

a small thread tail after trimming.

Tail length depends upon

- machine
- trim mechanism
- thread

Tail management is machine-specific.

---

# Machine Differences

Machines differ in

- automatic trimming
- manual trimming
- blade systems
- trim speed
- tail length

The compiler adapts logical trims accordingly.

---

# Sequencing

Good sequencing minimizes

```text
Trim Count
```

Without compromising

- appearance
- travel
- quality

Trim optimization is closely coupled with sequencing optimization.

---

# Fabric Influence

Certain fabrics require

more conservative trimming.

Examples

```text
Pile Fabrics

Towels

Stretch Fabrics
```

Hidden travel may become visible.

---

# Thread Influence

Thread characteristics influence trim quality.

Examples

```text
Polyester

Rayon

Metallic

Cotton
```

Metallic threads often require additional trimming considerations.

---

# Failure Modes

Insufficient trimming

```text
Visible Jump Threads

Loose Thread Bridges

Manual Cleanup
```

---

Excessive trimming

```text
Long Production Time

Extra Thread Usage

Unnecessary Machine Stops

More Tie Operations
```

---

Poor trimming

```text
Loose Thread Ends

Unsecured Thread

Thread Pull-Out

Visible Tail
```

---

# Optimization

Optimization aims to

- minimize trim count
- minimize thread waste
- hide travel
- reduce production time
- preserve embroidery quality

A trim should only exist when beneficial.

---

# Simulation

Simulation may display

```text
Trim Events
```

Professional simulation should optionally show

- trim locations
- thread cuts
- thread continuity

Consumer previews may hide trim operations.

---

# Machine Compilation

Compilation converts

```text
Logical Trim

↓

Machine Trim Instruction
```

The compiler may

- merge trims
- remove redundant trims
- replace trims with native machine commands

Logical intent remains unchanged.

---

# Domain Rules

The following always apply.

- Trims are manufacturing operations.
- Trims never produce visible embroidery.
- Every trim should normally follow a Tie-Off.
- Every trim should normally precede a Tie-In.
- Long visible travel should generally be trimmed.
- Hidden travel should be preserved whenever practical.
- Trim generation is an optimization problem.
- Machine compilation converts logical trims into machine-specific commands.
- Excessive trimming reduces manufacturing efficiency.
- Logical trim behavior remains machine-independent.

---

# Out of Scope

This document does not define

- jump stitch algorithms
- sequencing optimization
- machine command encoding
- thread tension control
- automatic thread break recovery

These are defined in later documents.

---

# Future Topics

Future embroidery documents expand

```text
Jump Stitches

Sequencing

Optimization

Machine Compiler

Manufacturing Profiles
```

---

# Acceptance Criteria

The Trim specification is complete when

✓ Trims are defined as manufacturing thread-cut operations.

✓ Trim lifecycle and interaction with Tie-In and Tie-Off are established.

✓ Automatic and manual trim behavior are documented.

✓ Interaction with jump stitches and color changes is specified.

✓ Optimization goals and trade-offs are identified.

✓ Fabric, thread, and machine influences are documented.

✓ Common failure modes are described.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Domain rules ensure machine-independent trim behavior.

✓ Trim management is established as a critical component of professional embroidery production.
