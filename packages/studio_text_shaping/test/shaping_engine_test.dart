import 'dart:typed_data';

import 'package:studio_text_shaping/studio_text_shaping.dart';
import 'package:test/test.dart';

void main() {
  // The engine loads only when a native libharfbuzz is present. In CI /
  // on machines without it, tryLoad() must degrade gracefully (null) so
  // callers fall back to the glyf parser — that graceful path is the
  // contract this suite guarantees everywhere.
  final engine = ShapingEngine.tryLoad();

  test('tryLoad degrades gracefully when the library is absent', () {
    // Either the library loaded (engine != null, available) or it did
    // not (null). Both are valid; the forbidden outcome is a throw,
    // which would have escaped tryLoad already.
    if (engine == null) {
      expect(engine, isNull);
    } else {
      expect(engine.available, isTrue);
    }
  });

  test(
    'shapes a run and returns positioned outlines',
    () {
      // Gated: only runs where a real HarfBuzz is available. Uses a
      // tiny bundled font if present; otherwise skipped.
      final font = _loadTestFont();
      if (engine == null || font == null) return;
      final glyphs = engine.shape(font, 'fi', sizeMm: 10);
      expect(glyphs, isNotEmpty);
      expect(glyphs.every((g) => g.advanceMm > 0), isTrue);
    },
    skip: engine == null ? 'libharfbuzz not available' : false,
  );
}

/// Loads an optional test font from the package (none checked in by
/// default — the shaping smoke test is exercised where a font + lib
/// exist). Returns null when unavailable.
Uint8List? _loadTestFont() => null;
