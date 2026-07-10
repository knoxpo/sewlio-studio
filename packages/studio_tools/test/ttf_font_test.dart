import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

/// First parseable TrueType file from the host's font dirs, or null
/// (tests skip on machines without one).
TtfTextFont? _anySystemFont() {
  const dirs = [
    '/System/Library/Fonts/Supplemental',
    '/System/Library/Fonts',
    '/usr/share/fonts/truetype',
    r'C:\Windows\Fonts',
  ];
  for (final dir in dirs) {
    final d = Directory(dir);
    if (!d.existsSync()) continue;
    final files = d.listSync(recursive: true).whereType<File>().where((f) =>
        f.path.toLowerCase().endsWith('.ttf') && f.lengthSync() < 10 << 20);
    for (final file in files) {
      final font = TtfTextFont.tryParse(file.readAsBytesSync());
      // Need Latin support for the assertions below.
      if (font != null && font.supports(0x41)) return font;
    }
  }
  return null;
}

void main() {
  final font = _anySystemFont();

  test('rejects non-TrueType bytes', () {
    expect(TtfTextFont.tryParse(Uint8List.fromList([1, 2, 3])), isNull);
    // 'OTTO' (CFF) is deliberately unsupported.
    final otto = Uint8List(16)..setAll(0, [0x4F, 0x54, 0x54, 0x4F]);
    expect(TtfTextFont.tryParse(otto), isNull);
  });

  test('parses a system font: family, metrics, outlines', () {
    if (font == null) {
      markTestSkipped('no parseable system TTF found');
      return;
    }
    expect(font.family, isNotEmpty);
    expect(font.advanceMm(0x41, 10), greaterThan(0));
    expect(
        font.advanceMm(0x41, 20), closeTo(font.advanceMm(0x41, 10) * 2, 1e-9));

    final paths = font.glyphPaths(0x41, Point.zero, 10);
    expect(paths, isNotEmpty);
    for (final path in paths) {
      expect(path.closed, isTrue);
      expect(path.segments, isNotEmpty);
    }
    // Glyph sits on the baseline, roughly em-sized.
    final bounds = paths.first.bounds();
    expect(bounds.maxY, lessThanOrEqualTo(1)); // above baseline (y up = -y)
    expect(bounds.minY, greaterThanOrEqualTo(-12));
  }, skip: font == null ? 'no parseable system TTF found' : false);

  test('lays out through the generic text pipeline', () {
    if (font == null) return;
    final paths = layoutText('AB', font, origin: Point.zero, sizeMm: 10);
    expect(paths.length, greaterThanOrEqualTo(2));
    final caret = layoutCaret('AB', font, origin: Point.zero, sizeMm: 10);
    expect(caret.x,
        closeTo(font.advanceMm(0x41, 10) + font.advanceMm(0x42, 10), 1e-9));
  }, skip: font == null ? 'no parseable system TTF found' : false);
}
