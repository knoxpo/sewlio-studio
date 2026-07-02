# Sewlio Studio

Cross-platform embroidery design studio.

## MVP strategy (ADR-026)

> MVP implementation is **Flutter-only using Dart packages**.
>
> **Rust** remains part of the long-term architecture and will be introduced after MVP validation
> for performance-critical modules.
>
> The codebase must maintain **clean interfaces** so Dart implementations can later be replaced by
> Rust modules **without changing UI or product workflows**.

Long-term (Phase 2) architecture: **Flutter** UI + **Rust** engine bridged by
[`flutter_rust_bridge`](https://cjycode.com/flutter_rust_bridge/) — preserved in `docs/` and the
`crates/es_*` scaffold, deferred per [ADR-026](docs/07-adr/026-use-dart-engine-for-mvp.md). Across
both phases: UI never mutates state directly — it sends **commands** to the engine and renders
**events**. Plan: [`docs/08-implementation/000-roadmap.md`](docs/08-implementation/000-roadmap.md).

> Status: **MVP planning.** Phase 1 = pure-Dart engine + Flutter shell (packages planned, see
> package map). The Task-1 Rust skeleton (`crates/es_*`, `ffi/es_ffi`, `packages/studio_bindings`)
> stays in-tree, compiling, as the Phase 2 migration target — not an MVP deliverable.

## MVP development (Flutter/Dart)

```bash
# Flutter SDK is pinned via FVM (.fvmrc). One-time:
fvm install

# per Dart/Flutter package (planned under packages/):
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm dart format .

# run the desktop app (once the app shell lands):
cd apps/studio && fvm flutter run -d macos
```

Phase 2 (Rust) toolchain — Cargo workspace, `flutter_rust_bridge_codegen`, `make check` — is
documented below and stays valid for when migration begins.

## Layout

```
crates/es_diagnostics   Rust · diagnostics primitives (leaf)
crates/es_core          Rust · engine foundation (kernel + runtime)   → es_diagnostics
crates/es_geometry      Rust · geometry domain, Geometry IR owner      → es_core
ffi/es_ffi              Rust · flutter_rust_bridge boundary (cdylib)   → es_core, es_geometry
packages/studio_bindings        Dart · generated bindings + initEngine()
packages/studio_design_system   Dart · design tokens / shared UI
apps/studio             Flutter · application shell
testdata/  tools/  docs/
```

Rust deps flow **downward only** (`docs/02-architecture/018-package-ownership.md`). This flat
`crates/` layout is the Task-1 starter; it migrates into the layered `engine/<layer>/` structure
later (`docs/05-engineering/103-runtime-targets.md`).

## Prerequisites

- Rust stable (`rustup`) — pinned by `rust-toolchain.toml`
- [FVM](https://fvm.app/) — Flutter version pinned by `.fvmrc` (`stable`). Run `fvm install` once.
- frb codegen: `cargo install flutter_rust_bridge_codegen --locked` (only needed to re-run `make gen`)

All Flutter/Dart commands go through `fvm` so everyone uses the pinned SDK.

## Common commands

```bash
make check          # full gate: fmt-check + lint + test (rust + flutter)
make test           # cargo test --workspace  +  fvm flutter test (all packages)
make lint           # cargo clippy -D warnings  +  fvm flutter analyze
make fmt            # cargo fmt + fvm dart format
make gen            # regenerate flutter_rust_bridge glue after editing ffi/es_ffi/src/api
./tools/check.sh    # same as `make check`, standalone
```

Rust only:

```bash
cargo build --workspace
cargo test  --workspace
cargo clippy --workspace --all-targets -- -D warnings
```

## Run the app (desktop)

The skeleton ships no platform runner dirs. Add one, then run:

```bash
cd apps/studio
fvm flutter create --platforms=macos .   # or windows / linux
fvm flutter run -d macos                  # shows the Rust engine version string
```

The version text on screen comes from `es_core::engine_version()` across the FFI boundary —
the end-to-end proof that Flutter ↔ Rust is wired.

## FFI workflow

Edit Rust API in `ffi/es_ffi/src/api/`, run `make gen` to regenerate Dart + Rust glue
(`frb_generated.*`, committed), then rebuild. Trivial getters are marked
`#[flutter_rust_bridge::frb(sync)]` so Dart sees plain values instead of futures.
