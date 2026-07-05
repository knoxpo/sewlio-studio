import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;
import 'package:studio_machine/studio_machine.dart';
import 'package:studio_simulation/studio_simulation.dart';

/// Hoop presets offered in the hoop panel.
const hoopPresets = <MachineModel>[
  MachineModel(name: '100 × 100 mm'),
  MachineModel(name: '130 × 180 mm', hoopWidthMm: 130, hoopHeightMm: 180),
  MachineModel(name: '200 × 200 mm', hoopWidthMm: 200, hoopHeightMm: 200),
];

/// Bottom workspace strip: stitch simulation, hoop settings, export.
class BottomPanel extends StatelessWidget {
  const BottomPanel({
    super.key,
    required this.sequence,
    required this.machine,
    required this.onMachineChanged,
    required this.onExport,
  });

  final StitchSequence sequence;
  final MachineModel machine;
  final void Function(MachineModel machine) onMachineChanged;
  final void Function(String suffix) onExport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: SimulationSection(sequence: sequence)),
          _HoopSection(machine: machine, onChanged: onMachineChanged),
          _ExportSection(onExport: onExport),
        ],
      ),
    );
  }
}

/// Simulation: play/scrub the digitized sequence with live stats.
class SimulationSection extends StatefulWidget {
  const SimulationSection({super.key, required this.sequence});

  final StitchSequence sequence;

  @override
  State<SimulationSection> createState() => _SimulationSectionState();
}

class _SimulationSectionState extends State<SimulationSection> {
  static const stitchesPerSecond = 1200;

  late PlaybackModel playback = PlaybackModel(widget.sequence);
  Timer? _timer;

  bool get playing => _timer != null;

  @override
  void didUpdateWidget(SimulationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sequence != widget.sequence) {
      _stop();
      playback = PlaybackModel(widget.sequence);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _togglePlay() {
    if (playing) {
      _stop();
      return;
    }
    if (playback.position >= widget.sequence.ops.length) playback.position = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        playback.position = (playback.position + stitchesPerSecond ~/ 20)
            .clamp(0, widget.sequence.ops.length);
        if (playback.position >= widget.sequence.ops.length) _stop();
      });
    });
    setState(() {});
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    final ops = widget.sequence.ops;
    int countOf(StitchKind kind) => ops.where((op) => op.kind == kind).length;
    final seconds = widget.sequence.stitchCount / stitchesPerSecond;
    final time = Duration(seconds: seconds.round());
    String pad(int n) => n.toString().padLeft(2, '0');

    return StudioPanel(
      title: 'Stitch Simulation',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controls
          Container(
            width: 110,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTokens.background,
              border: Border(right: BorderSide(color: AppTokens.border)),
            ),
            child: Column(
              children: [
                FilledButton.icon(
                  onPressed: ops.isEmpty ? null : _togglePlay,
                  icon:
                      Icon(playing ? Icons.pause : Icons.play_arrow, size: 16),
                  label: Text(playing ? 'Pause' : 'Play'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(30),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: ops.isEmpty
                      ? null
                      : () => setState(() {
                            _stop();
                            playback.position = 0;
                          }),
                  icon: const Icon(Icons.fast_rewind, size: 16),
                  label: const Text('Rewind'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(28),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          // Preview + timeline
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTokens.background,
                        border: Border.all(color: AppTokens.border),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRect(
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: StitchPreviewPainter(
                            ops: playback.visible,
                            all: ops,
                            color: AppTokens.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Slider(
                    value: playback.fraction.clamp(0, 1),
                    onChanged: ops.isEmpty
                        ? null
                        : (f) => setState(() {
                              _stop();
                              playback.seek(f);
                            }),
                  ),
                ],
              ),
            ),
          ),
          // Stats
          Container(
            width: 190,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppTokens.background,
              border: Border(left: BorderSide(color: AppTokens.border)),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 11, color: AppTokens.textMuted),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _stat('Frame', '${playback.position} / ${ops.length}'),
                  _stat('Stitches / sec', '$stitchesPerSecond'),
                  _stat('Colors', '${widget.sequence.threads.length}'),
                  _stat('Stops', '${countOf(StitchKind.stop)}'),
                  _stat('Trims', '${countOf(StitchKind.trim)}'),
                  _stat('Jumps', '${countOf(StitchKind.jump)}'),
                  _stat('Time',
                      '${pad(time.inHours)}:${pad(time.inMinutes % 60)}:${pad(time.inSeconds % 60)}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          Text(value, style: const TextStyle(color: AppTokens.textPrimary)),
        ],
      ),
    );
  }
}

class _HoopSection extends StatelessWidget {
  const _HoopSection({required this.machine, required this.onChanged});

  final MachineModel machine;
  final void Function(MachineModel) onChanged;

  @override
  Widget build(BuildContext context) {
    return StudioPanel(
      title: 'Hoop',
      width: 230,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Size:',
                      style:
                          TextStyle(color: AppTokens.textMuted, fontSize: 11)),
                ),
                DropdownButton<MachineModel>(
                  value: machine,
                  isDense: true,
                  style: const TextStyle(
                      fontSize: 11, color: AppTokens.textPrimary),
                  items: [
                    for (final preset in hoopPresets)
                      DropdownMenuItem(value: preset, child: Text(preset.name)),
                  ],
                  onChanged: (m) {
                    if (m != null) onChanged(m);
                  },
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: machine.hoopWidthMm / machine.hoopHeightMm,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppTokens.accentGreen.withValues(alpha: 0.5),
                          width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportSection extends StatelessWidget {
  const _ExportSection({required this.onExport});

  final void Function(String suffix) onExport;

  @override
  Widget build(BuildContext context) {
    Widget format(String label, {String? suffix}) => OutlinedButton(
          onPressed: suffix == null ? null : () => onExport(suffix),
          style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(label, style: const TextStyle(fontSize: 11)),
        );
    return StudioPanel(
      title: 'Export',
      width: 170,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 1.8,
          children: [
            format('DST', suffix: '.dst'),
            format('EXP', suffix: '.exp'),
            format('PES'), // ponytail: encoder post-MVP
            format('JEF'), // ponytail: encoder post-MVP
          ],
        ),
      ),
    );
  }
}

/// Paints a stitch-sequence prefix fitted into the available size.
class StitchPreviewPainter extends CustomPainter {
  StitchPreviewPainter(
      {required this.ops, required this.all, required this.color});

  final List<StitchOp> ops;
  final List<StitchOp> all;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (all.isEmpty) return;
    // Fit the whole design (not just the visible prefix) so the view
    // doesn't jump while scrubbing.
    final bounds = g.Bounds.fromPoints([for (final op in all) op.position]);
    final scale = 0.9 *
        (bounds.width < 1e-6 && bounds.height < 1e-6
            ? 1.0
            : [
                size.width / (bounds.width + 1e-6),
                size.height / (bounds.height + 1e-6),
              ].reduce((a, b) => a < b ? a : b));
    final center = bounds.center;
    Offset map(g.Point p) => Offset(
          size.width / 2 + (p.x - center.x) * scale,
          size.height / 2 + (p.y - center.y) * scale,
        );

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2;
    Offset? pen;
    for (final op in ops) {
      switch (op.kind) {
        case StitchKind.stitch:
          final next = map(op.position);
          if (pen != null) canvas.drawLine(pen, next, paint);
          pen = next;
        case StitchKind.jump:
          pen = map(op.position); // move without drawing
        case StitchKind.trim:
        case StitchKind.colorChange:
        case StitchKind.stop:
          break;
      }
    }
    if (pen != null) {
      canvas.drawCircle(pen, 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(StitchPreviewPainter oldDelegate) =>
      oldDelegate.ops.length != ops.length || oldDelegate.all != all;
}
