# UI
## UI-611 Project Recipes

**Document ID:** UI-611  
**Title:** Project Recipes  
**Version:** 1.0.0  
**Status:** Foundation (Innovation)  
**Priority:** High

**Owner:** Product & UX Team

**Related Documents**

```text
UI-606 New Document Workflow
UI-607 Document Setup
UI-610 Project Templates

DOM-300 Machine Model
DOM-304 Hoops
DOM-400 Thread Theory
DOM-500 Fabric Theory
DOM-505 Material Profiles

AI-903 Best Practices
```

---

# Purpose

Project recipes represent production workflows and may be Project-Type-specific. Embroidery recipes remain MVP recipes; future weaving and digital printing recipes must resolve to their domain engines and profiles.

This document defines Project Recipes.

A Project Recipe represents a complete embroidery production workflow.

Unlike Templates, Recipes capture manufacturing intent rather than only document defaults.

Recipes provide recommended settings for common embroidery scenarios.

---

# Philosophy

Most embroidery projects are created for a specific production purpose.

Examples

- Left Chest Logo
- Baseball Cap
- Jacket Back
- Sleeve Logo
- Patch
- Towel
- Foam Embroidery

Rather than asking users to configure every project manually,

Recipes configure the project using production best practices.

---

# Goals

Recipes shall

- accelerate project creation
- reduce configuration mistakes
- standardize production workflows
- capture manufacturing knowledge
- improve consistency
- provide AI guidance

---

# Template vs Recipe

Templates define

```text
Document Defaults

↓

Hoop

Units

Grid

Thread Library

Simulation
```

Recipes define

```text
Manufacturing Workflow

↓

Garment

Machine

Hoop

Fabric

Stabilizer

Thread

Needle

Export

Quality Profile
```

Templates answer

> "How should the document start?"

Recipes answer

> "How is this product manufactured?"

---

# Built-in Recipes

Examples

```text
Left Chest Logo

Cap Front

Jacket Back

Sleeve Logo

Patch

Large Back

Towel

3D Puff Foam

Applique

Freestanding Lace

Chenille

Sequin Embroidery
```

---

# Recipe Contents

A Recipe may define

Document

- Preferred Template
- Units

Machine

- Machine Profile
- Needle Count

Hoop

- Hoop Profile
- Safe Area

Material

- Fabric Profile
- Stabilizer
- Stretch

Thread

- Thread Library
- Weight
- Color Matching

Needle

- Needle Type
- Needle Size

Quality

- Density Preset
- Pull Compensation
- Underlay Defaults

Export

- Preferred Export Format

Simulation

- Default Quality

Warnings

- Common Problems

---

# Example

Recipe

```text
Cap Front
```

Automatically configures

```text
Machine

Brother PR680

↓

Hoop

Cap Driver

↓

Material

Structured Cap

↓

Stabilizer

Cap Backing

↓

Thread

Madeira Rayon 40

↓

Needle

75/11 Sharp

↓

Quality

Cap Optimized

↓

Export

PES
```

---

# AI Integration

Recipes provide contextual knowledge for the AI Assistant.

Example

```text
Selected Recipe

↓

Cap Front

↓

AI Recommendations

Increase Pull Compensation

Use Center Walk Underlay

Avoid Large Fill Areas

Reduce Stitch Length

Optimize Travel
```

---

# Recipe Categories

Recipes may be grouped by

```text
Garments

Promotional

Industrial

Sports

Patches

Home Decor

Specialty

Commercial
```

---

# User Recipes

Users may create

custom recipes.

Menu

```text
File

↓

Save as Recipe
```

Recipes contain manufacturing settings only.

Artwork is never stored.

---

# Recipe Preview

Selecting a recipe displays

```text
Recommended Hoop

Machine

Material

Thread

Needle

Estimated Difficulty

Estimated Stitch Quality

Typical Use Cases
```

---

# Validation

Changing the recipe after embroidery exists triggers

```text
Validation

↓

Affected Settings

↓

Warnings

↓

Apply

Cancel
```

Existing embroidery is never silently modified.

---

# Plugin Support

Plugins may contribute

- Recipes
- Categories
- Quality Profiles
- Validation Rules

Plugins cannot modify built-in recipes directly.

---

# Future Integration

Recipes may be associated with

- Customer Profiles
- Company Standards
- Machine Fleets
- Thread Suppliers
- Material Vendors

---

# Domain Rules

- Recipes represent manufacturing workflows.
- Recipes never contain artwork.
- Recipes never contain project history.
- Recipes may depend on templates.
- Templates do not depend on recipes.
- AI may recommend recipes.
- Users may override any recipe setting.
- Recipe changes require validation.

---

# Acceptance Criteria

✓ Recipe concept is defined.

✓ Recipe contents are documented.

✓ Recipe/template distinction is clear.

✓ AI integration is specified.

✓ Plugin extensibility is documented.

✓ Validation behavior is defined.
