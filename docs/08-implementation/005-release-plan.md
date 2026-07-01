# Implementation

## IMPL-005 Release Plan

**Document ID:** IMPL-005
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Technical Program Management

How Sewlio Studio ships across the 2-year program. Local-first desktop app (`docs/01-product`),
Flutter + Rust. Releases track milestones (`010-milestones.md`).

---

# Versioning

- **SemVer** for the app and every published crate/package; `0.x` until GA (M10 → `1.0.0`).
- **IRs are independently schema-versioned** (`docs/02-architecture/001`); breaking IR changes need
  an ADR + migration. Project format `.embproj` carries its own version.
- Git tags `vMAJOR.MINOR.PATCH`; release notes generated from merged PRs / closed issues.

---

# Release channels

| Channel | Audience | Cadence | Gate |
|---|---|---|---|
| `nightly` | engineer/CI | per green `main` | CI green |
| `alpha` | internal dogfood | per milestone M1-M6 | milestone exit criteria |
| `beta` | external testers | M7-M9 | beta checklist + no P0/P1 |
| `stable` | public | M10, then per hardened milestone | release checklist (`09-PM/009`) |

---

# What ships per milestone

| Milestone | Channel | Shippable artifact / demo |
|---|---|---|
| M1 Foundation | nightly/alpha | headless engine: bus dispatch demo, CI |
| M2 Geometry | alpha | Geometry IR + golden fixtures; CLI/lib demo |
| M3 Document + Storage | alpha | create/edit/save/load `.embproj` headlessly |
| M4 Import | alpha | import SVG → editable Geometry IR |
| M5 Embroidery Core | alpha | running-stitch digitize from geometry |
| M6 Machine + Export | **beta-candidate** | **SVG → DST** end-to-end (CLI); openable on a machine |
| M7 Simulation | beta | stitch playback timeline + stats |
| M8 Desktop Editor | beta | Flutter editor: draw, digitize, preview, export |
| M9 AI | beta | AI-assisted digitize + quality inspector (human-approved) |
| M10 Production Ready | **stable / GA** | signed desktop builds (macOS/Windows/Linux), full formats |

---

# Platform rollout

Desktop first (macOS → Windows → Linux), per `docs/05-engineering/103`. Tablet/mobile/web are
post-GA (`docs/02-architecture/020`); the Rust core is already cross-platform (WASM path reserved),
so rollout is a shell/packaging effort, not a core rewrite.

---

# Release train rules

- `main` is always releasable; feature work on branches, merged behind green CI + DoD.
- No release with an open P0/P1 or a failing golden/compat gate.
- Every stable release: signed binaries, changelog, migration notes if any schema changed,
  recovery-tested `.embproj` compatibility with the prior stable.
