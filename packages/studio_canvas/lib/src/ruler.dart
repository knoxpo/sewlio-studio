import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'viewport.dart';

/// Ruler thickness in logical pixels.
const double rulerThickness = 22;

/// A marker shown on a ruler (a guide's position + color).
final class RulerMarker {
  const RulerMarker({required this.positionMm, required this.color});

  final double positionMm;
  final Color color;
}

/// A millimeter ruler along one canvas edge (Affinity-style):
/// three-level adaptive ticks, labels on majors, a live cursor marker,
/// and clickable guide markers.
class Ruler extends StatefulWidget {
  const Ruler({
    super.key,
    required this.viewport,
    required this.axis,
    this.cursor,
    this.markers = const [],
    this.onTapMm,
    this.onGuidePullStart,
    this.onGuidePullUpdate,
    this.onGuidePullEnd,
  });

  final ViewportController viewport;
  final Axis axis;

  /// Pointer position in world mm; drawn as an accent marker line.
  final ValueListenable<g.Point?>? cursor;

  /// Guide markers to draw on the ruler.
  final List<RulerMarker> markers;

  /// Tap on the ruler, reported in world mm along this axis
  /// (guide creation/editing).
  final void Function(double mm)? onTapMm;

  /// Illustrator-style pull-out: dragging from the ruler onto the
  /// canvas creates a guide parallel to it (top ruler → horizontal
  /// guide, left ruler → vertical guide). [mm] is the world coordinate
  /// on the axis PERPENDICULAR to this ruler — the guide's position.
  /// End reports whether the pointer actually left the ruler strip
  /// (released inside it = cancelled).
  final void Function(double mm)? onGuidePullStart;
  final void Function(double mm)? onGuidePullUpdate;
  final void Function({required bool commit})? onGuidePullEnd;

  @override
  State<Ruler> createState() => _RulerState();
}

class _RulerState extends State<Ruler> {
  ViewportController get viewport => widget.viewport;
  Axis get axis => widget.axis;

  var _pulledOut = false;

  double _toMm(Offset local) => axis == Axis.horizontal
      ? (local.dx - viewport.pan.dx) / viewport.zoom
      : (local.dy - viewport.pan.dy) / viewport.zoom;

  /// World coordinate perpendicular to the ruler: the ruler strip sits
  /// [rulerThickness] before the canvas origin on that axis.
  double _toPerpendicularMm(Offset local) => axis == Axis.horizontal
      ? (local.dy - rulerThickness - viewport.pan.dy) / viewport.zoom
      : (local.dx - rulerThickness - viewport.pan.dx) / viewport.zoom;

  bool _insideStrip(Offset local) => axis == Axis.horizontal
      ? local.dy <= rulerThickness
      : local.dx <= rulerThickness;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onTapMm = widget.onTapMm;
    return SizedBox(
      width: axis == Axis.vertical ? rulerThickness : null,
      height: axis == Axis.horizontal ? rulerThickness : null,
      child: MouseRegion(
        // Clicking a ruler places/edits a guide — precise crosshair.
        cursor:
            onTapMm == null ? MouseCursor.defer : SystemMouseCursors.precise,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: onTapMm == null
              ? null
              : (details) => onTapMm(_toMm(details.localPosition)),
          onPanStart: widget.onGuidePullStart == null
              ? null
              : (details) {
                  _pulledOut = false;
                  widget.onGuidePullStart!(
                      _toPerpendicularMm(details.localPosition));
                },
          onPanUpdate: widget.onGuidePullUpdate == null
              ? null
              : (details) {
                  if (!_insideStrip(details.localPosition)) _pulledOut = true;
                  widget.onGuidePullUpdate!(
                      _toPerpendicularMm(details.localPosition));
                },
          onPanEnd: widget.onGuidePullEnd == null
              ? null
              : (_) => widget.onGuidePullEnd!(commit: _pulledOut),
          onPanCancel: widget.onGuidePullEnd == null
              ? null
              : () => widget.onGuidePullEnd!(commit: false),
          child: ListenableBuilder(
            listenable: Listenable.merge(
                [viewport, if (widget.cursor != null) widget.cursor!]),
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: _RulerPainter(
                viewport: viewport,
                axis: axis,
                cursor: widget.cursor?.value,
                markers: widget.markers,
                colorScheme: scheme,
              ),
            ),
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
    required this.markers,
    required this.colorScheme,
  });

  final ViewportController viewport;
  final Axis axis;
  final g.Point? cursor;
  final List<RulerMarker> markers;
  final ColorScheme colorScheme;

  static const _steps = [1.0, 2.0, 5.0, 10.0, 20.0, 50.0, 100.0, 200.0, 500.0];

  @override
  void paint(Canvas canvas, Size size) {
    // Everything stays inside the ruler strip: off-scale guide markers,
    // the cursor line, and labels must never bleed over neighbouring
    // toolbars/panels.
    canvas.clipRect(Offset.zero & size);
    final horizontal = axis == Axis.horizontal;
    final length = horizontal ? size.width : size.height;

    // Three-level tick hierarchy: minor / mid / major.
    final major = _steps.firstWhere((s) => s * viewport.zoom >= 55,
        orElse: () => _steps.last);
    final mid = major / 2;
    final minor = major / 10;

    final majorPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    final midPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.35)
      ..strokeWidth = 1;
    final minorPaint = Paint()
      ..color = colorScheme.onSurface.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    double toWorld(double px) => horizontal
        ? (px - viewport.pan.dx) / viewport.zoom
        : (px - viewport.pan.dy) / viewport.zoom;
    double toScreen(double mm) => horizontal
        ? mm * viewport.zoom + viewport.pan.dx
        : mm * viewport.zoom + viewport.pan.dy;

    void tickAt(double px, double tickLength, Paint paint) {
      if (horizontal) {
        canvas.drawLine(Offset(px, rulerThickness - tickLength),
            Offset(px, rulerThickness), paint);
      } else {
        canvas.drawLine(Offset(rulerThickness - tickLength, px),
            Offset(rulerThickness, px), paint);
      }
    }

    bool onGrid(double mm, double step) =>
        (mm / step - (mm / step).roundToDouble()).abs() < 1e-6;

    final first = (toWorld(0) / minor).floor() * minor;
    final last = toWorld(length);
    final textStyle = TextStyle(
        color: colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 8.5,
        fontFeatures: const [FontFeature.tabularFigures()]);

    for (var mm = first; mm <= last; mm += minor) {
      final px = toScreen(mm);
      if (onGrid(mm, major)) {
        tickAt(px, rulerThickness - 8, majorPaint);
        final painter = TextPainter(
          text: TextSpan(text: mm.round().toString(), style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        if (horizontal) {
          painter.paint(canvas, Offset(px + 3, 1));
        } else {
          canvas.save();
          // Rotated 90°, the glyph height extends toward -x — offset by
          // the text height so the label sits INSIDE the ruler instead
          // of bleeding over whatever is left of it.
          canvas.translate(painter.height + 1, px + 3);
          canvas.rotate(1.5707963267948966); // 90°
          painter.paint(canvas, Offset.zero);
          canvas.restore();
        }
      } else if (onGrid(mm, mid)) {
        tickAt(px, 8, midPaint);
      } else {
        tickAt(px, 4, minorPaint);
      }
    }

    // Guide markers: colored notch triangles pointing at the canvas.
    for (final marker in markers) {
      final px = toScreen(marker.positionMm);
      final paint = Paint()..color = marker.color;
      final path = Path();
      if (horizontal) {
        path
          ..moveTo(px - 4, rulerThickness - 7)
          ..lineTo(px + 4, rulerThickness - 7)
          ..lineTo(px, rulerThickness)
          ..close();
      } else {
        path
          ..moveTo(rulerThickness - 7, px - 4)
          ..lineTo(rulerThickness - 7, px + 4)
          ..lineTo(rulerThickness, px)
          ..close();
      }
      canvas.drawPath(path, paint);
    }

    // Live cursor marker.
    final c = cursor;
    if (c != null) {
      final px = toScreen(horizontal ? c.x : c.y);
      final marker = Paint()
        ..color = colorScheme.primary.withValues(alpha: 0.9)
        ..strokeWidth = 1;
      tickAt(px, rulerThickness.toDouble(), marker);
    }
  }

  @override
  bool shouldRepaint(_RulerPainter oldDelegate) =>
      oldDelegate.cursor != cursor ||
      oldDelegate.viewport != viewport ||
      oldDelegate.markers != markers ||
      oldDelegate.axis != axis;
}
