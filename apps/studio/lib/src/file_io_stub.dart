import 'dart:typed_data';

Never _unsupported() =>
    throw UnsupportedError('File access is not available on this platform');

Future<String> readFileString(String path) async => _unsupported();

Future<void> writeFileString(String path, String content) async =>
    _unsupported();

Future<void> writeFileBytes(String path, Uint8List bytes) async =>
    _unsupported();

bool fileExists(String path) => false;
