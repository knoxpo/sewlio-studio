import 'dart:typed_data';

import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_import/studio_import.dart';
import 'package:test/test.dart';

void main() {
  group('raster import', () {
    test('reads PNG dimensions from IHDR', () {
      final png = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // signature
        0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
        0x00, 0x00, 0x01, 0x90, // width 400
        0x00, 0x00, 0x00, 0xC8, // height 200
        0x08, 0x02, 0x00, 0x00, 0x00,
      ]);
      final asset = importRaster(png);
      expect(asset.format, RasterFormat.png);
      expect((asset.width, asset.height), (400, 200));
      expect(asset.widthMm(), closeTo(400 * 25.4 / 96, 1e-9));
    });

    test('reads JPEG dimensions from SOF0', () {
      final jpeg = Uint8List.fromList([
        0xFF, 0xD8, // SOI
        0xFF, 0xE0, 0x00, 0x04, 0x00, 0x00, // APP0, length 4
        0xFF, 0xC0, 0x00, 0x0B, 0x08, // SOF0, precision
        0x00, 0x64, // height 100
        0x00, 0xC8, // width 200
        0x03, 0x01, 0x00, 0x00,
      ]);
      final asset = importRaster(jpeg);
      expect(asset.format, RasterFormat.jpeg);
      expect((asset.width, asset.height), (200, 100));
    });

    test('rejects unknown or truncated data', () {
      expect(() => importRaster(Uint8List.fromList([1, 2, 3])),
          throwsFormatException);
      expect(() => importRaster(Uint8List.fromList([0xFF, 0xD8, 0x00, 0x00])),
          throwsFormatException);
    });
  });

  group('svg import', () {
    test('parses absolute M/L/Z into a closed mm path', () {
      final paths = parseSvgPathData('M 0 0 L 96 0 L 96 96 Z');
      expect(paths, hasLength(1));
      final path = paths.single;
      expect(path.closed, isTrue);
      expect(path.start, Point.zero);
      // 96 px = 25.4 mm.
      expect(
          path.segments.cast<LineSegment>().last.end, const Point(25.4, 25.4));
    });

    test('parses relative commands, H/V, and cubics', () {
      final paths =
          parseSvgPathData('m 96 96 h 96 v 96 c 0 96 96 96 96 0 l -96 -96');
      final path = paths.single;
      expect(path.start, const Point(25.4, 25.4));
      expect(path.segments, hasLength(4));
      expect(path.segments[2], isA<CubicSegment>());
      final cubic = path.segments[2] as CubicSegment;
      // (288,192) px → (76.2, 50.8) mm, within float accumulation.
      expect(cubic.end.almostEquals(const Point(76.2, 50.8), tolerance: 1e-9),
          isTrue);
      expect(path.segments[3], isA<LineSegment>());
    });

    test('multiple subpaths and implicit lineto after M', () {
      final paths = parseSvgPathData('M0 0 96 0 M 0 96 L 96 96');
      expect(paths, hasLength(2));
      expect(paths[0].segments.single, isA<LineSegment>());
      expect(paths[1].start, const Point(0, 25.4));
    });

    test('extracts d attributes from an SVG document', () {
      const svg = '''
        <svg xmlns="http://www.w3.org/2000/svg">
          <path fill="red" d="M0 0 L96 0"/>
          <path d="M0 96 L96 96 Z"/>
        </svg>''';
      final paths = importSvg(svg);
      expect(paths, hasLength(2));
      expect(paths[1].closed, isTrue);
    });

    test('rejects unsupported commands', () {
      expect(() => parseSvgPathData('M0 0 A 5 5 0 0 1 10 10'),
          throwsFormatException);
    });
  });
}
