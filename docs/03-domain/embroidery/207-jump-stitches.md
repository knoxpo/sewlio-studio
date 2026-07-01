# Domain
## DOM-207 Jump Stitches

**Document ID:** DOM-207  
**Title:** Jump Stitches  
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
DOM-208 Sequencing
DOM-214 Optimization

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
```

---

# Purpose

This document defines Jump Stitches and their role in machine embroidery.

Jump stitches allow the embroidery machine to move from one embroidery region to another without intentionally sewing between them.

Jump management is one of the most important manufacturing optimization problems because it directly affects

- embroidery quality
- production speed
- thread waste
- operator intervention
- post-processing effort

---

# Philosophy

Not every machine movement should produce embroidery.

Sometimes the needle must simply relocate.

```text
Embroidery Region A

↓

Jump

↓

Embroidery Region B
```

A jump is movement.

It is not decoration.

---

# Goals

The jump stitch system shall provide

- Efficient machine movement
- Minimal visible thread
- Reduced production time
- Machine independence
- Predictable optimization
- Integration with trimming and sequencing

---

# Definition

A Jump Stitch is a machine movement between embroidery locations performed without intentionally producing decorative stitches.

During a jump,

the embroidery machine repositions the needle before continuing sewing.

---

# Objectives

Jump stitches exist to

- move between isolated objects
- reposition after trims
- travel between embroidery regions
- reduce unnecessary stitching
- improve manufacturing efficiency

---

# Embroidery Lifecycle

```text
Embroidery

↓

Tie-Off (optional)

↓

Trim (optional)

↓

Jump

↓

Tie-In (optional)

↓

Continue Embroidery
```

---

# Logical Jump

Within Sewlio Studio,

a jump is represented as

```text
Logical Jump
```

Logical jumps describe movement intent.

They are machine-independent.

---

# Physical Jump

During machine compilation,

logical jumps become

```text
Machine Jump Commands
```

Implementation varies by embroidery format and machine.

---

# Jump Pipeline

```text
Embroidery Objects

↓

Sequencing

↓

Travel Planning

↓

Jump Generation

↓

Machine Compilation
```

---

# Jump Distance

Every jump has a measurable distance.

```text
Start Position

↓

End Position
```

Jump distance influences

- trimming
- tie management
- optimization
- production speed

---

# Short Jump

Short jumps

typically remain hidden beneath later embroidery.

Characteristics

```text
No Trim

Continuous Thread

Fast Production
```

---

# Long Jump

Long jumps often create

```text
Visible Thread Bridge
```

These generally require

- trimming
- tie-off
- tie-in

depending on configuration.

---

# Hidden Jump

A hidden jump travels beneath later embroidery.

Example

```text
Under Fill

↓

Invisible Thread
```

Hidden jumps are preferred whenever practical.

---

# Visible Jump

Visible jumps leave exposed thread between objects.

They should generally be avoided.

Exceptions include

- temporary production workflows
- user preference
- machine limitations

---

# Jump Threshold

The system defines a configurable

```text
Maximum Continuous Jump
```

Example

```text
Distance

↓

Threshold

↓

Trim Required
```

Threshold values depend upon

- fabric
- machine
- thread
- production profile

---

# Jump Direction

Jump direction has no visual effect,

but it influences

- travel optimization
- production time
- thread path

---

# Running Stitch Interaction

Instead of jumping,

the digitizer may choose

```text
Hidden Running Stitch
```

if

- later embroidery conceals it
- production becomes more efficient

---

# Satin Stitch Interaction

Isolated satin objects commonly require

```text
Jump

↓

Tie

↓

Continue
```

because exposed travel is highly visible.

---

# Fill Stitch Interaction

Large connected fill regions often avoid jumps.

Separate fill islands frequently require them.

---

# Underlay Interaction

Hidden jumps may occur within

```text
Underlay
```

where later embroidery conceals the travel.

---

# Tie-In & Tie-Off Interaction

Long jumps typically follow

```text
Tie-Off

↓

Jump

↓

Tie-In
```

Short hidden jumps may omit locking.

---

# Trim Interaction

Jump management and trim planning are closely related.

Example

```text
Short Jump

↓

No Trim

Long Jump

↓

Trim
```

---

# Color Changes

Color changes normally include

```text
Tie-Off

↓

Trim

↓

Needle Change

↓

Jump

↓

Tie-In
```

depending upon machine behavior.

---

# Machine Differences

Machines differ in

- jump implementation
- automatic trims
- maximum jump distance
- thread handling
- movement speed

The compiler adapts logical jumps accordingly.

---

# Fabric Influence

Certain fabrics make jump threads highly visible.

Examples

```text
Pile Fabrics

Towels

Velvet
```

These often require more aggressive trimming.

---

# Thread Influence

Thread type affects

- visibility
- elasticity
- snagging
- cleanup

Metallic thread often benefits from shorter jumps.

---

# Production Considerations

Every jump increases

- machine movement
- production time

Every trim increases

- machine operations
- thread consumption

Optimization balances these competing costs.

---

# Travel Planning

Travel planning attempts to

- reduce jump count
- shorten jump distance
- hide travel
- eliminate unnecessary trims

Travel planning is a global optimization problem.

---

# Sequencing

Good sequencing naturally reduces

- jumps
- trims
- thread changes

Poor sequencing dramatically increases machine movement.

---

# Failure Modes

Excessive jumps

```text
Visible Thread Bridges

Manual Cleanup

Poor Appearance
```

---

Missing trims after long jumps

```text
Loose Connecting Threads

Snagging

Customer Complaints
```

---

Excessive trimming

```text
Longer Production Time

More Thread Waste

Reduced Efficiency
```

---

Poor sequencing

```text
Many Jumps

Many Trims

Long Machine Runtime
```

---

# Optimization

Optimization aims to

- minimize jump count
- minimize jump distance
- minimize trims
- maximize hidden travel
- reduce machine movement

without changing the design.

---

# Simulation

Simulation may display

```text
Jump Events
```

Professional mode should optionally visualize

- jump paths
- travel movement
- thread continuity

Consumer previews may hide jumps.

---

# Machine Compilation

Machine compilation converts

```text
Logical Jump

↓

Machine Jump Command
```

The compiler may

- merge jumps
- remove redundant jumps
- replace jumps with machine-native movement commands
- coordinate jumps with trims

Logical jump intent remains unchanged.

---

# Domain Rules

The following always apply.

- Jump stitches are machine movement operations.
- Jump stitches are not decorative embroidery.
- Hidden jumps are preferred over visible jumps.
- Long visible jumps generally require trimming.
- Short hidden jumps should remain continuous when practical.
- Jump planning is part of sequencing optimization.
- Machine compilation converts logical jumps into machine-specific commands.
- Jump optimization must balance quality and production efficiency.
- Logical jump behavior remains machine-independent.
- Jump management is a core manufacturing optimization problem.

---

# Out of Scope

This document does not define

- sequencing algorithms
- trim algorithms
- machine command encoding
- thread tension control
- automatic thread break recovery

These are covered in subsequent documents.

---

# Future Topics

Future embroidery documents expand

```text
Sequencing

Optimization

Machine Compiler

Manufacturing Profiles

Production Analytics
```

---

# Acceptance Criteria

The Jump Stitch specification is complete when

✓ Jump stitches are defined as non-sewing machine movements.

✓ Logical and physical jump concepts are distinguished.

✓ Short and long jump behavior is documented.

✓ Interaction with trims, tie operations, and sequencing is specified.

✓ Fabric, thread, and machine influences are identified.

✓ Optimization goals and trade-offs are established.

✓ Common failure modes are documented.

✓ Simulation and machine compilation responsibilities are distinguished.

✓ Domain rules ensure machine-independent jump behavior.

✓ Jump management is established as a fundamental component of professional embroidery manufacturing optimization.
