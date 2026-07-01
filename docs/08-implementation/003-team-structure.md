# Implementation

## IMPL-003 Team Structure

**Document ID:** IMPL-003
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Engineering Manager

Execution model: **one senior engineer** drives the program, using the 10-agent team (`agents/`,
runnable from Claude Code / Codex / opencode) as scoped force-multipliers. Each agent owns a lane;
the engineer is integrator, reviewer, and final authority.

---

# Roles → ownership → RACI

| Agent | Owns (packages) | R | A | C | I |
|---|---|---|---|---|---|
| architect | boundaries, ADRs, dep direction | reviews designs | — | all impl agents | eng |
| core-engine | es_core, es_diagnostics, es_document, es_ffi, es_plugin | impl | eng | architect | qa-review |
| geometry | es_geometry (Geometry IR) | impl | eng | architect | — |
| embroidery | es_embroidery, es_digitizer (Stitch IR), es_thread | impl | eng | geometry | qa-review |
| machine-compiler | es_machine, es_machine_compiler (Machine IR) | impl | eng | embroidery | import-export |
| import-export | es_import (Import IR), es_gen_* , es_storage | impl | eng | machine-compiler | qa-review |
| rendering | es_render, es_playback (Playback IR) | impl | eng | geometry | ui |
| ui | apps/studio, studio_* packages | impl | eng | rendering | — |
| ai | es_ai | impl | eng | embroidery, machine-compiler | qa-review |
| qa-review | tests, CI compliance, security review | reviews | eng | all | eng |

R = Responsible, A = Accountable (the human engineer), C = Consulted, I = Informed.

---

# Working agreements

- **Read-only lanes:** `architect` and `qa-review` never edit source — they gate. (Codex enforces
  via `sandbox_mode = "read-only"`; other runners honor it from the prompt.)
- **One agent, one package context** — no agent moves responsibilities across packages or creates
  cross-layer deps. Uncertain → ADR, not scope-creep (`docs/02-architecture/018` AI Agent Rules).
- **Handoffs via artifacts** — agents communicate through Commands/Events/IRs and PRs, not shared
  mutable state.
- **The human** sequences sprints, integrates cross-lane work, approves ADRs, and owns releases.

---

# Scaling path (if the team grows)

The agent lanes map 1:1 to the doc's recommended human teams (`docs/02-architecture/018` Team
Ownership): Kernel, Platform, Geometry, Embroidery, Compiler, Rendering, Storage, AI, Plugin,
Flutter. Adding an engineer means taking over one lane wholesale — ownership boundaries already
make this conflict-free.

---

# Escalation

Boundary dispute, IR schema change, new/split/merged package, or public-API change → **stop, write
an ADR** (`docs/07-adr`), route to `architect` for review before implementation resumes.
