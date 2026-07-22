import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:test/test.dart';

void main() {
  group('CharAttrs', () {
    test('merge lets patch win, unions maps', () {
      const base = CharAttrs(
        fontFamily: 'Arial',
        sizeMm: 10,
        openTypeFeatures: {'liga': 1},
      );
      const patch = CharAttrs(
        sizeMm: 20,
        openTypeFeatures: {'smcp': 1},
      );
      final merged = base.merge(patch);
      expect(merged.fontFamily, 'Arial');
      expect(merged.sizeMm, 20);
      expect(merged.openTypeFeatures, {'liga': 1, 'smcp': 1});
    });

    test('isEmpty and hasOverrides', () {
      expect(CharAttrs.empty.isEmpty, isTrue);
      const styled = CharAttrs(styleId: 's1');
      expect(styled.isEmpty, isFalse);
      expect(styled.hasOverrides, isFalse); // only styleId set
      const overriding = CharAttrs(styleId: 's1', sizeMm: 14);
      expect(overriding.hasOverrides, isTrue);
    });

    test('json round-trip', () {
      const attrs = CharAttrs(
        fontFamily: 'Inter',
        styleName: 'Bold',
        sizeMm: 12.5,
        fillHex: '#112233',
        trackingMm: 0.2,
        baselineShiftMm: -1,
        hScale: 1.2,
        skewDeg: 10,
        decorations: TextDecorations(lines: {TextDecorationLine.underline}),
        openTypeFeatures: {'liga': 1},
        variableAxes: {'wght': 700},
        language: 'en-IN',
      );
      final back = CharAttrs.fromJson(attrs.toJson());
      expect(back, attrs);
    });
  });

  group('run normalization', () {
    test('coalesces adjacent equal runs, drops empties', () {
      const a = CharAttrs(styleName: 'Bold');
      final runs = normalizeRuns(
        [const StyleRun(0, 2, a), const StyleRun(2, 2, a)],
        4,
      );
      expect(runs, [const StyleRun(0, 4, a)]);
    });

    test('later run wins on overlap', () {
      const bold = CharAttrs(styleName: 'Bold');
      const italic = CharAttrs(styleName: 'Italic');
      final runs = normalizeRuns(
        [const StyleRun(0, 4, bold), const StyleRun(2, 2, italic)],
        4,
      );
      expect(runs, [const StyleRun(0, 2, bold), const StyleRun(2, 2, italic)]);
    });

    test('clamps out-of-range runs', () {
      const a = CharAttrs(sizeMm: 20);
      final runs = normalizeRuns([const StyleRun(2, 10, a)], 4);
      expect(runs, [const StyleRun(2, 2, a)]);
    });
  });

  group('applyPatchToRange', () {
    test('applies only to range and merges existing', () {
      const bold = CharAttrs(styleName: 'Bold');
      var runs = <StyleRun>[];
      runs = applyPatchToRange(runs, 5, 1, 4, bold);
      expect(runs, [const StyleRun(1, 3, bold)]);
      // Now recolor a sub-range; existing bold stays, fill added.
      const red = CharAttrs(fillHex: '#ff0000');
      runs = applyPatchToRange(runs, 5, 2, 3, red);
      expect(attrsAtOffset(runs, 1), bold);
      expect(attrsAtOffset(runs, 2), bold.merge(red));
      expect(attrsAtOffset(runs, 3), bold);
    });
  });

  group('queryRange (mixed values)', () {
    test('reports mixed where runs disagree, shared where equal', () {
      const defaults = CharAttrs(fontFamily: 'Arial', sizeMm: 10);
      // chars 0-1 default, 2-3 bold+size20
      const patch = CharAttrs(styleName: 'Bold', sizeMm: 20);
      final runs = applyPatchToRange(const [], 4, 2, 4, patch);
      final q = queryRange(runs, defaults, 0, 4);
      expect(q.mixed, contains('sizeMm'));
      expect(q.mixed, contains('styleName'));
      // fontFamily is Arial across the whole range -> shared
      expect(q.mixed.contains('fontFamily'), isFalse);
      expect(q.shared.fontFamily, 'Arial');
    });

    test('uniform range has no mixed fields', () {
      const defaults = CharAttrs(fontFamily: 'Arial', sizeMm: 10);
      final q = queryRange(const [], defaults, 0, 3);
      expect(q.mixed, isEmpty);
      expect(q.shared.sizeMm, 10);
    });
  });

  group('TextObject runs', () {
    TextObject textObj({List<StyleRun> runs = const []}) => TextObject(
          id: Id('t1'),
          path: Path(start: Point(0, 0), segments: [LineSegment(Point(10, 0))]),
          text: 'hello',
          fontFamily: 'Arial',
          runs: runs,
        );

    test('withRangeAttrs applies to range', () {
      final t = textObj().withRangeAttrs(0, 2, const CharAttrs(sizeMm: 20));
      expect(t.attrsAt(0).sizeMm, 20);
      expect(t.attrsAt(3).sizeMm, 10); // object default
    });

    test('json round-trip preserves runs; legacy loads as no runs', () {
      final t = textObj(runs: [const StyleRun(0, 2, CharAttrs(sizeMm: 20))]);
      final back = EmbroideryObject.fromJson(t.toJson()) as TextObject;
      expect(back.runs, t.runs);

      final legacy = Map<String, dynamic>.from(t.toJson())..remove('runs');
      final loaded = EmbroideryObject.fromJson(legacy) as TextObject;
      expect(loaded.runs, isEmpty);
      expect(loaded.text, 'hello');
    });
  });
}
