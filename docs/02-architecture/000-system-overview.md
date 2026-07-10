# System Overview
## Sewlio Studio

> **MVP note (ADR-026):** the **MVP is implemented Dart-first**. This overview describes the
> **long-term Flutter + Rust architecture**, which remains valid and is preserved as **Phase 2**.
> The MVP provides Dart implementations behind the same interfaces; do not couple UI or product
> workflows to the implementation language. See `docs/07-adr/026-use-dart-engine-for-mvp.md`.

**Document ID:** ARCH-000  
**Title:** System Overview  
**Version:** 1.0.0  
**Status:** Draft  
**Owner:** Architecture Team

**Related Documents**

```text
docs/00-overview/vision.md
docs/00-overview/philosophy.md
docs/01-product/prd.md
docs/01-product/non-functional-requirements.md
docs/02-architecture/001-intermediate-representations.md
docs/02-architecture/003-command-system.md
docs/02-architecture/005-document-model.md
docs/02-architecture/006-project-format.md
docs/02-architecture/031-platform-domain-architecture.md
docs/02-architecture/032-universal-design-document.md
docs/02-architecture/033-production-engine-architecture.md
```

---

# 1. Purpose

This document provides the high-level technical architecture for Sewlio Studio.

It defines:

- System boundaries
- Technology stack
- Flutter and Rust responsibilities
- Core data flow
- Intermediate representation strategy
- Command-driven mutation model
- Event-driven update model
- Storage architecture
- Platform architecture
- Package ownership philosophy
- AI-agent development constraints

This document is the entry point for all architecture documentation.

---

# 2. Product Architecture Summary

Sewlio Studio is a cross-platform textile design and production platform.

The MVP is embroidery-first and built with:

```text
Flutter

for UI, interaction, canvas, gestures, and platform UX

+

Pure Dart domain packages

for geometry, document model, embroidery production, simulation, export, storage, validation, and domain logic
```

Rust remains the Phase 2 migration target for performance-critical production systems after MVP validation.

The application targets:

```text
Desktop:
  Windows
  macOS
  Linux

Tablet:
  iPadOS
  Android Tablets

Mobile:
  iPhone
  Android Phones

Web:
  Flutter Web CSR
```

The product is:

- Offline-first
- Local-first
- Command-driven
- Event-driven
- IR-based
- Plugin-ready
- AI-ready

---

# 3. Architectural Thesis

Sewlio Studio is not only an editor.

It is a **compiler-style platform for textile production domains**.

```text
External Input

↓

Import IR

↓

Geometry IR

↓

Stitch IR

↓

Playback IR

Machine IR

↓

Simulation

Export
```

The Universal Design Document stores editable design intent.

For embroidery, the editor manipulates geometry.

The digitizer compiles geometry into stitches.

The simulator compiles stitches into playback.

The exporter compiles stitches into machine instructions.

This compiler-style architecture is the core technical identity of the project. Weaving and digital printing follow the same design-to-production shape with their own domain IRs instead of reusing Stitch IR or Machine IR.

---

# 3A. Platform and Production Domains

Sewlio Studio separates shared platform systems from production-domain systems.

```text
Shared Platform
  Universal Design Document
  Geometry, layers, assets, colors, materials
  Commands, events, storage, services, plugins, UI shell, AI framework

Production Domains
  Embroidery: Stitch Plan, Stitch IR, Machine IR, embroidery exporters
  Weaving: Weave Plan, Loom IR, loom/controller exporters
  Digital Printing: Print Plan, Print IR, RIP/file exporters
```

The selected Project Type resolves the active production engine, tools, panels, validators, simulation, exporters, profiles, and AI knowledge module.

---

# 4. Top-Level System Diagram

```text
+------------------------------------------------------------------+
|                          Flutter UI                              |
|                                                                  |
|  Workspace  Canvas  Panels  Gestures  Shortcuts  Platform UX     |
+------------------------------------------------------------------+
                                |
                                v
+------------------------------------------------------------------+
|                     Application Bridge Layer                     |
|                                                                  |
|        FFI / WASM / Message Contracts / Command Dispatch          |
+------------------------------------------------------------------+
                                |
                                v
+------------------------------------------------------------------+
|                         Rust Core Engine                         |
|                                                                  |
|  Commands  Events  Document  Geometry  Digitizer  Simulation     |
|  Machine   Export   Import    Thread    Storage    Recovery      |
+------------------------------------------------------------------+
                                |
                                v
+------------------------------------------------------------------+
|                         Local Persistence                        |
|                                                                  |
|       .embproj package  libSQL/Turso DB  Assets  Recovery        |
+------------------------------------------------------------------+
```

---

# 5. Flutter Responsibility

Flutter owns presentation and interaction.

Flutter is responsible for:

- Application shell
- Workspace layout
- Canvas widget
- Toolbars
- Panels
- Menus
- Dialogs
- Gesture recognition
- Stylus input
- Keyboard shortcuts
- Theme rendering
- Platform-adaptive layouts
- Accessibility semantics
- Displaying simulation
- Displaying validation messages
- Calling Rust commands

Flutter must not own embroidery business logic.

---

# 6. Rust Responsibility

Rust owns domain logic.

Rust is responsible for:

- Document model
- Command system
- Event system
- Geometry engine
- Import pipeline
- Digitizer compiler
- Stitch IR
- Playback compiler
- Machine compiler
- Export encoders
- Thread libraries
- Machine profiles
- Storage
- Recovery
- Validation
- Security gateway
- Plugin runtime
- AI tool execution

Rust is the authoritative source of truth.

---

# 7. Boundary Rule

The most important architecture rule:

```text
Flutter never mutates project state directly.

Flutter sends Commands to Rust.

Rust validates and executes Commands.

Rust emits Events.

Flutter renders Events.
```

No exceptions.

---

# 8. Platform Boundary

Desktop and mobile use native bindings.

```text
Flutter

↓

Rust FFI

↓

Rust Core
```

Web uses WASM.

```text
Flutter Web

↓

Rust WASM

↓

Rust Core
```

The same Rust domain logic should be reused across all platforms.

---

# 9. State Mutation Model

All mutations flow through Commands.

```text
User Action

↓

Flutter Interaction

↓

Command

↓

Security Gateway

↓

Validation

↓

Command Handler

↓

Document Mutation

↓

Events

↓

UI Update

↓

Autosave
```

Examples:

```text
CreateRectangleCommand
MoveObjectCommand
AssignThreadCommand
GenerateFillCommand
ExportProjectCommand
DeleteLayerCommand
```

There should be no hidden mutation path.

---

# 10. Event Model

After command execution, Rust emits immutable events.

```text
Command Executed

↓

Event Stream

↓

Canvas

Inspector

Layers

History

Simulation

Statistics

Autosave

Recovery
```

Events are append-only.

Events provide the basis for:

- UI refresh
- Undo/Redo
- Autosave
- Collaboration
- Audit logging
- AI reasoning
- Plugin notifications

---

# 11. Data Flow Overview

## Import flow

```text
SVG / PNG / JPEG / PDF / DXF

↓

Importer

↓

Import IR

↓

Normalizer

↓

Geometry IR

↓

Document
```

---

## Editing flow

```text
User Gesture

↓

Command

↓

Geometry Kernel

↓

Geometry IR

↓

Events

↓

Canvas
```

---

## Digitizing flow

```text
Geometry IR

↓

Digitizer Compiler

↓

Stitch IR

↓

Validation

↓

Statistics
```

---

## Simulation flow

```text
Stitch IR

↓

Playback Compiler

↓

Playback IR

↓

Flutter Renderer
```

---

## Export flow

```text
Stitch IR

↓

Machine Compiler

↓

Machine IR

↓

Format Encoder

↓

DST / PES / JEF / VP3 / EXP
```

---

# 12. Intermediate Representations

The architecture uses explicit intermediate representations.

## Import IR

Normalizes imported formats before entering the document model.

## Geometry IR

Editable vector and layout representation.

## Stitch IR

Machine-independent embroidery representation.

## Playback IR

Simulation and animation representation.

## Machine IR

Machine-oriented instruction representation.

These IRs are stable architectural contracts.

---

# 13. Document Model

The document model represents the editable project.

It contains:

```text
Project

Workspace

Layers

Geometry Objects

Embroidery Objects

Thread References

Machine Profile

Assets

Metadata

History

Settings
```

The document model is separate from storage.

Storage persists the document.

The document model must remain deterministic.

---

# 14. Project Format

Projects are stored as `.embproj`.

Internally, `.embproj` is a self-contained project package.

```text
project.embproj/

manifest.json
metadata.json
project.turso
commands.turso
assets/
previews/
exports/
cache/
recovery/
backups/
```

Machine files are generated exports.

They are not the editable source of truth.

---

# 15. Storage Architecture

Storage is handled through a Storage Abstraction Layer.

```text
Rust Core

↓

Storage API

↓

Storage Abstraction Layer

↓

Filesystem / Browser Storage / Mobile Files
```

Storage supports:

- Atomic writes
- Incremental saves
- Autosave
- Backups
- Recovery
- Migration
- Checksums
- Project validation

The rest of the application should not directly use platform file APIs.

---

# 16. Rendering Architecture

Rendering has two levels:

## Rust

Produces renderable domain data.

## Flutter

Draws UI and canvas using Flutter rendering APIs.

```text
Geometry IR / Playback IR

↓

Renderable Model

↓

Flutter Canvas

↓

Screen
```

Flutter renders.

Rust computes.

---

# 17. Digitizer Architecture

Digitizing is compiler-style.

```text
Geometry IR

↓

Geometry Analysis

↓

Digitizer Passes

↓

Stitch IR

↓

Optimization

↓

Validation
```

Digitizers should be modular.

Examples:

- Running stitch compiler
- Fill stitch compiler
- Satin stitch compiler
- Underlay compiler
- Optimization passes

---

# 18. Simulation Architecture

Simulation is not rendering logic.

Simulation is a compiler from Stitch IR to Playback IR.

```text
Stitch IR

↓

Playback Compiler

↓

Playback IR

↓

Flutter Timeline / Canvas
```

Playback IR powers:

- Timeline
- Needle animation
- Stitch progress
- Statistics overlay
- Future video export

---

# 19. Export Architecture

Export is a compiler backend.

```text
Stitch IR

↓

Machine Compiler

↓

Machine IR

↓

Format Encoder

↓

Binary File
```

Supported target formats:

- DST
- PES
- JEF
- VP3
- EXP
- XXX
- HUS

Each exporter is isolated.

Exporters do not regenerate stitches.

---

# 20. Import Architecture

Importers are plugin-style modules.

```text
Raw File

↓

Format Parser

↓

Import IR

↓

Normalizer

↓

Geometry IR
```

Importers should not create document objects directly.

They produce Import IR.

---

# 21. Thread Architecture

Threads are domain entities, not RGB colors.

Thread model includes:

- Manufacturer
- Code
- Name
- RGB preview
- Lab color future
- Material
- Weight
- Metadata

Embroidery objects reference thread IDs.

---

# 22. Machine Architecture

Machine Profiles describe capabilities.

They do not encode files.

Machine model includes:

- Manufacturer
- Model
- Hoops
- Capabilities
- Constraints
- Preferred formats
- Thread mapping

Machine Profiles feed validation and Machine IR generation.

---

# 23. Recovery Architecture

Recovery is a platform service.

```text
Command Bus

↓

Recovery Coordinator

↓

Checkpoint Engine

Journal Engine

Snapshot Engine

Backup Manager

↓

Recovery Center
```

Recovery is independent from normal save.

Recovery must never overwrite the original project automatically.

---

# 24. Plugin Architecture

Plugins interact only through public APIs.

```text
Plugin

↓

Plugin Runtime

↓

Plugin API

↓

Commands

↓

Document

↓

Events
```

Plugins may contribute:

- Importers
- Exporters
- Stitch algorithms
- Thread libraries
- Machine profiles
- Validation rules
- UI panels
- AI tools

Plugins never access internal state directly.

---

# 25. AI Architecture

AI is treated as another client of the command system.

```text
AI Request

↓

Context Builder

↓

Model

↓

Tool Calls

↓

Command Generator

↓

Command Bus

↓

Document
```

AI never mutates internal state directly.

AI actions must be:

- Reviewable
- Undoable
- Auditable
- Permission-controlled

---

# 26. Security Architecture

All external actors pass through the Security Gateway.

```text
User / Plugin / AI

↓

Security Gateway

↓

Permission Engine

↓

Command Bus

↓

Rust Core
```

Security responsibilities:

- Permission checks
- Plugin sandboxing
- AI context filtering
- Secret storage
- File integrity
- Audit logging

---

# 27. Package Ownership Philosophy

Every package should own exactly one domain.

Example:

```text
geometry

Owns:
  Geometry IR
  geometry operations
  geometry validation

Does not own:
  digitizing
  rendering
  export
```

This ownership model prevents architectural drift and helps AI agents work safely.

---

# 28. Dependency Direction

Dependencies should point inward.

```text
UI

↓

Application Services

↓

Domain Services

↓

Core Models
```

Domain logic must not depend on Flutter.

Exporters must not depend on UI.

Simulation must not depend on export.

Digitizer must not depend on machine file encoders.

---

# 29. Concurrency Model

Long-running operations run off the UI thread.

Examples:

- SVG import
- Digitizing
- Simulation generation
- Export
- Validation
- Backup
- Migration
- Thumbnail generation

Rust worker threads handle computation.

Flutter receives progress events.

---

# 30. Error Handling

Errors should be domain-specific and recoverable.

```text
Domain Error

↓

Application Error

↓

User Message
```

User-facing errors must be:

- Clear
- Actionable
- Non-technical
- Recoverable where possible

---

# 31. Testing Strategy

The system must be testable headlessly.

```text
SVG

↓

Import IR

↓

Geometry IR

↓

Stitch IR

↓

Machine IR

↓

DST
```

without Flutter.

Testing levels:

- Unit tests
- Integration tests
- Golden tests
- Regression tests
- Compatibility tests
- Performance benchmarks
- Fault injection tests

---

# 32. AI Agent Development Rules

AI agents must respect architecture boundaries.

Agents must not:

- Put business logic in Flutter
- Mutate project state outside Commands
- Bypass validation
- Modify IR schemas without ADR
- Add dependencies without review
- Change package ownership casually

Claude Code acts as technical lead.

Local coding agents implement scoped tasks.

---

# 33. Architecture Decision Records

Major decisions require ADRs.

Examples:

```text
ADR-0001 Command Bus
ADR-0002 Intermediate Representations
ADR-0003 Project Package Format
ADR-0004 Flutter Rust Boundary
ADR-0005 Machine IR
ADR-0006 Plugin Runtime
ADR-0007 AI Runtime
```

No major architectural change should occur without an ADR.

---

# 34. Non-Negotiable Rules

1. Flutter does not own business logic.
2. Rust owns the source of truth.
3. Commands are the only mutation path.
4. Events are immutable.
5. Machine files are generated artifacts.
6. `.embproj` is the editable project format.
7. Digitizer outputs Stitch IR, not machine files.
8. Export consumes Machine IR, not Geometry IR.
9. Simulation consumes Playback IR.
10. Plugins and AI use public APIs only.
11. Recovery never overwrites originals automatically.
12. Every major architecture change requires an ADR.

---

# 35. Implementation Priority

Recommended implementation order:

```text
1. IR definitions
2. Document model
3. Command system
4. Event system
5. Project format
6. Storage abstraction
7. Geometry kernel
8. Flutter workspace shell
9. Import SVG
10. Running stitch
11. Stitch preview
12. DST export
```

---

# 36. Architecture Acceptance Criteria

This architecture is valid when:

- All data flows through defined IRs.
- All mutations occur through Commands.
- Flutter contains no embroidery business logic.
- Rust core can run headlessly.
- `.embproj` is portable.
- Import, digitizer, simulation, and export are independent.
- Plugins and AI cannot bypass validation.
- Recovery works independently from normal save.
- System can be tested without UI.
- AI agents can work on packages independently.

---

# 37. Future Direction

The architecture should support:

- Real-time collaboration
- Plugin marketplace
- AI-assisted digitizing
- Server-side conversion
- CLI tools
- Batch automation
- Machine transfer
- Cloud sync
- Enterprise policy controls

without rewriting the core engine.

---

# 38. Summary

Sewlio Studio is architected as a modular, local-first, cross-platform embroidery compiler and editor.

Flutter provides the human interface.

Rust provides the domain engine.

Commands provide safe mutation.

Events provide system updates.

IRs provide stable contracts.

`.embproj` provides portable ownership.

This architecture is intentionally designed to support long-term scalability, AI-assisted development, plugin extensibility, and professional embroidery workflows.
