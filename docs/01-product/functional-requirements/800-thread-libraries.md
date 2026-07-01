# Functional Requirements
## FR-800 Thread Library Management

**Document ID:** FR-800  
**Title:** Thread Library Management System  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Thread & Color Systems Team

**Primary Packages**

```text
Flutter

thread_library/
thread_picker/
color_palette/
thread_manager/
project_threads/

↓

Rust

thread/
thread-library/
thread-mapping/
thread-parser/
thread-search/
color-engine/
```

---

# Purpose

The Thread Library Management System provides a standardized way to manage embroidery thread colors across projects.

Unlike RGB colors used in traditional vector editors, embroidery colors represent **physical thread products**.

Every stitch object references a thread entry instead of an RGB value.

---

# Objectives

The system shall:

- Manage thread manufacturers
- Manage thread catalogs
- Provide fast searching
- Maintain consistent color mapping
- Support project-specific thread palettes
- Support machine color mapping
- Allow custom thread libraries

---

# Design Principles

## Physical First

Thread colors represent actual embroidery threads.

Not simply RGB colors.

---

## Library Driven

Every color originates from a Thread Library.

---

## Deterministic

A thread ID always represents the same thread.

---

## Extensible

Users may install additional thread libraries.

---

## Portable

Projects embed thread references rather than copying complete libraries.

---

# Architecture

```text
Thread Library

↓

Thread Entry

↓

Project Thread Palette

↓

Embroidery Object

↓

Simulation

↓

Machine Mapping

↓

Export
```

---

# Thread Library

A Thread Library represents a manufacturer.

Examples

```
Madeira

Isacord

Brother

Janome

Sulky

Robison-Anton

Floriani

Gunold

DMC

Coats

Generic
```

---

Each library contains

```
Library ID

Manufacturer

Version

Country

License

Thread Entries

Metadata
```

---

# Thread Entry

Each thread entry contains

```
Thread ID

Manufacturer

Thread Code

Display Name

RGB Preview

Lab Color (future)

Thread Finish

Material

Weight

Metadata
```

Example

```
Madeira

1147

Deep Red

RGB

#A62026
```

RGB is only for visualization.

---

# Thread Reference Model

Embroidery Objects store

```
Thread ID

↓

Thread Library

↓

Thread Entry
```

Never duplicate thread definitions inside embroidery objects.

---

# Project Palette

Projects automatically build a palette.

```
Project

↓

Used Threads

↓

Project Palette
```

The palette only contains threads used by the project.

---

# FR-801

## Load Thread Libraries

Priority

Critical

---

The application loads thread libraries during startup.

Libraries may be

Built-in

User Installed

Project Local (future)

---

Acceptance Criteria

✓ Startup remains fast

✓ Libraries cached

✓ Errors isolated

---

# FR-802

## Browse Thread Libraries

Priority

Critical

---

Displays

Manufacturer

Thread Count

Version

Last Updated

Description

---

Supports

Expand

Collapse

Search

Sort

---

# FR-803

## Search Threads

Priority

Critical

---

Supports searching by

Thread Code

Name

Manufacturer

Color Family

Recently Used

Project Palette

---

Future

Nearest Color

AI Search

Natural Language

---

Acceptance Criteria

Search <50 ms.

---

# FR-804

## Assign Thread

Priority

Critical

---

Workflow

```
Select Embroidery Object

↓

Thread Picker

↓

Search

↓

Choose Thread

↓

Preview Updates
```

---

Acceptance Criteria

Assignment immediate.

Simulation updates.

Statistics update.

---

# FR-805

## Replace Thread

Priority

Critical

---

Replace

One Thread

↓

Entire Project

---

Example

```
Madeira 1147

↓

Isacord 1900
```

---

Acceptance Criteria

Replacement updates all embroidery objects.

Undo supported.

---

# FR-806

## Project Thread Palette

Priority

Critical

---

Displays

Only threads used.

Shows

Thread

Count

Estimated Length

Objects Using Thread

---

Supports

Rename Alias (future)

Replace

Remove unused

---

# FR-807

## Thread Preview

Priority

Critical

---

Display

Color

Code

Manufacturer

Name

Estimated Finish

---

Future

Thread texture

Gloss

Material preview

---

# FR-808

## Recent Threads

Priority

Critical

---

Maintain recently used list.

Supports

Desktop

Tablet

Web

---

Maximum

50 entries

Configurable.

---

# FR-809

## Favorite Threads

Priority

Alpha

---

Supports

Pin

Unpin

Groups

Favorites appear first.

---

# FR-810

## Thread Categories

Priority

Alpha

---

Categories

Red

Blue

Green

White

Black

Gold

Silver

Neon

Pastel

Metallic

Glow

Variegated

---

Categories searchable.

---

# FR-811

## Custom Thread Libraries

Priority

Alpha

---

Users may create

Custom Manufacturer

Custom Colors

Custom Codes

Custom Metadata

---

Supports

Export

Import

Share

---

# FR-812

## Thread Library Import

Priority

Alpha

---

Supports

CSV

JSON

Future

Manufacturer formats

---

Validation

Duplicate IDs

Duplicate Codes

Invalid Colors

---

# FR-813

## Thread Mapping

Priority

Critical

---

Maps

Project Thread

↓

Machine Thread

↓

Export Thread

---

Example

```
Madeira

↓

Brother

↓

Machine Index
```

---

Mappings configurable.

---

# FR-814

## Missing Threads

Priority

Critical

---

If project references missing thread

↓

Warning

↓

Fallback Thread

↓

User may remap

---

Project remains usable.

---

# FR-815

## Color Matching

Priority

Alpha

---

Supports

Nearest Thread

Nearest Manufacturer

Manual Match

---

Future

ΔE color matching.

---

# FR-816

## Thread Usage Statistics

Displays

Objects

Stitch Count

Estimated Length

Estimated Spool Usage

Color Changes

---

Updates automatically.

---

# FR-817

## Thread Validation

Checks

Duplicate IDs

Invalid RGB

Duplicate Codes

Missing Manufacturer

Broken References

---

Validation levels

Healthy

Warning

Recoverable

Error

---

# FR-818

## Project Thread Report

Generate

Printable report.

Contains

Thread

Manufacturer

Code

Length

Estimated Consumption

---

Future

Purchase List

Inventory Integration

---

# Thread Data Model

```
Manufacturer

↓

Thread Library

↓

Thread Entry

↓

Project Palette

↓

Embroidery Object
```

---

# Thread Picker

Displays

Search

Filters

Preview

Recently Used

Favorites

Project Palette

Manufacturer Tree

---

Supports

Keyboard

Touch

Stylus

---

# Machine Integration

Machine Profiles may

Limit

Maximum Colors

Thread Index

Needle Positions

---

Warnings shown before export.

---

# Simulation Integration

Simulation reads

Thread Entry

↓

Color

↓

Thread Name

↓

Metadata

---

Simulation never stores duplicate colors.

---

# Export Integration

Export converts

Thread Entry

↓

Machine Mapping

↓

Machine Commands

---

# Localization

Thread names remain

Manufacturer-defined.

UI translated.

---

# Performance Targets

Load libraries

<250 ms

---

Search

<50 ms

---

Assign thread

Immediate

---

Replace thread

10,000 objects

<200 ms

---

# Accessibility

Supports

Keyboard

Touch

Stylus

Screen Reader

High Contrast

Large Color Preview

---

Color never represented by color alone.

Always display

Manufacturer

Thread Code

Thread Name

---

# AI Agent Rules

Thread package owns

Libraries

Search

Mapping

Validation

Statistics

---

Thread package never owns

Canvas

Digitizer

Geometry

Simulation Rendering

---

Export package owns

Machine encoding.

---

Simulation package owns

Playback visualization.

---

# Testing

Unit

Search

Replacement

Mapping

Validation

Statistics

---

Golden

Known Library

↓

Known Search Results

---

Integration

Thread Assignment

↓

Simulation

↓

Export

↓

Verification

---

Performance

100 libraries

100,000 thread entries

10,000 project objects

---

Regression

Existing projects continue resolving thread references after library updates.

---

# Acceptance Criteria

Thread Library System is complete when

✓ Built-in libraries load

✓ Search functions correctly

✓ Thread assignment works

✓ Project palette generated automatically

✓ Replacement works project-wide

✓ Missing thread handling implemented

✓ Machine mapping supported

✓ Statistics generated

✓ Performance targets met

✓ Tests pass

---

# Future Enhancements

- Cloud thread libraries
- Manufacturer updates
- Inventory management
- Purchase planning
- AI thread recommendations
- Fabric-aware thread suggestions
- Thread texture rendering
- Metallic thread simulation
- Shared organization libraries
- Plugin thread providers
