import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import 'simulation_view_model.dart';

/// Timeline panel: scrub the playhead through the sequence.
// ponytail: a slider + frame readout — event ticks (color changes,
// trims) render on it when the timeline model lands.
class TimelinePanelContent extends StatelessWidget {
  const TimelinePanelContent({super.key, required this.sim});

  final SimulationViewModel sim;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sim,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          StudioSlider(
            key: const Key('sim-timeline-slider'),
            value: sim.playback.fraction.clamp(0, 1),
            onChanged: sim.ops.isEmpty ? null : sim.seek,
          ),
          const SizedBox(height: 4),
          Text(
            '${sim.playback.position} / ${sim.ops.length} ops',
            style: TextStyle(fontSize: 10, color: AppTokens.textMuted),
          ),
        ]),
      ),
    );
  }
}

/// Runtime stats panel: live counters over the sequence + playhead.
class RuntimeStatsPanelContent extends StatelessWidget {
  const RuntimeStatsPanelContent({super.key, required this.sim});

  final SimulationViewModel sim;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: sim,
      builder: (context, _) {
        int countOf(StitchKind kind) =>
            sim.ops.where((op) => op.kind == kind).length;
        final seconds = sim.sequence.stitchCount /
            (SimulationViewModel.stitchesPerSecond * sim.speed);
        final time = Duration(seconds: seconds.round());
        String pad(int n) => n.toString().padLeft(2, '0');
        Widget stat(String label, String value) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(children: [
                Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                Text(value, style: TextStyle(color: AppTokens.textPrimary)),
              ]),
            );
        return Padding(
          padding: const EdgeInsets.all(10),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 11, color: AppTokens.textMuted),
            child: Column(children: [
              stat('Frame', '${sim.playback.position} / ${sim.ops.length}'),
              stat('Speed', '${sim.speed}×'),
              stat('Colors', '${sim.sequence.threads.length}'),
              stat('Stops', '${countOf(StitchKind.stop)}'),
              stat('Trims', '${countOf(StitchKind.trim)}'),
              stat('Jumps', '${countOf(StitchKind.jump)}'),
              stat('Time',
                  '${pad(time.inHours)}:${pad(time.inMinutes % 60)}:${pad(time.inSeconds % 60)}'),
            ]),
          ),
        );
      },
    );
  }
}
