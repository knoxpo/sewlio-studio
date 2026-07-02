# ADR-026: Use a Dart Engine for the MVP

**Document ID:** ADR-026
**Title:** Use a Dart/Flutter Engine for the MVP (Rust deferred to Phase 2)
**Status:** Accepted
**Date:** 2026-07-02
**Owner:** Architecture Team

**Related:** ADR-001 (compiler-inspired architecture), ADR-002 (Machine IR), ADR-016 (deterministic
pipelines), ADR-022 (cross-platform engine core), `docs/08-implementation/000-roadmap.md`.

---

## Status

**Accepted.** Governs MVP execution only. The long-term architecture (Flutter + Rust via
`flutter_rust_bridge`) remains valid and is preserved; this ADR sequences *when* Rust is introduced,
it does not replace it.

---

## Context

- The long-term architecture supports Rust modules for performance-critical systems (geometry,
  digitizing, machine compilation, export, simulation) behind a stable FFI boundary.
- Starting with Rust + FFI immediately increases MVP complexity: a Cargo workspace, `flutter_rust_bridge`
  codegen, cross-language debugging, and platform build matrices all add friction before any product
  workflow is validated.
- The current priority is validating **workflows, UI, the document model, and embroidery concepts**
  quickly — product-risk questions, not performance questions.
- Nothing in the existing specs requires Rust *first*; the IR contracts and package boundaries are
  language-independent (`docs/02-architecture/001`, `018`).

---

## Decision

- Implement the **MVP engine in Dart/Flutter packages** — pure-Dart domain packages plus a Flutter
  app shell.
- **Preserve the Rust architecture for Phase 2**: all Rust docs, crates, ADRs, and tickets remain;
  they are relabeled Post-MVP, not removed.
- Keep interfaces clean so Dart implementations can later be **replaced by Rust modules** behind the
  same public API, without changing UI or product workflows.

---

## Consequences

- **Faster MVP velocity** — one language, one toolchain, hot reload.
- **Easier debugging and iteration** — no FFI boundary to cross while the design is still moving.
- **Lower initial tooling complexity** — no Cargo/frb/codegen in the MVP inner loop.
- **Some performance-critical systems may need later migration** to Rust (fill/satin generation,
  large-document geometry, export encoding, simulation/physics).
- **Public APIs must be designed carefully** to avoid a rewrite: the Dart interface a Rust module
  later implements is a contract from day one.

---

## Alternatives Considered

- **Rust-first implementation.** Best long-term performance and determinism story, but highest MVP
  complexity and slowest validation of product risk. Rejected for the MVP; adopted for Phase 2.
- **Hybrid Flutter + Rust from day one.** The documented long-term shape, but pays the full
  cross-language tax before the product is validated. Deferred to Phase 2.
- **Flutter-only forever.** Simplest, but forfeits the performance/determinism ceiling the domain
  needs (dense fills, large designs, byte-exact export). Rejected — Rust migration stays on the map.

---

## Implementation Notes

- Define **engine APIs as Dart interfaces** (abstract classes) in the domain packages; the Dart
  class is the first implementation, a future Rust module the second.
- Keep **domain logic separate from UI** — `studio_core`, `studio_geometry`, `studio_embroidery`,
  `studio_machine`, `studio_import`, `studio_export` have **no Flutter dependency**.
- **Avoid Flutter widget dependencies inside core logic packages** — core stays headless and
  unit-testable (the same discipline that keeps the Rust core headless).
- Keep the **migration path to Rust explicit**: preserve the IR contracts and package boundaries;
  a Rust crate for stage X ships behind the identical interface `studio_X` exposes.
- **Mark Rust implementation tasks as Phase 2 / Post-MVP** in the backlog, sprints, and issue
  tracker — deferred until MVP validation, not deleted.
