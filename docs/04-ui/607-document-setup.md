# UI
## UI-607 Document Setup

**Document ID:** UI-607  
**Title:** Document Setup  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-606 New Document Workflow
UI-600 Document Workflow
UI-605 Machine Preview

DOM-304 Hoops
DOM-500 Fabric Theory
DOM-505 Material Profiles

ARCH-004 Document Model
ARCH-008 State Management
```

---

# Purpose

This document defines how users modify an existing document's configuration after it has been created.

Document Setup allows users to update project-level settings without recreating the project.

---

# Philosophy

Creating a project should not permanently lock configuration choices.

Every important document property should remain editable throughout the project's lifetime.

Changing document settings should never silently invalidate existing embroidery data.

Project Type is not a normal editable setting. Cross-domain changes must use explicit conversion or derivation workflows.

---

# Access

The Document Setup dialog is available from

```text
File
 └── Document Setup...
```

or

```text
Document
 └── Settings...
```

---

# Layout

The Document Setup window is divided into logical sections.

```text
General

Project Type

Hoop

Machine

Material

Threads

Color Management

Simulation

Metadata

Advanced
```

Each section is collapsible.

Domain-specific sections are loaded from the active Project Type. Embroidery uses hoop, machine, material, thread, color management, simulation, and metadata. Future Weaving and Digital Printing Projects use their own setup sections.

---

# General

Fields

- Project Name
- Storage Location
- Units
- Author
- Description

---

# Hoop

Fields

- Hoop Profile
- Hoop Shape
- Width
- Height
- Orientation
- Safe Area
- Origin

Changing the hoop triggers validation.

---

# Machine

Fields

- Manufacturer
- Machine Model
- Needle Count
- Preferred Export Format

Machine selection is optional.

---

# Material

Fields

- Material Profile
- Fabric Color
- Stretch
- Thickness
- Stabilizer

Changing material updates simulation defaults.

---

# Thread

Fields

- Thread Manufacturer
- Thread Collection
- Thread Weight
- Default Palette

Changing thread libraries does not automatically recolor existing embroidery.

---

# Color Management

Fields

- Working Color Space
- Thread Matching Strategy
- Background Color
- Soft Proof Threads

---

# Simulation

Fields

- Default Simulation Speed
- Fabric Rendering
- Thread Rendering
- Physics Quality

These affect preview only.

---

# Metadata

Fields

- Customer
- Job Number
- Company
- Tags
- Notes

Metadata is stored with the document.

---

# Validation

Changing settings may trigger validation.

Examples

```text
Change Hoop

↓

Design exceeds hoop

↓

Warning Dialog

Resize Design

Reposition Design

Ignore

Cancel
```

The application never silently changes embroidery geometry.

---

# Save

Changes are applied only when the user confirms.

Cancel discards all pending modifications.

---

# Domain Rules

- All settings remain editable.
- Validation occurs before applying changes.
- Geometry is never modified automatically.
- Machine selection remains optional.
- Simulation settings do not modify embroidery data.
- Metadata does not affect manufacturing.

---

# Acceptance Criteria

✓ Existing document settings are editable.

✓ Validation is defined.

✓ Project configuration remains independent from embroidery objects.

✓ Safe update workflow is documented.
