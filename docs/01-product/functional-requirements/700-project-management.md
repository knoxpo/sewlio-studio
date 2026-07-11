# Functional Requirements
## FR-700 Project Management

**Document ID:** FR-700  
**Title:** Project Management System  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Core Platform Team

**Primary Packages**

```text
Flutter

project_manager/
recent_projects/
project_browser/
dashboard/
search/
templates/

↓

Rust

project/
storage/
metadata/
workspace/
history/
assets/
recovery/
```

---

# Purpose

The Project Management System manages the complete lifecycle of embroidery projects outside of the editor itself.

It enables users to create, organize, search, duplicate, archive, recover, and manage embroidery projects while maintaining portability and a local-first workflow.

Unlike the editor, which focuses on design creation, the Project Management System focuses on project organization and lifecycle management.

---

# Objectives

The Project Management System shall:

- Organize projects
- Provide fast project discovery
- Support local-first workflows
- Support external sync providers
- Protect user work
- Enable safe project recovery
- Preserve project history
- Scale to thousands of projects

---

# Design Principles

## Local First

Projects always belong to the user.

The application never requires cloud storage.

---

## Portable

Projects remain standard `.swl` packages.

They can be copied using:

- Finder
- Windows Explorer
- Linux File Managers
- Files.app
- Google Drive
- Dropbox
- OneDrive
- NAS
- USB drives

---

## Fast

Browsing projects should not require opening the project database.

Metadata should be sufficient.

---

## Safe

Every destructive action requires confirmation or supports recovery.

---

# Project Lifecycle

```text
Create

↓

Edit

↓

Save

↓

Close

↓

Export

↓

Archive

↓

Duplicate

↓

Delete

↓

Recover (if applicable)
```

---

# Project Browser

## FR-701

### Browse Projects

Priority

Critical

---

The application shall provide a Project Browser.

Displays

- Recent Projects
- Pinned Projects
- Local Projects
- Templates
- Archived Projects
- Favorites (future)

---

Project Card

Displays

- Thumbnail
- Name
- Last Modified
- Created Date
- Machine Profile
- Stitch Count
- Hoop Size
- Tags
- Export Status

---

Acceptance Criteria

✓ Loads without opening full project

✓ Supports sorting

✓ Supports searching

✓ Responsive with 5,000+ projects

---

# Recent Projects

## FR-702

Maintain a list of recently opened projects.

Store

- Path
- Thumbnail
- Last Opened
- Last Modified
- Pinned State

Broken paths remain visible until removed.

---

# Project Search

## FR-703

Supports searching by

- Name
- Tags
- Description
- Machine Profile
- Thread Library
- Created Date
- Modified Date
- Hoop Size
- Export Formats

Future

- Full-text search
- AI semantic search

---

Acceptance Criteria

Search updates incrementally.

---

# Project Metadata

## FR-704

Every project stores metadata.

```text
Project ID

Name

Description

Created Date

Modified Date

Project Version

Engine Version

Schema Version

Machine Profile

Thumbnail

Tags

Estimated Stitch Count

Estimated Color Count
```

Metadata must be readable without loading the project database.

---

# Rename Project

## FR-705

Supports

Rename

Project display name

Optionally rename file

---

Changing project name never changes Project ID.

---

# Duplicate Project

## FR-706

Creates

New Project ID

Copied Assets

Copied Metadata

Copied Database

Copied Preview

Independent History

---

Acceptance Criteria

Original project remains unchanged.

---

# Move Project

## FR-707

Supports

Move project

↓

Update recent list

↓

Preserve metadata

Application should detect moved projects.

---

# Delete Project

## FR-708

Supports

Soft Delete

↓

Recycle Bin / Trash

Permanent Delete (future option)

---

User confirmation required.

---

Acceptance Criteria

Deletion never occurs silently.

---

# Archive Project

## FR-709

Archived projects

Remain editable

Hidden by default

Can be restored

---

Future

Read-only archive mode.

---

# Project Templates

## FR-710

Users may create reusable templates.

Templates may contain

- Hoop
- Machine Profile
- Thread Palette
- Layer Structure
- Guides
- Notes

---

Create Project

↓

Choose Template

↓

Project Initialized

---

# Project Tags

## FR-711

Projects support tags.

Examples

```
Logo

Customer

Hat

Patch

Floral

Holiday

Commercial
```

Supports

Add

Remove

Rename

Search

Filter

---

# Favorites

## FR-712

Future

Users may mark projects as favorites.

Favorites appear separately.

---

# Project Notes

## FR-713

Projects support notes.

Supports

Markdown (future)

Plain text (MVP)

Notes never export.

---

# Project Thumbnail

## FR-714

Automatically generated after

Save

Export

Manual Refresh

---

Thumbnail stored separately from project database.

Supports

Light Theme

Dark Theme

Transparent Background (future)

---

# Preview Generation

## FR-715

Preview images generated automatically.

Displays

Artwork

Hoop

Thread colors

Optional background

---

Future

Animated preview

Simulation preview

---

# Project Statistics

## FR-716

Displays

Stitch Count

Color Count

Thread Length

Design Size

Machine Profile

Last Export

Project Size

---

Statistics update automatically after save.

---

# Workspace Restoration

## FR-717

Project remembers

- Zoom
- Camera
- Panel Layout
- Selected Tool
- Open Inspector Sections
- Grid Visibility
- Guides
- Theme

---

Workspace restored automatically when reopening.

---

# Autosave Integration

## FR-718

Project browser indicates

- Saved
- Unsaved
- Recoverable
- Recovery Available

---

Autosave status visible without opening editor.

---

# Recovery Management

## FR-719

If recovery exists

Display

```
Recovery Available

Recovered

Discard Recovery
```

Recovery never overwrites original automatically.

---

# External Storage

## FR-720

Projects may reside on

- Local disk
- External SSD
- USB
- NAS
- iCloud Drive
- Google Drive
- Dropbox
- OneDrive

Application edits local files only.

Synchronization is handled by storage providers.

---

# File Monitoring

## FR-721

Detect

Project moved

Project deleted

Project changed externally

Project renamed

---

Future

Offer reload.

---

# Conflict Detection

## FR-722

Future

Detect

```
External Modification

↓

Reload

Keep Local

Duplicate
```

---

# Batch Operations

## FR-723

Supports

Batch Delete

Batch Archive

Batch Export

Batch Rename (future)

Batch Tagging

---

# Import Existing Project

## FR-724

Supports opening

`.swl`

Validates

Schema

Metadata

Assets

Database

---

Migration supported automatically.

---

# Project Dashboard

## FR-725

Default landing page displays

Recent Projects

Templates

Recovery Projects

Documentation

Tutorials

News (future)

---

# Sorting

## FR-726

Supports

Name

Modified

Created

Size

Machine

Stitch Count

Hoop Size

---

Ascending

Descending

---

# Filtering

## FR-727

Supports

Machine

Tags

Date

Archived

Template

Recovery

---

Future

Custom saved filters.

---

# Project Validation

## FR-728

Checks

Metadata

Assets

Database

Preview

Schema

Thread Library

Machine Profile

---

Validation states

Healthy

Information

Warning

Recoverable

Corrupt

---

# Project Migration

## FR-729

Older projects

↓

Migration

↓

Backup

↓

Upgrade

↓

Open

Migration always creates backup.

---

# Performance Targets

Project Browser

5,000 projects

↓

Open < 500 ms

---

Search

↓

< 100 ms

---

Recent Projects

↓

Immediate

---

Thumbnail generation

↓

Background task

---

# Accessibility

Supports

Keyboard

Touch

Stylus

Screen Reader

High Contrast

Reduced Motion

---

# AI Agent Rules

Project Management package owns

- Dashboard
- Project Browser
- Metadata
- Search
- Templates
- Recent Projects
- Recovery List

---

Project Management never owns

- Geometry
- Digitizer
- Simulation
- Export
- Canvas

---

Storage package owns

- File system
- Project persistence
- Metadata loading
- Validation

---

# Testing

Unit

Metadata

Search

Sorting

Filtering

Duplicate

Archive

Delete

Recovery

---

Integration

Create

Open

Rename

Move

Duplicate

Recovery

Migration

---

Performance

5,000 projects

50,000 metadata records

Large thumbnails

---

Regression

Older projects

↓

Migration

↓

Open

---

# Acceptance Criteria

Project Management is complete when

✓ Project Browser functions

✓ Metadata loads without opening projects

✓ Search and filtering work

✓ Templates supported

✓ Recent projects maintained

✓ Recovery management works

✓ Duplicate and archive work safely

✓ External storage supported

✓ Performance targets achieved

✓ Tests pass

---

# Future Enhancements

- Smart Collections
- AI-powered project organization
- Semantic search
- Customer/project relationship management
- Embedded production notes
- Project version snapshots
- Time tracking
- Team workspaces
- Cloud synchronization
- Automatic backup scheduling
- Batch project migration
- Custom dashboards
- Project analytics
- Plugin-powered project metadata
