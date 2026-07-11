import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'file_io.dart' as io;

/// Native OS file dialogs (macOS/Windows/Linux via file_selector),
/// filtered to one extension. The save dialog handles overwrite
/// confirmation itself.
///
/// On web, uses File System Access API (showDirectoryPicker/showSaveFilePicker)
/// with fallback to <input type="file"> if FSA not available.

XTypeGroup _typeGroup(String suffix) => XTypeGroup(
      label: '$suffix files',
      extensions: [suffix.substring(1)],
      uniformTypeIdentifiers: const ['public.data'],
    );

Future<String?> pickOpenPath({required String suffix}) async {
  if (kIsWeb) {
    return await _pickOpenPathWeb(suffix);
  }

  final file = await openFile(acceptedTypeGroups: [_typeGroup(suffix)]);
  return file?.path;
}

bool get _isMobile =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

Future<String?> pickSavePath({
  required String suffix,
  String? suggestedName,
}) async {
  if (kIsWeb) {
    return await _pickSavePathWeb(suffix, suggestedName);
  }
  if (_isMobile) {
    return _mobileSavePath(suffix, suggestedName);
  }

  final location = await getSaveLocation(
    acceptedTypeGroups: [_typeGroup(suffix)],
    suggestedName: suggestedName,
  );
  if (location == null) return null;
  final path = location.path;
  return path.endsWith(suffix) ? path : '$path$suffix';
}

/// Mobile has no save dialog (file_selector's getSaveLocation is
/// unimplemented on iOS/Android): save straight into the app documents
/// directory — user-visible in the iOS Files app via
/// UIFileSharingEnabled — with a numeric suffix on collision. The shell
/// offers the system share sheet afterwards for copies to Files/Drive.
Future<String> _mobileSavePath(String suffix, String? suggestedName) async {
  final dir = (await getApplicationDocumentsDirectory()).path;
  var base = suggestedName ?? 'Untitled$suffix';
  if (base.endsWith(suffix)) {
    base = base.substring(0, base.length - suffix.length);
  }
  var path = '$dir/$base$suffix';
  for (var n = 2; io.fileExists(path); n++) {
    path = '$dir/$base ($n)$suffix';
  }
  return path;
}

// ===== Web-specific File System Access API =====

/// Web implementation: Open a directory via File System Access API.
/// Returns a directory handle reference (stored internally).
/// Falls back to file input if FSA not available.
Future<String?> _pickOpenPathWeb(String suffix) async {
  try {
    // Try File System Access API first
    final directoryHandle = await _showDirectoryPickerWeb();
    if (directoryHandle == null) return null;

    // Store handle and return reference
    final handleId = DateTime.now().millisecondsSinceEpoch.toString();
    _storeDirectoryHandle(handleId, directoryHandle);
    return 'fsa://$handleId';
  } catch (e) {
    // Fallback to file input (limited: only single file, no directory access)
    // FSA not available, falling back to file input
    return await _pickFileViaBrowserInput(suffix);
  }
}

/// Web implementation: Save a file via File System Access API.
/// Shows save dialog and stores the handle for future I/O.
Future<String?> _pickSavePathWeb(String? suffix, String? suggestedName) async {
  try {
    // Try File System Access API first
    final fileHandle = await _showSaveFilePickerWeb(suggestedName, suffix);
    if (fileHandle == null) return null;

    // Store handle and return reference
    final handleId = DateTime.now().millisecondsSinceEpoch.toString();
    _storeFileHandle(handleId, fileHandle);
    return 'fsa://$handleId';
  } catch (e) {
    // FSA save not available
    return null; // No fallback for save on web yet
  }
}

// ===== Browser File System Access API Wrappers =====

/// Call browser's showDirectoryPicker() if available.
/// Returns null if FSA not supported or user cancelled.
Future<dynamic> _showDirectoryPickerWeb() async {
  // ponytail: This will be implemented via JavaScript interop
  // For now, throw to indicate not yet implemented
  throw UnsupportedError('FSA directory picker not yet implemented');
}

/// Call browser's showSaveFilePicker() if available.
/// Returns null if FSA not supported or user cancelled.
Future<dynamic> _showSaveFilePickerWeb(
    String? suggestedName, String? suffix) async {
  // ponytail: This will be implemented via JavaScript interop
  throw UnsupportedError('FSA save picker not yet implemented');
}

/// Fallback: Use <input type="file"> to pick a single file.
/// Limited: only single file, no directory access.
Future<String?> _pickFileViaBrowserInput(String suffix) async {
  // ponytail: Implement via JavaScript interop (create input element, trigger click)
  throw UnsupportedError('File input picker not yet implemented');
}

// ===== Handle Storage (global, in-memory; cleared on page reload) =====

final Map<String, dynamic> _storedDirectoryHandles = {};
final Map<String, dynamic> _storedFileHandles = {};

void _storeDirectoryHandle(String handleId, dynamic handle) {
  _storedDirectoryHandles[handleId] = handle;
}

void _storeFileHandle(String handleId, dynamic handle) {
  _storedFileHandles[handleId] = handle;
}
