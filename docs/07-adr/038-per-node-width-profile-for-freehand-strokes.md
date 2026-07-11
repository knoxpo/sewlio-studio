# ADR-038: Per-Node Width Profile for Freehand Strokes

## Status

Accepted

## Context

Tablet support (Tier 2, platform-requirements §10–12) requires Apple Pencil / S Pen
pressure to produce pressure-varying stroke widths from the Pencil (freehand) tool.
Today an `EmbroideryObject` carries a single `StrokeProps.widthMm`; geometry (`Path`)
carries no width at all. Live pressure needs a persisted, per-point width so a stroke
drawn light-to-heavy renders (and later stitches) thin-to-thick.

Where could the width live?

1. **In `Path`/`Segment` (geometry)** — pollutes the core primitive every consumer
   touches (bounds, transforms, flattening, pen/node editing, exporters). Width is a
   stroke attribute, not geometry.
2. **In `StrokeProps`** — shared by every object type; a per-node list only makes
   sense for polyline freehand strokes.
3. **On `RunningStitchObject`** — the only object the Pencil tool creates; scoped,
   optional, and adjacent to the existing per-type stitch parameters.

## Decision

`RunningStitchObject` gains an optional `List<double>? widthProfile` — one width in
**mm per path node** (start point + each segment end, so
`widthProfile.length == segments.length + 1`). Serialized as a `'widthProfile'` JSON
array only when non-null. `withPath` keeps the profile when the node count is
unchanged (transforms) and drops it otherwise (node editing invalidates the mapping).

The canvas renders a profiled stroke as per-segment strokes with round caps,
interpolating width between nodes. Stitch generation ignores the profile for now;
the future satin generator may consume it (same deferral as `StrokeProps.widthMm`).

Pressure capture: the Pencil tool samples normalized stylus pressure (0–1) per trace
point and hands them to the shell, which maps them onto mm widths
(`widthMm * lerp(minFactor, 1, pressure)`) only when the stroke style's
`PressureProfile.pressure` is active. Velocity profiles remain unimplemented
(they were already declared-but-inactive defaults).

## Consequences

- **Document IR change (`.swl`)**: additive and optional. Old documents load
  unchanged; documents containing `widthProfile` degrade to a uniform-width stroke
  in older builds because `fromJson` reads by key and ignores unknown fields.
  No format version bump needed.
- RDP simplification must decimate widths in lockstep with points:
  `simplifyPolylineIndices` (geometry) returns kept indices; `simplifyPolyline`
  is reimplemented on top of it, unchanged for existing callers.
- Node editing a profiled stroke drops the profile (uniform width) rather than
  guessing widths for edited nodes — predictable, and re-drawable.
