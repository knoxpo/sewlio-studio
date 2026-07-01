# Implementation

## IMPL-004 Development Order

**Document ID:** IMPL-004
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Tech Lead

Topologically-sorted build order. **Deterministic core infrastructure before user-facing
features. Vertical slice (SVG→DST) before horizontal build-out.** Refines the impl order in
`docs/02-architecture/000` §35 and `000-implementation-roadmap.md`.

---

# Ordered stages (each depends only on earlier ones)

| # | Stage | Package(s) | Produces | Prereq |
|---|---|---|---|---|
| 1 | Foundation | es_diagnostics, es_core | command/event bus, registry, ids | — |
| 2 | IR framework | (shared traits in es_core) | versioned/serializable/immutable base + golden harness | 1 |
| 3 | Geometry | es_geometry | **Geometry IR** | 2 |
| 4 | Document model | es_document | project/layers/objects, command-driven mutation | 3 |
| 5 | Storage | es_storage | `.embproj`, atomic save, recovery | 4 |
| 6 | Import (SVG) | es_import | **Import IR** → Geometry IR | 3 (fixtures), 5 |
| 7 | Embroidery + running stitch | es_embroidery, es_digitizer | **Stitch IR** | 3 |
| 8 | Machine compiler | es_machine, es_thread, es_machine_compiler | **Machine IR** | 7 |
| 9 | DST generator + **SVG→DST gate** | es_gen_dst | DST bytes + headless integration test | 8, 6 |
| 10 | Export widening | es_gen_{exp,pes,jef,vp3,hus} | more formats | 9 |
| 11 | Embroidery widening | es_digitizer passes | satin/fill/underlay/compensation/optimization | 7 |
| 12 | Simulation | es_playback, es_render(model) | **Playback IR** + renderable model | 7 |
| 13 | Rendering (GPU) | es_render | scene/render graph, viewport | 3, 12 |
| 14 | FFI widening | es_ffi | Command/Event marshaling, progress, WASM | 1 |
| 15 | Desktop UI | apps/studio, studio_canvas/panels | shell, canvas, tools, inspector | 4, 13, 14 |
| 16 | AI | es_ai | knowledge graph, rules, digitizer, inspector | 7, 8 |
| 17 | Plugin | es_plugin, es_security | sandbox, extension registry | stable APIs (post-9) |
| 18 | Hardening | all | perf/compat/security, GA | all |

---

# Vertical slice first

Stages 1→9 deliberately drive one thin thread end-to-end (a hand-built Geometry IR fixture can feed
stages 7-9 before the SVG importer at stage 6 is hardened). Hitting the **headless SVG→DST
integration gate at stage 9** proves every architectural seam — commands, events, all five-minus-one
IRs, the generator boundary — before a single stage is widened. Everything after stage 9 widens a
proven pipeline against a green gate.

---

# Do-not-start-before rules (hard gates)

- No exporter before Machine IR (stage 8).
- No rendering before Geometry IR (stage 3).
- No UI before Foundation (1) + Document (4).
- No AI before domain knowledge (7 + 8).
- No plugin host before public APIs stabilize (post-9).

Sprints in `docs/09-project-management/003-sprints.md` follow this exact order; no sprint schedules a
task whose prerequisite stage is unfinished.
