import 'dart:io';
import 'dart:isolate';

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

/// Scans installed TrueType fonts → display name → file path. Runs in
/// an isolate: reading/parsing hundreds of font files off the UI
/// thread.
// ponytail: files over 30 MB (giant CJK collections) are skipped to
// keep the scan quick; CFF `.otf` is skipped by the parser. Stream the
// name table with RandomAccessFile if the full-read scan ever feels
// slow.
Future<Map<String, String>> scanSystemFontFamilies() {
  return Isolate.run(() {
    final families = <String, String>{};
    for (final dir in _fontDirs()) {
      final files =
          dir.listSync(recursive: true, followLinks: false).whereType<File>();
      for (final file in files) {
        final name = file.path.toLowerCase();
        if (!name.endsWith('.ttf') && !name.endsWith('.ttc')) continue;
        try {
          if (file.lengthSync() > 30 * 1024 * 1024) continue;
          final font = TtfTextFont.tryParse(file.readAsBytesSync());
          if (font != null && font.family.isNotEmpty) {
            families.putIfAbsent(font.family, () => file.path);
          }
        } catch (_) {
          // Unreadable/malformed file — skip.
        }
      }
    }
    return families;
  });
}

Future<TextFont?> loadFontFile(String path) async =>
    TtfTextFont.tryParse(await File(path).readAsBytes());
