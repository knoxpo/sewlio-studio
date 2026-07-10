/// System-font discovery and loading, guarded per platform. Desktop
/// scans the OS font directories; web gets an empty list (built-in
/// monoline only).
library;

export 'font_io_stub.dart' if (dart.library.io) 'font_io_native.dart';
