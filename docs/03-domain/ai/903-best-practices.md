# Domain
## DOM-903 AI Best Practices

**Document ID:** DOM-903  
**Title:** AI Best Practices  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** AI Platform Team

**Related Documents**

```text
DOM-000 Domain Overview

DOM-200 Stitch Theory
DOM-209 Density
DOM-210 Pull Compensation
DOM-214 Optimization

DOM-300 Machine Model
DOM-305 Machine Limits
DOM-308 Manufacturing

DOM-500 Material Profiles

DOM-900 AI Domain Knowledge
DOM-901 AI Digitizing Rules
DOM-902 AI Quality Analysis

ARCH-014 AI Runtime
ARCH-019 Error Handling
ARCH-021 Architecture Principles
ARCH-028 Observability
ARCH-030 Coding Standards
```

---

# Purpose

This document defines the best practices governing every AI feature within Sewlio Studio.

These practices ensure that AI remains reliable, explainable, deterministic, safe, and commercially useful.

Unlike implementation guidelines,

these are architectural principles

that every AI capability must follow.

---

# Philosophy

AI should

assist,

not replace,

professional embroidery knowledge.

```text
User

↓

AI Assistant

↓

Recommendation

↓

User Decision
```

AI

augments expertise.

The user

always remains

in control.

---

# Goals

The AI Best Practices shall ensure

- Explainable decisions
- Predictable behavior
- Commercial-quality recommendations
- Safe automation
- Transparent reasoning
- Trustworthy user experiences

---

# Principles

Every AI system

must follow

these principles.

```text
Explainability

Determinism

Transparency

Safety

User Control

Domain Knowledge

Consistency

Extensibility
```

---

# Knowledge First

AI

must reason

using

explicit

domain knowledge.

Never rely solely

on

statistical inference.

```text
Knowledge

↓

Reasoning

↓

Recommendation
```

Knowledge

is authoritative.

---

# Explain Every Decision

Every recommendation

must answer

```text
What happened?

Why?

Which rules?

What evidence?

What alternatives?
```

Users

must never receive

opaque advice.

---

# Deterministic Behavior

Given

```text
Same Design

Same Materials

Same Machine

Same Knowledge Version
```

AI

must produce

the same recommendations.

Randomness

is not permitted

for production workflows.

---

# Human Oversight

AI

never performs

irreversible actions

without

user approval.

Examples

```text
Auto Digitizing

Optimization

Object Deletion

Machine Export

Thread Replacement
```

Human review

remains mandatory.

---

# Recommendation, Not Authority

AI

suggests.

Users

decide.

The system

must distinguish

between

```text
Recommendation

Warning

Error

Requirement
```

Only true validation failures

prevent production.

---

# Evidence-Based Analysis

Recommendations

must reference

```text
Applied Rules

Simulation Results

Material Profiles

Machine Profiles

Quality Metrics
```

Evidence

is always visible.

---

# Confidence

Every recommendation

includes

```text
Confidence Score

Evidence

Knowledge Version

Supporting Rules
```

Confidence

must never be

the only explanation.

---

# No Hidden Rules

Every rule

used by AI

must exist

within

the canonical

knowledge base.

Undocumented behavior

is prohibited.

---

# Versioned Knowledge

Recommendations

must record

```text
Knowledge Version

Rule Version

Model Version

Material Profile Version

Machine Profile Version
```

Results

remain reproducible.

---

# Respect Machine Limits

AI

must never recommend

operations

outside

machine capabilities.

Examples

```text
Oversized Hoop

Unsupported Commands

Unsafe Stitch Length

Excessive Speed

Needle Limits
```

Machine safety

takes priority.

---

# Respect Material Limits

Recommendations

must consider

```text
Fabric

Thread

Needle

Stabilizer

Environment
```

No recommendation

is valid

without

material context.

---

# Commercial Manufacturability

AI

must optimize

for

real production,

not

idealized simulation.

Priorities include

```text
Reliability

Repeatability

Efficiency

Quality

Machine Compatibility
```

---

# Conservative Defaults

When uncertainty exists,

AI should choose

the safest

commercial option.

Example

```text
Unknown Fabric

↓

Recommend Stable Settings

↓

Ask User
```

Never assume

ideal conditions.

---

# Progressive Assistance

AI

should provide

increasing levels

of assistance.

```text
Suggestion

↓

Recommendation

↓

Automation

↓

Autonomous Workflow
```

Higher automation

requires

higher confidence

and

explicit user approval.

---

# User Overrides

Users

may override

recommendations.

Overrides

affect

only

the current project,

not

canonical knowledge.

---

# Learn Preferences

AI

may learn

user preferences

such as

```text
Preferred Density

Preferred Underlay

Preferred Sequencing

Favorite Thread Brands
```

Preferences

supplement

rules.

They never

replace

rules.

---

# Never Fabricate Knowledge

When AI

does not know,

it must

```text
State Uncertainty

Request More Information

Avoid Guessing
```

Hallucinated

embroidery advice

is unacceptable.

---

# Quality Before Speed

The AI

should prefer

higher-quality recommendations

over

faster responses

for

production workflows.

---

# Traceability

Every recommendation

must be traceable

to

```text
Rule

Evidence

Knowledge Source

Simulation

Model Version
```

Traceability

supports

debugging

and

auditing.

---

# Observability

Every AI workflow

should emit

structured telemetry.

Examples

```text
Decision Time

Rules Applied

Confidence

User Overrides

Execution Time

Diagnostics
```

Telemetry

supports

continuous improvement.

---

# Privacy

AI

must minimize

collection

of

user data.

Project data

must remain

under

user control.

Training

requires

explicit consent.

---

# Plugin AI

Plugins

may introduce

additional AI capabilities.

Plugins

must declare

```text
Knowledge

Capabilities

Rules

Dependencies

Version
```

Plugin AI

cannot override

core platform rules.

---

# Testing

Every AI feature

must support

```text
Unit Tests

Rule Tests

Regression Tests

Golden Outputs

Benchmark Designs
```

AI behavior

must be testable.

---

# Validation

Validation checks

```text
Missing Evidence

Conflicting Rules

Unsafe Recommendation

Machine Conflict

Material Conflict

Version Mismatch
```

Invalid recommendations

must not be promoted

to production.

---

# Diagnostics

AI diagnostics

may report

```text
Low Confidence

Incomplete Context

Rule Conflict

Unsupported Machine

Missing Material Profile

Simulation Failure
```

Diagnostics

never modify

project data.

---

# Performance

AI systems

shall support

```text
Interactive Editing

Large Designs

Parallel Evaluation

Incremental Analysis

Real-Time Feedback
```

without sacrificing

correctness.

---

# Domain Rules

The following always apply.

- AI augments expert users rather than replacing them.
- Domain knowledge is the primary source of truth.
- Every recommendation is explainable.
- AI behavior is deterministic for identical inputs.
- Users retain final control over production decisions.
- Machine and material limits are always respected.
- Learned preferences never replace canonical rules.
- Recommendations are evidence-based.
- Every decision is traceable and versioned.
- Safety and manufacturability take precedence over automation.

---

# Out of Scope

This document does not define

- LLM architectures
- model training
- inference engines
- prompt engineering
- deployment infrastructure

These belong

to the AI Runtime.

---

# Future Topics

Future AI documents expand

```text
AI Governance

Responsible AI

Model Evaluation

Knowledge Extraction

Human-in-the-Loop Workflows

Collaborative AI

Autonomous Manufacturing
```

---

# Acceptance Criteria

The AI Best Practices specification is complete when

✓ Architectural principles for AI are documented.

✓ Explainability, determinism, and transparency requirements are established.

✓ Human oversight and user control policies are defined.

✓ Knowledge-first reasoning is specified.

✓ Machine and material safety requirements are documented.

✓ Recommendation traceability and versioning are established.

✓ Testing, observability, and diagnostics responsibilities are defined.

✓ Plugin AI governance is specified.

✓ Domain rules guarantee trustworthy, commercial-quality AI behavior.

✓ The AI Best Practices document provides the canonical governance framework for every AI capability within Sewlio Studio.
