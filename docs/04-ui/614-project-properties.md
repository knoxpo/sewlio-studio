# UI
## UI-614 Project Properties

**Document ID:** UI-614  
**Title:** Project Properties  
**Version:** 1.0.0  
**Status:** Foundation (High)  
**Priority:** Medium

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-607 Document Setup
UI-610 Project Templates

ARCH-004 Document Model
```

---

# Purpose

This document defines project-level metadata.

Project Properties describe the project itself rather than its embroidery content.

Properties are editable throughout the project lifecycle.

---

# Philosophy

Project metadata should support organization, search, reporting, and collaboration without affecting embroidery output.

---

# Access

Project Properties are available from

```text
File

↓

Project Properties...
```

---

# Layout

Sections

```text
General

Author

Organization

Customer

Job Information

Classification

Notes
```

---

# General

Fields

- Project Name
- Description
- Version
- Status

---

# Author

Fields

- Author
- Designer
- Email
- Company

---

# Customer

Fields

- Customer Name
- Customer ID
- Contact
- Purchase Order

---

# Job Information

Fields

- Job Number
- Production Batch
- Due Date
- Quantity

---

# Classification

Fields

- Category
- Tags
- Keywords
- Product Type

---

# Notes

Fields

- Internal Notes
- Manufacturing Notes
- Customer Notes

---

# Preview

The dialog displays

- Project Thumbnail
- Creation Date
- Last Modified
- File Size
- Stitch Count
- Estimated Thread Usage

---

# Search Integration

Project Properties participate in

- Recent Project Search
- Project Browser
- Global Search
- Future Asset Management

---

# Export

Project metadata may optionally be embedded into supported project formats.

Machine formats that do not support metadata simply ignore these fields.

---

# Security

Sensitive fields are stored only within the project.

Exporters should not embed confidential metadata unless explicitly enabled.

---

# Domain Rules

- Metadata does not affect embroidery generation.
- Metadata does not affect simulation.
- Metadata does not affect export unless supported.
- Metadata is fully editable.
- Metadata participates in project search.

---

# Future Topics

Future versions may support

- Project approvals
- Digital signatures
- Revision history
- Asset tracking
- ERP integration
- MES integration
- Barcode generation

---

# Acceptance Criteria

✓ Metadata structure defined.

✓ UI layout documented.

✓ Search integration documented.

✓ Export behavior documented.

✓ Future enterprise extensions identified.