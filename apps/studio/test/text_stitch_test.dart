import 'package:flutter_test/flutter_test.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  test('text digitizes per glyph part: no drawn segment crosses glyphs', () {
    const font = MonolineTextFont();
    final outlines =
        layoutText('Knoxpo', font, origin: const Point(0, 0), sizeMm: 10);
    // Each glyph part is its own outline — the decomposition the stitch
    // generator walks (trim + jump between parts).
    expect(outlines.length, greaterThanOrEqualTo(6));
    final object = TextObject(
      id: const Id('t1'),
      path: Path(start: const Point(0, 0)),
      text: 'Knoxpo',
      fontFamily: font.family,
      outlines: outlines,
    );
    final ops = generateStitches(object);
    expect(ops.where((o) => o.kind == StitchKind.jump).length,
        outlines.length - 1);
    // Consecutive drawn stitches never span between glyphs: anything
    // longer than a stitch is a broken letterform.
    for (var i = 1; i < ops.length; i++) {
      if (ops[i].kind != StitchKind.stitch ||
          ops[i - 1].kind != StitchKind.stitch) {
        continue;
      }
      expect(ops[i].position.distanceTo(ops[i - 1].position),
          lessThanOrEqualTo(2.5 + 0.05),
          reason: 'drawn segment at op $i leaves its glyph part');
    }
  });
}
