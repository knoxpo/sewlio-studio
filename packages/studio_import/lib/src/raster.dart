import 'dart:typed_data';

enum RasterFormat { png, jpeg }

/// An imported raster reference image. Pixels stay encoded — the UI
/// layer decodes for display; the engine only needs dimensions for
/// placement and scaling.
final class RasterAsset {
  const RasterAsset({
    required this.format,
    required this.width,
    required this.height,
    required this.bytes,
  });

  final RasterFormat format;
  final int width;
  final int height;
  final Uint8List bytes;

  /// Size in mm at [dpi] (default 96, the CSS reference density).
  double widthMm({double dpi = 96}) => width * 25.4 / dpi;
  double heightMm({double dpi = 96}) => height * 25.4 / dpi;
}

/// Imports a PNG or JPEG by sniffing the header for format and
/// dimensions. Throws [FormatException] on unrecognized or truncated
/// data — import is a trust boundary.
// ponytail: header sniffing only, no pixel decode — bring in a decoder
// package when auto-digitizing needs pixel access.
RasterAsset importRaster(Uint8List bytes) {
  if (bytes.length >= 24 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    // PNG: IHDR is always the first chunk; width/height at offset 16.
    final data = ByteData.sublistView(bytes);
    return RasterAsset(
      format: RasterFormat.png,
      width: data.getUint32(16),
      height: data.getUint32(20),
      bytes: bytes,
    );
  }
  if (bytes.length >= 4 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
    // JPEG: scan segments for a SOFn frame header carrying dimensions.
    var i = 2;
    while (i + 9 < bytes.length && bytes[i] == 0xFF) {
      final marker = bytes[i + 1];
      final length = (bytes[i + 2] << 8) | bytes[i + 3];
      final isSof = marker >= 0xC0 &&
          marker <= 0xCF &&
          marker != 0xC4 &&
          marker != 0xC8 &&
          marker != 0xCC;
      if (isSof) {
        return RasterAsset(
          format: RasterFormat.jpeg,
          height: (bytes[i + 5] << 8) | bytes[i + 6],
          width: (bytes[i + 7] << 8) | bytes[i + 8],
          bytes: bytes,
        );
      }
      i += 2 + length;
    }
    throw const FormatException('JPEG has no SOF frame header');
  }
  throw const FormatException('Unrecognized raster format (need PNG/JPEG)');
}
