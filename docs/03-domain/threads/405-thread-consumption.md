# Domain
## DOM-405 Thread Consumption

**Document ID:** DOM-405  
**Title:** Thread Consumption  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Thread & Materials Team

**Related Documents**

```text
DOM-200 Stitch Theory
DOM-204 Underlay
DOM-205 Tie-In & Tie-Off
DOM-206 Trims
DOM-207 Jump Stitches
DOM-208 Sequencing
DOM-209 Density
DOM-214 Optimization

DOM-400 Thread Theory
DOM-401 Thread Types
DOM-402 Thread Colors
DOM-404 Thread Weight

DOM-308 Manufacturing

ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
ARCH-028 Observability
```

---

# Purpose

This document defines the Thread Consumption System used by Sewlio Studio.

Thread Consumption estimates the amount of embroidery thread required to manufacture a design.

Accurate thread estimation is essential for

- production planning
- manufacturing cost
- inventory management
- runtime estimation
- quality assurance

The Thread Consumption System provides deterministic, machine-independent material estimation.

---

# Philosophy

Every stitch consumes material.

```text
Stitches

↓

Thread Usage

↓

Production Cost

↓

Manufacturing Planning
```

Thread consumption is a manufacturing metric,

not a design property.

---

# Goals

The Thread Consumption System shall provide

- Accurate material estimation
- Machine-independent calculations
- Production planning support
- Inventory forecasting
- Cost estimation
- Future manufacturing analytics

---

# Definition

Thread Consumption represents the estimated amount of embroidery thread required to manufacture an embroidery design.

Consumption is calculated from logical embroidery data before machine-specific compilation.

---

# Responsibilities

Thread Consumption estimates

- upper thread usage
- bobbin thread usage (optional)
- material cost
- spool requirements
- production metrics

It does **not** manage

- inventory
- purchasing
- machine threading
- stitch generation

---

# Consumption Pipeline

```text
Embroidery Objects

↓

Stitch Generation

↓

Optimization

↓

Consumption Analysis

↓

Manufacturing Report
```

Consumption analysis occurs after optimization.

---

# Consumption Model

A consumption report contains

```text
Total Thread Length

Thread Per Color

Thread Per Object

Thread Per Layer

Estimated Waste

Spool Usage

Estimated Cost

Metadata
```

---

# Measurement Units

Supported units

```text
Millimeters

Centimeters

Meters

Feet

Yards
```

Internally,

millimeters

are recommended.

---

# Upper Thread

Upper thread

creates

the visible embroidery.

Consumption is estimated using

```text
Stitch Length

Density

Tie-In

Tie-Off

Trims

Jump Recovery
```

---

# Bobbin Thread

Optional estimation

may include

bobbin thread.

Typical approximation

is derived from

upper thread usage.

The estimation model

is implementation-defined.

---

# Consumption Sources

Thread usage originates from

```text
Visible Stitches

Underlay

Tie-In

Tie-Off

Jump Recovery

Overlap

Lock Stitches
```

Every manufacturing operation

may consume thread.

---

# Stitch Consumption

Each stitch contributes

```text
Travel Length

+

Thread Tension Factor

+

Machine Overhead
```

Actual machine usage

is typically greater

than geometric stitch length.

---

# Tie-In Consumption

Tie-in stitches

consume

additional thread.

Their contribution

should be included

in manufacturing estimates.

---

# Tie-Off Consumption

Tie-off stitches

also contribute

to

total thread usage.

---

# Underlay Consumption

Underlay

may account for

a significant portion

of thread usage.

Manufacturing estimates

must include

all underlay stitches.

---

# Jump Recovery

Machines

may consume

additional thread

after jumps,

trims,

or thread changes.

Profiles

may define

machine-specific overhead.

---

# Trim Overhead

Every trim

typically introduces

additional thread usage

due to

thread securing

and restarting.

---

# Thread Weight Interaction

Thread weight

influences

consumption.

Example

```text
Heavy Thread

↓

Greater Material

Per Stitch

Fine Thread

↓

Less Material

Per Stitch
```

---

# Thread Type Interaction

Different materials

may require

different

consumption factors.

Examples

```text
Metallic

↓

Higher Waste

Polyester

↓

Standard

Cotton

↓

Moderate
```

---

# Fabric Interaction

Fabric characteristics

may affect

actual thread usage.

Examples

```text
Towels

↓

Higher Underlay

↓

Higher Consumption

Stretch Fabric

↓

Additional Compensation

↓

More Thread
```

---

# Optimization Interaction

Optimization

may reduce

```text
Jump Stitches

Trim Count

Travel

Redundant Stitches
```

Resulting in

lower thread consumption.

---

# Manufacturing Profiles

Production profiles

may define

consumption multipliers.

Examples

```text
Commercial

Luxury

High Quality

Industrial

Economy
```

Profiles

may adjust

estimated waste.

---

# Thread Per Color

Consumption is reported

for each logical thread color.

Example

```text
Royal Blue

12.4 m

-----------------

White

4.1 m

-----------------

Gold

1.8 m
```

---

# Thread Per Object

Professional reports

may include

consumption

for each embroidery object.

Useful for

```text
Diagnostics

Optimization

Cost Analysis
```

---

# Thread Per Layer

Layer-level reporting

supports

large commercial designs

and production analysis.

---

# Estimated Waste

Waste includes

```text
Thread Starts

Thread Ends

Thread Breaks (Estimated)

Machine Overhead

Operator Setup
```

Waste estimation

is profile-dependent.

---

# Spool Estimation

The system

may estimate

required spools.

Example

```text
Total Usage

↓

Spool Capacity

↓

Required Spools
```

Partial spool usage

should also be reported.

---

# Cost Estimation

Optional cost estimation

uses

```text
Thread Usage

×

Material Cost

+

Waste

=

Estimated Cost
```

Pricing models

are external

to the logical domain.

---

# Reports

Manufacturing reports

may include

```text
Thread Usage

Per Color

Per Object

Per Layer

Total Length

Estimated Waste

Estimated Cost
```

Reports

are derived artifacts.

---

# Validation

Validation checks

```text
Missing Thread Data

Unknown Weight

Invalid Consumption

Negative Values

Overflow
```

Warnings

or errors

are generated

when estimates

cannot be produced.

---

# Simulation

Simulation

may optionally display

```text
Live Thread Consumption

Material Usage

Current Thread Length
```

Simulation

does not consume

actual inventory.

---

# Manufacturing

Manufacturing planning

uses

thread consumption

for

```text
Material Planning

Production Reports

Cost Analysis

Runtime Estimates

Inventory Forecasting
```

---

# Analytics

Future analytics

may include

```text
Thread Efficiency

Waste Analysis

Machine Comparison

Material Optimization

Historical Usage
```

Analytics

operate

on

derived data.

---

# Extensibility

Future capabilities

may include

```text
Real-Time Consumption

RFID Spools

Inventory Integration

Cloud Manufacturing

AI Material Forecasting

Carbon Footprint Analysis
```

The logical model

must remain extensible.

---

# Thread Safety

Consumption calculations

are pure functions.

Reports

are immutable

after generation.

Consumption analysis

may execute

concurrently.

---

# Performance

The Thread Consumption System

shall support

```text
Millions of Stitches

Large Designs

Batch Manufacturing

Incremental Analysis

Real-Time Reporting
```

without modifying

embroidery geometry.

---

# Domain Rules

The following always apply.

- Thread consumption is a manufacturing metric.
- Consumption is calculated after optimization.
- Every stitch contributes to material usage.
- Underlay contributes to total consumption.
- Tie-ins, tie-offs, trims, and jumps contribute to consumption.
- Thread weight influences material estimates.
- Reports are derived artifacts.
- Original embroidery geometry is never modified.
- Consumption calculations are deterministic.
- Machine compilation preserves manufacturing estimates.

---

# Out of Scope

This document does not define

- inventory management
- purchasing
- warehouse logistics
- accounting
- supplier pricing

These belong to future manufacturing and business modules.

---

# Future Topics

Future thread documents expand

```text
Inventory

Spool Management

Material Forecasting

Manufacturing Analytics

Cloud Production

ERP Integration

Sustainability Metrics
```

---

# Acceptance Criteria

The Thread Consumption specification is complete when

✓ Thread consumption is defined as a manufacturing metric.

✓ Consumption sources are documented.

✓ Thread weight, thread type, and fabric interactions are established.

✓ Reports for colors, objects, and layers are defined.

✓ Waste estimation and spool estimation are introduced.

✓ Manufacturing and simulation responsibilities are separated.

✓ Validation and analytics workflows are documented.

✓ Domain rules establish deterministic consumption behavior.

✓ Consumption reports remain derived and immutable.

✓ The Thread Consumption System provides the canonical material estimation model for the embroidery platform.
