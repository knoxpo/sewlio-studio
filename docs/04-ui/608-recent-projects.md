# UI
## UI-608 Recent Projects

**Document ID:** UI-608  
**Title:** Recent Projects  
**Version:** 1.0.0  
**Status:** Foundation (High)  
**Priority:** High

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-012 Home Workspace
UI-013 Document Lifecycle
UI-601 Open & Save

ARCH-009 Preferences
```

---

# Purpose

This document defines how recently opened projects are presented and managed.

Recent Projects provide quick access to frequently used work.

---

# Philosophy

Users should spend as little time as possible locating projects.

The Recent Projects experience should provide useful project information before opening the document.

---

# Layout

Projects are displayed as cards.

Each card contains

- Thumbnail
- Project Name
- Last Opened
- Last Modified
- File Location
- Hoop
- Machine
- Stitch Count
- Favorite Status

---

# Example

```text
┌──────────────────────────────────────┐
│ Company Logo                         │
│ logo.esproj                          │
│                                      │
│ 🪡 12,483 stitches                   │
│ 🧵 8 thread colors                   │
│ ⭕ Brother 130×180 Hoop              │
│ 📅 Yesterday                         │
│ ⭐ Favorite                          │
└──────────────────────────────────────┘
```

---

# Actions

Each project supports

- Open
- Pin
- Remove from Recent
- Duplicate
- Rename
- Show in Folder

Removing from Recent never deletes the project.

---

# Favorites

Projects may be pinned.

Pinned projects always appear before normal recent projects.

---

# Sorting

Supported sorting methods

- Last Opened
- Last Modified
- Name
- Favorite
- Stitch Count

---

# Search

Search supports

- Project Name
- Tags
- Customer
- Machine
- Hoop
- Folder

Search updates results in real time.

---

# Missing Files

If a project cannot be found

Display

```text
Project Missing

Locate

Remove

Ignore
```

The user may locate the new file path.

---

# Metadata

The Recent Project index stores lightweight metadata only.

It never loads the complete project until opened.

---

# Performance

Recent Projects should load immediately.

Project previews are loaded asynchronously.

Metadata should be cached.

---

# Persistence

The application stores

- Recent Projects
- Favorites
- Last Opened
- Custom Order (optional)

This information belongs to user preferences.

---

# Domain Rules

- Recent Projects never own project data.
- Removing from Recent never deletes files.
- Missing files are recoverable.
- Favorites remain until manually removed.
- Metadata should remain lightweight.

---

# Acceptance Criteria

✓ Recent Project cards are defined.

✓ Actions are documented.

✓ Search is specified.

✓ Missing project handling is documented.

✓ Persistence rules are defined.