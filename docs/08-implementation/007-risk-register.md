# Implementation

## IMPL-007 Risk Register

**Document ID:** IMPL-007
**Version:** 1.0.0
**Status:** Living
**Owner:** Technical Program Management

Likelihood (L) / Impact (I): Low / Med / High. Review each milestone exit.

| ID | Risk | L | I | Mitigation | Owner | Trigger / early signal |
|---|---|---|---|---|---|---|
| R1 | frb bridge complexity / version skew (frb crate ↔ codegen ↔ Flutter) | Med | High | Pin frb crate = codegen version (done: 2.12.0); `make gen` drift check in CI; ADR before Command/Event marshaling lands | core-engine | codegen mismatch warnings, generated-diff on CI |
| R2 | Float determinism across platforms breaks goldens | Med | High | Fix rounding/epsilon at Geometry IR (M2); byte-identical golden diff on all CI targets | geometry | golden diff differs macOS vs Linux |
| R3 | Storage engine assumption (libSQL/Turso vs SQLite) | Med | Med | Confirm before es_storage (M3); ADR; keep storage behind `ProjectStore` trait | import-export | dependency/licensing/perf surprise |
| R4 | Golden machine-file sourcing (real `.dst`/`.pes`) | Med | Med | Acquire small licensed/open fixture set before M6; commit under `testdata/` | import-export | exporter work reaches M6 without fixtures |
| R5 | Solo bus-factor (one engineer) | High | High | Docs-as-source-of-truth; agent lanes; small reviewable PRs; ADRs capture rationale | eng manager | knowledge siloing, undocumented decisions |
| R6 | Scope creep vs 2-year budget | High | Med | Rolling-wave planning; vertical slice first; ruthless YAGNI (ponytail); backlog triage each sprint | TPM | sprint velocity drift, growing WIP |
| R7 | GPU rendering complexity / cross-platform backends | Med | High | Keep rendering behind a replaceable backend; renderable model is pure data; defer to M7-M8 after geometry proven | rendering | shader/backend portability failures |
| R8 | IR schema churn as later stages land | High | Med | Versioned schemas + migration tests from M2; breaking change ⇒ ADR (`02-arch/001` C10) | architect | frequent breaking IR edits |
| R9 | Package-boundary drift as crate count grows | Med | Med | Dependency-direction lint in CI; ownership change ⇒ ADR | architect | new cross-layer dep appears |
| R10 | AI safety / unreviewed mutation | Low | High | AI emits Commands only; human approval, audit trail, permission gate (`06-ai/700`) | ai | AI path attempts direct state write |
| R11 | Performance budgets missed (large designs) | Med | High | Perf benchmarks wired at IR boundaries (Import <200ms, Machine <500ms); nightly perf gate | qa-review | benchmark regression |
| R12 | WASM/web parity drift from native core | Low | Med | Keep kernel/runtime/domains dependency-clean; add WASM build target early in CI | core-engine | native-only dep creeps into core |

New risks are appended here as discovered; closed risks are struck through with the resolving PR/ADR.
