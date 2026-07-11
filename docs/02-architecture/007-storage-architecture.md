# Architecture
## ARCH-007 Storage Architecture

**Document ID:** ARCH-007  
**Title:** Storage Architecture  
**Version:** 1.0.0  
**Status:** Foundation (Critical)  
**Priority:** Critical

**Owner:** Platform Storage Team

**Related Documents**

```text
ARCH-005 Document Model
ARCH-006 Project Format
FR-1800 Local Storage
FR-1900 Recovery
```

---

# Purpose

The Storage Architecture defines how Sewlio Studio persists, retrieves, validates, migrates, and protects project data.

Storage is one of the platform services.

Its responsibilities are:

- Persistence
- Loading
- Saving
- Recovery
- Backups
- Validation
- Migration
- Synchronization (future)

Storage never owns business logic.

Storage never knows how embroidery works.

---

# Design Philosophy

Storage is an infrastructure concern.

The application should never know

- filesystem APIs
- cloud APIs
- platform APIs

Instead

```text
Application

↓

Storage Service

↓

Storage Abstraction Layer

↓

Storage Provider

↓

Filesystem
```

Everything above the Storage API remains platform independent.

---

# Core Principles

## Local First

Projects always exist locally.

Cloud synchronization is optional.

---

## Offline First

Every feature works without Internet access.

---

## Atomic

Writes are transactional.

Never partially overwrite user data.

---

## Deterministic

Loading followed by saving should not change project meaning.

---

## Portable

Projects remain ordinary folders/packages.

Users own their files.

---

## Recoverable

Every write is recoverable.

---

## Versioned

Everything persisted has a schema version.

---

# High-Level Architecture

```text
                 Application
                       │
                       ▼
               Project Service
                       │
                       ▼
               Storage Service
                       │
                       ▼
        Storage Abstraction Layer (SAL)
                       │
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
 Local Provider   Cloud Provider   Memory Provider
        │
        ▼
 Filesystem
```

---

# Why a Storage Abstraction Layer?

Without SAL

```text
Flutter

↓

Filesystem
```

Every package becomes platform-aware.

With SAL

```text
Project

↓

Storage API

↓

SAL

↓

Provider
```

Only providers know how data is stored.

---

# Storage Responsibilities

Storage owns

- Opening
- Saving
- Serialization
- Deserialization
- Validation
- Checksums
- Migration
- Asset persistence
- Recovery persistence
- Backup persistence

Storage does **not** own

- Geometry
- Stitches
- Commands
- Rendering
- Simulation
- Export
- UI

---

# Layered Architecture

```text
Application
        │
        ▼
Project Service
        │
        ▼
Storage Service
        │
        ▼
Serialization Layer
        │
        ▼
Storage Provider
        │
        ▼
Filesystem
```

---

# Storage Components

## Project Service

Coordinates project lifecycle.

Responsible for

- Open
- Close
- Save
- Recover
- Duplicate

---

## Storage Service

Coordinates persistence.

Responsible for

- Read
- Write
- Transactions
- Migration
- Validation

---

## Serializer

Converts

```text
Document

↓

Persistent Data
```

Never touches files directly.

---

## Deserializer

Converts

```text
Persistent Data

↓

Document
```

---

## Storage Provider

Responsible for

Platform APIs

Examples

Desktop Files

Mobile Files

Web Storage

Cloud

---

# Storage Providers

## Local Provider

Desktop

```text
Filesystem

↓

.swl
```

---

## Mobile Provider

Uses

Files API

Scoped Storage

Document Picker

---

## Web Provider

Future

Uses

```text
OPFS

IndexedDB
```

---

## Cloud Provider

Future

Supports

iCloud

Google Drive

Dropbox

OneDrive

S3

WebDAV

---

# Storage Pipeline

## Save

```text
Document

↓

Serializer

↓

Validation

↓

Transaction

↓

Storage Provider

↓

Filesystem
```

---

## Load

```text
Filesystem

↓

Provider

↓

Deserializer

↓

Validation

↓

Document
```

---

# Domain Serialization

Each domain serializes independently.

```text
Geometry

↓

Geometry Serializer

----------------

Embroidery

↓

Embroidery Serializer

----------------

Threads

↓

Thread Serializer

----------------

Machine

↓

Machine Serializer
```

This enables incremental saves.

---

# Incremental Saving

Only dirty domains are written.

Example

```text
Geometry Dirty

↓

Geometry Database

↓

Write
```

Thread database remains untouched.

---

# Dirty Tracking

Every domain tracks

```text
Dirty

Clean

Modified At

Version
```

The Storage Service decides what needs writing.

---

# Transactions

Every save executes inside a transaction.

```text
Begin

↓

Write

↓

Validate

↓

Checksum

↓

Commit
```

Failure

↓

Rollback

---

# Atomic Writes

Storage never overwrites live files.

Workflow

```text
Temporary Directory

↓

Validation

↓

Swap

↓

Cleanup
```

---

# Validation Pipeline

Before saving

```text
Document Validation

↓

Reference Validation

↓

Schema Validation

↓

Checksum

↓

Write
```

---

After loading

```text
Read

↓

Schema Validation

↓

Migration

↓

Reference Validation

↓

Integrity Validation

↓

Open
```

---

# Migration Pipeline

```text
Old Version

↓

Backup

↓

Migration

↓

Validation

↓

Open
```

Migration never modifies the original first.

---

# Backup Integration

Storage cooperates with Recovery.

```text
Save

↓

Checkpoint

↓

Backup

↓

Write
```

---

# Asset Storage

Assets stored independently.

```text
Document

↓

Asset Registry

↓

Asset Store
```

Assets referenced by UUID.

---

# Asset Pipeline

```text
Import Image

↓

Hash

↓

Asset Registry

↓

UUID

↓

Store
```

Duplicate assets detected automatically.

---

# Content Addressable Storage (Future)

Instead of

```text
image.png
```

Future

```text
SHA256

↓

Asset Store
```

Enables deduplication.

---

# Workspace Storage

Workspace persists separately.

```text
.embws

↓

Workspace Storage
```

Never inside the project.

---

# Cache Storage

Cache is disposable.

Contains

- Playback
- Rendering
- Simulation
- Validation
- Optimization

Storage may delete cache anytime.

---

# Recovery Storage

Recovery owns

- Journals
- Snapshots
- Checkpoints

Storage persists them.

Recovery controls them.

---

# Storage Metadata

Every object stores

```text
UUID

Version

Created

Modified

Checksum
```

---

# Concurrency

Read

Concurrent.

Write

Single Writer.

No two save operations may execute simultaneously.

---

# File Locking

Future

```text
Project Lock

↓

Exclusive Write

↓

Release
```

Supports

Multi-window

Collaboration

Cloud

---

# Resource Manager Integration

Storage never duplicates shared resources.

Instead

```text
Workspace

↓

Resource Manager

↓

Thread Libraries

Fonts

Machine Profiles

Fabric Libraries

↓

Projects
```

Projects store only references.

---

# Storage Index

Workspace maintains

```text
Recent Projects

Recent Workspaces

Pinned Projects

Search Index

Metadata Cache
```

Project loading is not required.

---

# Synchronization Architecture (Future)

```text
Local Project

↓

Change Detection

↓

Sync Engine

↓

Provider

↓

Remote
```

Storage does not know sync logic.

Sync consumes Storage.

---

# Security

Storage verifies

Manifest

Checksums

Versions

Schema

Signatures (future)

Storage never stores

Passwords

OAuth Tokens

API Keys

Secrets

These belong to Secure Storage.

---

# Secure Storage

Separate service.

Platform implementations

Windows

Credential Manager

macOS

Keychain

Linux

Secret Service

Android

Keystore

iOS

Keychain

---

# Performance Targets

Metadata Load

<20 ms

Project Open

<1 s

Small Projects

Incremental Save

<100 ms

Autosave

Background

Migration

Background

Thumbnail Read

<50 ms

Asset Lookup

O(1)

---

# Thread Safety

Storage API

Thread Safe

Serialization

Worker Threads

Disk Access

Worker Threads

Main Thread

Never blocked

---

# Testing

Every provider requires

- Open Tests
- Save Tests
- Migration Tests
- Corruption Tests
- Recovery Tests
- Backup Tests
- Performance Tests
- Stress Tests

Fault injection

- Disk Full
- Permission Denied
- Interrupted Save
- Corrupt Database
- Missing Asset
- Invalid Manifest

---

# AI Agent Rules

Storage package owns

- Serialization
- Deserialization
- Transactions
- Providers
- Validation
- Migration
- Checksums

Storage package never owns

- Geometry
- Commands
- Rendering
- Digitizing
- Simulation
- Export

---

# Architectural Constraints

1. Storage is infrastructure, not business logic.
2. Projects are always local-first.
3. Storage is accessed only through the Storage API.
4. Domain serializers are independent.
5. Incremental saves use dirty tracking.
6. Writes are atomic.
7. Reads are concurrent.
8. Writes use a single-writer policy.
9. Assets are UUID referenced.
10. Cache is disposable.
11. Recovery is independent.
12. Workspace storage is separate from project storage.
13. Secrets never enter project files.
14. Storage providers are interchangeable.
15. All persistence must be independently testable.

---

# Future Enhancements

- Live synchronization
- Differential synchronization
- Block-level storage
- Remote project providers
- Project streaming
- Background compaction
- Automatic asset deduplication
- Snapshot filesystem integration
- Version-control integration
- Enterprise storage policies

---

# Acceptance Criteria

The Storage Architecture is complete when

✓ Storage is fully abstracted behind the Storage API.

✓ The application is unaware of platform-specific storage.

✓ Projects remain local-first and portable.

✓ Incremental saves are implemented.

✓ Atomic writes prevent corruption.

✓ Recovery integrates cleanly.

✓ Workspace and Project storage are separated.

✓ Multiple storage providers can be added without modifying business logic.

✓ Secrets are stored securely outside project files.

✓ The storage subsystem remains deterministic, scalable, and independently testable.
