# Functional Requirements
## FR-600 Export System

**Document ID:** FR-600  
**Title:** Machine Export System  
**Version:** 1.0.0  
**Status:** Draft  
**Priority:** Critical (MVP)

**Owner:** Machine Formats Team

**Primary Packages**

```text
Rust

export/
formats/
machine/
stitch-ir/
optimizer/
validation/
thread/

↓

Flutter

export_ui/
machine_profile_ui/
validation_ui/
progress_ui/
```

---

# Purpose

The Export System converts Sewlio Studio's internal embroidery representation into machine-readable embroidery files.

Unlike traditional embroidery software, the export system **must never regenerate stitches**.

Its responsibility is to transform the normalized Stitch IR into machine-specific instructions while preserving design intent.

---

# Design Philosophy

The export pipeline should behave like a compiler backend.

```text
Vector Objects
      │
      ▼
Digitizer
      │
      ▼
Stitch IR
      │
      ▼
Machine Optimizer
      │
      ▼
Machine Encoder
      │
      ▼
DST / PES / JEF / VP3 / ...
```

The export system **consumes** Stitch IR.

It never owns embroidery generation.

---

# Core Principles

## Deterministic

Identical Stitch IR always produces identical machine files.

---

## Stateless

Exporters never modify projects.

---

## Read-only

Projects remain editable after export.

---

## Format Isolation

Every embroidery format lives in an independent package.

---

## Streaming

Large exports should stream to disk.

Avoid building huge temporary buffers.

---

## Extensible

Adding a new export format should require no changes to existing exporters.

---

# Architecture

```text
Project

↓

Embroidery Objects

↓

Stitch IR

↓

Export Validation

↓

Machine Optimization

↓

Format Encoder

↓

Binary Writer

↓

Output File
```

---

# Export Pipeline

```text
Project

↓

Validation

↓

Machine Constraints

↓

Optimization

↓

Encoding

↓

Checksum

↓

Write File

↓

Verification
```

---

# Supported Formats

## MVP

DST

---

## Public Alpha

PES

JEF

VP3

EXP

---

## Professional

XXX

HUS

PCS

SEW

VIP

PEC

SHV

TAP

U??

(Research required)

---

# Format Architecture

Every format implements the same interface.

```rust
pub trait ExportFormat {

    fn id(&self) -> FormatId;

    fn display_name(&self) -> &'static str;

    fn capabilities(&self) -> FormatCapabilities;

    fn validate(
        &self,
        graph: &StitchIR
    ) -> ValidationReport;

    fn encode(
        &self,
        graph: &StitchIR
    ) -> ExportResult;
}
```

---

# Machine Profile

Export always occurs using a Machine Profile.

Machine Profile contains

```text
Machine Name

Supported Formats

Hoop Sizes

Maximum Stitches

Maximum Jump Length

Thread Limit

Color Limit

Needle Count

Metadata
```

---

# Export Workflow

```text
User

↓

Export

↓

Choose Format

↓

Choose Machine

↓

Validation

↓

Warnings

↓

Export

↓

Verification

↓

Success
```

---

# Export Dialog

Displays

Destination

Format

Machine

Statistics

Warnings

Estimated Size

Export Time

---

Future

Recent Presets

Batch Export

Favorites

---

# FR-601

## DST Export

Priority

Critical

---

Description

Export design as Tajima DST.

---

Consumes

Stitch IR

---

Produces

Binary DST

---

Validation

Maximum jump

Coordinate limits

Stitch count

---

Acceptance Criteria

✓ Opens in DST viewers

✓ Machine compatible

✓ Deterministic

---

# FR-602

## PES Export

Priority

Alpha

---

Supports

Brother embroidery.

---

Acceptance Criteria

Compatible with modern Brother software.

---

# FR-603

## JEF Export

Priority

Alpha

---

Supports

Janome embroidery.

---

# FR-604

## VP3 Export

Priority

Alpha

---

Supports

Pfaff

Husqvarna Viking

---

# FR-605

## EXP Export

Priority

Alpha

---

Supports

Melco/Bernina compatible workflows.

---

# Export Validation

Validation stages

```text
Stitch IR

↓

Geometry

↓

Machine Rules

↓

Format Rules

↓

Warnings

↓

Errors
```

---

# Validation Levels

Healthy

↓

Information

↓

Warning

↓

Recoverable

↓

Blocking Error

---

Examples

Too many stitches

↓

Warning

---

Unsupported command

↓

Blocking

---

Design exceeds hoop

↓

Warning or Blocking (user configurable in future)

---

# Machine Optimization

Export-specific optimization only.

Examples

Split long jumps

Convert unsupported commands

Compress color table

Coordinate encoding

---

Never

Change embroidery appearance.

---

# Coordinate Encoding

Internal

Millimeters

↓

Machine Units

↓

Binary Encoding

---

Precision loss should be minimized.

---

# Thread Mapping

Sewlio Studio Thread

↓

Machine Thread

↓

Output

---

Unknown thread

↓

Warning

↓

Fallback color

---

Future

Custom thread maps.

---

# Color Changes

Supports

Thread sequence

Machine stops

Color commands

---

Exporter responsible for encoding.

---

# Jump Stitches

Exporter should

Encode

Validate

Split if required

Warn when exceeding limits.

---

# Trim Commands

Supports

Machine trim

Software trim

Future

Machine-specific behavior.

---

# Tie In / Tie Off

Supports

Explicit commands

Machine substitutions

---

Machine profile determines behavior.

---

# Metadata

Machine files may contain

Design name

Author

Stitch count

Color count

Comments

Creation date

Where supported by format.

---

# File Naming

Default

```
ProjectName.dst
```

Supports

Overwrite warning

Automatic increment

Example

```
Logo.dst

↓

Logo (1).dst
```

---

# Export Destination

Supports

Local Folder

iCloud Drive

Google Drive

Dropbox

OneDrive

USB Drives

Network Shares

---

Application uses operating system file dialogs.

---

# Export Progress

Display

Progress bar

Current stage

Estimated time

Cancel

---

Stages

Validation

Encoding

Writing

Verification

Complete

---

# Export Verification

Optional

Read generated file

↓

Parse

↓

Compare

↓

Verification report

---

Future

Machine emulator validation.

---

# Batch Export

Future

```text
Project

↓

DST

PES

JEF

VP3

↓

Output Folder
```

---

# Export Presets

Future

Store

Preferred format

Machine

Naming pattern

Destination

Validation level

---

# Export History

Future

Store

Time

Format

Machine

Destination

Duration

Warnings

---

# Error Handling

Destination unavailable

↓

Readable message

↓

Retry

---

Disk full

↓

Abort

↓

Project unchanged

---

Unsupported feature

↓

Warning

↓

Continue if safe

---

Write interrupted

↓

Delete partial file

↓

Rollback

---

# Performance Targets

100k stitches

↓

DST

<2 seconds

---

PES

<3 seconds

---

Large project

1 million stitches

↓

Stream output

---

Memory

Avoid duplicate stitch buffers.

---

# Security

Export never

Uploads files

Contacts cloud services

Executes external code

---

File system permissions handled by operating system.

---

# Accessibility

Export dialog

Keyboard

Touch

Stylus

Screen reader

High contrast

---

Progress updates announced appropriately.

---

# AI Agent Rules

Export package owns

Format encoding

Validation

Machine optimization

Binary writing

Verification

---

Export package never owns

Digitization

Geometry

Simulation

Canvas

Flutter widgets

---

Machine package owns

Capabilities

Constraints

Limits

Thread mappings

---

Stitch IR package owns

Canonical embroidery instructions.

---

# Testing

Unit

DST encoder

PES encoder

Validation

Coordinate conversion

Thread mapping

---

Golden

Known Stitch IR

↓

Known binary output

---

Compatibility

Generated files tested in

Reference viewers

Reference machines

Vendor software (where legally available)

---

Regression

Same Stitch IR

↓

Identical binary output

---

Performance

100k stitches

500k stitches

1 million stitches

---

# Acceptance Criteria

Export System is complete when

✓ DST export implemented

✓ Validation works

✓ Machine constraints enforced

✓ Progress reporting available

✓ Binary output deterministic

✓ Files verified

✓ Performance targets achieved

✓ Tests pass

✓ Project remains unchanged after export

---

# Future Enhancements

- Batch export
- Cloud export
- Machine transfer (USB/Wi-Fi/Bluetooth)
- Export profiles
- Production worksheets
- Print-ready stitch reports
- Thread consumption reports
- Machine simulation validation
- Vendor-specific optimizers
- Plugin export formats
- Command-line export engine
- Headless server export API
