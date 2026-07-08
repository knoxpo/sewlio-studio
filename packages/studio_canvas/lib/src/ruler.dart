import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'viewport.dart';

/// Ruler thickness in logical pixels.
const double rulerThickness = 22;

/// A millimeter ruler along one canvas edge (Affinity-style): adaptive
/// tick density, labels on major ticks, and a live cursor marker.
class Ruler extends StatelessWidget {
  const Ruler({
    super.key,
    required this.viewport,
    required this.axis,
    this.cursor,
  });

  final ViewportController viewport;
  final Axis axis;

  /// Pointer position in world mm; drawn as an accent marker line.
  final ValueListenable<g.Point?>? cursor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: axis == Axis.vertical ? rulerThickness : null,
      height: axis == Axis.horizontal ? rulerThickness : null,
      child: ListenableBuilder(
        listenable: Listenable.merge([viewport, if (cursor != null) cursor!]),
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _RulerPainter(
            viewport: viewport,
            axis: axis,
            cursor: cursor?.value,
            colorScheme: scheme,
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  _RulerPainter({
    required this.viewport,
    required this.axis,
    required this.cursor,
    required this.colorScheme,
  });

  final ViewportController viewport;
  final Axis axis;
  final g.Point? cursor;
  final ColorScheme colorScheme;

  static const _steps = [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0];

  @override
  void paint(Canvas canvas, Size size) {
    final horizontal = axis == Axis.horizontal;
    final length = horizontal ? size.width : size.height;
    final tick = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    // Major step: smallest mm step that keeps labels ≥ 55 px apart.
    final major = _steps.firstWhere((s) => s * viewport.zoom >= 55,
        orElse: () => _steps.last);
    final minor = major / 5;

    double toWorld(double px) => horizontal
        ? (px - viewport.pan.dx) / viewport.zoom
        : (px - viewport.pan.dy) / viewport.zoom;
    double toScreen(double mm) => horizontal
        ? mm * viewport.zoom + viewport.pan.dx
        : mm * viewport.zoom + viewport.pan.dy;

    final first = (toWorld(0) / minor).floor() * minor;
    final last = toWorld(length);
    final textStyle = TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.55), fontSize: 8);

    for (var mm = first; mm <= last; mm += minor) {
      final px = toScreen(mm);
      // Snap the major test to the grid to dodge float drift.
      final isMajor = (mm / major - (mm / major).roundToDouble()).abs() < 1e-6;
      final tickLength = isMajor ? rulerThickness : 6.0;
      if (horizontal) {
        canvas.drawLine(Offset(px, rulerThickness - tickLength),
            Offset(px, rulerThickness), tick);
      } else {
        canvas.drawLine(Offset(rulerThickness - tickLength, px),
            Offset(rulerThickness, px), tick);
      }
      if (isMajor) {
        final painter = TextPainter(
          text: TextSpan(text: mm.round().toString(), style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        if (horizontal) {
          painter.paint(canvas, Offset(px + 2, 1));
        } else {
          // Rotate labels along the vertical ruler.
          canvas.save();
          canvas.translate(1, px + 2);
          canvas.rotate(1.5707963267948966); // 90°
          painter.paint(canvas, Offset.zero);
          canvas.restore();
        }
      }
    }

    // Live cursor marker.
    final c = cursor;
    if (c != null) {
      final px = toScreen(horizontal ? c.x : c.y);
      final marker = Paint()
        ..color = colorScheme.primary
        ..strokeWidth = 1;
      if (horizontal) {
        canvas.drawLine(Offset(px, 0), Offset(px, rulerThickness), marker);
      } else {
        canvas.drawLine(Offset(0, px), Offset(rulerThickness, px), marker);
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter oldDelegate) =>
      oldDelegate.cursor != cursor ||
      oldDelegate.viewport != viewport ||
      oldDelegate.axis != axis;
}
