# Implementation

## IMPL-009 CI/CD Plan

**Document ID:** IMPL-009
**Version:** 1.0.0
**Status:** Foundation
**Owner:** DevEx / QA

Pipelines mirror the local gate already in the repo (`Makefile`, `tools/check.sh`). Same commands
run locally and in CI — no drift.

---

# Pipeline stages (on every PR / push to `main`)

| Stage | Command | Blocks merge |
|---|---|---|
| Rust format | `cargo fmt --all --check` | yes |
| Rust lint | `cargo clippy --workspace --all-targets -- -D warnings` | yes |
| Rust test | `cargo test --workspace` | yes |
| frb drift | `make gen` then `git diff --exit-code` (generated glue committed) | yes |
| Dep direction | dependency-direction check (no upward/cross-layer edge) | yes |
| Flutter analyze | `fvm flutter analyze` per package | yes |
| Flutter test | `fvm flutter test` per package | yes |
| Golden | pipeline-stage golden diffs (once stages exist) | yes |
| WASM build | `cargo build --target wasm32-unknown-unknown -p es_core` | yes (warn early) |

---

# Nightly / scheduled

- Performance benchmarks vs budgets (Import <200 ms, Machine <500 ms) — regression fails the job.
- Fault-injection + recovery suite.
- Cross-platform matrix: macOS · Windows · Linux (build + test the Rust core and the app).
- Compatibility suite against real-world SVG / machine-file fixtures.

---

# Release automation (tag `v*`)

1. Green full gate + nightly required.
2. Build signed desktop bundles per platform (`fvm flutter build` + Rust cdylib/staticlib).
3. Generate changelog from merged PRs / closed issues; attach migration notes if a schema changed.
4. Publish to the target channel (`005-release-plan.md`); create GitHub release with artifacts.

---

# Toolchain pinning (reproducible)

- Rust: `rust-toolchain.toml` (stable + rustfmt + clippy).
- Flutter: `.fvmrc` (FVM-pinned) — CI runs `fvm install` then all Flutter/Dart commands via `fvm`.
- frb: `flutter_rust_bridge` crate pinned = `flutter_rust_bridge_codegen` version.

---

# Environment

- CI provider: GitHub Actions (workflows added when a remote exists; see `tools/github/`).
- Caching: cargo registry/target + pub cache + FVM SDK cache keyed on the pin files.
- Secrets: signing certs / notarization creds in CI secrets, never in-repo (`docs/05-eng/704`).

Until a remote exists, `tools/check.sh` is the authoritative gate; the workflow YAML is a thin
wrapper over it.
