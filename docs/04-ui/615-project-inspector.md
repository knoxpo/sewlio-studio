# UI
## UI-615 Project Inspector

**Document ID:** UI-615
**Title:** Project Inspector
**Version:** 1.0.0
**Status:** Foundation (Critical)
**Priority:** High

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-613 Document Validation
UI-614 Project Properties

UI-300 Canvas
UI-203 Panels

AI-902 Quality Analysis
```

---

# Purpose

The Project Inspector provides a live overview of the currently opened Sewlio Studio project.

The inspector always shows shared project identity, Project Type, metadata, validation state, and export readiness. Domain sections are contributed by the active Project Type.

Unlike Project Properties, the Project Inspector displays calculated information that continuously updates while the document is edited.

It acts as the project's dashboard.

---

# Philosophy

Users should never need to manually inspect dozens of dialogs just to understand the health of a project.

The Project Inspector provides an at-a-glance overview of

- project state
- quality
- manufacturing readiness
- statistics
- export readiness

---

# Goals

The Project Inspector shall

- summarize the project
- expose manufacturing metrics
- provide quality indicators
- surface AI recommendations
- present validation status
- display export readiness

---

# Layout

The Project Inspector is divided into sections.

```text
Overview

Statistics

Manufacturing

Quality

Simulation

Export

AI Insights
```

Every section is collapsible.

---

# Overview

Displays

- Project Name
- Active Recipe
- Active Template
- Hoop
- Machine
- Material
- Thread Library

---

# Statistics

Displays

- Stitch Count
- Object Count
- Layer Count
- Thread Changes
- Trim Count
- Jump Count
- Color Count
- Estimated Thread Usage
- Estimated File Size

These values update automatically.

---

# Manufacturing

Displays

- Machine Profile
- Hoop Compatibility
- Estimated Runtime
- Needle Changes
- Thread Consumption
- Production Status

---

# Quality

Displays

- Quality Score

- Errors

- Warnings

- Suggestions

- Validation Status

Each item links directly to the Validation Panel.

---

# Simulation

Displays

- Simulation Ready

- Physics Enabled

- Thread Preview

- Fabric Preview

- Estimated Simulation Time

---

# Export

Displays

- Preferred Export Format

- Compatibility Status

- Last Export

- Export Warnings

- Machine Support

---

# AI Insights

Displays

- Optimization Opportunities

- Density Suggestions

- Pull Compensation Suggestions

- Sequencing Suggestions

- Manufacturing Advice

Selecting an insight opens the AI Assistant.

---

# Live Updates

The Project Inspector updates automatically whenever

- embroidery changes
- document settings change
- simulation finishes
- validation changes
- export analysis completes

Manual refresh is never required.

---

# Status Indicators

Each section displays

```text
Healthy

Information

Warning

Error
```

Example

```text
Quality

🟢 Healthy

96 / 100
```

---

# Performance

Statistics should update incrementally.

Large projects should avoid full recalculation whenever possible.

---

# Domain Rules

- The Project Inspector is read-only.
- It never modifies document data.
- It reflects the current document state.
- It updates automatically.
- It aggregates information from multiple subsystems.

---

# Acceptance Criteria

✓ Overview defined.

✓ Statistics defined.

✓ Manufacturing summary defined.

✓ Quality summary defined.

✓ Export readiness defined.

✓ AI integration defined.

✓ Live update behavior documented.
