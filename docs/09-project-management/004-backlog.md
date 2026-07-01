# Project Management

## PM-004 Backlog & Label Taxonomy

**Document ID:** PM-004
**Version:** 1.0.0
**Status:** Living
**Owner:** Technical Program Management

Single prioritized backlog. Near-term items (Wave 1) are task-level and sprint-assigned; the rest
are epic/feature stubs pulled forward as milestones approach. The machine-importable form lives in
`tools/github/issues.json` (+ `labels.json`, `import.sh`).

---

# Backlog order (top = next)

1. **E1 Foundation** — E1-F1…F5 (S1-S2) · P0
2. **E2 IR Framework** — E2-F1…F3 (S2) · P0
3. **E3 Geometry** — E3-F1…F7 (S3-S4) · P0
4. **E4 Document** — E4-F1…F4 (S5-S6) · P0
5. **E5 Storage** — E5-F1…F4 (S6-S7) · P0
6. **E6 Import** — E6-F1…F3 (S8-S9) · P1
7. **E7 Embroidery (running stitch)** — E7-F1,F2,F6,F8 (S10-S11) · P0
8. **E8 Machine** — E8-F1…F3 (S11-S12) · P0
9. **E9 Export (DST + gate)** — E9-F1,F2 (S13) · P1
10. **E7 widening** — satin/fill/underlay/compensation/optimization · P1
11. **E9 widening** — EXP/PES/JEF/VP3/HUS · P1
12. **E10 Simulation** · P2
13. **E15 FFI marshaling / WASM** · P1
14. **E11 Rendering** · P2
15. **E12 Desktop UI** · P1
16. **E13 AI** · P2
17. **E14 Plugin** · P3
18. **E16 Testing/CI/Security** — continuous, threaded through all · P0

Cross-cutting continuous work (E16) is not a single backlog slot — each sprint carries its share.

---

# Label taxonomy (Step 10)

Mirrors `tools/github/labels.json`. Colors are hints.

**Domain / layer** `#1d76db`: `kernel` `runtime` `geometry` `embroidery` `thread` `machine`
`import` `export` `generator` `simulation` `rendering` `ui` `ai` `plugin` `storage` `security` `ffi`

**Stack** `#5319e7`: `rust` `flutter`

**Kind** `#0e8a16`: `epic` `feature` `task` `bug` `research` `docs` `testing` `performance` `ci-cd`

**Priority** `#b60205`: `P0` `P1` `P2` `P3`

**Size** `#fbca04`: `size/XS` `size/S` `size/M` `size/L`

**Workflow** `#d93f0b`: `blocked` `good-first-issue`

---

# Grooming rules

- Reprioritize every sprint boundary; keep the top ~2 sprints task-ready.
- Every backlog item maps to an epic/feature ID and carries labels + priority + size.
- Split any item > size/M into tasks before it enters a sprint.
- `blocked` items name the blocking ID; nothing `blocked` is pulled into a sprint.
