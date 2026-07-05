import 'package:flutter/material.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;
import 'package:studio_simulation/studio_simulation.dart';

/// Modal stitch preview: scrub through the digitized sequence.
Future<void> showSimulationDialog(
    BuildContext context, StitchSequence sequence) {
  final playback = PlaybackModel(sequence);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Simulation — ${sequence.stitchCount} stitches'),
      content: StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 420,
          height: 460,
          child: Column(
            children: [
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _StitchPainter(
                    ops: playback.visible,
                    all: sequence.ops,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Slider(
                value: playback.fraction,
                onChanged: (f) => setState(() => playback.seek(f)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _StitchPainter extends CustomPainter {
  _StitchPainter({required this.ops, required this.all, required this.color});

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
  bool shouldRepaint(_StitchPainter oldDelegate) =>
      oldDelegate.ops.length != ops.length;
}
