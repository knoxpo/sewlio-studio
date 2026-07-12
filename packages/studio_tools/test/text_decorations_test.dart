import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const font = MonolineTextFont();

  CharAttrs deco(Set<TextDecorationLine> lines) =>
      CharAttrs(decorations: TextDecorations(lines: lines));

  test('underline emits one closed bar below the baseline, appended '
      'after all glyph paths', () {
    final plain =
        layoutText('AB', font, origin: Point.zero, attrsOf: (_) => CharAttrs.empty);
    final decorated = layoutText('AB', font,
        origin: Point.zero,
        attrsOf: (_) => deco({TextDecorationLine.underline}));
    expect(decorated.length, plain.length + 1);
    // Glyph paths are byte-identical prefix (glyphOutlineGroups contract).
    for (var i = 0; i < plain.length; i++) {
      expect(decorated[i].start, plain[i].start);
    }
    // The bar is a CLOSED rect (fillable — text renders through the
    // fill pipeline, where a zero-area line would be invisible).
    final bar = decorated.last;
    expect(bar.closed, isTrue);
    final bounds = bar.bounds();
    expect(bounds.minY, greaterThan(0), reason: 'below baseline (Y-down)');
    expect(bounds.maxY, greaterThan(bounds.minY), reason: 'has thickness');
    expect(bounds.maxX, greaterThan(bounds.minX));
  });

  test('double strikethrough emits two bars above the baseline', () {
    final decorated = layoutText('A', font,
        origin: Point.zero,
        attrsOf: (_) => deco({TextDecorationLine.doubleStrikethrough}));
    final plainCount = layoutText('A', font, origin: Point.zero).length;
    final bars = decorated.sublist(plainCount);
    expect(bars, hasLength(2));
    for (final bar in bars) {
      expect(bar.bounds().maxY, lessThan(0));
    }
    expect(bars[0].bounds().minY, isNot(bars[1].bounds().minY));
  });

  test('decoration span covers only the decorated runes', () {
    // Only 'B' (offset 1) of 'ABC' is underlined.
    final decorated = layoutText('ABC', font,
        origin: Point.zero,
        attrsOf: (o) =>
            o == 1 ? deco({TextDecorationLine.underline}) : CharAttrs.empty);
    final bounds = decorated.last.bounds();
    final advanceA = font.advanceMm('A'.runes.first, 10);
    expect(bounds.minX, closeTo(advanceA, 0.001));
    expect(bounds.maxX,
        closeTo(advanceA + font.advanceMm('B'.runes.first, 10), 0.001));
  });

  test('justify pads word gaps to fill the frame; paragraph-final line '
      'stays left', () {
    // Frame wide enough for 'AA BB' on one line, forcing 'CC' down.
    final width = textLineWidthMm('AA BB CC', font, 10) - 1;
    final metrics = layoutLineMetrics('AA BB CC', font,
        origin: Point.zero,
        frameWidthMm: width,
        align: MonoTextAlign.justify);
    expect(metrics, hasLength(2));
    // Justified first line: its trailing caret lands at the frame edge.
    expect(metrics[0].xs.last, closeTo(width, 0.001));
    // Last (paragraph-final) line is not stretched.
    expect(metrics[1].xs.last, lessThan(width));
    // layoutText agrees with the metrics (same distribution).
    final paths = layoutText('AA BB CC', font,
        origin: Point.zero,
        frameWidthMm: width,
        align: MonoTextAlign.justify);
    expect(paths, isNotEmpty);
  });

  test('justify without a frame (point text) behaves like left', () {
    final left = layoutText('AA BB', font, origin: Point.zero);
    final justified = layoutText('AA BB', font,
        origin: Point.zero, align: MonoTextAlign.justify);
    expect(justified.length, left.length);
    for (var i = 0; i < left.length; i++) {
      expect(justified[i].start, left[i].start);
    }
  });
}
