# Personas
## Sewlio Studio

**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Product Management

---

# Purpose

This document defines the target users of Sewlio Studio.

Every feature, UX decision, engineering decision, performance optimization, and future roadmap item should be evaluated against these personas.

Personas are not fictional marketing exercises—they define the users for whom the product is being optimized.

---

# Product Positioning

Sewlio Studio serves creators rather than enterprises.

The platform is designed for people who create embroidery rather than simply consume embroidery files.

The primary audience includes:

- Hobbyists
- Small Businesses
- Professional Digitizers
- Designers
- Makers
- Educational Institutions

---

# Persona Priority

| Priority | Persona | MVP |
|----------|----------|-----|
| P0 | Professional Digitizer | ✅ |
| P0 | Small Business Owner | ✅ |
| P0 | Hobbyist | ✅ |
| P1 | Etsy Seller | ✅ |
| P1 | Apparel Designer | Phase 2 |
| P1 | Embroidery Shop | Phase 2 |
| P2 | Educational Institution | Phase 3 |
| P2 | Plugin Developer | Future |
| P3 | Enterprise Team | Future |

---

# Persona 1
# Professional Digitizer

## Profile

Professional embroidery designers who produce embroidery files for clients.

Often work full time creating embroidery designs.

Usually familiar with:

- Wilcom
- Hatch
- Pulse
- Brother PE-Design
- Embrilliance

---

## Goals

Create embroidery designs quickly.

Minimize manual editing.

Produce accurate machine files.

Deliver commercial-quality embroidery.

Handle large projects.

---

## Pain Points

Commercial software is expensive.

Licensing restrictions.

Windows-only software.

Poor UI.

Old workflows.

Weak tablet support.

Little automation.

Vendor lock-in.

---

## Needs

Professional tools.

Accurate digitizing.

Reliable exports.

High performance.

Large project support.

Advanced stitch control.

Thread libraries.

Machine profiles.

---

## Typical Workflow

Receive customer artwork.

↓

Clean vector.

↓

Prepare embroidery objects.

↓

Digitize.

↓

Preview stitches.

↓

Export.

↓

Deliver files.

---

## Success Criteria

Sewlio Studio replaces commercial software for day-to-day production.

---

# Persona 2
# Hobbyist

## Profile

Creates embroidery as a hobby.

Usually owns:

Single embroidery machine.

Works evenings and weekends.

---

## Goals

Learn embroidery.

Create gifts.

Personalize clothing.

Experiment creatively.

---

## Pain Points

Commercial software is confusing.

Too expensive.

Too technical.

Poor documentation.

---

## Needs

Simple interface.

Good tutorials.

Affordable.

Safe experimentation.

Undo.

Templates.

---

## Success Criteria

Can create a design without reading extensive documentation.

---

# Persona 3
# Etsy Seller

## Profile

Runs a small online embroidery business.

Creates products for:

Etsy

Shopify

Instagram

Craft fairs

---

## Goals

Fast production.

Repeatable workflow.

Product customization.

Professional quality.

---

## Pain Points

Time-consuming digitizing.

Managing customer revisions.

File organization.

---

## Needs

Templates.

Project duplication.

Reusable assets.

Fast export.

Reliable machine files.

---

## Success Criteria

Reduce production time.

Increase repeatability.

---

# Persona 4
# Embroidery Shop

## Profile

Small commercial embroidery business.

Produces:

Uniforms

Corporate apparel

Sportswear

Promotional products

---

## Goals

Consistent quality.

Support many machines.

Fast turnaround.

Reuse designs.

---

## Pain Points

Managing machine compatibility.

Large customer libraries.

Software costs.

---

## Needs

Machine profiles.

Thread libraries.

Project organization.

Reliable exports.

---

## Success Criteria

Standardize production.

---

# Persona 5
# Apparel Designer

## Profile

Graphic designer incorporating embroidery into apparel.

Usually familiar with:

Illustrator

Affinity Designer

Photoshop

Figma

---

## Goals

Move from artwork to embroidery quickly.

Reuse existing vector assets.

Preview embroidery early.

---

## Pain Points

Traditional embroidery software has poor vector editing.

Multiple software packages required.

---

## Needs

Excellent vector editor.

SVG import.

Modern UI.

Fast preview.

---

## Success Criteria

Stay inside one application.

---

# Persona 6
# Maker / Fab Lab User

## Profile

Uses makerspaces.

Interested in:

Laser cutting

3D printing

CNC

Embroidery

---

## Goals

Experiment.

Prototype.

Share projects.

---

## Pain Points

Embroidery software feels outdated.

---

## Needs

Open source.

Cross-platform.

Modern interface.

Community.

---

## Success Criteria

Embroidery becomes another digital fabrication workflow.

---

# Persona 7
# Teacher / Educational Institution

## Profile

Teaches embroidery.

Works with beginners.

---

## Goals

Teach embroidery concepts.

Demonstrate stitch generation.

Show simulations.

---

## Needs

Affordable software.

Simple UI.

Classroom-friendly.

Offline support.

---

## Success Criteria

Students learn without expensive licenses.

---

# Persona 8
# Plugin Developer (Future)

## Profile

Software developer extending the platform.

---

## Goals

Create plugins.

Automation.

Custom exporters.

Integrations.

---

## Needs

Stable APIs.

Documentation.

SDK.

Testing tools.

---

## Success Criteria

Can extend functionality without modifying the core.

---

# Persona 9
# AI Agent (Internal Persona)

## Profile

Autonomous software engineering agent.

Examples:

Claude Code

Gemma

Qwen

Future local models

---

## Goals

Implement tasks accurately.

Respect architecture.

Maintain code quality.

---

## Needs

Clear documentation.

Stable APIs.

Small implementation tasks.

Package ownership.

Acceptance criteria.

Architecture rules.

---

## Success Criteria

Can implement features without introducing architectural drift.

---

# Primary User Journeys

## Professional Digitizer

Open project

↓

Import customer artwork

↓

Clean vectors

↓

Digitize

↓

Preview

↓

Export

↓

Deliver

---

## Hobbyist

Create project

↓

Draw artwork

↓

Convert to stitches

↓

Preview

↓

Save

↓

Export

↓

Embroider

---

## Etsy Seller

Duplicate template

↓

Modify customer text/logo

↓

Export

↓

Ship order

---

# Product Priorities by Persona

| Feature | Professional | Hobbyist | Etsy | Shop | Designer |
|----------|-------------:|----------:|------:|------:|----------:|
| SVG Import | High | Medium | High | Medium | Critical |
| Vector Editing | High | Medium | High | Medium | Critical |
| Running Stitch | Critical | High | Critical | Critical | High |
| Satin Stitch | Critical | Medium | High | Critical | Medium |
| Fill Stitch | Critical | Medium | High | Critical | Medium |
| Thread Libraries | High | Medium | Medium | Critical | Low |
| Machine Profiles | High | Low | Medium | Critical | Low |
| Tablet UX | High | High | High | Medium | High |
| Offline Mode | Critical | High | High | Critical | Medium |
| AI Assistance | Medium | High | High | Medium | Medium |

---

# Design Principles Derived from Personas

The personas lead to the following product decisions:

1. The application must never require an internet connection.

2. Professional users must not lose precision in favor of simplicity.

3. Beginners should be able to start with templates and guided workflows.

4. The UI should feel familiar to users of Figma, Affinity Designer, Illustrator, and Procreate.

5. Tablet workflows are first-class experiences, not simplified companion interfaces.

6. The editable source of truth is always `.swl`; machine formats are generated outputs.

7. Performance must scale from simple hobby projects to commercial, high-stitch-count designs.

8. Documentation should serve both human contributors and AI engineering agents.

---

# Future Persona Expansion

Future versions of this document may include:

- Large enterprise embroidery operations
- Textile manufacturers
- OEM embroidery machine vendors
- Plugin marketplace developers
- AI workflow designers
- Automation engineers
- Print-on-demand businesses
- Fashion brands
- Educational curriculum authors

---

# Acceptance Criteria

This document is considered complete when:

- Every major product feature maps to one or more personas.
- Every roadmap item identifies its primary beneficiary.
- UX decisions reference persona needs.
- AI agents can identify the intended audience before implementing a feature.
- New features cannot be proposed without identifying the personas they serve.
