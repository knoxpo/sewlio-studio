# Architecture
## ARCH-014 AI Runtime

**Document ID:** ARCH-014  
**Title:** AI Runtime  
**Version:** 1.0.0  
**Status:** Foundation / Future-Ready  
**Priority:** High

**Owner:** AI Platform Team

**Related Documents**

```text
ARCH-001 Intermediate Representations
ARCH-003 Command System
ARCH-004 Event System
ARCH-009 Digitizer Pipeline
ARCH-011 Machine Compiler
ARCH-012 Export Pipeline
FR-1500 Plugin System
FR-1700 Security & Privacy
```

---

# Purpose

The Plugin Architecture defines how Sewlio Studio can be extended safely without modifying the core application.

Plugins allow third parties, advanced users, organizations, and future AI-generated extensions to add new capabilities such as:

- Importers
- Export generators
- Stitch algorithms
- Compiler passes
- Machine profiles
- Thread libraries
- Validation rules
- Workspace panels
- Rendering overlays
- AI tools
- Automation commands

Plugins must extend the platform through stable public APIs only.

---

# Core Principle

Plugins are guests.

The core platform remains the authority.

```text
Plugin

↓

Plugin Runtime

↓

Public Plugin API

↓

Commands / Events / IRs

↓

Core Engine
```

Plugins never access internal state directly.

---

# Plugin Philosophy

Plugins should be:

- Secure
- Sandboxed
- Versioned
- Permissioned
- Deterministic
- Observable
- Disableable
- Independently testable

A broken plugin must never corrupt a project.

---

# High-Level Architecture

```text
Application
    │
    ▼
Plugin Manager
    │
    ▼
Plugin Runtime
    │
    ├── Plugin Registry
    ├── Permission Engine
    ├── Extension Registry
    ├── Event Bridge
    ├── Command Bridge
    ├── Resource Bridge
    └── Sandbox
            │
            ▼
          Plugin
```

---

# Plugin Lifecycle

```text
Discover

↓

Validate

↓

Load

↓

Initialize

↓

Register Extensions

↓

Run

↓

Disable / Unload
```

---

# Plugin Package Format

A plugin is distributed as:

```text
plugin.embplugin/
│
├── manifest.json
├── plugin.wasm / plugin.native
├── assets/
├── resources/
├── locales/
├── README.md
├── LICENSE
└── signature/
```

---

# Plugin Manifest

Every plugin must include a manifest.

Example:

```json
{
  "id": "studio.example.dst-plus",
  "name": "DST Plus Exporter",
  "version": "1.0.0",
  "apiVersion": "1.0.0",
  "author": "Example Studio",
  "description": "Adds advanced DST export diagnostics.",
  "entryPoint": "plugin.wasm",
  "permissions": [
    "read_project",
    "export",
    "register_export_generator"
  ],
  "extensionPoints": [
    "export.generator",
    "diagnostics.provider"
  ]
}
```

---

# Plugin Runtime Types

## Preferred Runtime

```text
WebAssembly
```

WebAssembly should be the preferred long-term plugin runtime because it is portable and sandboxable.

---

## Future Runtime Options

```text
Native Rust Plugins
JavaScript Plugins
Python Plugins
Cloud Plugins
```

Native plugins should be restricted because they are harder to sandbox.

---

# Plugin API

Plugins interact with the application through typed APIs.

They may access:

```text
Commands

Events

IR Readers

Diagnostics

Resources

Settings

Extension Points
```

They may not access:

```text
Raw Document Memory

Private Rust Structs

Internal Databases

Unvalidated File Paths

Other Plugin Storage

Secrets
```

---

# Extension Points

The platform exposes explicit extension points.

## Import

```text
import.parser
import.validator
import.normalizer
```

Plugins may add support for new file formats.

---

## Digitizer

```text
digitizer.compiler_pass
digitizer.optimization_pass
digitizer.validation_pass
digitizer.stitch_algorithm
```

Plugins may add new stitch generation strategies.

---

## Machine

```text
machine.profile_provider
machine.capability_provider
machine.validation_rule
machine.optimization_pass
```

Plugins may add machine profiles and manufacturing policies.

---

## Export

```text
export.generator
export.metadata_writer
export.verification_rule
```

Plugins may add new machine file formats.

---

## Thread

```text
thread.library_provider
thread.matcher
thread.mapper
```

Plugins may add thread catalogs and mapping logic.

---

## Rendering

```text
render.overlay
render.diagnostic_layer
render.preview_mode
```

Plugins may add visual overlays.

---

## Workspace UI

```text
workspace.panel
inspector.section
toolbar.action
command_palette.command
```

Plugins may contribute UI surfaces.

---

## AI

```text
ai.tool
ai.context_provider
ai.suggestion_provider
```

Plugins may add AI tools and context sources.

---

# Command Integration

Plugins may only mutate projects by issuing Commands.

```text
Plugin

↓

Command API

↓

Security Gateway

↓

Command Bus

↓

Document
```

Plugins never modify the Document directly.

---

# Event Integration

Plugins may subscribe to approved events.

```text
Event Bus

↓

Event Filter

↓

Plugin Event Bridge

↓

Plugin
```

Event payloads are filtered based on permissions.

---

# Permission Model

Plugins must request permissions.

Example permissions:

```text
read_project
modify_project
read_selection
register_importer
register_export_generator
register_digitizer_pass
register_ui_panel
access_files
access_network
access_ai
access_clipboard
```

Permissions are granted explicitly by the user.

---

# Security Model

Plugins run through the Security Gateway.

```text
Plugin Action

↓

Permission Check

↓

Policy Check

↓

Command / API Call

↓

Audit Log
```

Plugin failures are isolated.

A plugin cannot bring down the application.

---

# Plugin Sandboxing

Sandbox prevents:

- Direct memory access
- Direct database access
- Arbitrary file access
- Access to secrets
- Access to another plugin's storage
- Runtime patching
- Unapproved network calls

---

# Plugin Storage

Each plugin gets isolated storage.

```text
workspace/
└── plugins/
    └── plugin-id/
        ├── config/
        ├── cache/
        ├── data/
        └── logs/
```

Plugin storage is never mixed with project data unless explicitly requested.

---

# Plugin Settings

Plugins may register settings.

Settings must include:

```text
Setting ID
Display Name
Description
Type
Default Value
Validation Rules
Migration Version
```

Settings appear inside the Preferences system.

---

# Plugin Diagnostics

Plugins may emit diagnostics.

Diagnostics include:

```text
Severity

Source

Message

Suggestion

Affected Object

Code

Documentation Link
```

Plugin diagnostics are clearly marked as plugin-originated.

---

# Plugin Failure Handling

If a plugin fails:

```text
Failure

↓

Runtime catches error

↓

Plugin disabled if necessary

↓

User notified

↓

Audit log updated
```

Core application continues running.

---

# Plugin Versioning

Plugins declare:

```text
Plugin Version

Required API Version

Minimum Application Version

Compatible IR Versions
```

Breaking API changes require migration or compatibility layers.

---

# Plugin Registry

The Plugin Registry stores:

```text
Plugin ID

Installed Version

Enabled State

Permissions

Extension Points

Storage Path

Trust Level

Last Loaded

Last Error
```

---

# Plugin Trust Levels

Suggested trust levels:

```text
Built-in

Verified Publisher

User Installed

Unsigned

Development
```

Unsigned plugins require warnings.

---

# Plugin Marketplace

Future marketplace support may include:

- Search
- Install
- Update
- Remove
- Ratings
- Publisher verification
- Paid plugins
- Enterprise plugin catalogs

Marketplace is optional.

---

# Plugin Development Mode

Development mode supports:

- Local plugin loading
- Hot reload
- Debug logs
- API validation
- Manifest validation
- Plugin test harness

Development mode is disabled by default.

---

# Plugin Testing

Every plugin should support:

- Manifest validation
- Permission validation
- API compatibility tests
- Extension registration tests
- Failure isolation tests
- Performance tests
- Security tests

---

# Performance Targets

```text
Plugin discovery: <200 ms
Plugin load: <100 ms per plugin
Event dispatch to plugin: <5 ms
Command validation: <2 ms
Plugin failure isolation: immediate
```

Plugins that exceed performance budgets may be throttled or disabled.

---

# AI Agent Rules

AI agents implementing plugin features must obey:

1. Plugins never mutate documents directly.
2. Plugins register extension points only through public APIs.
3. Plugin APIs must be versioned.
4. Plugin permissions must be explicit.
5. Plugin failures must be isolated.
6. Plugin data must be sandboxed.
7. Plugins must not access private Rust structs.
8. Plugin extensions must be independently testable.

---

# Architectural Constraints

1. Plugins communicate only through public APIs.
2. Plugins use Commands for mutation.
3. Plugins consume filtered Events.
4. Plugins never bypass Security Gateway.
5. Plugins are sandboxed.
6. Plugin APIs are versioned.
7. Plugin extension points are explicit.
8. Plugin storage is isolated.
9. Plugin failures never corrupt projects.
10. Plugin runtime must be independently testable.

---

# Future Enhancements

- WebAssembly Component Model
- Signed plugin bundles
- Enterprise plugin policies
- Plugin marketplace
- AI-generated plugins
- Remote plugin execution
- Plugin dependency graph
- Plugin performance profiler
- Plugin permission simulator
- Organization plugin registry

---

# Acceptance Criteria

The Plugin Architecture is complete when:

✓ Plugins can be discovered, validated, loaded, and disabled.

✓ Plugins can register extension points.

✓ Plugins can issue Commands but cannot mutate state directly.

✓ Plugins can subscribe to filtered Events.

✓ Plugin permissions are enforced.

✓ Plugin storage is isolated.

✓ Plugin failures are contained.

✓ Plugin APIs are versioned.

✓ Import, export, digitizer, machine, thread, rendering, AI, and UI extension points are defined.

✓ The plugin system can evolve without destabilizing the core engine.
