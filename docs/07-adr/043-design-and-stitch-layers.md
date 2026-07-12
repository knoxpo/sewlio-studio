# ADR-043: Design Layers and Stitch Layers

## Status

Accepted

## Context

Sewlio conflated the vector and stitch abstractions: drawing a shape immediately
created a `RunningStitchObject`, text auto-digitized to outline lettering, and the
Stitch view digitized *every* visible object. There was no notion of a pure
"design" surface (vector fill/stroke, Illustrator/Affinity-style) distinct from a
"stitch" surface where elements are turned into stitch forms and their stitch type
chosen. Users expect two abstractions: a **design layer** they author vector art
on, and a **stitch layer** that sits on top and converts design elements into
stitches.

The obvious model — a new `VectorObject` type separate from stitch objects — would
force exhaustive updates to every `switch (object)` (JSON, generators, painter,
inspectors) and break the many tests and flows that assume a drawn object. That is
a large, high-churn change for the outcome required.

## Decision

Draw the design/stitch distinction at the **layer** level, not the object type.

- `LayerNode` gains `LayerKind { design, stitch }` (additive, default `design`;
  serialized only when `stitch`). Design layers hold vector art; stitch layers
  hold generated stitch objects.
- The digitizer and Stitch view consume **stitch-layer objects only**
  (`Document.flattenVisibleStitchObjects`); the design view keeps rendering all
  objects as vector (fill/stroke). Design-layer elements are therefore *not*
  stitched until converted.
- Convert (`convertTextToStitches`, extendable to shapes) no longer replaces the
  source. It creates the stitch objects on the document's stitch layer (creating
  one named "Stitches" if absent) and **keeps** the design element — the stitch
  layer sits on top of the design layer. One undoable step.

An object's concrete subclass (`RunningStitchObject`/`SatinObject`/`FillObject`)
still encodes its stitch type; a design-layer object simply isn't digitized, so
any stitch params it carries are inert there.

## Consequences

- **Document IR change (`.swl`)**: additive — `LayerKind` writes only for stitch
  layers; old documents load as all-design. `fromJson` defaults to `design`. **No
  version bump.**
- **Behaviour change**: a freshly drawn shape or typed text is a *design* element
  and does not appear as stitches until converted onto a stitch layer. This is the
  intended two-abstraction workflow; tests and flows that assumed "draw ⇒
  stitchable" now go through convert.
- **Minimal churn** vs. a new object type: no new `switch` arm, no generator or
  painter changes for a new type. The distinction is one enum + a digitize filter
  + convert targeting a stitch layer.
- **Deferred**: a live source→stitch link (`sourceId`, re-convert on design edit)
  is future work; convert is a one-shot copy today.
