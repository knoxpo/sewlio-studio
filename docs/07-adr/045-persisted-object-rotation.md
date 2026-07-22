# ADR-045: Persisted Object Rotation (Oriented Selection Box)

## Status

Accepted

## Context

Transforms bake into object geometry (`transformedBy` →
`path.transformed`), and nothing stored an orientation. After a
rotate-handle drag the object looked right, but the selection box was
recomputed as the axis-aligned bounding box of the rotated geometry —
the current rotation silently became the new "zero". Rotating a second
time started from an axis-aligned box, and reselecting showed an
upright rectangle around a tilted object.

## Decision

- `EmbroideryObject` gains a persisted `rotationDeg` (base field,
  serialized as `rotation`, omitted when 0 — legacy documents load as
  axis-aligned). Geometry stays world-baked; the field only remembers
  orientation. Normalized to (-180, 180].
- `TransformSelection` gains `rotateDeg`: the Select tool declares how
  much of a drag's transform is rotation, and the handler accumulates
  it onto each object. Extracting the angle from an arbitrary affine
  matrix would be lossy (non-uniform scales alias as rotation), so the
  intent is explicit. Snapshot-based undo restores the field for free.
- The Select tool computes the transform box in the selection's own
  frame: `frameBounds` (geometry counter-rotated, then AABB) plus
  `boxTransform` (frame rotation with the live drag transform composed
  on top). Handles are hit-tested through the same mapping; resize is
  computed in frame coordinates and mapped back
  (`R · scale · R⁻¹`), so a rotated object scales along its own axes.
- The canvas painter already mapped box corners through a per-corner
  transform (used for the live-drag preview) and derives the rotation
  grip from the transformed top-edge normal — the persisted orientation
  reuses that channel unchanged.
- Multi-selections stay axis-aligned (Illustrator behavior); the
  oriented box applies to single selections.

## Deferred

- Oriented hit-testing and marquee overlap — both stay AABB-based
  (existing `ponytail:` note in `hitTest`).
- A rotation field in the Properties panel (X/Y/W/H stay world-AABB).
- Re-layout surfaces that regenerate geometry axis-aligned (text
  re-layout) resetting `rotationDeg` — pre-existing behavior.

## Consequences

- The selection box, handles, and rotation grip stay aligned with a
  rotated object across move/resize/re-rotate/undo/reselect.
- Document schema change is additive and backward compatible.
