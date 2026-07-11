# Implementation

## IMPL-010 Milestones

**Document ID:** IMPL-010
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Technical Program Management

Ten milestones, foundation-first. Each has entry criteria, exit criteria (the gate), and a demo.
Approx durations assume one senior engineer + agents (see `007-estimation-guidelines.md`); they are
planning estimates, refined per rolling wave.

Platform update: Phase 1 remains Flutter/Dart and embroidery-first. Phase 1.5 generalizes project types and production engine contracts. Additional weaving and printing engines are post-MVP. Rust migration remains deferred until after MVP validation and measured need.

---

## M1 — Foundation  ·  ~4 sprints
- **Entry:** skeleton (Task 1) green.
- **Exit:** command bus + event bus dispatch round-trip in tests; service registry; IR base traits
  (versioned/serializable/immutable) + golden harness; CI full gate green; WASM core builds.
- **Demo:** headless program issues a Command, receives the resulting Event.

## M2 — Geometry  ·  ~4 sprints
- **Entry:** M1.
- **Exit:** Geometry IR (points/paths/curves/transforms/bbox) serializes deterministically; unit +
  serialization + migration + validation + golden + property tests; rounding/epsilon policy fixed.
- **Demo:** build a shape via geometry API, round-trip it, diff against golden.

## M3 — Document Model + Storage  ·  ~4 sprints
- **Entry:** M2.
- **Exit:** document (project/layers/objects) mutates only via Command→Event; `.swl` atomic
  save/load round-trips; recovery + crash-mid-write fault tests pass.
- **Demo:** create/edit/save/reopen a project headlessly.

## M4 — Import  ·  ~3 sprints
- **Entry:** M3.
- **Exit:** SVG → Import IR → normalize → Geometry IR; golden import + SVG compatibility set.
- **Demo:** import a real SVG into an editable document.

## M5 — Embroidery Core  ·  ~4 sprints
- **Entry:** M2 (can run on fixtures ahead of M4).
- **Exit:** Geometry IR → Stitch IR for running stitch; golden stitch + determinism test.
- **Demo:** digitize a path into running stitches.

## M6 — Machine + Export  ·  ~4 sprints
- **Entry:** M5.
- **Exit:** Stitch IR → Machine IR (needle/thread/jump/trim, hoop+limit validation); DST binary
  golden; **headless SVG→DST integration gate passes**; Machine-compile perf <500 ms.
- **Demo:** SVG in → DST out on the CLI; file opens on a machine/simulator. **← architecture proof.**

## M7 — Simulation  ·  ~4 sprints
- **Entry:** M5.
- **Exit:** Stitch IR → Playback IR; timeline-consistency tests; headless renderable model + stats.
- **Demo:** stitch-by-stitch playback timeline with statistics.

## M8 — Desktop Editor  ·  ~8 sprints
- **Entry:** M3 + M7 (needs document + renderable model) + FFI marshaling.
- **Exit:** Flutter shell drives Commands, renders Events; canvas draw/select/transform; inspector,
  layers, import/export UI; widget + bridge-contract tests.
- **Demo:** draw → digitize → preview → export, all in the app.

## M9 — AI  ·  ~6 sprints
- **Entry:** M6 (domain knowledge: Embroidery + Machine).
- **Exit:** knowledge graph + rule engine; AI digitizer + quality inspector; AI emits Commands only,
  every recommendation explainable, human-approved, audited.
- **Demo:** AI proposes a digitizing plan; user reviews and approves; result is undoable.

## M10 — Production Ready  ·  ~8 sprints
- **Entry:** M8 (+ M9 for AI features).
- **Exit:** plugin system + sandbox; full format set; perf/compat/security gates green;
  signed cross-platform builds; `1.0.0`.
- **Demo:** installable, signed Sewlio Studio on macOS/Windows/Linux; GA.

---

# Cross-milestone gate

The **SVG→DST headless integration test** (M6) is the single most important checkpoint — it proves
Commands, Events, the IR chain, and the generator boundary together. No milestone past M6 is
considered stable while that gate is red.

Total: ~53 sprints ≈ 2 years, matching the program budget. Later milestones (M8-M10) carry wider
estimate bands and are refined as they approach (rolling wave).
