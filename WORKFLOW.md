# Sewlio Studio — Development Workflow

How work flows from a planned GitHub issue to a merged, tested change, across two runners.

> **MVP note (ADR-026):** MVP tasks target **Dart packages** (`packages/studio_*`). Role agents
> emit **Dart** for MVP work (labeled `mvp`) and **Rust** for deferred migration work (labeled `post-mvp`).

The active MVP remains Flutter/Pure Dart and embroidery-first. Weaving and digital printing are post-MVP production domains unless a future roadmap explicitly pulls a small platform slice forward.
> The routing, gates, and escalation rules below apply to both; only the target language differs.

## Runner roles (hybrid)

| Runner | Model | Does |
|---|---|---|
| **Claude Code** | Opus (cloud) | Planning, architecture, ADRs, cross-package decisions, final review. Created the roadmap, sprints, and GitHub issues. |
| **opencode** | `omlx_remote/*` (local MLX box) | The implementer swarm — runs the role + task agents on local models to write code and tests. |
| **Codex** | per `.codex/agents/*.toml` | Optional third runner; same neutral prompts. |

**Why hybrid:** Claude Code sub-agents cannot route to local models
([claude-code#38698](https://github.com/anthropics/claude-code/issues/38698)); opencode can. So
high-value reasoning stays on Opus, bulk implementation runs cheap and local on opencode. The two
**do not share a process** — they hand off through GitHub issues and git branches, not a single
tool call.

## The loop (one sprint task)

```
GitHub issue (milestone Mn, label task)
   │  sprint-runner selects lowest-dependency open task; deps must be closed first
   ▼
git worktree/branch  task/<issue#>-<slug>     (never work on main)
   │  routed to the matching role agent (geometry / core-engine / …)
   ▼
implement code + tests  (opencode, omlx_remote model)
   │
   ▼
make check   (cargo fmt+clippy+test, fvm flutter analyze+test)   ── must be green
   │
   ▼
review gates:  ir-guardian (IR touched) · dep-fitness (deps changed) ·
               ffi-bridge (boundary touched) · qa-review (always)
   │  any gate fails → back to role agent
   ▼
PR  "Closes #<issue>"  → human approval → merge → issue auto-closes
```

## Commands

Pick and implement a task locally (opencode, local model):

```bash
# see the current sprint's open tasks
gh issue list --repo knoxpo/sewlio-studio --milestone "M1 Foundation" --label task --state open

# branch, then run a role agent on the issue (opencode uses its .opencode/opencode.json model map)
git worktree add ../es-task-42 -b task/42-command-bus
cd ../es-task-42
opencode run --agent core-engine "Implement issue #42 per its acceptance criteria. \
  Add tests. Keep to one package. Stop and flag if it needs an ADR."

# gate locally
make check

# review passes
opencode run --agent qa-review    "Review the diff on this branch against the DoD."
opencode run --agent dep-fitness  "Check crate dependency direction on this diff."

# PR (human approves + merges)
gh pr create --fill --base main
```

Orchestrate the whole loop for one issue:

```bash
opencode run --agent sprint-runner "Take the next open task in milestone 'M1 Foundation' and drive \
  it to a PR: branch, route to the right role agent, run make check, run the review gates, open a PR."
```

## When to escalate to Claude Code

Local models implement; **Claude Code decides architecture.** Escalate (do not let a local agent
proceed) when a task would:

- cross a package boundary or add a cross-layer dependency,
- change an **IR schema** (Import/Geometry/Stitch/Playback/Machine),
- change a public API contract or the `.swl` format,
- introduce a new dependency or a new package.

These require an **ADR** (`docs/07-adr`) authored/approved via Claude Code (architect) before code.
This is one of the 12 Non-Negotiables (`docs/02-architecture/000` §34).

## Agents & model routing

- Prompts: one neutral file per agent in `agents/` (loaded by all runners via symlink).
- Per-agent local model: `.opencode/opencode.json` → `agent.<name>.model` (coding →
  `Qwen3-Coder-30B-A3B`; hard compiler/IR → `Qwen3.6-35B-A3B`; reason/review/orchestrate →
  `Qwen3.5-27B-Opus-Distilled`).
- Roster and ownership: `AGENTS.md`. DoD + templates: `docs/09-project-management/`.

## Prerequisites

- `omlx_remote` reachable at `http://192.168.20.209:8000/v1` (auth stored). Offline ⇒ opencode
  falls back to the local `ollama` provider declared in `.opencode/opencode.json`.
- `gh` authenticated; Rust toolchain + `fvm` + `flutter_rust_bridge_codegen` installed (see README).
