# UI
## UI-606 New Document Workflow

**Document ID:** UI-606  
**Title:** New Document Workflow  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-010 Application Lifecycle
UI-011 Workspaces
UI-012 Home Workspace
UI-013 Document Lifecycle

UI-607 Document Setup
UI-610 Project Templates
UI-611 Project Recipes

DOM-300 Machine Model
DOM-304 Hoops
DOM-400 Thread Theory
DOM-402 Thread Colors
DOM-500 Fabric Theory
DOM-505 Material Profiles

ARCH-004 Document Model
ARCH-008 State Management
```

---

# Purpose

This document defines the complete workflow for creating a new Sewlio Studio project.

Unlike traditional graphics applications where a new document primarily defines a canvas, Sewlio Studio creates a complete production-ready project containing document, production, and simulation defaults.

The New Document Workflow is the primary entry point for selecting a Project Type and creating a project.

---

# Philosophy

Creating a project should be simple for beginners while remaining powerful enough for professional digitizers.

The workflow should minimize repetitive configuration by encouraging the use of Templates and Project Recipes.

Users should be able to start working within seconds while still having access to advanced production settings.

---

# Goals

The New Document Workflow shall provide

- Fast project creation
- Beginner-friendly defaults
- Professional production configuration
- Template support
- Recipe support
- Live project preview
- Validation before creation
- Progressive disclosure of advanced settings

---

# Workflow Overview

```text
Application Launch

↓

Home Workspace

↓

New Project

↓

Choose Project Type

↓

Select Template / Recipe

↓

Configure Project

↓

Validation

↓

Create Document

↓

Document Session

↓

Open Editor Workspace
```

---

# Entry Points

A new document may be created from

- Home Workspace
- File → New Project
- Keyboard Shortcut
- Command Palette
- Welcome Screen
- Template Browser
- Recipe Browser

---

# User Interface

The workflow is presented as a full-page creation experience rather than a small modal dialog.

```text
┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│ ← Back                                            New Embroidery Project                     │
├─────────────────────┬──────────────────────────────────────────────┬─────────────────────────┤
│                     │                                              │                         │
│ Templates           │ Project Configuration                        │ Live Preview            │
│ Recipes             │                                              │                         │
│                     │ Document                                     │ Hoop Preview            │
│ Blank               │ Hoop                                         │ Safe Area               │
│ Left Chest          │ Machine                                      │ Material Preview        │
│ Cap Front           │ Material                                     │ Grid                    │
│ Patch               │ Thread                                       │ Orientation             │
│ Jacket Back         │ Color Management                             │                         │
│ Custom              │ Advanced                                     │                         │
│                     │                                              │                         │
├─────────────────────┴──────────────────────────────────────────────┴─────────────────────────┤
│ Cancel                                                             Create Project            │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

# Workflow Stages

The workflow consists of six stages.

```text
1. Choose Project Type

↓

2. Select Template or Recipe

↓

3. Configure Project

↓

4. Validate Configuration

↓

5. Create Project

↓

6. Open Editor
```

Initial Project Type options are Embroidery, Weaving, and Digital Printing. Only Embroidery must create a fully implemented MVP project. Weaving and Digital Printing may be documented as future-capable options until their engines exist.

---

# Templates

Templates provide document defaults.

Examples

```text
Blank Project

Left Chest Logo

Cap Front

Patch

Jacket Back

Sleeve Logo

Large Back

Towel

Custom Hoop
```

Templates configure

- Units
- Hoop
- Grid
- Background
- Thread Library
- Simulation Defaults

Templates do not define manufacturing intent.

---

# Project Recipes

Recipes represent production workflows.

Examples

```text
Corporate Polo

Sports Jersey

Baseball Cap

Leather Patch

Towel Embroidery

3D Puff Foam

Freestanding Lace

Applique
```

Recipes configure

- Recommended Hoop
- Material Profile
- Stabilizer
- Thread Library
- Needle
- Quality Preset
- Machine Defaults
- Export Defaults

Recipes may internally reference Templates.

---

# Project Configuration

The center panel contains the project configuration.

Sections

```text
General

Hoop

Machine

Material

Threads

Color Management

Advanced
```

Each section is collapsible.

---

# General

Fields

- Project Name
- Storage Location
- Units
- Template
- Recipe

Supported Units

- Millimeters
- Inches

Millimeters are the default.

---

# Hoop

The Hoop section defines the embroidery working area.

Fields

- Hoop Profile
- Hoop Shape
- Width
- Height
- Orientation
- Safe Area
- Rotation
- Origin

Supported Shapes

- Rectangle
- Square
- Oval
- Circle
- Custom

Users may select either predefined hoops or create custom hoops.

---

# Machine

Machine selection is optional.

Fields

- Manufacturer
- Machine
- Needle Count
- Preferred Export Format

If no machine is selected, the project uses a Generic Machine Profile.

---

# Material

Fields

- Material Profile
- Fabric Color
- Fabric Type
- Stretch Level
- Thickness
- Stabilizer

Selecting a material automatically updates

- Simulation defaults
- Quality recommendations
- Thread rendering
- AI suggestions

---

# Threads

Fields

- Thread Manufacturer
- Thread Collection
- Thread Weight
- Default Palette

Examples

```text
Madeira

Isacord

Brother

Gunold

Robison-Anton
```

---

# Color Management

The document stores a working color space.

Fields

- Working Color Space
- Thread Matching Method
- Background Color
- Soft Proof Threads

Supported Working Color Spaces

- sRGB
- Display P3
- Adobe RGB
- CIELAB

Color spaces affect artwork preview only.

Machine embroidery always maps colors to physical thread libraries.

---

# Advanced

Advanced settings include

- Metadata
- Grid Preset
- Measurement Precision
- Simulation Defaults
- Export Defaults
- AI Defaults

The Advanced section is collapsed by default.

---

# Live Preview

The right panel continuously previews the project.

The preview updates immediately whenever configuration changes.

Displayed information

- Hoop
- Safe Area
- Fabric Color
- Background
- Grid
- Orientation
- Units
- Estimated Work Area

The preview is informational only.

Editing occurs through the configuration panel.

---

# Validation

Before project creation, the application validates

- Project Name
- Hoop Dimensions
- Machine Compatibility
- Material Profile
- Thread Library
- Recipe Requirements

Validation levels

```text
Information

Warning

Error

Critical
```

Errors prevent project creation.

Warnings allow project creation after confirmation.

---

# Project Creation

Selecting **Create Project** performs

```text
Create Document

↓

Create Document Session

↓

Create Initial Layer

↓

Initialize Workspace

↓

Open Editor Workspace

↓

Focus Canvas
```

---

# Default Document Contents

Every new project starts with

- Empty Document
- Root Layer
- Default Grid
- Default Viewport
- Default Thread Library
- Selected Hoop
- Material Profile
- Undo History
- Validation State

No embroidery objects are created automatically.

---

# User Templates

Users may save current settings as a reusable template.

Menu

```text
Save as Template
```

Templates store configuration only.

No artwork is included.

---

# User Recipes

Users may save manufacturing workflows as Recipes.

Menu

```text
Save as Recipe
```

Recipes include production recommendations but never include project artwork.

---

# Editing After Creation

All project settings remain editable.

Menu

```text
File

↓

Document Setup...
```

Changing settings after embroidery exists triggers validation.

The application never silently modifies embroidery geometry.

---

# Accessibility

The workflow supports

- Keyboard navigation
- Screen readers
- High contrast mode
- Full keyboard operation
- Focus management

Every control must be accessible without a mouse.

---

# Domain Rules

The following always apply.

- Every project begins with a valid hoop.
- Machine selection is optional.
- Material influences simulation defaults.
- Thread library establishes project defaults.
- Templates define document defaults.
- Recipes define manufacturing workflows.
- Live Preview reflects the current configuration.
- Validation occurs before creation.
- Users may modify all settings before creation.
- All project settings remain editable after creation.
- Creating a project never creates embroidery objects automatically.

---

# Future Enhancements

Future versions may support

- AI-generated project recipes
- Cloud templates
- Company template libraries
- Team recipe catalogs
- Machine fleet presets
- Material vendor catalogs
- Customer-specific defaults
- Interactive preview rendering
- Template marketplace

---

# Acceptance Criteria

The New Document Workflow specification is complete when

✓ Project creation workflow is defined.

✓ Template support is documented.

✓ Recipe support is documented.

✓ Project configuration sections are specified.

✓ Live Preview behavior is defined.

✓ Validation workflow is documented.

✓ Accessibility requirements are established.

✓ Project creation sequence is documented.

✓ Editing after creation is supported.

✓ Domain rules are clearly defined.
