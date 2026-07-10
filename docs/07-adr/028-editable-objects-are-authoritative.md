# ADR-028: Editable design objects are the authoritative model; stitches are derived

- **Status:** Accepted
- **Date:** 2026-07-10
- **Relates to:** ADR-026 (Dart engine for MVP), ADR-027 (layer hierarchy),
  ARCH-005 (document model), ARCH-009 (digitizer pipeline)

## Context

A review of the editing workflows raised the concern that stitches were being
treated as the primary data model. The audit found the pipeline direction is
already correct — the document stores design objects and `digitizeObjects`
regenerates the Stitch IR on demand (nothing persists stitches) — but three
real gaps made the model *feel* stitch-first:

1. **Text was destructive.** The Text tool converted typed text into dozens of
   per-stroke path objects at commit. The design intent (string, font, size,
   alignment) was discarded; nothing was re-editable.
2. **The active layer was ignored.** Every creation tool inserted into the
   default (first) layer regardless of which layer was selected.
3. **Single-path objects.** `EmbroideryObject` exposed exactly one `path`, so
   any design element with multiple contours (text, future symbols/images) had
   to shatter into many objects.

## Decision

1. **The editable document model is the single source of truth.** Layers own
   design objects (paths, shapes, text; later images and symbols). The Stitch
   IR is derived, disposable, regenerated from objects on demand — never
   stored in the document, never edited directly. (This codifies existing
   behavior as a rule.)

2. **`EmbroideryObject` gains multi-contour support** without a schema break:
   - `List<Path> get renderPaths` (default `[path]`) — geometry consumed by
     rendering, hit-testing, and stitch generation.
   - `Bounds bounds()` (default `path.bounds()`).
   - `EmbroideryObject transformedBy(Transform2)` (default
     `withPath(path.transformed(t))`) — commands transform objects through
     this, letting composite objects transform all contours.

3. **`TextObject` is a first-class editable object** (`type: 'text'` in the
   object registry): text string, font family, size, tracking, line height,
   alignment, optional frame width, stitch length — plus **cached glyph
   outlines** (`renderPaths`). One text element = one object in one layer.
   Outlines are derived data cached on the object so the domain layer never
   depends on the font engine (which lives above it in `studio_tools`);
   editing regenerates them. Double-click on a text object re-enters in-place
   editing; commit replaces the object (one undo step).

4. **Creation respects the active layer.** The active layer is derived from
   the selection (the selected layer, or the ancestor layer of the selected
   node; default layer only as fallback). All creation tools insert via
   `AddObject(parent: activeLayer)`.

5. **Stitch strategy stays on the object for the MVP.** `RunningStitchObject`
   / `SatinObject` / `FillObject` / `TextObject` carry their generation
   parameters; `generateStitches` dispatches on type. Splitting strategy from
   geometry (multiple strategies per object, strategy presets) is deferred
   until the satin/fill generators exist — the derived-stitches rule above is
   what keeps that refactor cheap.

## Schema impact

`.embproj` stays at version 2. `type: 'text'` is an additive object kind:
older files load unchanged; files containing text objects are unreadable by
pre-ADR builds (acceptable pre-release, consistent with ADR-027's no-migration
stance).

## Known gaps (tracked, not blocked on this ADR)

- Object properties panel edits text metadata but full typography editing
  goes through the canvas Text tool.
- Layer UX completeness (drag between layers, Move to Layer command,
  cut/paste across layers) rides on existing `MoveNode` — UI wiring is
  incremental work, not architecture.
- Images, symbols, kerning/shaping, satin/fill generators: future work that
  slots into `renderPaths`/`generateStitches` without further schema churn.

## Consequences

- Editing stays non-destructive end to end; any future stitch algorithm is a
  pure function of the document.
- Canvas, selection, transforms, and the digitizer consume `renderPaths` /
  `bounds()` instead of assuming one path per object.
- `docs/02-architecture/005-document-model.md` and
  `009-digitizer-pipeline.md` describe this relationship; UI docs on layers
  (04-ui) gain the active-layer rule.
