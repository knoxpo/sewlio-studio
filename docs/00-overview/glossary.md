# Glossary

---

## Project

An editable embroidery document.

Stored as:

.embproj

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

Rust subsystem responsible for loading and saving .embproj projects.

---

## Geometry Engine

Rust subsystem responsible for vector mathematics.

---

## Digitizer

Rust subsystem converting geometry into embroidery stitches.

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
