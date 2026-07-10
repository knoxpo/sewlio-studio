# Project Management

## PM-001 Epics

**Document ID:** PM-001
**Version:** 1.0.0
**Status:** Living
**Owner:** Technical Program Management

> **ADR-026:** these 16 epics are the **long-term (Rust) program**, preserved intact. The **MVP
> delivers Dart equivalents first** (see `003-sprints.md` MVP Sprints 1-10, `004-backlog.md`
> category 1); Rust implementation of these epics is **Phase 2 / Post-MVP**. No epic is deleted or
> descoped — only resequenced after MVP validation.

16 epics covering the whole program. Complexity: S/M/L/XL. Duration in 2-week sprints (planning
estimates; far-milestone epics carry wider bands — rolling wave). Priority P0 (blocking spine) → P3.
All 16 are decomposed to features (`002-features.md`) and task-loaded sprints (`003-sprints.md`,
Sprints 1–48); far tasks (M9–M10) stay planning estimates until their milestone enters the wave.
Dependencies reference `docs/08-implementation/002-dependency-map.md`.

| ID | Epic | Description | Depends on | Complexity | Duration | Priority | Milestone |
|---|---|---|---|---|---|---|---|
| E1 | Foundation (kernel+runtime) | Lifecycle, ids, time, diagnostics, command bus, event bus, service registry, scheduler, dependency graph. The only mutation path. | — | L | ~4 | P0 | M1 |
| E2 | IR Framework | Shared IR traits: versioned, serializable, immutable, deterministic + golden-fixture harness. | E1 | M | ~2 | P0 | M1 |
| E3 | Geometry Engine | Geometry IR: points, paths, curves, transforms, bounding boxes, algorithms. mm-internal, deterministic. | E2 | L | ~4 | P0 | M2 |
| E4 | Document Model & Project | Project/layers/objects; command-driven mutation; event emission; `.embproj` structure. | E3 | L | ~3 | P0 | M3 |
| E5 | Storage & Recovery | Persistence, serialization, migration, atomic saves, backups, recovery. | E4 | M | ~2 | P0 | M3 |
| E6 | Import Pipeline | Import IR; SVG → raster → embroidery parsers; normalization. | E3, E5 | L | ~4 | P1 | M4 |
| E7 | Embroidery Engine | Stitch IR; running/satin/fill/underlay; density, compensation, sequencing, trims, jumps, optimization. | E3 | XL | ~8 | P0 | M5 / M6-widen |
| E8 | Machine Compiler | Machine IR; needle assignment, thread mapping, machine/hoop validation. | E7 | L | ~4 | P0 | M6 |
| E9 | Export / Generators | One crate per format: DST first, then EXP/PES/JEF/VP3/HUS. Consume Machine IR only. | E8 | L | ~4 | P1 | M6+ |
| E10 | Simulation | Playback IR; timeline, frames, needle motion, playback stats. | E7 | M | ~4 | P2 | M7 |
| E11 | Rendering | Scene graph, render graph, GPU backend, viewport, LOD/culling. | E3, E10 | XL | ~6 | P2 | M7/M8 |
| E12 | Desktop UI | Flutter shell, canvas, tools, panels, inspector, import/export UI. | E4, E11, E15 | XL | ~8 | P1 | M8 |
| E13 | AI Runtime | Knowledge graph, rule engine, AI digitizer, quality inspector, assistant. Command-only, explainable, human-approved. | E7, E8 | XL | ~6 | P2 | M9 |
| E14 | Plugin System | Plugin runtime, sandbox, extension registry, lifecycle. | stable public APIs (post-E9) | L | ~4 | P3 | M10 |
| E15 | FFI Bridge | flutter_rust_bridge boundary: Command dispatch, Event stream, progress; WASM path. | E1 | M | ~3 | P1 | M1/M8 |
| E16 | Testing, CI/CD & Security | Golden/perf/compat/fault harness, pipelines, dependency-direction enforcement, permissions/audit. Cross-cutting. | E1 | L | continuous | P0 | all |
| E17 | Shared Textile Platform | Universal Design Document, Project Type architecture, production engine framework, dynamic UI contributions. | E1, E4 | L | ~4 | P0/P1 | MVP/1.5 |
| E18 | Weaving Engine | Weave Plan, Loom IR, weaving UI, loom/controller capabilities and exporters. | E17 | XL | research | P2 | Post-MVP |
| E19 | Digital Printing Engine | Print Plan, Print IR, color/RIP pipeline, printing UI, print exporters. | E17 | XL | research | P2 | Post-MVP |
| E20 | Cross-Domain Conversion | Explicit derivation workflows between Project Types with diagnostics. | E17 | L | research | P3 | Post-MVP |

---

# Notes

- **E7 is the largest epic** — running stitch (P0, M5) ships first; the rest (satin/fill/underlay/
  compensation/optimization) widen after the SVG→DST gate (M6), interleaved through the mid program.
- **Critical spine** (P0, must be sequential): E1 → E2 → E3 → E4 → E5 → E7 → E8. Everything else
  hangs off it.
- Durations sum to the ~53-sprint / 2-year budget with hardening slack; see `010-milestones.md`.

Features per epic: `002-features.md`. Sprint loading: `003-sprints.md`. E17-E20 extend the program for the expanded Sewlio Studio platform; E18-E20 do not move weaving or printing into the embroidery MVP.
