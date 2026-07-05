import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:test/test.dart';

void main() {
  test('severity ordering', () {
    expect(Severity.error >= Severity.warning, isTrue);
    expect(Severity.info >= Severity.warning, isFalse);
    expect(Severity.warning >= Severity.warning, isTrue);
  });

  test('collecting sink stores diagnostics and detects errors', () {
    final sink = CollectingSink();
    expect(sink.hasErrors, isFalse);

    sink.report(const Diagnostic(
      severity: Severity.warning,
      code: 'test.warn',
      message: 'a warning',
    ));
    expect(sink.diagnostics, hasLength(1));
    expect(sink.hasErrors, isFalse);

    sink.report(const Diagnostic(
      severity: Severity.error,
      code: 'test.err',
      message: 'an error',
      source: 'studio_diagnostics',
    ));
    expect(sink.hasErrors, isTrue);
    expect(sink.diagnostics.last.toString(),
        '[error] test.err: an error (studio_diagnostics)');
  });
}
