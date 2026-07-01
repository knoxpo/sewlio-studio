# Functional Requirements
## FR-1000 Preferences & Application Settings

**Document ID:** FR-1000  
**Title:** Preferences & Application Settings  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Platform Experience Team

**Primary Packages**

```text
Flutter

settings/
preferences/
appearance/
shortcuts/
workspace/
dialogs/

↓

Rust

preferences/
settings/
configuration/
serialization/
migration/
validation/
```

---

# Purpose

The Preferences System provides centralized management of all user-configurable application settings.

Unlike project settings, which are stored inside `.embproj` files, preferences belong to the user and apply across projects.

Preferences should synchronize seamlessly across devices through external storage providers (future) while remaining fully functional offline.

---

# Design Goals

The Preferences System shall

- Persist user preferences
- Be platform independent
- Be extensible
- Support migration
- Support versioning
- Never corrupt user settings
- Be recoverable

---

# Core Principles

## User-owned

Preferences belong to the user.

They are not tied to projects.

---

## Local First

Preferences are stored locally.

Cloud synchronization remains optional.

---

## Versioned

Every settings schema has a version.

---

## Safe

Corrupted preferences should automatically recover.

---

## Non-destructive

Unknown future settings should be preserved whenever possible.

---

# Architecture

```text
Application

↓

Settings Service

↓

Preference Registry

↓

Preference Store

↓

Persistence
```

---

# Storage

Preferences stored separately from projects.

Example

```text
preferences.json
```

or

```text
preferences.db
```

The storage backend should be abstracted.

---

# Preference Categories

## General

## Appearance

## Workspace

## Canvas

## Editor

## Digitizer

## Simulation

## Export

## Thread Libraries

## Machine Profiles

## Keyboard

## Touch & Stylus

## Accessibility

## Performance

## Developer

---

# Preference Model

Every preference contains

```text
ID

Category

Display Name

Description

Type

Default Value

Current Value

Validation

Version
```

---

# FR-1001

## General Preferences

Priority

Critical

---

Supports

Language

Units

Auto Save

Recent Projects

Telemetry

Crash Reports

Updates

---

Default Units

Millimeters

Future

Inches

---

# FR-1002

## Appearance

Priority

Critical

---

Themes

Light

Dark

System

High Contrast Light

High Contrast Dark

---

Accent Color

Future

Customizable.

---

UI Scaling

100%

125%

150%

175%

200%

250%

300%

---

# FR-1003

## Workspace Preferences

Priority

Critical

---

Stores

Panel Layout

Dock Positions

Inspector Width

Timeline Height

Hidden Panels

Recent Tools

Floating Panels

---

Workspace restored automatically.

---

# FR-1004

## Canvas Preferences

Priority

Critical

---

Supports

Grid

Guides

Snap

Rulers

Zoom Behavior

Pan Behavior

Background Color

Selection Colors

---

Future

Infinite canvas colors.

---

# FR-1005

## Vector Editor Preferences

Priority

Critical

---

Supports

Bezier Handles

Node Size

Selection Handles

Snapping

Simplification

Drawing Smoothing

---

Future

Pressure curves.

---

# FR-1006

## Digitizer Preferences

Priority

Critical

---

Default Values

Running Stitch Length

Fill Density

Fill Angle

Underlay

Tie In

Tie Off

Jump Handling

---

These become defaults for new embroidery objects.

---

# FR-1007

## Simulation Preferences

Priority

Critical

---

Supports

Playback Speed

Needle Visibility

Thread Visibility

Grid

Statistics

Camera Behavior

Loop Playback

---

Future

Fabric rendering.

---

# FR-1008

## Export Preferences

Priority

Critical

---

Stores

Last Export Folder

Preferred Format

Preferred Machine

Overwrite Behavior

Verification

Batch Export Defaults

---

# FR-1009

## Thread Preferences

Priority

Critical

---

Stores

Preferred Manufacturer

Recent Threads

Favorite Threads

Thread Preview Size

Search Behavior

---

# FR-1010

## Machine Preferences

Priority

Critical

---

Stores

Preferred Machine

Preferred Hoop

Recent Machines

Validation Strictness

---

# FR-1011

## Keyboard Shortcuts

Priority

Critical

---

Supports

View

Search

Customize

Reset

Conflict Detection

---

Future

Profiles

Import

Export

---

# FR-1012

## Touch & Stylus

Priority

Critical

---

Supports

Palm Rejection

Double Tap

Pressure Sensitivity

Gesture Navigation

Hover

Touch Targets

---

Future

Custom gestures.

---

# FR-1013

## Accessibility

Priority

Critical

---

Supports

High Contrast

Reduced Motion

Large Fonts

Large Icons

Screen Reader Hints

Animation Speed

---

# FR-1014

## Performance

Priority

Medium

---

Supports

Preview Quality

Simulation Quality

GPU Usage

Frame Rate Limit

Cache Size

Memory Budget

Background Threads

---

# FR-1015

## Developer

Priority

Medium

---

Supports

Debug Logging

Performance Overlay

FPS Counter

Layout Inspector

Command Log

Experimental Features

---

Hidden by default.

---

# Preference Validation

Each preference validates

Type

Allowed Range

Dependencies

Migration

---

Invalid values automatically replaced with defaults.

---

# Migration

When schema changes

```text
Old Preferences

↓

Migration

↓

Validation

↓

Updated Preferences
```

---

Migration never deletes user settings unnecessarily.

---

# Import Preferences

Future

Supports

JSON

YAML

Preference Package

---

# Export Preferences

Future

Supports

Backup

Transfer

Workspace Sharing

---

# Reset Preferences

Supports

Reset All

Reset Category

Reset Single Preference

---

Confirmation required.

---

# Search

Supports

Instant Search

Categories

Keywords

Descriptions

---

Future

Natural language search.

---

# Performance Targets

Load Preferences

<50 ms

---

Apply Theme

Immediate

---

Save Preferences

Background

---

Preference Search

<20 ms

---

# Accessibility

Preferences window fully supports

Keyboard

Touch

Stylus

Screen Reader

High Contrast

---

All settings include

Title

Description

Default value

Validation feedback

---

# AI Agent Rules

Preferences package owns

Preference registry

Storage

Migration

Validation

Search

---

Preferences package never owns

Canvas

Digitizer

Simulation

Export

---

Each subsystem owns its own defaults.

Preferences only store configuration.

---

# Testing

Unit

Validation

Migration

Defaults

Search

Reset

Serialization

---

Integration

Load

Modify

Restart

Verify persistence

---

Regression

Older preference versions migrate successfully.

---

Performance

Large preference sets

Migration

Search

---

# Acceptance Criteria

Preferences System is complete when

✓ Preferences persist

✓ Categories organized

✓ Themes supported

✓ Workspace restored

✓ Keyboard shortcuts configurable

✓ Accessibility options implemented

✓ Migration works

✓ Validation works

✓ Performance targets achieved

✓ Tests pass

---

# Future Enhancements

- Preference profiles
- Workspace presets
- Cloud synchronization
- Team preference sharing
- AI-recommended settings
- Device-specific profiles
- Import/export bundles
- Plugin-contributed preferences
- Remote configuration
- Live synchronization across running instances
