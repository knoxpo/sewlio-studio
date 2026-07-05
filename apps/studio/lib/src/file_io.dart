/// Path-based file IO, guarded per platform.
///
/// Desktop (dart:io) reads/writes real paths; on web these throw
/// [UnsupportedError], which the shell surfaces as a toast.
// ponytail: web gets no persistence yet — swap for download/upload
// (package:web) or file_selector when web save/load matters.
library;

export 'file_io_stub.dart' if (dart.library.io) 'file_io_native.dart';
