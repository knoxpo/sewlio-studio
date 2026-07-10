# Sewlio Studio — Agent Team

Shared instructions for every coding agent across all runners (Claude Code, Codex, opencode).

## Source of truth

- Docs in `docs/` are authoritative. Where any agent prompt and a doc disagree, the doc wins.
- Roadmap: `docs/08-implementation/000-implementation-roadmap.md`.
- Architecture: `docs/02-architecture/` (esp. `000` system overview, `001` IRs, `018` package ownership).

## Non-negotiable rules (all agents)

- Obey the 12 Non-Negotiables in `docs/02-architecture/000` §34.
- Respect package ownership and **downward-only** dependencies (`docs/02-architecture/018`):
  `kernel → runtime → platform → domains → compilers → generators → services → bridges → flutter`.
- Respect IR ownership (`docs/02-architecture/001`): one owner per IR; IRs are immutable + versioned.
- Flutter never mutates state — all mutation flows through Commands; state changes emit Events.
- Add or update tests with every change. Core/domain packages must stay headless-testable; Rust remains the later performance migration path.
- No unsafe install scripts or remote code. Keep changes small and reviewable.
- Crossing a package boundary or changing an IR schema → **stop and require an ADR** (`docs/07-adr`).

## Working style (all agents, all runners)

- **YAGNI / minimal first (ponytail).** Build the smallest thing that works. No interface with one
  implementation, no factory for one product, no config for a value that never changes, no
  scaffolding "for later". Reach for stdlib / native platform features before adding a dependency.
  Deletion over addition. Shortest working diff wins. Mark deliberate shortcuts with a
  `ponytail:` comment naming the ceiling and upgrade path. Never simplify away input validation
  at trust boundaries, error handling that prevents data loss, security, or anything explicitly
  asked for.
- **Terse communication (caveman).** Status, reviews, and chat: drop filler, hedging, and
  pleasantries; fragments fine. **Code, commits, PRs, doc prose, and code comments stay normal,
  fully readable** — terseness governs conversation, never artifacts a teammate must read.

These are runner-agnostic norms. Under Claude Code the `ponytail` and `caveman` plugins enforce
them automatically; Codex/opencode agents follow them from this section.

## Tooling

- **graphify** — knowledge-graph skill. Turns any input (docs, code, papers) into a clustered
  graph (interactive HTML + GraphRAG JSON + audit `GRAPH_REPORT.md`). Useful for mapping the
  `docs/` spec set or a package's structure before touching it.
  - Canonical `SKILL.md` lives once in `skills/graphify/`. Each runner discovers it via a symlink
    to that dir: Claude Code `.claude/skills/`, opencode `.opencode/skills/`, Codex `.agents/skills/`.
  - Invoke: `/graphify [path]` (Claude) or load the `graphify` skill by name (opencode/Codex).
    The Python `graphify` package self-installs on first run (`pip install graphifyy`).
  - **Caveat:** the semantic-extraction step is written for Claude Code (it dispatches parallel
    `general-purpose` subagents and uses Claude vision). The structural half — AST extraction,
    clustering, HTML/JSON/report — is pure Python and runner-agnostic. Under Codex/opencode an
    agent must map "dispatch subagents" onto that runner's own subagent mechanism; behavior is
    equivalent, not identical.

## The team

Canonical role prompts live once in `agents/<role>.md`. Each runner loads them as follows:

| Role | Slug | Sandbox | Loads from |
|---|---|---|---|
| Architect | `architect` | read-only | `agents/architect.md` |
| Core Engine | `core-engine` | write | `agents/core-engine.md` |
| Geometry | `geometry` | write | `agents/geometry.md` |
| Embroidery Domain | `embroidery` | write | `agents/embroidery.md` |
| Machine Compiler | `machine-compiler` | write | `agents/machine-compiler.md` |
| Import/Export | `import-export` | write | `agents/import-export.md` |
| Rendering | `rendering` | write | `agents/rendering.md` |
| UI | `ui` | write | `agents/ui.md` |
| AI | `ai` | write | `agents/ai.md` |
| QA / Review | `qa-review` | read-only | `agents/qa-review.md` |

Active MVP agents focus on the Flutter/Pure Dart embroidery-first vertical slice: platform architecture, universal design/document model, Flutter foundation, Dart core engine, Dart geometry, embroidery engine, machine/export, Flutter UI, and QA/documentation review.

Future domain agents are planned but not active for MVP implementation:

| Role | Slug | Sandbox | Status |
|---|---|---|---|
| Weaving Domain | `weaving-domain` | write | Future |
| Loom Compiler | `loom-compiler` | write | Future |
| Digital Printing Domain | `digital-printing-domain` | write | Future |
| Print Pipeline | `print-pipeline` | write | Future |
| Cross-Domain Conversion | `cross-domain-conversion` | write | Future |

Phase 2 Rust migration agents are deferred until MVP acceptance and measured performance need:

| Role | Slug | Sandbox | Status |
|---|---|---|---|
| Rust Migration Architect | `rust-migration-architect` | read-only | Deferred |
| Rust Geometry | `rust-geometry` | write | Deferred |
| Rust Production Engine | `rust-production-engine` | write | Deferred |
| Flutter-Rust Bridge | `ffi-bridge` | write | Deferred |
| Performance Benchmark | `performance-benchmark` | read-only | Deferred |

Project-specific task agents (workflow + guardrails):

| Role | Slug | Sandbox | Loads from |
|---|---|---|---|
| Sprint Runner (orchestrator) | `sprint-runner` | write | `agents/sprint-runner.md` |
| IR Guardian | `ir-guardian` | read-only | `agents/ir-guardian.md` |
| FFI Bridge | `ffi-bridge` | write | `agents/ffi-bridge.md` |
| Golden Runner | `golden-runner` | write | `agents/golden-runner.md` |
| Dependency Fitness | `dep-fitness` | read-only | `agents/dep-fitness.md` |

## Workflow & model routing

Execution model is **hybrid** — see [`WORKFLOW.md`](WORKFLOW.md) for the full loop:

- **Claude Code (Opus)** plans, decides architecture, authors ADRs, and does final review.
- **opencode** runs the implementer agents on **local models** via the `omlx_remote` provider.
  Per-agent model is set in [`.opencode/opencode.json`](.opencode/opencode.json) (`agent.<name>.model`):
  coding roles → `Qwen3-Coder-30B-A3B`; compiler/IR roles → `Qwen3.6-35B-A3B`; review/orchestrate →
  `Qwen3.5-27B-Opus-Distilled`. Per-agent model lives here, not in the shared `agents/*.md`
  frontmatter, because Claude's `model:` field can't take an opencode provider string.
- The two runners hand off through GitHub issues + git branches, not a single tool call. Anything
  crossing a package boundary or changing an IR schema escalates to Claude Code for an ADR first.

## How each runner loads the team

- **Claude Code** — `.claude/agents` → symlink to `agents/`. Reads each file's `name` + `description`.
- **opencode** — `.opencode/agent` → symlink to `agents/`. Reads `description` + `mode: subagent`.
- **Codex** — `.codex/agents/<role>.toml` stubs set `sandbox_mode` and point `developer_instructions`
  at the matching `agents/<role>.md`. Codex also reads this `AGENTS.md` automatically.

Editing a role prompt: change `agents/<role>.md` once — Claude and opencode pick it up via symlink;
the Codex stub already references it. Only add per-runner overrides when a runner genuinely needs one.
