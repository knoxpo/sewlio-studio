import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:studio_export/studio_export.dart';
import 'package:studio_machine/studio_machine.dart';
import 'package:test/test.dart';

const _program = MachineProgram(threadColors: [
  '#ff0000'
], ops: [
  MachineOp(MachineOpKind.stitch, 0, 0),
  MachineOp(MachineOpKind.stitch, 25, 0),
  MachineOp(MachineOpKind.stitch, -5, 10),
  MachineOp(MachineOpKind.jump, 100, -50),
  MachineOp(MachineOpKind.colorChange),
  MachineOp(MachineOpKind.stitch, 1, 1),
  MachineOp(MachineOpKind.trim),
  MachineOp(MachineOpKind.end),
]);

void main() {
  group('DST', () {
    late final bytes = encodeDst(_program, designName: 'GOLDEN');

    test('header is 512 bytes with correct counts and extents', () {
      expect(bytes.length, 512 + 8 * 3);
      final header = String.fromCharCodes(bytes.take(512));
      expect(header, startsWith('LA:GOLDEN          \r'));
      expect(header, contains('ST:0000004\r'));
      expect(header, contains('CO:001\r'));
      expect(header, contains('+X:00121\r')); // 25-5+100+1
      expect(header, contains('-X:00000\r'));
      expect(header, contains('+Y:00010\r'));
      expect(header, contains('-Y:00040\r')); // 10-50+1 dips to -40
      expect(header, contains('PD:******\r'));
    });

    test('records match golden bytes', () {
      final records = bytes.sublist(512);
      expect(records, [
        0x00, 0x00, 0x03, // stitch 0,0
        0x01, 0x06, 0x03, // stitch 25,0   (27-3+1)
        0xA9, 0x01, 0x03, // stitch -5,10  (x:-9+3+1, y:9+1)
        0x89, 0xA4, 0x97, // jump 100,-50  (x:81+27-9+1, y:-81+27+3+1)
        0x00, 0x00, 0xC3, // color change
        0x81, 0x00, 0x03, // stitch 1,1
        0x00, 0x00, 0x83, // trim → zero-length jump
        0x00, 0x00, 0xF3, // end
      ]);
    });

    test('round trips every legal delta exactly', () {
      // Decode a record back to (dx, dy) and verify for the full range.
      (int, int) decode(List<int> r) {
        var x = 0, y = 0;
        final b0 = r[0], b1 = r[1], b2 = r[2];
        if (b0 & 0x01 != 0) x += 1;
        if (b0 & 0x02 != 0) x -= 1;
        if (b0 & 0x04 != 0) x += 9;
        if (b0 & 0x08 != 0) x -= 9;
        if (b0 & 0x80 != 0) y += 1;
        if (b0 & 0x40 != 0) y -= 1;
        if (b0 & 0x20 != 0) y += 9;
        if (b0 & 0x10 != 0) y -= 9;
        if (b1 & 0x01 != 0) x += 3;
        if (b1 & 0x02 != 0) x -= 3;
        if (b1 & 0x04 != 0) x += 27;
        if (b1 & 0x08 != 0) x -= 27;
        if (b1 & 0x80 != 0) y += 3;
        if (b1 & 0x40 != 0) y -= 3;
        if (b1 & 0x20 != 0) y += 27;
        if (b1 & 0x10 != 0) y -= 27;
        if (b2 & 0x04 != 0) x += 81;
        if (b2 & 0x08 != 0) x -= 81;
        if (b2 & 0x20 != 0) y += 81;
        if (b2 & 0x10 != 0) y -= 81;
        return (x, y);
      }

      for (var d = -121; d <= 121; d++) {
        final program = MachineProgram(
            threadColors: const ['#000000'],
            ops: [MachineOp(MachineOpKind.stitch, d, -d)]);
        final record = encodeDst(program).sublist(512, 515);
        expect(decode(record), (d, -d), reason: 'delta $d');
      }

      expect(
        () => encodeDst(const MachineProgram(
            threadColors: [], ops: [MachineOp(MachineOpKind.stitch, 122, 0)])),
        throwsArgumentError,
      );
    });
  });

  group('EXP', () {
    test('encodes stitches, escapes, and drops nothing (golden)', () {
      final sink = CollectingSink();
      final bytes = encodeExp(_program, sink: sink);
      expect(bytes, [
        0x00, 0x00, // stitch 0,0
        25, 0x00, // stitch 25,0
        0xFB, 10, // stitch -5,10 (-5 = 0xFB)
        0x80, 0x04, 100, 0xCE, // jump 100,-50
        0x80, 0x01, 0x00, 0x00, // color change
        1, 1, // stitch 1,1
        0x80, 0x02, 0x00, 0x00, // trim
      ]);
      expect(sink.diagnostics, isEmpty);
    });

    test('reports and drops out-of-range deltas', () {
      const bad = MachineProgram(threadColors: [], ops: [
        MachineOp(MachineOpKind.stitch, 200, 0),
        MachineOp(MachineOpKind.end),
      ]);
      final sink = CollectingSink();
      expect(encodeExp(bad, sink: sink), isEmpty);
      expect(sink.hasErrors, isTrue);
      expect(sink.diagnostics.single.code, 'export.exp.deltaOutOfRange');
    });
  });
}
