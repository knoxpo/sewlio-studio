# UI
## UI-610 Project Templates

**Document ID:** UI-610  
**Title:** Project Templates  
**Version:** 1.0.0  
**Status:** Foundation (High)  
**Priority:** High

**Owner:** Product & UX Team

**Related Documents**

```text
UI-606 New Document Workflow
UI-607 Document Setup

DOM-304 Hoops
DOM-505 Material Profiles
DOM-402 Thread Colors
```

---

# Purpose

Project templates may be shared or Project-Type-specific. Embroidery templates remain MVP templates; future weaving and digital printing templates must declare their Project Type.

This document defines reusable project templates.

Templates accelerate project creation by providing predefined document configurations.

Templates contain defaults only.

They never contain embroidery artwork.

---

# Philosophy

Most embroidery work starts from a common production scenario.

Templates should eliminate repetitive configuration while remaining easy to customize.

---

# Goals

Templates shall provide

- Faster project creation
- Consistent document defaults
- Standardized production settings
- Team consistency

---

# Built-in Templates

The application includes templates such as

```text
Blank Project

Left Chest Logo

Cap Front

Jacket Back

Patch

Sleeve Logo

Large Back

Towel

Custom Hoop
```

Additional templates may be provided by plugins.

---

# Template Contents

Templates may define

- Units
- Hoop
- Hoop Orientation
- Material Profile
- Thread Library
- Grid Settings
- Snap Settings
- Simulation Defaults
- Export Defaults
- Background Color

Templates never contain

- Artwork
- Embroidery Objects
- Undo History
- Customer Data
- Project Metadata

---

# Creating from Template

Workflow

```text
Home Workspace

↓

New Project

↓

Choose Template

↓

Modify Configuration

↓

Create Document
```

Users may modify any setting before creation.

---

# User Templates

Users may create custom templates from an existing project.

Example

```text
File

↓

Save as Template
```

The application removes all project-specific data before saving the template.

---

# Template Categories

Templates may be organized by category.

Examples

```text
General

Corporate Branding

Apparel

Patches

Caps

Home Decor

Custom
```

---

# Template Preview

Each template displays

- Name
- Thumbnail
- Hoop
- Material
- Thread Library
- Description

---

# Template Updates

Built-in templates may be updated with new application versions.

User templates remain untouched.

---

# Sharing

User templates may be exported and imported.

This enables

- Team sharing
- Company standards
- Marketplace distribution (future)

---

# Domain Rules

- Templates contain defaults only.
- Templates never contain project data.
- Templates remain editable before project creation.
- User templates override built-in templates when names conflict.
- Templates may be extended by plugins.

---

# Future Topics

Future versions may support

- Cloud templates
- Company template libraries
- Template marketplace
- AI-generated templates
- Versioned templates

---

# Acceptance Criteria

✓ Built-in templates are defined.

✓ User templates are supported.

✓ Template contents are documented.

✓ Sharing behavior is specified.

✓ Plugin extensibility is documented.
