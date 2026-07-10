# Domain
## DOM-900 AI Domain Knowledge

**Document ID:** DOM-900  
**Title:** AI Domain Knowledge  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** AI & Knowledge Systems Team

**Related Documents**

```text
DOM-000 Domain Overview

DOM-100 Coordinate System
DOM-101 Paths
DOM-102 Curves
DOM-103 Transformations
DOM-104 Bounding Boxes
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
DOM-301 Machine Coordinates
DOM-302 Needle System
DOM-303 Thread Changes
DOM-304 Hoops
DOM-305 Machine Limits
DOM-306 Machine Speed
DOM-307 Machine Commands
DOM-308 Manufacturing

DOM-400 Thread Theory
DOM-401 Thread Types
DOM-402 Thread Colors
DOM-403 Color Matching
DOM-404 Thread Weight
DOM-405 Thread Consumption

DOM-500 Fabric Theory
DOM-501 Stabilizers
DOM-502 Puckering
DOM-503 Fabric Stretch
DOM-504 Distortion
DOM-505 Material Profiles

DOM-600 Thread Physics
DOM-601 Needle Motion
DOM-602 Fabric Simulation
DOM-603 Rendering Model

DOM-700 Vector Import
DOM-701 Raster Import
DOM-702 Embroidery Import
DOM-703 Normalization

DOM-800 Machine IR
DOM-806 Format Capabilities

ARCH-009 Digitizer Pipeline
ARCH-010 Simulation Pipeline
ARCH-011 Machine Compiler
ARCH-013 Plugin Architecture
ARCH-028 Observability
```

---

# Purpose

This document defines the AI Domain Knowledge architecture used by Sewlio Studio.

AI systems within Sewlio Studio are expected to reason about embroidery using the same canonical domain model as the rest of the platform.

As Sewlio Studio expands, AI domain knowledge is split into shared platform knowledge and Project-Type-specific modules.

The AI system never learns embroidery through hidden heuristics alone.

Instead,

it reasons using explicit domain knowledge.

---

# Philosophy

AI should understand

embroidery,

weaving,

digital printing,

not merely

predict it.

The active Project Type selects the active production knowledge module.

```text
Domain Knowledge

↓

AI Reasoning

↓

Recommendation

↓

User
```

Knowledge

is authoritative.

Models

perform reasoning.

---

# Goals

The AI Knowledge System shall provide

- Domain-aware reasoning
- Deterministic decision support
- Explainable recommendations
- Machine-independent intelligence
- Extensible knowledge representation
- AI interoperability

---

# Definition

AI Domain Knowledge

is the structured representation

of embroidery expertise

used by

AI services.

Knowledge includes

```text
Embroidery Rules

Geometry Rules

Machine Rules

Thread Rules

Fabric Rules

Manufacturing Rules

Simulation Rules
```

---

# Responsibilities

The AI Knowledge System provides

- domain reasoning
- recommendations
- validation
- optimization guidance
- educational explanations
- semantic search

It does **not** perform

- neural inference
- machine learning training
- document editing
- rendering

---

# Knowledge Pipeline

```text
Domain Specifications

↓

Knowledge Extraction

↓

Knowledge Graph

↓

AI Reasoning

↓

Recommendations
```

The documentation

is the primary source

of domain truth.

---

# Knowledge Sources

AI knowledge originates from

```text
Architecture Documents

Domain Specifications

Machine Profiles

Material Profiles

Thread Libraries

Plugin Knowledge

User Rules
```

No undocumented rule

should become

canonical knowledge.

---

# Knowledge Categories

Knowledge is organized into

```text
Geometry

Embroidery

Machine

Thread

Fabric

Simulation

Import

Export

Manufacturing

Optimization
```

Each category

is independently searchable.

---

# Geometry Knowledge

Geometry knowledge

includes

```text
Paths

Curves

Transformations

Bounding Boxes

Topology

Algorithms
```

AI uses

geometry reasoning

for

editing

and

digitizing.

---

# Embroidery Knowledge

Embroidery knowledge

includes

```text
Stitch Types

Density

Pull Compensation

Push Compensation

Underlay

Sequencing

Travel Optimization
```

These rules

drive

AI recommendations.

---

# Machine Knowledge

Machine knowledge

includes

```text
Needles

Hoops

Machine Limits

Commands

Speed

Capabilities
```

Machine knowledge

remains

vendor-neutral.

---

# Thread Knowledge

Thread knowledge

includes

```text
Thread Types

Thread Colors

Weight

Consumption

Brand Catalogs

Color Matching
```

AI

may recommend

alternative threads.

---

# Fabric Knowledge

Fabric knowledge

includes

```text
Fabric Types

Stretch

Stabilizers

Distortion

Puckering

Material Profiles
```

Fabric knowledge

influences

digitizing decisions.

---

# Simulation Knowledge

Simulation knowledge

includes

```text
Thread Physics

Needle Motion

Fabric Simulation

Rendering

Quality Prediction
```

AI

may explain

predicted results.

---

# Import Knowledge

Import knowledge

includes

```text
Vector Formats

Raster Formats

Embroidery Formats

Normalization

Compatibility
```

AI

may recommend

the optimal workflow.

---

# Export Knowledge

Export knowledge

includes

```text
Machine IR

Format Capabilities

DST

PES

JEF

VP3

EXP
```

AI

may recommend

the most appropriate

output format.

---

# Manufacturing Knowledge

Manufacturing knowledge

includes

```text
Machine Compatibility

Production Limits

Hoops

Needles

Commercial Workflows

Quality Control
```

---

# Knowledge Graph

The AI system

represents

domain knowledge

using

a Knowledge Graph.

```text
Embroidery

├── Stitch

├── Fabric

├── Thread

├── Machine

├── Geometry

├── Simulation

└── Export
```

Relationships

are explicit.

---

# Semantic Relationships

Knowledge relationships

include

```text
Uses

Requires

Produces

Depends On

Compatible With

Conflicts With

Optimizes
```

The graph

supports

reasoning.

---

# Rule Engine

The AI system

uses

an explicit

Rule Engine.

Rules may express

```text
If

Then

Otherwise

Constraints

Recommendations
```

Rules

remain explainable.

---

# Knowledge Versioning

Knowledge

is versioned

alongside

the platform.

```text
Domain Version

↓

Knowledge Version

↓

AI Version
```

AI reasoning

is reproducible.

---

# Explainability

Every recommendation

must provide

its reasoning.

Example

```text
Increase Underlay

↓

Because

↓

Fabric Stretch

↓

Material Profile

↓

Puckering Risk
```

The AI

never produces

unexplained

recommendations.

---

# Confidence

Every recommendation

includes

```text
Confidence Score

Evidence

Rules Applied

Knowledge Version
```

Confidence

never replaces

explanation.

---

# Knowledge Queries

AI supports

semantic queries

such as

```text
Why?

How?

What If?

Recommend

Compare

Explain
```

The answers

derive

from

the Knowledge Graph.

---

# Learning

AI models

may learn

from

user interactions.

However,

learned behavior

never overrides

canonical domain rules.

Learning

produces

recommendations,

not

authoritative knowledge.

---

# Plugin Knowledge

Plugins

may contribute

additional knowledge.

Plugin knowledge

must declare

```text
Rules

Entities

Capabilities

Relationships

Version
```

Plugin rules

remain isolated

from

core knowledge.

---

# Validation

Knowledge validation

checks

```text
Missing Rules

Circular Dependencies

Conflicting Rules

Unknown References

Version Compatibility
```

Invalid knowledge

cannot become

canonical.

---

# Diagnostics

AI diagnostics

may report

```text
Conflicting Recommendations

Unsupported Machine

Incomplete Knowledge

Rule Conflicts

Low Confidence
```

Diagnostics

never modify

documents.

---

# Security

AI knowledge

is

read-only.

AI systems

cannot modify

domain specifications

or

canonical rules.

---

# Thread Safety

Knowledge graphs

are immutable.

Multiple AI services

may query

the same knowledge

concurrently.

---

# Performance

The AI Knowledge System

shall support

```text
Real-Time Reasoning

Large Knowledge Graphs

Semantic Search

Parallel Queries

Incremental Updates
```

while maintaining

interactive responsiveness.

---

# Domain Rules

The following always apply.

- Domain documentation is the primary source of truth.
- AI reasons using canonical knowledge.
- Knowledge is explicit and versioned.
- Rules are explainable.
- Recommendations are deterministic when given identical inputs.
- Learned behavior never replaces canonical rules.
- Knowledge graphs are immutable.
- Plugin knowledge is isolated.
- Every recommendation includes evidence.
- AI remains machine-independent.

---

# Out of Scope

This document does not define

- machine learning architectures
- neural network training
- LLM implementation
- model deployment
- inference infrastructure

These are defined

by the AI Runtime.

---

# Future Topics

Future AI documents expand

```text
Knowledge Graph Schema

Reasoning Engine

AI Agents

AI Digitizer

AI Quality Inspector

AI Manufacturing Advisor

Conversational Assistant

Retrieval-Augmented Generation (RAG)
```

---

# Acceptance Criteria

The AI Domain Knowledge specification is complete when

✓ AI knowledge responsibilities are separated from AI inference.

✓ Canonical knowledge sources are documented.

✓ Knowledge categories are established.

✓ Knowledge Graph architecture is defined.

✓ Rule-based reasoning is specified.

✓ Explainability and confidence reporting are documented.

✓ Plugin knowledge integration is defined.

✓ Validation and diagnostics responsibilities are established.

✓ Domain rules guarantee deterministic, versioned, and explainable reasoning.

✓ The AI Knowledge System provides the canonical knowledge foundation for every AI capability in Sewlio Studio.
