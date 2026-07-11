/// HarfBuzz-backed text shaping and glyph-outline extraction (ADR-041).
///
/// Shapes Unicode text with OpenType features and variable-font axes and
/// returns positioned glyph outlines as `studio_geometry` paths in mm, so
/// the embroidery pipeline stitches shaped text like any other contour.
/// Degrades gracefully: [ShapingEngine.tryLoad] returns null when the
/// native library is unavailable (web, or desktop without libharfbuzz),
/// and callers fall back to the pure Dart glyf parser.
library;

export 'src/shaping_engine.dart' show ShapingEngine, ShapedGlyph, AxisInfo;
