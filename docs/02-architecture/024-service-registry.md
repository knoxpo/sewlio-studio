# Architecture
## ARCH-024 Service Registry

**Document ID:** ARCH-024  
**Title:** Service Registry  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Runtime Platform Team

---

# Purpose

The Service Registry provides the central runtime infrastructure for discovering, composing, initializing, monitoring, and accessing services throughout Sewlio Studio.

Unlike a traditional Service Locator, the Service Registry is **Runtime-owned** and **dependency-driven**.

It exists to:

- Build the runtime dependency graph
- Coordinate service lifecycle
- Resolve dependencies
- Manage service health
- Enable test substitution
- Support plugins
- Support future distributed execution

The registry itself contains **no business logic**.

---

# Design Goals

The Service Registry shall provide:

- Explicit dependency injection
- Deterministic initialization
- Type-safe service resolution
- Runtime lifecycle coordination
- Health monitoring
- Lazy initialization
- Scoped services
- Plugin service registration
- Service capabilities
- Testability

---

# Philosophy

Services should never discover each other.

The Runtime composes services.

```text
Runtime

↓

Dependency Graph

↓

Service Registry

↓

Resolved Services

↓

Running System
```

No service owns another service.

The Runtime owns composition.

---

# Architectural Principles

The Service Registry follows these principles.

### Runtime Owned

Only the Runtime creates and destroys services.

---

### Explicit Dependencies

Dependencies must be declared.

Never discovered dynamically.

---

### Type Safe

Services are resolved through strongly typed APIs.

---

### Immutable Topology

After Runtime startup:

- no dependency graph changes
- no service replacement
- no hidden registrations

Only service state changes.

---

### No Global State

Services are never accessed through global mutable singletons.

---

# High-Level Architecture

```text
                    Runtime
                       │
                       ▼
             Lifecycle Manager
                       │
                       ▼
              Service Registry
                       │
 ┌─────────────────────┼─────────────────────┐
 ▼                     ▼                     ▼
Configuration      Scheduler           Diagnostics
 ▼                     ▼                     ▼
Storage          Resources         Rendering
 ▼                     ▼                     ▼
Plugins            AI Runtime        Workspace
```

---

# Responsibilities

The Service Registry owns

- registration
- dependency graph
- service metadata
- dependency validation
- lifecycle coordination
- service discovery
- diagnostics
- health monitoring
- service lookup
- service replacement during tests

The registry never owns business state.

---

# Service Definition

Every Runtime service implements a common interface.

```rust
pub trait RuntimeService {

    fn metadata() -> ServiceMetadata;

    fn initialize(&mut self, ctx: &RuntimeContext);

    fn start(&mut self);

    fn suspend(&mut self);

    fn resume(&mut self);

    fn stop(&mut self);

    fn dispose(&mut self);
}
```

The Runtime invokes lifecycle methods.

Services never invoke each other.

---

# Service Metadata

Every service publishes metadata.

```text
Service ID

Display Name

Version

Category

Scope

Capabilities

Dependencies

Optional Dependencies

Health

Priority

Owner
```

Metadata is immutable after registration.

---

# Service Identity

Every service has a globally unique identifier.

Examples

```text
runtime.configuration

runtime.scheduler

runtime.storage

runtime.resources

runtime.rendering

runtime.ai

runtime.plugins

runtime.security
```

Service IDs remain stable across releases.

---

# Service Categories

## Kernel

```text
Configuration

Logging

Tracing

Diagnostics

Scheduler

Thread Pool

Clock
```

---

## Runtime

```text
Command Bus

Event Bus

Dependency Graph

Pipeline Runtime

Task Runtime
```

---

## Platform

```text
Storage

Recovery

Rendering

Resources

Security

Simulation
```

---

## Extension

```text
Plugin Runtime

AI Runtime

Automation

Marketplace

Cloud Sync
```

---

## Workspace

```text
Selection

Viewport

Preferences

Layout

History
```

---

# Dependency Graph

Services declare dependencies.

```text
Configuration

↓

Logging

↓

Diagnostics

↓

Storage

↓

Resources

↓

Plugins

↓

AI Runtime

↓

Workspace
```

Dependencies form a Directed Acyclic Graph.

Circular dependencies are prohibited.

---

# Dependency Resolution

During startup

```text
Collect Metadata

↓

Build Graph

↓

Validate Graph

↓

Topological Sort

↓

Initialize
```

The Runtime computes initialization order automatically.

---

# Dependency Types

## Required

Startup fails if unavailable.

---

## Optional

Feature degrades gracefully.

Example

```text
AI Runtime

↓

Telemetry (optional)
```

---

## Deferred

Resolved later.

Useful for

- plugins
- cloud providers
- future services

---

# Service Capabilities

A service advertises capabilities.

Example

```text
Storage

Capabilities

Read

Write

Transactions

Recovery

Migration
```

Consumers depend on capabilities whenever practical.

---

# Capability Registry

Alongside the Service Registry is a Capability Registry.

```text
Capability

↓

Provider

↓

Runtime Resolution
```

Example

```text
Persistence

↓

Storage Service
```

Multiple providers may expose the same capability.

Future example

```text
Persistence

↓

Local Storage

Cloud Storage

Enterprise Storage
```

The Runtime selects the active provider.

---

# Service Resolution

Services are resolved using type-safe APIs.

```rust
let storage = ctx.resolve::<StorageService>();
```

Capability-based lookup

```rust
let persistence =
ctx.resolve_capability::<Persistence>();
```

Runtime validates availability.

---

# Service Scopes

## Application Scope

One instance per process.

Examples

```text
Configuration

Logging

Scheduler
```

---

## Workspace Scope

One instance per workspace.

Examples

```text
Panels

Selection

AI Conversations
```

---

## Project Scope

One instance per project.

Examples

```text
Undo Stack

Simulation Session

Project Cache
```

---

## Task Scope

Short-lived.

Examples

```text
Export

Import

Digitizer Job

Thumbnail Job
```

Destroyed automatically.

---

# Lifecycle

Services always follow

```text
Registered

↓

Initialized

↓

Started

↓

Running

↓

Suspended

↓

Stopping

↓

Disposed
```

Runtime owns every transition.

---

# Lazy Services

Expensive services initialize on demand.

Examples

```text
AI Runtime

Marketplace

Cloud Sync

Telemetry
```

Lazy services still participate in lifecycle management.

---

# Health Monitoring

Every service exposes runtime health.

States

```text
Healthy

Busy

Idle

Degraded

Unavailable

Stopping
```

Health changes generate Runtime Events.

---

# Service Events

Examples

```text
ServiceRegistered

ServiceInitialized

ServiceStarted

ServiceStopped

ServiceFailed

HealthChanged

CapabilityRegistered
```

Events never modify services.

---

# Failure Handling

Initialization failure

```text
Initialize

↓

Structured Error

↓

Retry

↓

Fallback

↓

Disable

↓

Continue
```

Optional services may fail.

Core services may not.

---

# Service Replacement

Testing supports service replacement.

```text
Storage

↓

Mock Storage

↓

Tests
```

Production services are immutable after startup.

---

# Plugin Services

Plugins may contribute services.

Restrictions

- sandboxed
- permission checked
- scoped
- isolated
- no core replacement

Plugins may add capabilities.

Plugins may not replace Runtime services.

---

# Runtime Context

Services communicate through Runtime Context.

Provides

```text
Registry

Diagnostics

Configuration

Scheduler

Commands

Events

Capabilities

Resources
```

Runtime Context replaces global state.

---

# Diagnostics

Registry diagnostics expose

```text
Registered Services

Initialization Order

Dependency Graph

Health

Capabilities

Initialization Time

Memory Usage

Version

Owner
```

---

# Security

Only the Runtime may

- register services
- unregister services
- replace services
- modify dependency graph

Plugins cannot manipulate the registry.

---

# Thread Safety

The registry is immutable after startup.

Lookups are lock-free.

Service state synchronization is owned by the service.

---

# Performance Targets

```text
Registration

<50 ms

Dependency Resolution

<10 ms

Lookup

<1 µs

Capability Lookup

<2 µs

Health Query

<1 ms
```

---

# Testing

The Service Registry requires

- registration tests
- dependency validation tests
- cycle detection tests
- capability tests
- lifecycle tests
- service replacement tests
- plugin service tests
- health monitoring tests
- concurrency tests
- performance benchmarks

---

# AI Agent Rules

AI agents must

- declare dependencies explicitly
- avoid hidden service lookups
- avoid global state
- support mock services
- use capability interfaces when appropriate
- keep services independently testable

---

# Architectural Constraints

1. Runtime owns the Service Registry.
2. Dependencies must be explicitly declared.
3. The dependency graph must remain acyclic.
4. Service registration is immutable after startup.
5. Services communicate only through public APIs.
6. Capabilities are preferred over concrete implementations where appropriate.
7. Plugin services cannot replace Runtime services.
8. Services remain independently testable.
9. Runtime Context replaces global singletons.
10. Service composition remains deterministic.

---

# Future Enhancements

- Distributed Service Registry
- Cluster-aware services
- Remote capability providers
- Live dependency visualization
- Runtime service profiler
- Hot-reloadable optional services
- Service version negotiation
- Service contracts
- Enterprise policy integration
- Multi-process runtime

---

# Acceptance Criteria

The Service Registry is complete when

✓ Every Runtime service registers through the Runtime.

✓ Dependency resolution is automatic and deterministic.

✓ Circular dependencies are rejected.

✓ Services expose immutable metadata.

✓ Capabilities are discoverable independently of implementations.

✓ Service lifecycle is centrally managed.

✓ Plugin services remain isolated and sandboxed.

✓ Services can be substituted during testing.

✓ Registry diagnostics expose health, dependencies, and capabilities.

✓ The Service Registry remains deterministic, thread-safe, extensible, and independently testable.
