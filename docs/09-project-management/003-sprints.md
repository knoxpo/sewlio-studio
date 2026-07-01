# Project Management

## PM-003 Sprint Plan (Rolling Wave)

**Document ID:** PM-003
**Version:** 1.0.0
**Status:** Living
**Owner:** Technical Program Management

2-week sprints, one senior engineer + agents. **Near-term sprints (S1-S13, Milestones M1-M6) are
task-loaded**; later sprints are feature-level and refined as they approach. No sprint schedules a
task before its prerequisite (`docs/08-implementation/004-development-order.md`). Every sprint is
shippable + demoable.

Task ID scheme `E<epic>-F<feat>-T<n>`. Each task follows `006-task-template.md` (4-12h).

---

# Wave 1 — detailed (M1-M6)

## Sprint 1 — Engine foundation I  ·  Goal: command/event bus dispatch
- Features: E1-F1, E1-F2, E1-F3, E1-F4
- Tasks:
  - `E1-F1-T1` ids + monotonic time (S) → `es_core/src/id.rs`, tests
  - `E1-F2-T1` diagnostics/severity + log sink (S) → `es_diagnostics` (exists; extend)
  - `E1-F3-T1` `Command` trait + dispatch (M) → `es_core/src/command.rs`, unit
  - `E1-F3-T2` validation hook + error path (S) → same, tests
  - `E1-F4-T1` `Event` + append-only stream (M) → `es_core/src/event.rs`, unit
  - `E1-F4-T2` command→event integration test (S)
- Deliverable: dispatch a Command, observe the Event. **Demo:** headless bus round trip.
- Testing/DoD: unit for bus; fault-injection on cancel; `make check` green.

## Sprint 2 — Foundation II + IR framework  ·  Goal: service registry + IR base
- Features: E1-F5, E2-F1, E2-F2, E2-F3
- Tasks: `E1-F5-T1` registry (M); `E2-F1-T1` versioned/immutable/serializable traits (M);
  `E2-F2-T1` golden harness (M); `E2-F2-T2` byte-stable diff + update mode (S); `E2-F3-T1`
  migration scaffold (S).
- Deliverable: IR base + golden harness. **Demo:** round-trip a sample IR through goldens.
- Testing/DoD: serialization + migration tests; WASM core build in CI.

## Sprint 3 — Geometry I  ·  Goal: coordinate system + paths
- Features: E3-F1, E3-F2, E3-F5. Tasks: coord/epsilon policy (M); Point/Path types (M) [extends
  existing `es_geometry`]; path validation (S); bbox (S); golden fixtures (S).
- **Demo:** build/validate a path, golden-diff. Testing: unit + property + golden.

## Sprint 4 — Geometry II  ·  Goal: curves, transforms, algorithms, IR serialize
- Features: E3-F3, E3-F4, E3-F6, E3-F7. Tasks: bezier eval/subdivide (M); affine transforms (M);
  length/flatten/hit-test (M); Geometry IR serialization + schema version (M).
- **Demo:** transform a curve, serialize, golden-diff. → **M2 exit.**

## Sprint 5 — Document model  ·  Goal: command-driven document
- Features: E4-F1, E4-F2. Tasks: doc/layers/objects tree (M); geometry commands create/move/delete
  (M); command→event integration (M); undo scaffold (S).
- **Demo:** mutate document via Commands, observe Events.

## Sprint 6 — Document + Storage I  ·  Goal: history + `.embproj`
- Features: E4-F3, E4-F4, E5-F1. Tasks: event-sourced undo/redo (M); project metadata (S);
  `.embproj` layout + manifest (M); load validation (S).
- **Demo:** edit → undo/redo → save.

## Sprint 7 — Storage II  ·  Goal: atomic save + recovery  → M3 exit
- Features: E5-F2, E5-F3, E5-F4. Tasks: atomic write + checksum (M); crash-mid-write fault test (M);
  journal/recovery, never auto-overwrite (M); project migration (S).
- **Demo:** kill mid-save, recover cleanly. → **M3 exit.**

## Sprint 8 — Import I  ·  Goal: Import IR + SVG parse
- Features: E6-F1, E6-F2. Tasks: Import IR model (M); SVG parser → Import IR (M×2); diagnostics (S).
- **Demo:** parse an SVG into Import IR.

## Sprint 9 — Import II  ·  Goal: normalize → Geometry IR  → M4 exit
- Features: E6-F3. Tasks: normalization Import→Geometry (M); golden import (S); SVG compat set (M).
- **Demo:** import real SVG into editable document. → **M4 exit.**

## Sprint 10 — Embroidery I  ·  Goal: Stitch IR + running stitch
- Features: E7-F1, E7-F2. Tasks: Stitch IR model + serialization (M); running-stitch pass (M×2);
  determinism test (S).
- **Demo:** digitize a path to running stitches.

## Sprint 11 — Embroidery I cont. + Machine I  ·  Goal: Stitch IR solid, start Machine IR → M5 exit
- Features: E7-F6, E7-F8, E8-F1. Tasks: density model (S); sequencing/tie/trim/jump (M); Machine IR
  model (M); Stitch IR goldens (S).
- **Demo:** running-stitch design with sequencing + ties. → **M5 exit.**

## Sprint 12 — Machine compiler  ·  Goal: Stitch IR → Machine IR
- Features: E8-F2, E8-F3. Tasks: needle/thread mapping (M); machine/hoop validation (M); Machine IR
  goldens (S); perf budget harness <500 ms (S).
- **Demo:** compile Stitch IR to validated Machine IR.

## Sprint 13 — DST + integration gate  ·  Goal: SVG→DST  → M6 exit
- Features: E9-F1, E9-F2. Tasks: DST encoder (M); DST binary golden (S); **headless SVG→DST
  integration test** (M); wire into CI (S).
- **Demo:** SVG in → DST out, opens on machine/simulator. → **M6 exit — architecture proof.**

---

# Wave 2 — task-loaded (M6 widening → M10)

Ordering respects `004-development-order.md`. Sprints S28+ (Desktop UI onward) are planning
estimates on the 2-year horizon — task lists there are refined when the milestone enters the
current wave (rolling wave), but are decomposed here for scheduling and issue import.

## Sprint 14 — Embroidery widen I  ·  Goal: satin + fill columns
- Features: E7-F3, E7-F4. Tasks: satin column generator (M); fill/tatami with angle+density (M);
  satin golden (S); fill golden (S).
- **Demo:** letterform in satin, region in tatami fill, both deterministic.

## Sprint 15 — Embroidery widen II  ·  Goal: underlay + density
- Features: E7-F5, E7-F6. Tasks: underlay passes (M); density model + validation (S);
  underlay golden (S); density unit tests (S).
- **Demo:** satin with underlay; density violation flagged.

## Sprint 16 — Embroidery widen III  ·  Goal: compensation + sequencing
- Features: E7-F7, E7-F8. Tasks: pull/push compensation (M); sequencing tie-in/off/trim/jump (M);
  compensation golden (S); sequencing golden (S).
- **Demo:** compensated satin; ordered multi-object stitch-out.

## Sprint 17 — Optimization + export formats  ·  Goal: travel opt + EXP
- Features: E7-F9, E9-F3. Tasks: travel/color-change optimization (M) + determinism test (S);
  EXP generator (M); EXP binary golden (S).
- **Demo:** optimized path; SVG→EXP export. → **E7/E9 widen milestone (M11-wide) checkpoint.**

## Sprint 18 — Simulation I  ·  Goal: Playback IR + compiler
- Features: E10-F1, E10-F2. Tasks: Playback IR types + serialization (M); playback compiler
  Stitch IR→Playback IR (M); determinism test (S).
- **Demo:** Stitch IR compiled to a headless timeline.

## Sprint 19 — Simulation II + FFI marshaling I  ·  Goal: motion/stats + Command bridge
- Features: E10-F3, E10-F4, E15-F1. Tasks: needle-motion model (S); playback statistics (S);
  frb Command dispatch bridge (M) + contract test (S).
- **Demo:** per-frame needle position + stats; Flutter dispatches a Command to Rust.

## Sprint 20 — Simulation III + FFI marshaling II  ·  Goal: playback service + Event stream
- Features: E10-F5, E15-F2, E15-F3. Tasks: playback service play/pause/seek (M); frb Event stream
  bridge (M); progress/cancellation (S).
- **Demo:** headless playback controls; Rust events stream to Flutter. → **M7 exit.**

## Sprint 21 — FFI WASM parity  ·  Goal: web boundary
- Features: E15-F4. Tasks: WASM build target (M); engine API parity smoke suite (M);
  CI web matrix job (S).
- **Demo:** same engine API under Flutter Web.

## Sprint 22 — Rendering I  ·  Goal: renderable model + scene graph
- Features: E11-F1, E11-F2. Tasks: renderable model from Geometry/Playback IR (M); scene-graph
  nodes + dirty tracking (M); scene unit tests (S).
- **Demo:** geometry → renderable scene, no document mutation.

## Sprint 23 — Rendering II  ·  Goal: render graph
- Features: E11-F3. Tasks: render-graph pass ordering (M); GPU-resource/document-resource
  separation (M); snapshot test (S).
- **Demo:** multi-pass render graph executes.

## Sprint 24 — Rendering III  ·  Goal: GPU backend
- Features: E11-F4. Tasks: replaceable GPU backend (L); render-to-target (M); backend golden (S).
- **Demo:** scene rendered via GPU backend.

## Sprint 25 — Rendering IV  ·  Goal: viewport + camera
- Features: E11-F5. Tasks: viewport pan/zoom/fit (M); device-pixel correctness (S); camera unit
  tests (S).
- **Demo:** navigable viewport.

## Sprint 26 — Rendering V  ·  Goal: LOD + culling
- Features: E11-F6. Tasks: culling for large documents (M); level-of-detail (M); perf benchmark (S).
- **Demo:** large document renders within perf budget.

## Sprint 27 — Rendering VI  ·  Goal: thread rendering
- Features: E11-F7. Tasks: stitch/thread visual styling from Playback IR (M); thread golden (S);
  render perf pass (S).
- **Demo:** realistic thread preview. → **M7/M8 rendering checkpoint.**

## Sprint 28 — Desktop UI I  ·  Goal: shell + docking
- Features: E12-F1, E12-F2. Tasks: app shell/window/theme/lifecycle (M); workspace docking +
  layout persistence (M); shell widget tests (S).
- **Demo:** dockable-panel app shell.

## Sprint 29 — Desktop UI II  ·  Goal: canvas widget
- Features: E12-F3. Tasks: canvas hosting render viewport (M); gesture→Command dispatch (M);
  interaction tests (S).
- **Demo:** pan/zoom canvas; gestures produce Commands.

## Sprint 30 — Desktop UI III  ·  Goal: selection + transform tools
- Features: E12-F4. Tasks: selection tool via Commands (M); transform gizmos move/scale/rotate (M);
  interaction tests (S).
- **Demo:** select + transform objects.

## Sprint 31 — Desktop UI IV  ·  Goal: creation tools
- Features: E12-F5. Tasks: pen tool (M); shape/text tools (M); tool-state isolation test (S).
- **Demo:** draw geometry with pen/shape/text.

## Sprint 32 — Desktop UI V  ·  Goal: inspector
- Features: E12-F6. Tasks: property inspector edits via Commands (M); event-derived state binding
  (S); widget tests (S).
- **Demo:** edit object properties live.

## Sprint 33 — Desktop UI VI  ·  Goal: layers + history
- Features: E12-F7. Tasks: layer tree (M); undo/redo/history view from events (M); widget tests (S).
- **Demo:** reorder layers; scrub history.

## Sprint 34 — Desktop UI VII  ·  Goal: thread + machine panels
- Features: E12-F8. Tasks: thread panel assign-via-Command (M); machine-profile panel (S);
  widget tests (S).
- **Demo:** assign threads; pick machine profile.

## Sprint 35 — Desktop UI VIII  ·  Goal: import/export UI
- Features: E12-F9. Tasks: import dialog wired to pipeline (M); export dialog wired to generators
  (M); integration test (S).
- **Demo:** import SVG, export DST from the UI. → **M8 exit — usable desktop editor.**

## Sprint 36 — AI I  ·  Goal: knowledge graph
- Features: E13-F1. Tasks: knowledge-graph model from `docs/03-domain/ai` (M); loader + query (M);
  unit tests (S).
- **Demo:** query embroidery domain knowledge.

## Sprint 37 — AI II  ·  Goal: rule engine
- Features: E13-F2. Tasks: deterministic rule evaluation (M); rule set from `901-digitizing-rules`
  (M); rule-eval tests (S).
- **Demo:** rules evaluate deterministically.

## Sprint 38 — AI III  ·  Goal: confidence + explainability
- Features: E13-F3. Tasks: confidence scoring (S); explanation generator (M); explainability
  tests (S).
- **Demo:** each result carries score + rationale.

## Sprint 39 — AI IV  ·  Goal: analyzer + quality inspector
- Features: E13-F4, E13-F6. Tasks: artwork analyzer/classifier (M); quality inspector risk flags
  (M); eval suite (S).
- **Demo:** classify artwork; flag density/puckering risk.

## Sprint 40 — AI V  ·  Goal: AI digitizer (Command-only)
- Features: E13-F5. Tasks: stitch strategy planner (L); emit plan as Commands, no direct mutation
  (M); integration test (S).
- **Demo:** AI proposes a digitizing plan as reviewable Commands.

## Sprint 41 — AI VI  ·  Goal: assistant + human approval
- Features: E13-F7. Tasks: assistant/chat tool-calling (M); approval + audit + permission gate (M);
  integration test (S).
- **Demo:** assistant edits only after human approval; audited. → **M9 exit.**

## Sprint 42 — Plugin I  ·  Goal: runtime + registry
- Features: E14-F1, E14-F3. Tasks: plugin runtime/lifecycle (M); extension registry (M);
  unit tests (S).
- **Demo:** load/unload a plugin; register a contribution.

## Sprint 43 — Plugin II  ·  Goal: sandbox + permissions
- Features: E14-F2. Tasks: sandbox isolation (M); permission-gated engine access via public APIs
  (M); sandbox tests (S).
- **Demo:** plugin blocked from private state; permitted calls succeed.

## Sprint 44 — Plugin III  ·  Goal: contribution points
- Features: E14-F4. Tasks: plugin importer/exporter hook (M); plugin stitch-algorithm hook (M);
  integration test through IR contracts (S).
- **Demo:** third-party importer + exporter run via plugin.

## Sprint 45 — Plugin IV  ·  Goal: plugin UI panels
- Features: E14-F5. Tasks: host plugin-contributed panels (M); panel isolation/safety (S);
  widget test (S).
- **Demo:** plugin panel renders safely in the shell. → **M10 plugin checkpoint.**

## Sprint 46 — Hardening I  ·  Goal: performance
- Features: E16-F2. Tasks: perf-benchmark CI gate (M); large-document perf pass (M); regression
  budgets wired (S).
- **Demo:** perf dashboard green against budgets.

## Sprint 47 — Hardening II  ·  Goal: compatibility + fault injection
- Features: E16-F3. Tasks: real-world file compat suite (M); storage/lifecycle fault-injection (M);
  recovery verification (S).
- **Demo:** compat matrix green; recovers from injected faults.

## Sprint 48 — Hardening III  ·  Goal: security + GA
- Features: E16-F4, E14-F2. Tasks: security gateway + audit hardening (M); signed/notarized builds
  (M); release checklist dry-run (S).
- **Demo:** signed build passes `009-release-checklist.md`. → **M10 exit — production ready (GA).**

---

# Sprint mechanics

- Sprint 0 already done (Task 1 skeleton).
- Each sprint ends with: green `make check`, a demo, updated `010-project-dashboard.md`, backlog
  groomed for the next.
- Carryover is re-estimated, not silently rolled; scope is cut before quality (ponytail).
