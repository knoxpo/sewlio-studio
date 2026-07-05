import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_simulation/studio_simulation.dart';
import 'package:test/test.dart';

void main() {
  final sequence = StitchSequence(
    threads: const [Thread('#000000')],
    ops: [
      for (var i = 0; i < 10; i++) StitchOp.stitch(Point(i.toDouble(), 0)),
    ],
  );

  test('starts at the end and seeks with clamping', () {
    final playback = PlaybackModel(sequence);
    expect(playback.position, 10);
    expect(playback.fraction, 1);

    playback.seek(0.5);
    expect(playback.visible, hasLength(5));

    playback.seek(-1);
    expect(playback.position, 0);
    playback.seek(2);
    expect(playback.position, 10);
  });

  test('empty sequence is safe', () {
    final playback = PlaybackModel(const StitchSequence(threads: [], ops: []));
    expect(playback.fraction, 1);
    expect(playback.visible, isEmpty);
    playback.seek(0.5);
    expect(playback.position, 0);
  });
}
