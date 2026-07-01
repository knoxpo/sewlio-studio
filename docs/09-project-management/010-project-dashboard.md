# Project Management

## PM-010 Project Dashboard

**Document ID:** PM-010
**Version:** 1.0.0
**Status:** Living (update each sprint)
**Owner:** Technical Program Management

Single-glance status. Update at every sprint boundary. Values below are the **current baseline**
(program start, post Task-1 skeleton).

---

# Program status

| Field | Value |
|---|---|
| Current milestone | **M1 Foundation** |
| Current sprint | Pre-S1 (skeleton done) |
| Phase | Wave 1 (task-loaded) |
| Overall | 🟢 on track |

---

# Milestone burnup

| Milestone | Status | Target | Notes |
|---|---|---|---|
| M1 Foundation | ⬜ not started | S1-S4 | next up |
| M2 Geometry | ⬜ | S3-S4 | — |
| M3 Document+Storage | ⬜ | S5-S7 | — |
| M4 Import | ⬜ | S8-S9 | — |
| M5 Embroidery Core | ⬜ | S10-S11 | — |
| M6 Machine+Export | ⬜ | S12-S13 | **SVG→DST gate** |
| M7 Simulation | ⬜ | S18-S21 | — |
| M8 Desktop Editor | ⬜ | S28-S35 | — |
| M9 AI | ⬜ | S36-S41 | — |
| M10 Production | ⬜ | S46-S53 | GA |

Legend: ⬜ not started · 🟨 in progress · ✅ done.

---

# Epic status

| Epic | Status | % | Owner |
|---|---|---|---|
| E1 Foundation | ⬜ 0% | | core-engine |
| E2 IR Framework | ⬜ 0% | | core-engine |
| E3 Geometry | 🟨 ~5% (Point stub) | | geometry |
| E15 FFI Bridge | 🟨 ~10% (frb skeleton) | | core-engine |
| E16 Testing/CI | 🟨 ~10% (make check) | | qa-review |
| E4-E14 | ⬜ 0% | | — |

(Skeleton delivered: workspace, es_diagnostics/es_core/es_geometry stubs, es_ffi + frb round trip,
Flutter app + design system + bindings, CI gate.)

---

# Current sprint board (template)

| Task | Status | Size | Owner |
|---|---|---|---|
| E1-F1-T1 ids/time | ⬜ | S | core-engine |
| … | | | |

Status: ⬜ todo · 🟨 wip · 🔵 review · ✅ done · 🔴 blocked.

---

# Risk heat (top 3)

| Risk | L×I | Trend |
|---|---|---|
| R5 Solo bus-factor | High×High | ↔ mitigated by docs/agents |
| R1 frb bridge | Med×High | ↘ skeleton proven |
| R2 Float determinism | Med×High | ↔ policy due M2 |

Full register: `08-impl/007-risk-register.md`.

---

# Update ritual (each sprint end)

1. Flip milestone/epic/sprint statuses.
2. Recompute epic % from tasks Done ÷ planned.
3. Refresh risk heat; open new risks.
4. Groom backlog for next sprint; record the demo outcome.
