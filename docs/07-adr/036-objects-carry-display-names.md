# ADR-036: Objects Carry Display Names

## Status

Accepted

## Context

The Layers panel represents the editable document model, while the
Stitches panel represents generated embroidery execution (ADR-028).
Until now design objects had no user-facing identity: the UI derived
labels from the stitch generator kind ("Running Stitch", "Satin
Stitch"), leaking execution vocabulary into the document hierarchy and
making objects impossible to rename.

Professional vector tools name document objects by their design origin
(`<Rectangle>`, `<Path>`, `<Text>`) and let users rename them freely.

## Decision

- `EmbroideryObject` gains an optional `name` field (`String?`),
  serialized into the project format as `name` (omitted when null).
  The field is preserved through every object copy path (`withPath`,
  `withStroke`, `transformedBy`, subtree duplication).
- A null name means "use the derived default": `<Text>` for text
  objects, `<Path>` otherwise. Creation tools may set a more specific
  default (the Shape tool stamps `<Rectangle>`, `<Ellipse>`, …).
- Renaming is a plain `ReplaceObject` with `object.withName(...)` — no
  new command; undo/redo and events come for free.
- Stitch-kind vocabulary (Running/Satin/Fill…) remains exclusive to
  stitch-facing surfaces (Stitches panel, simulation, export).

## Consequences

- Project format is extended additively (`name` optional) — older
  files load unchanged; older readers ignore the extra key. No format
  version bump needed.
- The Layers panel reads/writes names; anything else referencing an
  object continues to work because identity is still the `Id`.
- Groups and layers already had names; the document model is now
  uniformly nameable.
