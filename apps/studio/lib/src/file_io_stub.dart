import 'package:flutter/foundation.dart';

Never _unsupported() =>
    throw UnsupportedError('File access is not available on this platform');

/// Read a file from the File System Access API.
/// [path] can be a string path (for format compatibility) or a serialized handle reference.
/// Throws if FSA not available or handle is invalid.
Future<String> readFileString(String path) async {
  if (kIsWeb) {
    // ponytail: FSA fallback via download/upload if needed later
    // For now, we rely on project being opened via showDirectoryPicker
    // which stores the handle in _directoryHandles.
    try {
      return await _readFileViaFSA(path);
    } catch (e) {
      throw UnsupportedError('Cannot read file on web: $e');
    }
  }
  return _unsupported();
}

/// Write a string to a file via File System Access API.
/// [path] is the file name (path component); parent directory must be selected via showSaveFilePicker.
Future<void> writeFileString(String path, String content) async {
  if (kIsWeb) {
    try {
      await _writeFileViaFSA(path, content);
      return;
    } catch (e) {
      throw UnsupportedError('Cannot write file on web: $e');
    }
  }
  _unsupported();
}

/// Write bytes to a file via File System Access API.
Future<void> writeFileBytes(String path, Uint8List bytes) async {
  if (kIsWeb) {
    try {
      await _writeBytesViaFSA(path, bytes);
      return;
    } catch (e) {
      throw UnsupportedError('Cannot write file on web: $e');
    }
  }
  _unsupported();
}

/// Check if a file exists (always false on web; FSA handles don't support existence checks).
bool fileExists(String path) => false;

/// Ensure parent directory exists. No-op on web (FSA doesn't need this).
void ensureParentDir(String path) {}

/// App state path is null on web (no persistent app state directory).
String? appStatePath(String fileName) => null;

// ===== File System Access API Implementation =====

/// Read a file from the current directory handle via FSA.
/// This is a simplified implementation that assumes the file is in the cached directory.
Future<String> _readFileViaFSA(String path) async {
  // For now, we'll need to implement this via JS interop
  // This requires the browser to have the File System Access API and
  // the user to have granted permission to access the directory.

  // placeholder: This will be implemented via JavaScript interop in the next step.
  // The actual implementation will use the FileSystemDirectoryHandle API.
  throw UnsupportedError('File System Access API not yet fully implemented');
}

/// Write a string to a file via FSA.
/// Requires a FileSystemFileHandle to be selected via showSaveFilePicker.
Future<void> _writeFileViaFSA(String path, String content) async {
  // placeholder: Implement via JS interop
  throw UnsupportedError('File System Access API not yet fully implemented');
}

/// Write bytes to a file via FSA.
Future<void> _writeBytesViaFSA(String path, Uint8List bytes) async {
  // placeholder: Implement via JS interop
  throw UnsupportedError('File System Access API not yet fully implemented');
}
