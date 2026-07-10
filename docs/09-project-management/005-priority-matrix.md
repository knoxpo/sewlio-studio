# Project Management

## PM-005 Priority Matrix

**Document ID:** PM-005
**Version:** 1.0.0
**Status:** Foundation
**Owner:** Technical Program Management

How work is prioritized. Combines a **value/effort** view with **MoSCoW** and a **P0-P3** scale.

> **ADR-026:** MVP priorities are Dart-first. The Rust migration and other long-term epics are P2
> Post-MVP. Priorities below lead with the MVP; the Rust-epic mapping is preserved beneath.

---

# MVP priorities (active, ADR-026)

**P0 — MVP (must ship):** Flutter app shell · Dart core/domain packages (`studio_core`,
`studio_geometry`, `studio_embroidery`) · document model · geometry · embroidery basics · Machine IR
(Dart) · minimal Project Type architecture for Embroidery Projects · basic import/export (DST/EXP) · canvas · save/load.

**P1 — MVP polish:** simulation preview · inspector · AI assistant hooks · quality diagnostics.

**P2 — Post-MVP:** Weaving engine · digital printing engine · Rust migration · `flutter_rust_bridge` · GPU rendering backend · plugin runtime ·
advanced exporters (PES/JEF/VP3/HUS) · advanced AI.

---

# Priority scale

| P | Meaning | Scheduling rule |
|---|---|---|
| P0 | Blocking spine — nothing ships without it | scheduled first, never deferred |
| P1 | Core product value | scheduled right after its P0 prereqs |
| P2 | Important, not gating the vertical slice | after P0/P1 in the same milestone |
| P3 | Enhancement / deferrable | pulled only with spare capacity |

---

# MoSCoW → epics

- **Must** (P0): E1 Foundation, E2 IR, E3 Geometry, E4 Document, E5 Storage, E7 Embroidery core,
  E8 Machine, E16 Testing/CI/Security.
- **Should** (P1): E6 Import, E9 Export, E12 Desktop UI, E15 FFI.
- **Could** (P2): E10 Simulation, E11 Rendering, E13 AI.
- **Won't-yet** (P3): E14 Plugin, tablet/mobile/web shells (post-GA).

---

# Value / effort quadrant

```text
        high value
            │
  E3,E4,E7  │  E1,E2,E8,E9     ← do first (spine; high value)
  E12,E11   │  E6,E5,E15
────────────┼──────────────── effort →
  E13,E10   │  E16 (continuous)
  E14       │
            │
        low value
```

- **High value / lower effort** (top-right): the P0 spine — do first.
- **High value / high effort** (top-left): E12 UI, E11 Rendering — big but essential; sequence after
  the engine is proven.
- **Lower value / high effort** (bottom-left): AI, Simulation, Plugin — real but deferrable to
  mid/late program.

---

# Tie-breakers (when two items share priority)

1. Unblocks the most downstream work (spine first).
2. Advances the SVG→DST vertical slice.
3. Reduces a top risk (`08-impl/007-risk-register.md`).
4. Smaller / more reviewable (ship the lazy version, question the rest).
