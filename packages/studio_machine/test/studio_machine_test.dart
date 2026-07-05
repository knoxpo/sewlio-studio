import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_machine/studio_machine.dart';
import 'package:test/test.dart';

void main() {
  const red = Thread('#ff0000');

  group('compiler', () {
    test('positions become machine-unit deltas ending with end op', () {
      const seq = StitchSequence(threads: [
        red
      ], ops: [
        StitchOp.stitch(Point(0, 0)),
        StitchOp.stitch(Point(2.5, 0)),
        StitchOp.stitch(Point(2.5, 1.5)),
      ]);
      final program = compileToMachine(seq);

      expect(program.ops, const [
        MachineOp(MachineOpKind.stitch, 0, 0),
        MachineOp(MachineOpKind.stitch, 25, 0),
        MachineOp(MachineOpKind.stitch, 0, 15),
        MachineOp(MachineOpKind.end),
      ]);
      expect(program.threadColors, ['#ff0000']);
    });

    test('over-long stitch splits into jumps + final stitch', () {
      const seq = StitchSequence(threads: [
        red
      ], ops: [
        StitchOp.stitch(Point(0, 0)),
        StitchOp.stitch(Point(30, 0)), // 30 mm > 12.1 mm limit
      ]);
      final program = compileToMachine(seq);

      final moves =
          program.ops.where((op) => op.dx != 0 || op.dy != 0).toList();
      expect(moves, hasLength(3));
      expect(
          moves.take(2).every((op) => op.kind == MachineOpKind.jump), isTrue);
      expect(moves.last.kind, MachineOpKind.stitch);
      // Deltas still sum to the full 30 mm.
      expect(moves.fold<int>(0, (sum, op) => sum + op.dx), 300);
      // Program validates against the generic machine.
      final sink = CollectingSink();
      expect(program.validate(MachineModel.generic, sink), isTrue,
          reason: sink.diagnostics.join('\n'));
    });

    test('compiled program is deterministic', () {
      const line =
          Path(start: Point(0, 0), segments: [LineSegment(Point(10, 7))]);
      final seq = StitchSequence(
          threads: const [red], ops: generateRunningStitch(line));
      expect(compileToMachine(seq).ops, compileToMachine(seq).ops);
    });
  });

  group('validation', () {
    test('flags over-limit movement and hoop escape', () {
      const program = MachineProgram(threadColors: [
        '#ff0000'
      ], ops: [
        MachineOp(MachineOpKind.stitch, 200, 0), // 20 mm stitch
        MachineOp(MachineOpKind.jump, 400, 0), // now at 60 mm > 50 half-hoop
        MachineOp(MachineOpKind.end),
      ]);
      final sink = CollectingSink();
      expect(program.validate(MachineModel.generic, sink), isFalse);
      final codes = sink.diagnostics.map((d) => d.code).toSet();
      expect(codes, contains('machine.stitchTooLong'));
      expect(codes, contains('machine.jumpTooLong'));
      expect(codes, contains('machine.outsideHoop'));
    });

    test('flags thread mapping and missing end', () {
      const program = MachineProgram(threadColors: [
        '#ff0000'
      ], ops: [
        MachineOp(MachineOpKind.stitch, 10, 0),
        MachineOp(MachineOpKind.colorChange),
        MachineOp(MachineOpKind.stitch, 10, 0),
      ]);
      final sink = CollectingSink();
      expect(program.validate(MachineModel.generic, sink), isFalse);
      final codes = sink.diagnostics.map((d) => d.code).toSet();
      expect(codes, contains('machine.threadMapping'));
      expect(codes, contains('machine.missingEnd'));
    });
  });
}
