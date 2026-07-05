import 'package:studio_embroidery/studio_embroidery.dart';

import 'machine_ir.dart';
import 'machine_model.dart';

/// Compiles Stitch IR into Machine IR for [machine].
///
/// Positions (mm) become integer machine-unit deltas; the first op
/// moves from the origin (hoop center) to the first stitch. Movements
/// longer than the machine's limit are split into equal sub-moves —
/// intermediate legs of a long stitch become jumps so no extra needle
/// penetrations are invented.
MachineProgram compileToMachine(
  StitchSequence sequence, {
  MachineModel machine = MachineModel.generic,
}) {
  final ops = <MachineOp>[];
  var x = 0, y = 0;

  void move(MachineOpKind kind, int tx, int ty, double maxLenMm) {
    final x0 = x, y0 = y;
    final dx = tx - x0, dy = ty - y0;
    final maxUnits = maxLenMm * unitsPerMm;
    final length = MachineOp(kind, dx, dy).lengthUnits;
    final steps = length <= maxUnits ? 1 : (length / maxUnits).ceil();
    for (var i = 1; i <= steps; i++) {
      final nx = x0 + (dx * i / steps).round();
      final ny = y0 + (dy * i / steps).round();
      // Only the final leg keeps the stitch; interim legs jump.
      final legKind = (kind == MachineOpKind.stitch && i < steps)
          ? MachineOpKind.jump
          : kind;
      ops.add(MachineOp(legKind, nx - x, ny - y));
      x = nx;
      y = ny;
    }
  }

  int toUnits(double mm) => (mm * unitsPerMm).round();

  for (final op in sequence.ops) {
    final tx = toUnits(op.position.x), ty = toUnits(op.position.y);
    switch (op.kind) {
      case StitchKind.stitch:
        move(MachineOpKind.stitch, tx, ty, machine.maxStitchLengthMm);
      case StitchKind.jump:
        move(MachineOpKind.jump, tx, ty, machine.maxJumpLengthMm);
      case StitchKind.trim:
        ops.add(const MachineOp(MachineOpKind.trim));
      case StitchKind.colorChange:
        ops.add(const MachineOp(MachineOpKind.colorChange));
      case StitchKind.stop:
        ops.add(const MachineOp(MachineOpKind.stop));
    }
  }
  ops.add(const MachineOp(MachineOpKind.end));

  return MachineProgram(
    threadColors: [for (final t in sequence.threads) t.color],
    ops: ops,
  );
}
