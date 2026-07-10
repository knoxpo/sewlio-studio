# UI
## UI-609 Session Recovery

**Document ID:** UI-609  
**Title:** Session Recovery  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** High

**Owner:** Desktop Experience Team

**Related Documents**

```text
UI-010 Application Lifecycle
UI-012 Home Workspace
UI-013 Document Lifecycle
UI-601 Open & Save
UI-608 Recent Projects

ARCH-004 Document Model
ARCH-008 State Management
ARCH-011 Background Tasks
```

---

# Purpose

This document defines how Sewlio Studio detects, stores, presents, and restores recovery sessions after an unexpected shutdown or crash.

Recovery protects user work without replacing normal project saves.

---

# Philosophy

Recovery is a safety net.

Users should always be informed when recoverable work exists and should remain in control of whether to restore or discard it.

Recovery data is temporary and independent of the project's saved state.

---

# Goals

The Session Recovery system shall provide

- Automatic recovery snapshots
- Safe crash recovery
- User-controlled restoration
- Multiple document recovery
- Recovery cleanup
- Recovery diagnostics

---

# Workflow

```text
Application Running

↓

Recovery Snapshot Created

↓

Unexpected Shutdown

↓

Application Restart

↓

Recovery Detection

↓

Recovery Workspace

↓

User Decision

├── Restore
├── Discard
└── Inspect

↓

Home Workspace
or
Recovered Documents
```

---

# Recovery Sources

Recovery data may originate from

- Application crash
- Operating system restart
- Power failure
- Forced termination
- Unexpected plugin failure

---

# Recovery Workspace

When recovery data exists, the Home Workspace displays a dedicated Recovery section.

Each recovery entry displays

- Project Name
- Original File
- Snapshot Time
- Time Since Crash
- Unsaved Changes
- Recovery Status

---

# Recovery Actions

Each recovery session supports

- Restore
- Restore as Copy
- Compare with Saved Version
- Discard
- View Details

---

# Restore

Selecting Restore creates

```text
Recovery Snapshot

↓

Document Session

↓

Recovered Document

↓

Editor Workspace
```

The original project file is never overwritten automatically.

---

# Restore as Copy

Creates a new project from the recovery snapshot.

The original project remains unchanged.

---

# Compare with Saved Version

Future functionality may compare

- Metadata
- Objects
- Stitch Count
- Layers
- Document Properties

This feature is optional.

---

# Recovery Snapshot

A snapshot stores

- Document State
- Undo History (optional)
- Viewport
- Active Tool
- Selection
- Simulation Cache (optional)

Snapshots are internal and not intended for long-term storage.

---

# Auto Recovery

Recovery snapshots should be generated

- periodically
- after significant document changes
- before long-running operations

The exact interval is implementation-defined.

---

# Multiple Recoveries

The application supports recovering multiple projects independently.

Each recovery session is isolated.

---

# Cleanup

Recovery data is automatically removed when

- the user successfully restores and saves the document
- the user explicitly discards the recovery
- recovery expires according to user preferences

---

# Errors

If a recovery snapshot is corrupted

Display

```text
Recovery Failed

View Details

Discard Recovery
```

The application continues running normally.

---

# Domain Rules

- Recovery is independent of project saves.
- Recovery never silently overwrites project files.
- Recovery always requires user confirmation.
- Multiple recoveries are supported.
- Recovery data is temporary.
- Corrupted recovery data must never prevent application startup.

---

# Future Topics

Future versions may support

- Incremental recovery
- Cloud recovery
- Version comparison
- Recovery timeline
- Automatic recovery validation

---

# Acceptance Criteria

✓ Recovery workflow is defined.

✓ Recovery actions are documented.

✓ Snapshot ownership is specified.

✓ Cleanup rules are documented.

✓ User confirmation requirements are defined.
