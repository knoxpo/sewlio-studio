import 'dart:math' as math;

import 'package:studio_diagnostics/studio_diagnostics.dart';

import 'machine_model.dart';

/// Machine IR schema version. Bump + migrate on breaking change (ADR).
const String machineIrVersion = '1';

enum MachineOpKind { stitch, jump, trim, colorChange, stop, end }

/// One machine command: a relative movement in machine units (0.1 mm)
/// plus what happens there. Non-movement ops carry zero deltas.
final class MachineOp {
  const MachineOp(this.kind, [this.dx = 0, this.dy = 0]);

  final MachineOpKind kind;
  final int dx;
  final int dy;

  double get lengthUnits => math.sqrt((dx * dx + dy * dy).toDouble());

  @override
  bool operator ==(Object other) =>
      other is MachineOp &&
      other.kind == kind &&
      other.dx == dx &&
      other.dy == dy;

  @override
  int get hashCode => Object.hash(kind, dx, dy);

  @override
  String toString() => '${kind.name}($dx, $dy)';
}

/// The Machine IR: an immutable machine command program with its
/// thread order. Temporary — generated during export (ARCH-001).
final class MachineProgram {
  const MachineProgram({required this.threadColors, required this.ops});

  /// Thread colors (`#RRGGBB`) in usage order; colorChange advances to
  /// the next one.
  final List<String> threadColors;
  final List<MachineOp> ops;

  int get stitchCount =>
      ops.where((op) => op.kind == MachineOpKind.stitch).length;

  /// Validates against [machine] limits, reporting problems to [sink].
  /// Returns true when no errors were reported.
  bool validate(MachineModel machine, DiagnosticSink sink) {
    var ok = true;
    void error(String code, String message) {
      ok = false;
      sink.report(Diagnostic(
        severity: Severity.error,
        code: code,
        message: message,
        source: 'studio_machine',
      ));
    }

    final maxStitch = machine.maxStitchLengthMm * unitsPerMm;
    final maxJump = machine.maxJumpLengthMm * unitsPerMm;
    final halfW = machine.hoopWidthMm * unitsPerMm / 2;
    final halfH = machine.hoopHeightMm * unitsPerMm / 2;

    var x = 0, y = 0, colorChanges = 0;
    for (var i = 0; i < ops.length; i++) {
      final op = ops[i];
      x += op.dx;
      y += op.dy;
      switch (op.kind) {
        case MachineOpKind.stitch when op.lengthUnits > maxStitch:
          error('machine.stitchTooLong',
              'op $i: stitch ${op.lengthUnits / unitsPerMm} mm exceeds ${machine.maxStitchLengthMm} mm');
        case MachineOpKind.jump when op.lengthUnits > maxJump:
          error('machine.jumpTooLong',
              'op $i: jump ${op.lengthUnits / unitsPerMm} mm exceeds ${machine.maxJumpLengthMm} mm');
        case MachineOpKind.colorChange:
          colorChanges++;
        default:
          break;
      }
      if (x.abs() > halfW || y.abs() > halfH) {
        error(
            'machine.outsideHoop',
            'op $i: position (${x / unitsPerMm}, ${y / unitsPerMm}) mm outside '
                '${machine.hoopWidthMm}×${machine.hoopHeightMm} mm hoop');
      }
    }

    if (colorChanges + 1 > threadColors.length) {
      error(
          'machine.threadMapping',
          '$colorChanges color changes need ${colorChanges + 1} threads, '
              'got ${threadColors.length}');
    }
    if (colorChanges + 1 > machine.needleCount && machine.needleCount > 1) {
      error('machine.needleCount',
          '${colorChanges + 1} threads exceed ${machine.needleCount} needles');
    }
    if (ops.isEmpty || ops.last.kind != MachineOpKind.end) {
      error('machine.missingEnd', 'program must end with an end op');
    }
    return ok;
  }
}
