import 'dart:typed_data';

import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:studio_machine/studio_machine.dart';

/// Encodes a [MachineProgram] as a Melco EXP file.
///
/// EXP is headerless: 2-byte stitch records (signed dx, dy) with 0x80
/// escape sequences for jump/trim/color change. Deltas must fit a
/// signed byte (±127 units = ±12.7 mm); out-of-range deltas are
/// reported to [sink] and the op is dropped rather than corrupted.
Uint8List encodeExp(MachineProgram program, {DiagnosticSink? sink}) {
  final out = BytesBuilder();

  void addDelta(int dx, int dy, {List<int> escape = const []}) {
    if (dx.abs() > 127 || dy.abs() > 127) {
      sink?.report(Diagnostic(
        severity: Severity.error,
        code: 'export.exp.deltaOutOfRange',
        message: 'delta ($dx, $dy) exceeds ±127 units; op dropped',
        source: 'studio_export',
      ));
      return;
    }
    out
      ..add(escape)
      ..addByte(dx & 0xff)
      ..addByte(dy & 0xff);
  }

  for (final op in program.ops) {
    switch (op.kind) {
      case MachineOpKind.stitch:
        addDelta(op.dx, op.dy);
      case MachineOpKind.jump:
        addDelta(op.dx, op.dy, escape: const [0x80, 0x04]);
      case MachineOpKind.trim:
        out.add(const [0x80, 0x02, 0x00, 0x00]);
      case MachineOpKind.colorChange || MachineOpKind.stop:
        out.add(const [0x80, 0x01, 0x00, 0x00]);
      case MachineOpKind.end:
        break; // EXP has no end record.
    }
  }
  return out.toBytes();
}
