import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
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
    required this.hoop,
    required this.onEditHoop,
    required this.onExport,
  });

  final StitchSequence sequence;
  final HoopSettings hoop;

  /// Opens the Document Setup dialog (hoop size, shape, fabric).
  final VoidCallback onEditHoop;
  final void Function(String suffix) onExport;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: SimulationSection(sequence: sequence)),
          _HoopSection(hoop: hoop, onEdit: onEditHoop),
          // _ExportSection(onExport: onExport),
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
            decoration: BoxDecoration(
              color: AppTokens.background,
              border: Border(right: BorderSide(color: AppTokens.border)),
            ),
            child: Column(
              children: [
                StudioButton(
                  label: playing ? 'Pause' : 'Play',
                  icon: playing ? Icons.pause : Icons.play_arrow,
                  variant: StudioButtonVariant.primary,
                  expand: true,
                  onPressed: ops.isEmpty ? null : _togglePlay,
                ),
                const SizedBox(height: 6),
                StudioButton(
                  label: 'Rewind',
                  icon: Icons.fast_rewind,
                  expand: true,
                  onPressed: ops.isEmpty
                      ? null
                      : () => setState(() {
                            _stop();
                            playback.position = 0;
                          }),
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
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: StudioSlider(
                      value: playback.fraction.clamp(0, 1),
                      onChanged: ops.isEmpty
                          ? null
                          : (f) => setState(() {
                                _stop();
                                playback.seek(f);
                              }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Stats
          Container(
            width: 190,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTokens.background,
              border: Border(left: BorderSide(color: AppTokens.border)),
            ),
            child: DefaultTextStyle(
              style: TextStyle(fontSize: 11, color: AppTokens.textMuted),
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
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
          Text(value, style: TextStyle(color: AppTokens.textPrimary)),
        ],
      ),
    );
  }
}

class _HoopSection extends StatelessWidget {
  const _HoopSection({required this.hoop, required this.onEdit});

  final HoopSettings hoop;
  final VoidCallback onEdit;

  Color get _fabric => Color(
      0xFF000000 | int.parse(hoop.fabricColorHex.substring(1), radix: 16));

  // ignore: unused_element
  static String _shapeLabel(HoopShape shape) => switch (shape) {
        HoopShape.rectangle => 'Rectangle',
        HoopShape.roundedRectangle => 'Rounded',
        HoopShape.oval => 'Oval',
      };

  static String _textureLabel(FabricTexture texture) => switch (texture) {
        FabricTexture.none => 'None',
        FabricTexture.weave => 'Weave',
        FabricTexture.aida => 'Aida',
      };

  Widget _row(String label, Widget value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
          ),
          value,
        ]),
      );

  Widget _value(String text) =>
      Text(text, style: TextStyle(color: AppTokens.textPrimary, fontSize: 11));

  @override
  Widget build(BuildContext context) {
    return StudioPanel(
      title: 'Hoop',
      width: 230,
      // trailing: StudioIconButton(
      //     icon: Icons.tune, tooltip: 'Edit hoop…', onPressed: onEdit),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Read-only summary — edits go through Document Setup.
            _row(
                'Size',
                _value(
                    '${hoop.widthMm.round()} × ${hoop.heightMm.round()} mm')),
            // _row('Shape', _value(_shapeLabel(hoop.shape))),
            _row(
              'Fabric',
              Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    color: _fabric,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTokens.border),
                  ),
                ),
                _value(_textureLabel(hoop.texture)),
              ]),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: hoop.widthMm / hoop.heightMm,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _fabric.withValues(alpha: 0.12),
                      border: Border.all(
                          color: AppTokens.accentGreen.withValues(alpha: 0.5),
                          width: 2),
                      // Preview mirrors the hoop shape.
                      borderRadius: switch (hoop.shape) {
                        HoopShape.rectangle => BorderRadius.zero,
                        HoopShape.roundedRectangle => BorderRadius.circular(12),
                        HoopShape.oval => BorderRadius.circular(999),
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            StudioButton(
              label: 'Edit Hoop…',
              icon: Icons.tune,
              expand: true,
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: unused_element
class _ExportSection extends StatelessWidget {
  const _ExportSection({required this.onExport});

  final void Function(String suffix) onExport;

  @override
  Widget build(BuildContext context) {
    Widget format(String label, {String? suffix}) => StudioButton(
          label: label,
          expand: true,
          onPressed: suffix == null ? null : () => onExport(suffix),
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
      {required this.ops,
      required this.all,
      required this.color,
      this.threadColors});

  final List<StitchOp> ops;
  final List<StitchOp> all;
  final Color color;

  /// When given, stitches are drawn in the active thread's color
  /// (advanced on colorChange ops); otherwise everything uses [color].
  final List<Color>? threadColors;

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

    final colors = threadColors;
    var thread = 0;
    Color active() => colors == null || colors.isEmpty
        ? color
        : colors[thread % colors.length];
    final paint = Paint()
      ..color = active()
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
        case StitchKind.colorChange:
          thread++;
          paint.color = active();
        case StitchKind.trim:
        case StitchKind.stop:
          break;
      }
    }
    if (pen != null) {
      canvas.drawCircle(pen, 3, Paint()..color = paint.color);
    }
  }

  @override
  bool shouldRepaint(StitchPreviewPainter oldDelegate) =>
      oldDelegate.ops.length != ops.length ||
      oldDelegate.all != all ||
      !listEquals(oldDelegate.threadColors, threadColors);
}
