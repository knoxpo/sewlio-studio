import 'dart:math' as math;
import 'dart:typed_data';

import 'package:studio_machine/studio_machine.dart';

/// Encodes a [MachineProgram] as a Tajima DST file.
///
/// DST records are 3 bytes encoding per-axis deltas of −121…+121
/// machine units as sums of ±1/±3/±9/±27/±81. Compile with a
/// [MachineModel] whose max lengths are ≤ 12.1 mm so deltas fit;
/// out-of-range deltas throw [ArgumentError] rather than corrupt output.
Uint8List encodeDst(MachineProgram program, {String designName = 'SEWLIO'}) {
  final records = BytesBuilder();
  var minX = 0, maxX = 0, minY = 0, maxY = 0, x = 0, y = 0;
  var stitches = 0, colorChanges = 0;

  for (final op in program.ops) {
    switch (op.kind) {
      case MachineOpKind.stitch:
        records.add(_record(op.dx, op.dy, 0));
        stitches++;
      case MachineOpKind.jump:
        records.add(_record(op.dx, op.dy, 0x80));
      case MachineOpKind.trim:
        // DST has no trim record; machines trim on long jump sequences.
        // ponytail: emitted as a zero-length jump — revisit if a target
        // machine needs the 2-jump trim idiom.
        records.add(_record(0, 0, 0x80));
      case MachineOpKind.colorChange || MachineOpKind.stop:
        records.add(_record(0, 0, 0xC3));
        colorChanges++;
      case MachineOpKind.end:
        records.add(Uint8List.fromList([0x00, 0x00, 0xF3]));
    }
    x += op.dx;
    y += op.dy;
    minX = math.min(minX, x);
    maxX = math.max(maxX, x);
    minY = math.min(minY, y);
    maxY = math.max(maxY, y);
  }

  final header = StringBuffer()
    ..write('LA:${designName.padRight(16).substring(0, 16)}\r')
    ..write('ST:${stitches.toString().padLeft(7, '0')}\r')
    ..write('CO:${colorChanges.toString().padLeft(3, '0')}\r')
    ..write('+X:${maxX.toString().padLeft(5, '0')}\r')
    ..write('-X:${minX.abs().toString().padLeft(5, '0')}\r')
    ..write('+Y:${maxY.toString().padLeft(5, '0')}\r')
    ..write('-Y:${minY.abs().toString().padLeft(5, '0')}\r')
    ..write('AX:+${x.abs().toString().padLeft(5, '0')}\r')
    ..write('AY:+${y.abs().toString().padLeft(5, '0')}\r')
    ..write('MX:+00000\r')
    ..write('MY:+00000\r')
    ..write('PD:******\r');

  final out = BytesBuilder();
  final headerBytes = header.toString().codeUnits;
  out.add(headerBytes);
  out.addByte(0x1A);
  out.add(List.filled(512 - headerBytes.length - 1, 0x20));
  out.add(records.takeBytes());
  return out.toBytes();
}

/// Encodes one 3-byte DST record for deltas [dx], [dy] with control
/// bits [flags] OR-ed into byte 3 (0x80 jump, 0xC3 color change).
Uint8List _record(int dx, int dy, int flags) {
  if (dx.abs() > 121 || dy.abs() > 121) {
    throw ArgumentError('DST delta out of range: ($dx, $dy)');
  }
  var b0 = 0, b1 = 0, b2 = 0x03 | flags;
  var x = dx, y = dy;

  if (x >= 41) {
    b2 |= 0x04;
    x -= 81;
  } else if (x <= -41) {
    b2 |= 0x08;
    x += 81;
  }
  if (x >= 14) {
    b1 |= 0x04;
    x -= 27;
  } else if (x <= -14) {
    b1 |= 0x08;
    x += 27;
  }
  if (x >= 5) {
    b0 |= 0x04;
    x -= 9;
  } else if (x <= -5) {
    b0 |= 0x08;
    x += 9;
  }
  if (x >= 2) {
    b1 |= 0x01;
    x -= 3;
  } else if (x <= -2) {
    b1 |= 0x02;
    x += 3;
  }
  if (x >= 1) {
    b0 |= 0x01;
    x -= 1;
  } else if (x <= -1) {
    b0 |= 0x02;
    x += 1;
  }

  if (y >= 41) {
    b2 |= 0x20;
    y -= 81;
  } else if (y <= -41) {
    b2 |= 0x10;
    y += 81;
  }
  if (y >= 14) {
    b1 |= 0x20;
    y -= 27;
  } else if (y <= -14) {
    b1 |= 0x10;
    y += 27;
  }
  if (y >= 5) {
    b0 |= 0x20;
    y -= 9;
  } else if (y <= -5) {
    b0 |= 0x10;
    y += 9;
  }
  if (y >= 2) {
    b1 |= 0x80;
    y -= 3;
  } else if (y <= -2) {
    b1 |= 0x40;
    y += 3;
  }
  if (y >= 1) {
    b0 |= 0x80;
    y -= 1;
  } else if (y <= -1) {
    b0 |= 0x40;
    y += 1;
  }

  assert(x == 0 && y == 0, 'unencoded remainder for ($dx, $dy)');
  return Uint8List.fromList([b0, b1, b2]);
}
