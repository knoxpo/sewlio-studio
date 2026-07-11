import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/workspace/simulation_view_model.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';

StitchSequence _sequence() => StitchSequence(threads: const [
      Thread('#ff0000'),
      Thread('#00ff00'),
    ], ops: [
      for (var i = 0; i < 100; i++) StitchOp.stitch(Point(i.toDouble(), 0)),
      const StitchOp(StitchKind.colorChange, Point(100, 0)),
      for (var i = 0; i < 50; i++)
        StitchOp.stitch(Point(100 + i.toDouble(), 0)),
      const StitchOp(StitchKind.trim, Point(150, 0)),
      for (var i = 0; i < 20; i++)
        StitchOp.stitch(Point(150 + i.toDouble(), 0)),
    ]);

void main() {
  test('tick advances by speed; end pauses (or loops)', () {
    final sim = SimulationViewModel(_sequence())..playback.position = 0;
    sim.tick();
    expect(sim.playback.position, 60); // 1200 sps × 50ms
    sim.setSpeed(0.5);
    sim.tick();
    expect(sim.playback.position, 90);

    sim.seek(1);
    sim.loop = true;
    sim.tick();
    expect(sim.playback.position, 0); // wrapped
    sim.dispose();
  });

  test('stop resets, stepBy clamps, seek pauses', () {
    final sim = SimulationViewModel(_sequence());
    sim.stepBy(10); // from end: clamped
    expect(sim.playback.position, sim.ops.length);
    sim.stop();
    expect(sim.playback.position, 0);
    sim.stepBy(-5);
    expect(sim.playback.position, 0);
    sim.seek(0.5);
    expect(sim.playback.position, (sim.ops.length * 0.5).round());
    expect(sim.playing, isFalse);
    sim.dispose();
  });

  test('jumpToNext lands just past the next color change / trim', () {
    final sim = SimulationViewModel(_sequence())..playback.position = 0;
    sim.jumpToNext(StitchKind.colorChange);
    expect(sim.playback.position, 101);
    sim.jumpToNext(StitchKind.trim);
    expect(sim.playback.position, 152);
    // Nothing ahead → cycles around the sequence.
    sim.jumpToNext(StitchKind.colorChange);
    expect(sim.playback.position, 101);
    sim.playback.position = sim.ops.length;
    sim.jumpToNext(StitchKind.trim);
    expect(sim.playback.position, 152);
    // No stop ops at all → playhead stays put.
    sim.jumpToNext(StitchKind.stop);
    expect(sim.playback.position, 152);
    sim.dispose();
  });
}
