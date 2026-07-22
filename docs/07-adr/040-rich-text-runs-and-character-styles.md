# ADR-040: Rich-Text Style Runs and Character Styles

## Status

Accepted

## Context

The Character panel (UI-405 / FR-200 Text Tool) targets professional typography:
select a character range and format only that range (font, weight, size, color,
decorations, kerning/tracking, baseline shift, scale, skew, rotation, OpenType
features, variable-font axes, language). Today a `TextObject`
(`packages/studio_embroidery/lib/src/objects.dart`) carries scalar typography
that applies to the **whole string**: one `fontFamily`, one `sizeMm`, one
`trackingMm`, one `alignment`. There is no way to represent "these three
characters are bold" — the model has no notion of a sub-string span.

Range formatting needs a per-range attribute container plus a mapping from
character offsets to attributes. Reusable **character styles** (named formatting
applied to a range, with per-run overrides) additionally need a document-level
table the runs can reference.

Where could per-range attributes live?

1. **On `Path`/geometry** — text has no glyphs at the geometry layer (only cached
   outlines); spans are a text concept, not a geometry one. Rejected (same reason
   ADR-038 kept width off `Path`).
2. **A parallel `List<TextSpan>` replacing `text`** — forces every reader to walk
   spans even when unstyled, and breaks the plain-string invariant the caret,
   wrap, and glyph-inspection code relies on.
3. **Keep `text` as the source string; add an ordered `runs` list keyed by
   character offset** — the string stays authoritative for editing/caret/wrap;
   runs are an optional overlay. Unstyled text = zero or one default run.

## Decision

`TextObject` keeps `text` (and its existing scalar fields as the object-level
defaults) and gains:

- `CharAttrs` — an immutable value type of **optional** typography fields
  (`fontFamily?`, `styleName?`, `sizeMm?`, `fillHex?`, `strokeHex?`,
  `trackingMm?`, `baselineShiftMm?`, `hScale?`, `vScale?`, `skewDeg?`,
  `rotationDeg?`, `decorations` set, `openTypeFeatures` map, `variableAxes` map,
  `language?`, `script?`, `styleId?`). Every field is nullable/defaulted so
  "unset ⇒ inherit the object (or referenced character style) default" is
  representable. This nullability is what drives **mixed-value** display
  (a field is `Mixed` when runs over the selection disagree) and **override**
  display (a run with a `styleId` and any non-null field is overriding that style).
- `StyleRun` = `(int start, int length, CharAttrs attrs)`. `TextObject.runs` is a
  normalized `List<StyleRun>`: sorted by `start`, non-overlapping, gaps allowed
  (a gap inherits object defaults), adjacent runs with equal attrs coalesced.
  Helpers: `attrsAt(offset)`, `applyToRange(start, end, patch)` (returns a new
  normalized run list), and `runsForRange(start, end)` (per field: the shared
  value or a `Mixed` sentinel).
- `CharacterStyle` = `(String id, String name, CharAttrs base)`. The `Document`
  gains an optional `characterStyles` list (the style table). A run references a
  style by `CharAttrs.styleId`; fields set on the run **override** the style's
  `base`; clearing overrides resets those fields to null.

Applying attributes to a range, applying/creating/updating character styles, and
clearing overrides all flow through commands (ADR-003 / NN #3) — see ADR-041's
sibling and `studio_document` command additions; the panel only captures intent.
Outlines regenerate from the run-aware layout after any geometry-affecting change.

## Consequences

- **Document IR change (`.swl`)**: additive and optional. `toJson` writes
  `'runs'` only when a text object has non-default runs, and `'characterStyles'`
  on the document only when non-empty. Old documents load as a single implicit
  default run (the existing scalar fields); newer documents open in older builds
  as uniform text because `fromJson` reads by key and ignores unknown fields.
  **No format version bump.**
- The scalar fields (`fontFamily`, `sizeMm`, `trackingMm`, `alignment`) remain the
  **object-level defaults**; runs override per range. Whole-object editing (no
  active range) still edits the scalars. This keeps back-compat and the existing
  toolbar/inspector working unchanged.
- Run offsets are character (rune) offsets into `text`. Any edit that inserts or
  deletes runes must shift/split runs in lockstep (the Text tool's insert/delete
  ops own this), exactly as ADR-038's width profile decimates in lockstep with
  points. Structural text edits that cannot preserve the mapping collapse to the
  object defaults rather than guessing.
- Character styles are document-scoped shared resources; deleting a style leaves
  referencing runs with their resolved attrs inlined (no dangling `styleId`).
