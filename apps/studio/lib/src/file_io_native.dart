import 'dart:io';
import 'dart:typed_data';

Future<String> readFileString(String path) => File(path).readAsString();

Future<void> writeFileString(String path, String content) =>
    File(path).writeAsString(content);

Future<void> writeFileBytes(String path, Uint8List bytes) =>
    File(path).writeAsBytes(bytes);

bool fileExists(String path) => File(path).existsSync();

void ensureParentDir(String path) =>
    File(path).parent.createSync(recursive: true);

/// Per-user application-state directory file, or null when the home
/// directory is unknown.
String? appStatePath(String fileName) {
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  return home == null ? null : '$home/.sewlio_studio/$fileName';
}
