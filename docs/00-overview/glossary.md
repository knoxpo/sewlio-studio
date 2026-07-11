# Glossary

---

## Project

An editable embroidery document.

Stored as:

.swl

---

## Machine File

A generated embroidery file.

Examples:

DST

PES

VP3

JEF

EXP

Machine files are NOT editable project files.

---

## Stitch

The smallest embroidery instruction.

Contains:

Position

Type

Color

Machine command

---

## Stitch Object

A logical embroidery object.

Example:

Fill Region

Running Stitch

Satin Column

---

## Vector Object

Editable drawing object.

Rectangle

Bezier

Circle

Path

Polygon

---

## Digitizing

The process of converting vector objects into stitch objects.

---

## Simulation

Visualization of machine execution.

Needle movement.

Thread path.

Color changes.

---

## Hoop

Embroidery work area.

Defined by:

Width

Height

Margins

Origin

---

## Thread Library

Collection of embroidery thread colors.

Example:

Madeira

Brother

DMC

---

## Machine Profile

Defines:

Supported formats

Hoop sizes

Thread limits

Stitch limits

---

## Project Engine

Rust subsystem responsible for loading and saving .swl projects.

---

## Geometry Engine

Rust subsystem responsible for vector mathematics.

---

## Digitizer

Rust subsystem converting geometry into embroidery stitches.

## Universal Design Document

The editable source of truth for a Sewlio Studio project. It stores shared design intent such as geometry, text, layers, assets, colors, materials, transforms, and metadata. Production plans and export output are derived from it.

## Project Type

The persistent production type selected for a project, such as Embroidery, Weaving, or Digital Printing. Project Type resolves the active production engine, tools, validators, simulation, exporters, profiles, and AI knowledge module.

## Production Domain

A textile manufacturing area with its own production semantics. Embroidery, weaving, and digital printing are production domains.

## Production Engine

A domain-owned engine that converts the Universal Design Document and production configuration into a derived production plan, diagnostics, simulation data, compiled IR, and export readiness.

## Production Plan

A derived domain-specific plan, such as a Stitch Plan, Weave Plan, or Print Plan. It is regenerated from editable design intent and production configuration.

---

## Renderer

Flutter subsystem displaying embroidery previews.

---

## Export Engine

Rust subsystem generating machine files.

---

## Command

Undoable action.

Example:

Move Object

Rotate Object

Delete Layer

---

## History

Chronological record of project changes.

Supports Undo and Redo.

---

## Workspace

Complete editing environment including panels, tools, and open projects.

---

## Canvas

Primary drawing surface where vectors, stitches, guides, and hoop boundaries are displayed.
