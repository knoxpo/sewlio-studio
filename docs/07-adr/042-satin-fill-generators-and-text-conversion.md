# ADR-042: Satin & Fill Stitch Generators and Text→Stitch Conversion

## Status

Accepted

## Context

Two capabilities were missing. First, `SatinObject` and `FillObject` existed in
the model but their stitch generators threw `UnimplementedError`
(`packages/studio_embroidery/lib/src/running_stitch.dart`), so only running
stitch (and text as outline running stitch) reached the Stitch IR. Second, a
`TextObject` could only ever stitch as outline lettering; there was no way to
turn it into editable stitch objects or choose a stitch type — the spec'd but
unbuilt UC-007 / UC-008 ("Convert to Running Stitch" / "Convert Closed Shape to
Fill Stitch").

Filling glyphs with counters ('O', 'A', 'e') correctly requires an even-odd
rule across the glyph's contour set, but `FillObject` held a single boundary
`path` with no way to express holes.

## Decision

**Satin generator** (`satin.dart`): `generateSatin(path, {width, density})`
walks the centerline polyline, stepping ~`density` mm, and emits needle points
alternating `±width/2` along the local perpendicular — a zig-zag column.
Deterministic; the final column lands on the path end. `SatinObject` digitizes
through it.

**Fill generator** (`fill.dart`): `generateFill(boundaries, {spacing, angleDeg})`
rotates the contour set by `-angle`, scans horizontal rows spaced `spacing`,
computes x-crossings against every boundary edge, and fills between crossings
under the **even-odd** rule (holes stay empty), connecting rows boustrophedon
and rotating points back. Rows stitch via the existing running-stitch
resampler. Deterministic (fixed scan order, no randomness).

**`FillObject.holes`**: an additive `List<Path>` (default `const []`).
`renderPaths => [path, ...holes]`; the fill generator receives `[path,
...holes]` and applies even-odd. Serialized as `'holes'` only when non-empty.

**`ConvertToStitch(objectId, target)`** command (`target ∈ {running, satin,
fill}`): reads a `TextObject`'s cached glyph `outlines` and replaces it with
editable stitch objects — one `RunningStitchObject`/`SatinObject` per contour
for running/satin (grouped), or a single `FillObject` (first contour as `path`,
the rest as `holes`) for fill — removing the text, as one undoable step.

New text is committed with a default fill (`StrokeProps(fillHex, colorHex)`) so
a real (TTF, closed-contour) font renders as solid glyphs; the single-stroke
Monoline font has no interior and stays an outline skeleton.

## Consequences

- **Document IR change (`.swl`)**: additive and optional. `FillObject.holes`
  writes only when non-empty; old documents load with no holes; `fromJson`
  ignores unknown keys. **No format version bump.**
- **Stitch IR ownership unchanged**: the new generators live in
  `studio_embroidery` (the Stitch IR owner) and emit only `StitchOp`s. Same
  geometry + params ⇒ identical ops, preserving determinism (ADR-001) and the
  golden-fixture contract.
- Satin for converted text traces each glyph *contour* as a satin border, not
  medial-axis satin columns (a skeletonizer is future work).
- Fill uses the even-odd rule, matching the renderer's fill of the same
  contours, so on-screen preview and stitched output agree on which regions are
  solid.
- Converting a `TextObject` is destructive of the editable text (it becomes
  geometry); undo restores it via the command's captured-snapshot reverse.
