# UI
## UI-509 Stitch Sequence Panel

**Document ID:** UI-509  
**Title:** Stitch Sequence Panel  
**Version:** 1.0.0  
**Status:** Implementation Guidance  
**Priority:** High  
**Owner:** Product Experience Team

**Related Documents**

```text
docs/02-architecture/000-system-overview.md
docs/02-architecture/003-command-system.md
docs/04-ui/502-layer-panel.md
docs/07-adr/028-editable-objects-are-authoritative.md
docs/07-adr/036-objects-carry-display-names.md
```
---

# Purpose

This document defines the Stitch Sequence panel ("Stitches"): the
embroidery-execution view of the document. It is the counterpart of the
Layer panel (UI-502) under a strict separation of concerns:

- **Layer panel** — the editable document model: layers, groups,
  vector objects, text; design-origin names.
- **Stitch Sequence panel** — the generated embroidery output: stitch
  order, stitch type, thread colour, counts, machine execution
  sequence.

The two panels complement each other and must not expose the same
vocabulary: stitch-kind names (Running/Satin/Fill/…) never appear in
the Layer panel; design names never replace stitch types here.

---

# Definition

Each entry represents one design object's generated stitch sequence, in
execution order. Execution order IS document order — the panel derives
its list from the flattened visible hierarchy, and reordering an entry
reparents/reindexes the object via `MoveNode` (undoable; preview and
simulation follow automatically).

Columns: sequence number, thread-colour swatch, stitch type, stitch
count. Text objects expand into per-glyph inspection rows that drive
the canvas highlight (view state only — never document mutations).

---

# Implementation Status (MVP)

Implemented as `StitchesPanelContent` in
`apps/studio/lib/src/panels/stitches_panel.dart`, hosted by the dock
(UI-202).

## As built

- **Columns** — `# / CLR / STITCH TYPE / COUNT`; thread swatch shows
  the object's stroke colour (fallback: fill, then theme default —
  matching the canvas renderer); counts use tabular figures.
- **Selection** — rows select the underlying object (shared selection
  with canvas and Layer panel); fill + accent-bar styling.
- **Reordering** — drag a row above/below another (2 px drop
  indicator); issues `MoveNode` relative to the target's position.
- **Glyph rows** — expandable per-glyph stitch counts for text objects;
  tapping toggles the canvas outline-range highlight.
- **Summary footer** — Stitch Count (headline metric), Objects,
  Colours (distinct thread colours), Thread Length (summed stitch
  segment lengths, mm/m), Est. Time (flat 700 spm until machine
  profiles land).

## Not yet built

Bean/tack/underlay stitch kinds (generators pending), jump/trim rows,
colour-block grouping, per-entry stitch parameter editing (lives in
Properties), machine-profile-aware time estimates.

---

# Rules

- Never mutate the document directly: selection goes through the
  selection controller; reordering goes through `MoveNode` commands.
- Stitch data shown here is derived (regenerable) — nothing in this
  panel is authoritative state (ADR-028, ADR-035).
