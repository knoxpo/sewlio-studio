# UI
## UI-613 Document Validation

**Document ID:** UI-613  
**Title:** Document Validation  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** High

**Owner:** Quality Engineering Team

**Related Documents**

```text
UI-606 New Document Workflow
UI-607 Document Setup
UI-605 Machine Preview

DOM-300 Machine Model
DOM-304 Hoops
DOM-806 Format Capabilities

AI-902 Quality Analysis
```

---

# Purpose

This document defines how Sewlio Studio validates projects throughout their lifecycle.

Validation is delegated to the active Production Engine. Embroidery validation covers hoop, machine, thread, stitch, density, and export readiness. Future weaving and printing validation covers loom/weave and print/RIP readiness.

Validation ensures that documents remain manufacturable while allowing users to continue editing.

Validation never modifies document data automatically.

---

# Philosophy

Validation should assist users, not interrupt them.

Errors should clearly explain:

- what is wrong
- why it is wrong
- how to fix it

Validation should be proactive, contextual, and non-destructive.

---

# Goals

The validation system shall

- detect manufacturing issues
- detect export issues
- detect hoop violations
- detect machine incompatibilities
- detect quality problems
- provide actionable recommendations

---

# Validation Categories

## Document Validation

Examples

- Missing document name
- Invalid units
- Missing hoop
- Missing thread library

---

## Hoop Validation

Examples

- Design exceeds hoop
- Safe area exceeded
- Invalid hoop dimensions

---

## Machine Validation

Examples

- Unsupported hoop
- Too many colors
- Unsupported stitch type
- Unsupported machine command

---

## Material Validation

Examples

- Density too high
- Pull compensation recommended
- Stabilizer missing
- Fabric profile mismatch

---

## Thread Validation

Examples

- Missing thread color
- Unsupported thread weight
- Thread library unavailable

---

## Export Validation

Examples

- Format limitation
- Unsupported commands
- Missing trims
- Unsupported jump length

---

## Quality Validation

Examples

- Excessive density
- Small satin width
- Long jumps
- Excessive trims
- Excessive stitch count
- Poor sequencing

---

# Validation Levels

Information

Blue

No action required.

Example

```text
Estimated thread usage

18.2 m
```

---

Warning

Yellow

May affect quality.

Example

```text
Satin width exceeds recommendation.
```

---

Error

Red

Prevents export or production.

Example

```text
Design exceeds hoop boundaries.
```

---

Critical

Dark Red

Project cannot proceed.

Example

```text
Document is corrupted.
```

---

# Validation Timing

Validation occurs

- During editing
- Before export
- Before simulation
- Before machine preview
- After document setup changes

Validation should never block normal editing.

---

# Validation Panel

The Validation panel displays

- Severity
- Message
- Affected Object
- Suggested Fix
- Documentation Link (future)

Example

```text
⚠ Long Jump Stitch

Object:
Logo Outline

Recommendation:
Insert trim or resequence objects.
```

---

# Quick Fixes

Some validations may provide automatic fixes.

Examples

- Center Design
- Resize to Hoop
- Insert Trim
- Add Tie-Off
- Recalculate Underlay

Quick Fixes always require user confirmation.

---

# Validation Summary

The application displays

```text
2 Errors

5 Warnings

8 Suggestions

12 Information Messages
```

The summary updates in real time.

---

# Background Validation

Validation runs asynchronously.

Large documents should not block editing.

---

# Plugin Support

Plugins may

- add validators
- contribute Quick Fixes
- define custom severity rules

---

# Domain Rules

- Validation never edits embroidery automatically.
- Validation is deterministic.
- Errors prevent manufacturing.
- Warnings do not block export unless configured.
- Information messages never block workflows.
- Quick Fixes require user approval.

---

# Acceptance Criteria

✓ Validation categories defined.

✓ Severity model documented.

✓ Validation timing documented.

✓ Quick Fix workflow documented.

✓ Plugin support documented.
