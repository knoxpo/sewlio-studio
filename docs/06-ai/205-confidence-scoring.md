# AI
## AI-205 Confidence Scoring

**Document ID:** AI-205  
**Title:** Confidence Scoring  
**Version:** 1.0.0  
**Status:** Implementation Guidance  
**Priority:** High  
**Owner:** AI Platform Team

**Related Documents**

```text
docs/02-architecture/014-ai-runtime.md
docs/03-domain/ai/900-domain-knowledge.md
docs/03-domain/ai/901-digitizing-rules.md
docs/03-domain/ai/902-quality-analysis.md
docs/03-domain/ai/903-best-practices.md
docs/02-architecture/003-command-system.md
docs/02-architecture/028-observability.md
```
---

# Purpose

This document defines the confidence scoring architecture for Sewlio Studio's AI platform.

It explains how the capability should operate within a knowledge-driven, explainable, and human-governed embroidery system.

The intent is to support practical AI assistance without violating deterministic platform rules or command-gated mutation boundaries.

---

# Philosophy

AI in Sewlio Studio should reason from explicit knowledge, validated context, and stable policies before relying on statistical inference.

Model output is advisory until it passes rule checks, confidence evaluation, and human approval thresholds appropriate to the task.

AI must never directly modify persistent state outside the documented command system.

---

# Goals

- Provide bounded confidence signals
- Provide risk-aware thresholds
- Provide calibration
- Provide approval routing

---

# Definition

Confidence Scoring is the AI subsystem responsible for bounded confidence signals and risk-aware thresholds.

It combines prompts, retrieval, rules, model providers, and observability into a bounded runtime capability that can assist operators and automation workflows.

Its outputs are explanations, recommendations, plans, diagnostics, or command proposals that remain inspectable and approval-aware.

---

# Responsibilities

- Manage confidence scoring behavior through versioned prompts, typed tool contracts, governed context, and observable execution.
- Use domain knowledge, machine/material rules, and project context as first-class inputs to decision making.
- Emit explanations, confidence signals, and source attribution sufficient for operator trust and audit review.
- Integrate with commands, events, services, and scheduler tasks without bypassing runtime governance.

---

# Pipeline

```text
Request

↓

Policy + Context Assembly

↓

Knowledge / Rules / Retrieval

↓

Model or Deterministic Engine

↓

Confidence + Safety Evaluation

↓

Explanation / Command Proposal / Approval
```

The confidence scoring implementation should explicitly expose each stage for testing, observability, and human review.

---

# AI Rules

- Persistent project changes must be emitted as command proposals and pass the same validation as user-authored commands.
- Knowledge, rules, and source references take precedence over opaque model heuristics whenever a deterministic answer is possible.
- Provider-specific behavior must be isolated behind abstractions so policies, tests, and audits remain stable across model vendors.
- Sensitive project data must be minimized, redacted when needed, and routed according to privacy and deployment policy.

---

# Out of Scope

- Autonomous mutation without approval or command dispatch.
- Undocumented retention of user or project data.
- Provider-specific prompt hacks treated as permanent architecture.
- Unexplained recommendations that cannot be traced back to context, rules, or source knowledge.

---

# Future Topics

- Expanded local-model coverage as device capabilities improve.
- More formal evaluation suites for domain-specific AI tasks.
- Cross-agent collaboration patterns with stronger supervisory controls.
- Richer feedback loops that update knowledge assets without weakening auditability.

---

# Acceptance Criteria

- The confidence scoring capability can be implemented within the documented AI runtime and command governance model.
- Inputs, outputs, safety gates, and observability expectations are explicit enough for engineering and evaluation teams.
- Cross-references align with existing architecture and domain rules for embroidery, machine, material, and simulation knowledge.
- The document supports deterministic fallbacks and human approval for production-impacting changes.
