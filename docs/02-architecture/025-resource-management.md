# Architecture
## ARCH-025 Resource Management

**Document ID:** ARCH-025  
**Title:** Resource Management Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Platform Resource Team

**Related Documents**

```text
ARCH-005 Document Model
ARCH-007 Storage Architecture
ARCH-008 Rendering Architecture
ARCH-013 Plugin Architecture
ARCH-014 AI Runtime
ARCH-016 Performance Architecture
ARCH-018 Package Ownership
ARCH-021 Architecture Principles
ARCH-024 Service Registry
```

---

# Purpose

The Resource Management Architecture defines how reusable assets are identified, loaded, cached, referenced, versioned, shared, and released throughout the platform.

Resources are shared platform assets.

Projects reference resources.

They do not own them.

The Resource Manager is responsible for ensuring efficient memory usage, eliminating duplication, and providing deterministic access to every shared asset.

---

# Vision

Every reusable asset inside Sewlio Studio is a managed resource.

Examples include:

- Thread Libraries
- Machine Profiles
- Hoop Profiles
- Fabric Profiles
- Images
- Fonts
- SVG Symbols
- Templates
- Color Palettes
- Materials
- Icons
- Localization Files
- AI Models
- Plugin Assets
- GPU Textures
- Shader Programs

---

# Philosophy

Resources are loaded once.

Referenced many times.

Released automatically.

Applications never manually manage resource lifetimes.

---

# Goals

The Resource Manager shall provide

- Centralized resource registry
- Resource handles
- Reference counting
- Lazy loading
- Streaming
- Memory budgeting
- Shared caching
- Versioning
- Resource validation
- Plugin resources
- AI resource management
- GPU resource ownership
- Resource diagnostics

---

# High-Level Architecture

```text
                    Runtime
                       │
                       ▼
               Resource Manager
                       │
      ┌────────────────┼────────────────┐
      ▼                ▼                ▼
 Resource Registry  Cache Manager  Loader Manager
      ▼                ▼                ▼
 Storage        GPU Resources     Plugin Resources
```

---

# Core Components

The Resource Management subsystem consists of

```text
Resource Manager

Resource Registry

Resource Handles

Resource Loader

Resource Cache

Memory Manager

Streaming Manager

Dependency Manager

Version Manager

Validation Manager
```

---

# Resource Categories

## Design Resources

```text
Images

SVG

Templates

Symbols

Patterns
```

---

## Embroidery Resources

```text
Thread Libraries

Needles

Machine Profiles

Hoops

Fabric Profiles

Stitch Presets
```

---

## Rendering Resources

```text
Textures

Shaders

Meshes

GPU Buffers

Icons
```

---

## Workspace Resources

```text
Themes

Localization

Preferences

UI Assets
```

---

## AI Resources

```text
Embeddings

Local Models

Prompt Templates

Knowledge Packs
```

---

## Plugin Resources

```text
Plugin Icons

Plugin Assets

Plugin Templates

Plugin Data
```

---

# Resource Identity

Every resource has a globally unique identifier.

```text
resource://thread/madeira-classic

resource://machine/tajima-tmez

resource://font/inter

resource://shader/thread-preview

resource://fabric/cotton-heavy
```

Resource IDs remain stable.

---

# Resource Handles

Applications never hold direct resource ownership.

Instead

```text
Project

↓

Resource Handle

↓

Resource Manager

↓

Actual Resource
```

Handles are lightweight.

Resources remain centralized.

---

# Resource Lifecycle

Every resource follows

```text
Discovered

↓

Registered

↓

Loading

↓

Loaded

↓

Referenced

↓

Idle

↓

Unloaded

↓

Disposed
```

Only the Resource Manager changes lifecycle state.

---

# Resource Registry

The Resource Registry maintains

```text
Resource ID

Type

Version

Location

Dependencies

State

Reference Count

Metadata

Owner
```

The registry is the source of truth.

---

# Resource Loading

Loading occurs through Resource Loaders.

```text
Handle

↓

Loader

↓

Validation

↓

Decode

↓

Resource

↓

Registry
```

Loaders are specialized by resource type.

---

# Loader Types

Examples

```text
Image Loader

SVG Loader

Font Loader

Thread Loader

Machine Loader

Shader Loader

Plugin Loader

Localization Loader
```

Plugins may register new loaders.

---

# Lazy Loading

Resources load only when first requested.

Example

```text
Project

↓

Thread Library Handle

↓

Access

↓

Load

↓

Cache

↓

Return
```

Unused resources remain unloaded.

---

# Streaming

Large resources support streaming.

Examples

```text
High-resolution Images

AI Models

Large Templates

Future Fabric Databases
```

Streaming is transparent to consumers.

---

# Reference Counting

Every resource tracks active references.

```text
Reference

↓

+1

↓

Resource Active

----------------

Release

↓

-1

↓

Unload Candidate
```

Resources unload automatically when no longer referenced.

---

# Resource Cache

The cache stores recently used resources.

Categories

```text
Memory Cache

GPU Cache

Thumbnail Cache

Metadata Cache

Decoded Cache
```

Caches are disposable.

---

# Memory Budget

Each cache has configurable limits.

Example

```text
Images

512 MB

GPU

2 GB

Thumbnails

128 MB

AI Models

User Configurable
```

When limits are exceeded

```text
Least Recently Used

↓

Unload
```

---

# Resource Dependencies

Resources may depend on other resources.

Example

```text
Machine Profile

↓

Thread Library

↓

Color Palette
```

Dependencies form a DAG.

Circular dependencies are prohibited.

---

# Versioning

Every resource includes

```text
Version

Schema Version

Compatibility

Checksum

Created By

Modified Date
```

Migration is handled automatically when supported.

---

# Validation

Every resource is validated before registration.

Validation includes

- schema
- checksum
- compatibility
- permissions
- plugin ownership
- security

Invalid resources are rejected.

---

# Resource Ownership

Ownership determines who may modify a resource.

Examples

```text
System

Workspace

Project

Plugin

User
```

Shared resources are immutable while in use.

---

# Workspace Resources

Workspace-scoped resources include

```text
Themes

Layouts

Recent Files

Window State

Temporary AI Data
```

Workspace resources are not embedded in projects.

---

# Project Resources

Projects reference

```text
Images

Fonts

Templates

Thread Libraries

Machine Profiles
```

Projects do not duplicate shared resources unless explicitly embedded.

---

# Embedded Resources

Projects may optionally embed resources.

Examples

```text
Image

Font

Custom Thread Library

Custom Fabric
```

Embedded resources become project-owned.

---

# GPU Resources

GPU assets are managed separately.

Examples

```text
Textures

Buffers

Vertex Arrays

Shaders
```

GPU resources are recreated automatically after device loss.

---

# AI Resources

AI models are resources.

Examples

```text
LLM

Embeddings

Prompt Templates

Indexes
```

Models may be

```text
Local

Cloud Metadata

Plugin Provided
```

---

# Plugin Resources

Plugins may contribute

```text
Icons

Templates

Thread Libraries

Machine Profiles

Shaders

Localization
```

Plugin resources are sandboxed.

---

# Resource Events

Examples

```text
ResourceRegistered

ResourceLoaded

ResourceUpdated

ResourceReleased

ResourceUnloaded

ResourceInvalidated

ResourceRemoved
```

Events never mutate resources.

---

# Resource Invalidation

When a resource changes

```text
Invalidate

↓

Dependent Resources

↓

Cache

↓

Rendering

↓

Workspace
```

The Dependency Manager propagates invalidation.

---

# Resource Serialization

Persistent resources serialize through the Storage Service.

Transient resources never serialize.

Examples

Persistent

```text
Thread Libraries

Templates

Machine Profiles
```

Transient

```text
GPU Buffers

Decoded Images

Caches
```

---

# Resource Discovery

Resources are discovered from

```text
Application Assets

Workspace

Project

Plugins

User Libraries

Future Cloud Sources
```

Discovery occurs during Runtime initialization.

---

# Diagnostics

Resource diagnostics expose

```text
Resource Count

Memory Usage

Reference Counts

Cache Hits

Cache Misses

Load Time

Unload Time

Dependency Graph

Version

Owner
```

---

# Security

Resources are validated before loading.

Plugins cannot access resources outside their permissions.

AI cannot access resources without explicit authorization.

All resource paths are normalized to prevent traversal attacks.

---

# Performance Targets

```text
Resource Lookup

<1 µs

Lazy Load

Background

Cache Hit

<100 ns

Reference Update

<1 µs

Resource Validation

<10 ms
```

---

# Thread Safety

The registry is concurrent.

Reference counts are atomic.

Loaders execute on worker threads.

GPU resources are synchronized through the Rendering Service.

---

# Testing

The Resource Manager requires

- loader tests
- validation tests
- cache tests
- reference counting tests
- dependency graph tests
- streaming tests
- GPU recovery tests
- plugin resource tests
- version migration tests
- concurrency tests

---

# AI Agent Rules

AI agents must

- use Resource Handles instead of raw references
- never duplicate shared resources
- declare resource dependencies explicitly
- respect ownership rules
- avoid bypassing the Resource Manager
- support lazy loading where appropriate

---

# Architectural Constraints

1. Every reusable asset is a managed resource.
2. Resources are accessed through handles.
3. Resources are loaded lazily when possible.
4. Reference counting manages resource lifetime.
5. Shared resources are centralized.
6. Embedded resources are explicitly owned by projects.
7. Resource dependencies form a DAG.
8. Validation occurs before registration.
9. GPU resources are managed separately.
10. The Resource Manager remains the sole authority over resource lifecycle.

---

# Future Enhancements

- Distributed resource repositories
- Remote asset streaming
- Resource compression
- Hot-reloadable assets
- Content-addressable storage
- Incremental resource synchronization
- Resource marketplace
- Asset dependency visualization
- AI-generated resource indexing
- Enterprise asset management

---

# Acceptance Criteria

The Resource Management Architecture is complete when

✓ Every reusable asset is represented as a managed resource.

✓ Resources are referenced through lightweight handles.

✓ Lazy loading and reference counting are implemented.

✓ Shared resources eliminate duplication across projects.

✓ Resource dependencies are validated and cycle-free.

✓ GPU, AI, plugin, workspace, and project resources are managed consistently.

✓ Resource caching and memory budgets are enforced.

✓ Resource lifecycle is deterministic and observable.

✓ Security and validation are applied before resource use.

✓ The Resource Manager remains the single authority for resource ownership and lifecycle.
