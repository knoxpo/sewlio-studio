import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_simulation/studio_simulation.dart';

/// Simulation-mode playback state over the digitized sequence: wraps
/// [PlaybackModel] (studio_simulation, read-only over Stitch IR) with
/// transport controls. View state only — never touches the document.
// ponytail: op-index playback at a flat stitches/second; per-stitch
// machine timing arrives with realtime simulation.
final class SimulationViewModel extends ChangeNotifier {
  SimulationViewModel(this.sequence) : playback = PlaybackModel(sequence);

  static const stitchesPerSecond = 1200;
  static const _tickMs = 50;

  final StitchSequence sequence;
  final PlaybackModel playback;

  Timer? _timer;
  bool loop = false;
  double speed = 1.0; // 0.25×–4× multiplier on [stitchesPerSecond]

  // View toggles for the simulation canvas/overlays.
  // TODO: rendered paths arrive with the simulation painters.
  bool showNeedle = true;
  bool showTravel = false;
  bool showMachinePath = false;

  bool get playing => _timer != null;
  List<StitchOp> get ops => sequence.ops;

  void play() {
    if (playing || ops.isEmpty) return;
    if (playback.position >= ops.length) playback.position = 0;
    _timer = Timer.periodic(
        const Duration(milliseconds: _tickMs), (_) => tick());
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    playback.position = 0;
    notifyListeners();
  }

  /// One playback step (also the test seam — timers just call this).
  void tick() {
    final step = (stitchesPerSecond * speed * _tickMs / 1000).round();
    playback.position = (playback.position + step).clamp(0, ops.length);
    if (playback.position >= ops.length) {
      loop ? playback.position = 0 : pause();
    }
    notifyListeners();
  }

  void stepBy(int opsDelta) {
    pause();
    playback.position = (playback.position + opsDelta).clamp(0, ops.length);
    notifyListeners();
  }

  void seek(double fraction) {
    pause();
    playback.seek(fraction.clamp(0, 1));
    notifyListeners();
  }

  void setSpeed(double value) {
    speed = value;
    notifyListeners();
  }

  void toggleLoop() {
    loop = !loop;
    notifyListeners();
  }

  /// Jumps the playhead just past the next op of [kind] (color change,
  /// trim), cycling around the sequence; no-op when none exists.
  void jumpToNext(StitchKind kind) {
    pause();
    final n = ops.length;
    for (var i = 0; i < n; i++) {
      final index = (playback.position + i) % n;
      if (ops[index].kind == kind) {
        playback.position = index + 1;
        break;
      }
    }
    notifyListeners();
  }

  void toggleShow(String which) {
    switch (which) {
      case 'needle':
        showNeedle = !showNeedle;
      case 'travel':
        showTravel = !showTravel;
      case 'machine-path':
        showMachinePath = !showMachinePath;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
