# ADR-041: HarfBuzz Shaping Engine, Platform-Degraded

## Status

Accepted

## Context

The Character panel exposes OpenType features (ligatures, stylistic sets, small
caps, figures, swashes…), variable-font axes, kerning, and language/script-aware
shaping. The current font engine (`packages/studio_tools/lib/src/ttf_font.dart`,
`TtfTextFont`) is a hand-written TrueType-`glyf` parser: `glyf` outlines only, no
CFF/`.otf`, no kerning, no GSUB/GPOS, no variable fonts, Latin-only. Its own
`ponytail:` comment defers all of that to "a real shaping engine (HarfBuzz)."

Embroidery is the hard constraint: stitch generation consumes glyph **outline
contours** as `studio_geometry.Path` (ADR-028 — outlines are the derived cache).
`dart:ui`'s `Paragraph` shapes text beautifully (it uses HarfBuzz + ICU + Skia
internally) but only rasterizes/paints — it will not hand back per-glyph outline
contours. So we cannot delegate to the framework's text stack; we need a shaper
that yields both positioned glyph ids **and** their outlines.

Options:

1. **Pure-Dart shaper** — no OpenType-grade implementation exists; writing one
   (GSUB/GPOS state machines, variable interpolation, BiDi) is a research project.
   Rejected.
2. **`dart:ui` Paragraph** — shapes but yields no outlines. Rejected (above).
3. **HarfBuzz via `dart:ffi`** — HarfBuzz shapes (unicode + features + variations
   → glyph ids + advances + offsets) **and**, via its draw API
   (`hb_font_draw_glyph` / `hb_draw_funcs`, HB ≥ 7), emits move/line/quad/cubic
   for **both** `glyf` and CFF outlines, honoring active variation coordinates.
   One dependency replaces the hand parser and unlocks `.otf`, kerning, OpenType,
   and variable fonts. But `dart:ffi` is unavailable on Flutter web, and it
   requires bundling a native `libharfbuzz` per desktop platform.

## Decision

Introduce a new leaf package **`studio_text_shaping`** (Flutter layer, sits beside
`studio_tools` in the dependency ladder) providing `HarfBuzzTextFont`, a
`TextFont` implementation backed by `dart:ffi` HarfBuzz. It shapes runs and
extracts outlines to `Path` via the HB draw API. `studio_tools` depends on it; the
built-in `MonolineTextFont` (stroke font) is unchanged.

`TextFont` grows a **capabilities** surface so the panel enables/disables controls
from the real font, not guesses: `stylesFor(family)`, `variationAxes()`,
`availableFeatures()`, `supportsFeature(tag)`. Layout functions in `text_font.dart`
become run-aware and shape-aware (shape each style run, apply per-run affine
transforms, concatenate), replacing the raw per-rune advance loop.

**Platform degradation.** Native desktop (macOS/Windows/Linux) uses
`HarfBuzzTextFont`. On web (and when the native library fails to load), the engine
falls back to the existing `TtfTextFont` `glyf` parser, whose capabilities surface
reports empty — the panel then disables OpenType/variable/complex-script controls
with a "not available on this platform" tooltip (FR-200 §8: unsupported controls
are disabled with a clear reason). This mirrors the existing conditional-import
split (`font_io_native.dart` vs `font_io_stub.dart`). Font selection between the
two implementations lives behind a conditional import so web never links FFI.

## Consequences

- **New dependency + native bundling.** `libharfbuzz` ships per desktop platform;
  CI (`.github/workflows/ci.yml`) must provide it for the FFI-backed tests, which
  are gated to skip when the library is absent (headless/web runners fall back to
  the `glyf` path). No IR schema change — this is an engine swap behind
  `TextFont`; the `.swl` stores intent (features/axes as `CharAttrs`, ADR-040),
  never shaped glyph ids.
- **Downward-only deps hold** (`docs/02-architecture/018`): `studio_text_shaping`
  is a Flutter-layer leaf; `studio_tools` → `studio_text_shaping` is downward. The
  headless domain packages (`studio_embroidery`, `studio_geometry`) do not depend
  on it — the shaping result reaches them only as already-computed `Path` outlines
  cached on `TextObject` (ADR-028), so those packages stay headless-testable.
- **Determinism.** Same font bytes + same `CharAttrs` (features/axes/language) ⇒
  identical shaped outlines. Shaping happens in the tools layer; the digitizer
  still sees deterministic outlines, so Stitch IR determinism (NN, ADR-001) is
  preserved.
- **Web parity gap (accepted).** Web loses OpenType/variable/complex-script until
  a `harfbuzzjs`/WASM backend is added behind the same `TextFont` interface — a
  future, isolated workstream requiring no model change.
- CFF/`.otf` fonts, unsupported by the old parser, load on desktop.
