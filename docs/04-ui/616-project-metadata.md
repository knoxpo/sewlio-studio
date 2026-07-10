# UI
## UI-616 Project Metadata

**Document ID:** UI-616
**Title:** Project Metadata
**Version:** 1.0.0
**Status:** Foundation
**Priority:** Medium

**Owner:** Core Platform Team

**Related Documents**

```text
UI-614 Project Properties

ARCH-004 Document Model

EXP-800 Machine IR
```

---

# Purpose

Project Metadata defines structured information stored within a Sewlio Studio project file.

Metadata supports search, versioning, plugins, collaboration, and interoperability.

Unlike Project Properties, metadata includes both user-visible and system-managed information.

---

# Metadata Categories

Project Metadata consists of

```text
Identity

Versioning

Ownership

Document

Runtime

Plugin

Custom

System
```

---

# Identity

Stores

- UUID
- Project Identifier
- Schema Version

---

# Versioning

Stores

- File Format Version
- Document Revision
- Creation Date
- Last Modified
- Last Saved

---

# Ownership

Stores

- Author
- Company
- Organization
- Customer
- Job Number

---

# Document

Stores

- Units
- Hoop
- Machine
- Material
- Thread Library
- Active Recipe
- Active Template

---

# Runtime

Stores

- Last Opened

- Last Export

- Last Simulation

- Last Validation

These values are optional.

---

# Plugin Data

Plugins may store

```text
Plugin Identifier

Plugin Version

Plugin Settings

Plugin Cache
```

Plugins must namespace their metadata.

---

# Custom Metadata

Users may define arbitrary metadata fields.

Examples

```text
Department

Purchase Order

Cost Center

Production Batch

Operator
```

---

# Search

Metadata participates in

- Project Browser
- Recent Projects
- Global Search
- Enterprise Search

---

# Export

Project metadata is preserved in

Sewlio Studio project files.

Machine formats include metadata only when supported.

---

# Migration

Older project versions should migrate metadata automatically whenever possible.

Unknown metadata should be preserved.

---

# Domain Rules

- Metadata never affects embroidery geometry.
- Unknown metadata should never be discarded.
- Plugin metadata must be namespaced.
- Metadata should be versioned.
- Metadata should support forward compatibility.

---

# Acceptance Criteria

✓ Metadata categories defined.

✓ Plugin support documented.

✓ Versioning documented.

✓ Migration strategy documented.

✓ Search integration documented.
