import 'dart:io';
import 'dart:typed_data';

Future<String> readFileString(String path) => File(path).readAsString();

Future<void> writeFileString(String path, String content) =>
    File(path).writeAsString(content);

Future<void> writeFileBytes(String path, Uint8List bytes) =>
    File(path).writeAsBytes(bytes);

bool fileExists(String path) => File(path).existsSync();
