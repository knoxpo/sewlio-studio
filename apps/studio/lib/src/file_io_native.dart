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

/// App-state base directory override for platforms where HOME is
/// wrong or unset (iOS/Android): `main()` sets it from path_provider
/// before any store is constructed, keeping [appStatePath] sync.
String? appStateBaseDirOverride;

/// Per-user application-state directory file, or null when the home
/// directory is unknown.
String? appStatePath(String fileName) {
  if (appStateBaseDirOverride != null) {
    return '$appStateBaseDirOverride/$fileName';
  }
  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  return home == null ? null : '$home/.sewlio_studio/$fileName';
}
