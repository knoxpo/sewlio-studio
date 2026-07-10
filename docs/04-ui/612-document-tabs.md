# UI
## UI-612 Document Tabs

**Document ID:** UI-612  
**Title:** Document Tabs  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-011 Workspaces
UI-012 Home Workspace
UI-013 Document Lifecycle

UI-608 Recent Projects

ARCH-008 State Management
```

---

# Purpose

This document defines the behavior of document tabs.

Document Tabs provide access to multiple simultaneously opened document sessions.

Tabs are presentation components.

They never own document data.

---

# Philosophy

Tabs should make switching between embroidery projects fast, predictable, and informative.

The tab bar should communicate document state without requiring users to open every document.

---

# Layout

Example

```text
🏠 Home

Logo.esproj ●

Patch.esproj

Cap.esproj

+
```

The Home tab is pinned and cannot be closed.

---

# Tab Contents

Each tab displays

- Project Name
- Dirty Indicator
- Close Button
- Read-only Indicator
- Warning Indicator
- Background Activity Indicator

---

# States

Normal

```text
Logo.esproj
```

Dirty

```text
Logo.esproj ●
```

Read Only

```text
🔒 Logo.esproj
```

Validation Warning

```text
⚠ Logo.esproj
```

Export Running

```text
⏳ Logo.esproj
```

Recovery

```text
🛟 Logo.esproj
```

---

# Actions

Each tab supports

- Activate
- Close
- Duplicate
- Close Others
- Close All
- Reveal in Explorer
- Rename
- Pin (future)

---

# Drag & Drop

Users may

- reorder tabs
- move tabs between windows (future)

Dragging never modifies the document.

---

# Closing

Closing a dirty document displays

```text
Save

Discard

Cancel
```

---

# Multiple Windows

Future versions may move tabs between application windows.

Each window owns its own tab strip.

---

# Tab Persistence

The application remembers

- open tabs
- active tab
- tab order

These are restored on startup if session restoration is enabled.

---

# Background Operations

Tabs may display progress for

- Export
- Import
- Simulation
- AI Analysis
- Validation

Progress indicators should not block editing.

---

# Accessibility

Tabs support

- keyboard navigation
- close shortcuts
- screen readers
- high contrast mode

---

# Domain Rules

- Tabs never own document data.
- Every open document has one tab.
- Home is not a document.
- Closing a tab closes only its Document Session.
- Tab order has no effect on document content.
- Dirty state belongs to the document, not the tab.

---

# Acceptance Criteria

✓ Tab lifecycle is documented.

✓ Tab states are defined.

✓ Actions are documented.

✓ Persistence is specified.

✓ State ownership is clear.