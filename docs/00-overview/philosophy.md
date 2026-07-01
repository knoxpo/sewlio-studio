# Engineering Philosophy

Version 1.0

---

# Core Philosophy

The project follows six primary philosophies.

---

## 1. Offline First

The application must never require internet connectivity.

Internet is optional.

Local functionality is mandatory.

Users should never lose access to their work because of authentication or network outages.

---

## 2. Local First

Users own their data.

Projects live on their devices.

Synchronization is optional.

Cloud storage providers are optional.

No vendor lock-in.

---

## 3. Cross Platform

Every supported platform should receive the same feature set whenever technically feasible.

Supported platforms:

Windows

macOS

Linux

Web

iPadOS

Android Tablets

---

## 4. Embroidery First

Every engineering decision should answer one question:

Does this improve embroidery workflows?

If not,

it probably does not belong.

---

## 5. Performance First

Performance is considered a feature.

Avoid unnecessary allocations.

Avoid unnecessary copies.

Avoid unnecessary abstractions.

Benchmark critical algorithms.

---

## 6. AI First Development

The project is intentionally designed for AI-assisted engineering.

Documentation is code.

Architecture is documentation.

Every subsystem must be understandable without human tribal knowledge.

---

# Engineering Goals

Readable code.

Deterministic behavior.

Strong typing.

High test coverage.

Clear ownership.

Stable APIs.

Minimal dependencies.

Maximum portability.

---

# Product Goals

Fast startup.

Fast rendering.

Fast export.

Large project support.

Tablet-first interaction.

Professional desktop workflow.

---

# Things We Explicitly Avoid

Mandatory accounts

Cloud lock-in

Electron

Large runtime dependencies

Framework-specific business logic

Business logic inside Flutter widgets

Platform-specific embroidery logic

---

# Guiding Principle

The Flutter application is replaceable.

The Rust engine is the product.
