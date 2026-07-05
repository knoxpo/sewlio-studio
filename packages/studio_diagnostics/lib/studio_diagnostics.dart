/// Severity levels and diagnostic reporting for Sewlio Studio.
///
/// Pure Dart — no Flutter dependency. Domain packages report problems
/// through a [DiagnosticSink] instead of throwing or printing, so hosts
/// (app, tests, CLI) decide what to do with them.
library;

/// How serious a diagnostic is.
enum Severity {
  debug,
  info,
  warning,
  error;

  /// True if this severity is at least as severe as [other].
  bool operator >=(Severity other) => index >= other.index;
}

/// An immutable report of something noteworthy that happened.
final class Diagnostic {
  const Diagnostic({
    required this.severity,
    required this.code,
    required this.message,
    this.source,
  });

  final Severity severity;

  /// Stable machine-readable identifier, e.g. `export.dst.stitchTooLong`.
  final String code;

  /// Human-readable description.
  final String message;

  /// Optional origin (package or subsystem name).
  final String? source;

  @override
  String toString() =>
      '[${severity.name}] $code: $message${source == null ? '' : ' ($source)'}';
}

/// Receives diagnostics from domain code.
abstract interface class DiagnosticSink {
  void report(Diagnostic diagnostic);
}

/// A sink that stores everything it receives. Default for tests and
/// batch operations that surface diagnostics afterwards.
final class CollectingSink implements DiagnosticSink {
  final List<Diagnostic> diagnostics = [];

  @override
  void report(Diagnostic diagnostic) => diagnostics.add(diagnostic);

  /// True if any collected diagnostic is [Severity.error] or worse.
  bool get hasErrors => diagnostics.any((d) => d.severity >= Severity.error);
}
