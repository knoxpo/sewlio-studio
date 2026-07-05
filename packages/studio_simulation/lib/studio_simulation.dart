/// Stitch playback model: a scrubber over a Stitch IR sequence.
/// Consumes Stitch IR read-only (ARCH-010) — never modifies it.
library;

import 'package:studio_embroidery/studio_embroidery.dart';

/// A position within a stitch sequence for preview scrubbing.
// ponytail: op-index playback, no timing model — add per-stitch timing
// (machine speed, acceleration) when realtime simulation lands.
final class PlaybackModel {
  PlaybackModel(this.sequence) : position = sequence.ops.length;

  final StitchSequence sequence;

  /// Number of ops currently played back (0 ≤ position ≤ ops.length).
  int position;

  double get fraction =>
      sequence.ops.isEmpty ? 1 : position / sequence.ops.length;

  /// Ops up to the playhead.
  List<StitchOp> get visible => sequence.ops.sublist(0, position);

  /// Moves the playhead to [fraction] of the sequence, clamped.
  void seek(double fraction) {
    position = (sequence.ops.length * fraction).round().clamp(
          0,
          sequence.ops.length,
        );
  }
}
