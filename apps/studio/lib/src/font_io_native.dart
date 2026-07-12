import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:studio_tools/studio_tools.dart';

/// OS font directories, existing ones only.
List<Directory> _fontDirs() {
  final home = Platform.environment['HOME'] ?? '';
  final candidates = Platform.isMacOS
      ? [
          '/System/Library/Fonts',
          '/System/Library/Fonts/Supplemental',
          '/Library/Fonts',
          '$home/Library/Fonts',
        ]
      : Platform.isWindows
          ? [r'C:\Windows\Fonts']
          : [
              '/usr/share/fonts',
              '/usr/local/share/fonts',
              '$home/.fonts',
              '$home/.local/share/fonts',
            ];
  return [
    for (final path in candidates)
      if (Directory(path).existsSync()) Directory(path),
  ];
}

/// Scans installed TrueType fonts → family (nameID 1) → style
/// subfamily (nameID 2) → file path, grouping Bold/Italic faces under
/// their family. Runs in an isolate: reading/parsing hundreds of font
/// files off the UI thread.
// ponytail: files over 30 MB (giant CJK collections) are skipped to
// keep the scan quick; CFF `.otf` is skipped by the parser. Stream the
// name table with RandomAccessFile if the full-read scan ever feels
// slow.
Future<Map<String, Map<String, String>>> scanSystemFontFamilies() {
  return Isolate.run(() {
    final families = <String, Map<String, String>>{};
    for (final dir in _fontDirs()) {
      final files =
          dir.listSync(recursive: true, followLinks: false).whereType<File>();
      for (final file in files) {
        final name = file.path.toLowerCase();
        if (!name.endsWith('.ttf') && !name.endsWith('.ttc')) continue;
        try {
          if (file.lengthSync() > 30 * 1024 * 1024) continue;
          final bytes = file.readAsBytesSync();
          // Every face of a collection — macOS ships Bold/Italic faces
          // inside `.ttc` files, not as separate files.
          final faces = TtfTextFont.faceCount(bytes);
          for (var i = 0; i < faces; i++) {
            final font = TtfTextFont.tryParse(bytes, faceIndex: i);
            if (font != null && font.family.isNotEmpty) {
              families
                  .putIfAbsent(font.family, () => {})
                  .putIfAbsent(font.styleName, () => facePath(file.path, i));
            }
          }
        } catch (_) {
          // Unreadable/malformed file — skip.
        }
      }
    }
    return families;
  });
}

/// Encodes a face inside a collection as 'path::N' (plain path for
/// face 0) — the scan's map values, decoded by [loadFontFile].
String facePath(String path, int faceIndex) =>
    faceIndex == 0 ? path : '$path::$faceIndex';

(String, int) _decodeFacePath(String path) {
  final match = RegExp(r'^(.*)::(\d+)$').firstMatch(path);
  return match == null
      ? (path, 0)
      : (match.group(1)!, int.parse(match.group(2)!));
}

Future<TextFont?> loadFontFile(String path) async {
  final (file, face) = _decodeFacePath(path);
  return TtfTextFont.tryParse(await File(file).readAsBytes(),
      faceIndex: face);
}

/// Raw font-file bytes, for registering a preview face with Flutter.
Future<Uint8List?> loadFontBytes(String path) async {
  try {
    final (file, _) = _decodeFacePath(path);
    return await File(file).readAsBytes();
  } catch (_) {
    return null;
  }
}
