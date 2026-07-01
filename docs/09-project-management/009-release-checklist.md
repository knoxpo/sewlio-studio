# Project Management

## PM-009 Release Checklist

**Document ID:** PM-009
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Technical Program Management

Run before tagging any `stable`/`beta` release. Complements Release DoD
(`08-impl/008-definition-of-done.md`) and the release plan (`08-impl/005`).

---

# Pre-flight

- [ ] Target milestone exit criteria met (`08-impl/010-milestones.md`).
- [ ] `main` is the release commit; all release-scope PRs merged.
- [ ] No open **P0/P1** issues; risk register reviewed, no unmitigated High/High.

# Quality gates (all green in CI)

- [ ] Rust: fmt + clippy(-D warnings) + `cargo test --workspace`.
- [ ] Flutter: analyze + test (all packages).
- [ ] frb glue in sync (`make gen` → no diff).
- [ ] Golden suite (geometry, stitch, machine, binary formats).
- [ ] Integration gate (SVG→DST) green.
- [ ] Performance budgets met (Import <200 ms, Machine <500 ms, others per plan).
- [ ] Cross-platform matrix green (macOS/Windows/Linux).
- [ ] Compatibility suite (real SVG + machine files) green.
- [ ] Dependency-direction check green.

# Compatibility & data safety

- [ ] `.embproj` opens files from the prior stable; migrations tested both ways where relevant.
- [ ] Recovery tested (crash-mid-save → clean recover, original never auto-overwritten).
- [ ] Exported files verified against a reference simulator/machine for the shipped formats.

# Packaging

- [ ] Version bumped (SemVer); IR/project schema versions confirmed.
- [ ] Signed + notarized desktop bundles built per platform.
- [ ] Changelog generated; migration notes included if a schema changed.
- [ ] Toolchain pins (`rust-toolchain.toml`, `.fvmrc`, frb version) recorded in the release notes.

# Publish

- [ ] Tag `vX.Y.Z`; GitHub release with artifacts + changelog.
- [ ] Announce channel promotion (`005-release-plan.md`).
- [ ] Post-release: dashboard updated, next wave groomed, retro logged.

---

A single unchecked box blocks the release. Emergency fixes follow the same list scoped to the
patch.
