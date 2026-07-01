# Functional Requirements
## FR-900 Machine Profile Management

**Document ID:** FR-900  
**Title:** Machine Profile Management System  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Machine Compatibility Team

**Primary Packages**

```text
Flutter

machine_profiles/
machine_selector/
hoop_selector/
machine_validation/
machine_settings/

↓

Rust

machine/
machine-profile/
machine-registry/
machine-validator/
machine-ir/
hoops/
constraints/
```

---

# Purpose

The Machine Profile Management System provides a standardized abstraction over embroidery machines.

Rather than configuring exports manually, users work with a machine profile that defines the capabilities and limitations of a specific embroidery machine.

Machine Profiles ensure that designs are validated early, reducing export failures and production issues.

---

# Objectives

The Machine Profile System shall:

- Represent supported embroidery machines
- Define machine capabilities
- Define hoop compatibility
- Validate designs against hardware limits
- Drive export behavior
- Support custom machine profiles
- Remain independent of embroidery formats

---

# Design Philosophy

A Machine Profile describes **what a machine can do**, not **how a file is encoded**.

```text
Project

↓

Machine Profile

↓

Validation

↓

Machine IR

↓

Export Format
```

A machine may support multiple export formats.

An export format may support multiple machines.

---

# Architecture

```text
Machine Registry

↓

Machine Profile

↓

Capabilities

↓

Constraints

↓

Validation

↓

Machine IR

↓

Exporter
```

---

# Core Principles

## Machine Agnostic Core

The editor and digitizer are independent of machine limitations.

Machine-specific validation occurs later.

---

## Extensible

Adding a new machine should not require changes to the digitizer or export engine.

---

## Profile-Based

Projects reference a Machine Profile ID rather than embedding machine settings.

---

## Deterministic

The same project with the same Machine Profile always produces the same validation results.

---

# Machine Registry

The application includes a Machine Registry.

Each profile contains:

```text
Machine ID

Manufacturer

Model

Display Name

Supported Formats

Supported Hoops

Capabilities

Constraints

Metadata
```

---

# Supported Manufacturers

Examples

- Brother
- Janome
- Bernina
- Tajima
- Barudan
- Melco
- Pfaff
- Husqvarna Viking
- HappyJapan
- Ricoma
- SWF
- ZSK
- Generic

Additional manufacturers may be installed later.

---

# Machine Profile

A Machine Profile contains

```text
Machine ID

Manufacturer

Model

Firmware Version (optional)

Preferred Export Format

Hoop Collection

Needle Count

Maximum Colors

Maximum Stitch Count

Maximum Jump Length

Maximum Design Area

Thread Mapping

Capabilities

Constraints
```

---

# FR-901

## Load Machine Profiles

Priority

Critical

---

The application loads built-in Machine Profiles during startup.

Profiles should be cached for fast access.

---

Acceptance Criteria

✓ Startup remains responsive

✓ Invalid profiles do not prevent application startup

✓ Profiles are versioned

---

# FR-902

## Select Machine Profile

Priority

Critical

---

Workflow

```text
Project

↓

Machine Selector

↓

Choose Profile

↓

Project Updated

↓

Validation Runs
```

---

Changing Machine Profile does **not** modify geometry or Stitch IR.

Only validation, previews, and export defaults are updated.

---

# FR-903

## Hoop Management

Priority

Critical

---

Each Machine Profile contains one or more supported hoops.

Example

```text
100 × 100 mm

130 × 180 mm

150 × 240 mm

200 × 300 mm
```

---

Supports

- Select Hoop
- Change Hoop
- Custom Hoop (future)

---

Acceptance Criteria

✓ Hoop boundary updates immediately

✓ Validation updates automatically

---

# FR-904

## Machine Constraints

Priority

Critical

---

Supported constraints

- Maximum stitch count
- Maximum jump length
- Maximum design width
- Maximum design height
- Maximum colors
- Maximum thread changes
- Supported commands
- Supported trims
- Supported tie-in/tie-off

---

Machine constraints are independent of export formats.

---

# FR-905

## Machine Validation

Priority

Critical

---

Validation checks

Design Size

↓

Hoop Size

↓

Stitch Count

↓

Jump Distance

↓

Thread Count

↓

Machine Commands

↓

Warnings

---

Validation Levels

Healthy

Information

Warning

Recoverable

Blocking Error

---

Acceptance Criteria

Validation never modifies project data.

---

# FR-906

## Preferred Export Format

Priority

Critical

---

Each Machine Profile specifies

Preferred Format

Fallback Formats

Unsupported Formats

---

Example

```text
Brother

Preferred

PES

Supports

DST

EXP
```

---

The Export dialog should preselect the preferred format.

---

# FR-907

## Thread Mapping

Priority

Critical

---

Maps

Project Thread

↓

Machine Thread

↓

Needle Position (where applicable)

---

Supports

Automatic mapping

Manual override

Future

Saved mappings

---

# FR-908

## Needle Configuration

Priority

Alpha

---

Supports

Needle Count

Needle Assignment

Needle Colors

Reserved Needles

Disabled Needles

---

Future

Multi-head machines.

---

# FR-909

## Machine Capabilities

Priority

Critical

---

Capabilities include

Supports Trims

Supports Tie-in

Supports Tie-off

Supports Color Stops

Supports Automatic Thread Cut

Supports Appliqué Commands (future)

Supports Sequins (future)

Supports Cording (future)

Supports Chenille (future)

---

Capabilities drive UI and validation.

---

# FR-910

## Machine Metadata

Priority

Medium

---

Display

Manufacturer

Model

Supported Formats

Maximum Hoop

Maximum Colors

Needle Count

Firmware Notes

Documentation Link (future)

---

# FR-911

## Custom Machine Profiles

Priority

Alpha

---

Users may create custom profiles.

Supports

Custom hoops

Custom limits

Preferred export

Metadata

---

Custom profiles remain local by default.

---

# FR-912

## Import Machine Profiles

Priority

Future

---

Supports

JSON

YAML

Vendor package (future)

---

Validation

Duplicate IDs

Missing capabilities

Invalid hoop definitions

---

# FR-913

## Project Machine Report

Priority

Alpha

---

Displays

Selected Machine

Hoop

Warnings

Stitch Count

Color Count

Thread Usage

Export Compatibility

---

Printable in future.

---

# FR-914

## Machine Compatibility Check

Priority

Critical

---

Checks

Hoop fit

Design size

Jump distance

Thread count

Needle count

Machine commands

Format compatibility

---

Displayed before export.

---

# FR-915

## Unsupported Features

Priority

Critical

---

If a project uses a feature unsupported by the selected machine

↓

Show warning

↓

Recommend solution

↓

Allow correction

---

Example

```text
Selected machine does not support automatic trims.

Suggested actions:

• Convert trims to jumps
• Select another machine
```

---

# Machine Profile Data Model

```text
Machine Registry

↓

Machine Profile

↓

Hoop Collection

↓

Capabilities

↓

Constraints

↓

Thread Mapping
```

---

# Hoop Library

Hoops are reusable objects.

Each hoop stores

```text
Hoop ID

Display Name

Width

Height

Shape

Safe Margin

Metadata
```

---

Future

Oval hoops

Cap hoops

Magnetic hoops

Specialty hoops

---

# Machine Registry Updates

Future

Manufacturer updates

Community profiles

Plugin providers

---

Profiles should be versioned.

---

# Machine Warnings

Examples

Design exceeds hoop

↓

Warning

---

Jump exceeds limit

↓

Warning

---

Color count exceeds machine limit

↓

Blocking

---

Unsupported stitch command

↓

Blocking

---

# Performance Targets

Load registry

<100 ms

---

Machine selection

Immediate

---

Validation

<100 ms

---

Hoop switching

Immediate

---

# Accessibility

Supports

Keyboard

Touch

Stylus

Screen Reader

High Contrast

---

Machine information should not rely solely on icons.

Always display

Manufacturer

Model

Hoop

Preferred format

---

# AI Agent Rules

Machine package owns

Profiles

Registry

Capabilities

Constraints

Validation

Hoops

---

Machine package never owns

Digitizer

Geometry

Simulation

Canvas

Flutter widgets

---

Export package consumes Machine Profiles.

Thread package consumes Thread Mapping.

---

# Testing

Unit

Registry loading

Constraint validation

Hoop selection

Thread mapping

Machine capabilities

---

Golden

Known project

↓

Known validation report

---

Integration

Project

↓

Machine Profile

↓

Validation

↓

Export

---

Performance

1,000 machine profiles

10,000 validation operations

---

Regression

Existing projects continue resolving Machine Profiles after registry updates.

---

# Acceptance Criteria

Machine Profile System is complete when

✓ Built-in Machine Profiles load correctly

✓ Hoop selection functions

✓ Machine constraints validate designs

✓ Preferred export formats are applied

✓ Thread mapping integrates correctly

✓ Validation produces actionable messages

✓ Custom profiles supported (Alpha)

✓ Performance targets met

✓ Tests pass

---

# Future Enhancements

- Cloud-synchronized machine profiles
- Manufacturer-certified profile packages
- Firmware-specific capabilities
- Multi-head machine support
- Production presets
- Fleet management
- Machine health metadata
- USB/Wi-Fi machine discovery
- Direct machine transfer
- Vendor plugin ecosystem
- AI-based machine compatibility recommendations
