import 'package:flutter/material.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'viewport.dart';

/// The design canvas: paints document objects through [viewport], pans
/// and pinch-zooms, and reports taps/drags in world coordinates so
/// tools can act on them.
class CanvasView extends StatefulWidget {
  const CanvasView({
    super.key,
    required this.document,
    required this.viewport,
    this.selectedId,
    this.hoopSize,
    this.onTapWorld,
    this.onHoverWorld,
    this.onDragStartWorld,
    this.onDragUpdateWorld,
    this.onDragEndWorld,
  });

  final Document document;
  final ViewportController viewport;

  /// Object drawn with selection visuals (bbox + handles).
  final Id? selectedId;

  /// Hoop outline (mm, centered on the world origin), drawn when set.
  final Size? hoopSize;

  final void Function(g.Point world)? onTapWorld;

  /// Pointer position in world mm (status bar readout).
  final void Function(g.Point world)? onHoverWorld;

  /// When a drag callback claims the gesture (returns true), drag
  /// updates go to the tool; otherwise the canvas pans.
  final bool Function(g.Point world)? onDragStartWorld;
  final void Function(g.Point world)? onDragUpdateWorld;
  final void Function()? onDragEndWorld;

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  var _toolDrag = false;
  double _lastScale = 1;

  @override
  Widget build(BuildContext context) {
    final viewport = widget.viewport;
    return ClipRect(
      child: MouseRegion(
        onHover: (event) => widget.onHoverWorld
            ?.call(viewport.screenToWorld(event.localPosition)),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => widget.onTapWorld
              ?.call(viewport.screenToWorld(details.localPosition)),
          // Scale gesture covers both one-pointer pan and pinch zoom.
          onScaleStart: (details) {
            _lastScale = 1;
            _toolDrag = details.pointerCount == 1 &&
                (widget.onDragStartWorld?.call(
                        viewport.screenToWorld(details.localFocalPoint)) ??
                    false);
          },
          onScaleUpdate: (details) {
            if (_toolDrag) {
              widget.onDragUpdateWorld
                  ?.call(viewport.screenToWorld(details.localFocalPoint));
              return;
            }
            if (details.scale != 1) {
              viewport.zoomAt(
                  details.localFocalPoint, details.scale / _lastScale);
              _lastScale = details.scale;
            }
            viewport.panBy(details.focalPointDelta);
          },
          onScaleEnd: (_) {
            if (_toolDrag) widget.onDragEndWorld?.call();
            _toolDrag = false;
          },
          child: ListenableBuilder(
            listenable: viewport,
            builder: (context, _) => CustomPaint(
              size: Size.infinite,
              painter: _DesignPainter(
                document: widget.document,
                viewport: viewport,
                selectedId: widget.selectedId,
                hoopSize: widget.hoopSize,
                colorScheme: Theme.of(context).colorScheme,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesignPainter extends CustomPainter {
  _DesignPainter({
    required this.document,
    required this.viewport,
    required this.selectedId,
    required this.hoopSize,
    required this.colorScheme,
  });

  final Document document;
  final ViewportController viewport;
  final Id? selectedId;
  final Size? hoopSize;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    _paintHoop(canvas);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colorScheme.primary;

    for (final object in document.objects) {
      final points = object.path.toPolyline();
      final path = Path()..moveTo(0, 0);
      final first = viewport.worldToScreen(points.first);
      path.moveTo(first.dx, first.dy);
      for (final p in points.skip(1)) {
        final o = viewport.worldToScreen(p);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, stroke);

      if (object.id == selectedId) {
        _paintSelection(canvas, object.path.bounds());
      }
    }
  }

  /// 10 mm grid in world space across the visible region.
  void _paintGrid(Canvas canvas, Size size) {
    const step = 10.0; // mm
    final paint = Paint()
      ..color = colorScheme.outline.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    final topLeft = viewport.screenToWorld(Offset.zero);
    final bottomRight = viewport.screenToWorld(Offset(size.width, size.height));
    for (var x = (topLeft.x / step).floor() * step;
        x <= bottomRight.x;
        x += step) {
      final sx = viewport.worldToScreen(g.Point(x, 0)).dx;
      canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), paint);
    }
    for (var y = (topLeft.y / step).floor() * step;
        y <= bottomRight.y;
        y += step) {
      final sy = viewport.worldToScreen(g.Point(0, y)).dy;
      canvas.drawLine(Offset(0, sy), Offset(size.width, sy), paint);
    }
  }

  /// Hoop outline centered on the world origin.
  void _paintHoop(Canvas canvas) {
    final hoop = hoopSize;
    if (hoop == null) return;
    final min =
        viewport.worldToScreen(g.Point(-hoop.width / 2, -hoop.height / 2));
    final max =
        viewport.worldToScreen(g.Point(hoop.width / 2, hoop.height / 2));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromPoints(min, max), Radius.circular(8 * viewport.zoom / 4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = colorScheme.secondary.withValues(alpha: 0.5),
    );
  }

  void _paintSelection(Canvas canvas, g.Bounds bounds) {
    final min = viewport.worldToScreen(g.Point(bounds.minX, bounds.minY));
    final max = viewport.worldToScreen(g.Point(bounds.maxX, bounds.maxY));
    final rect = Rect.fromPoints(min, max).inflate(4);
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = colorScheme.secondary,
    );
    final handle = Paint()..color = colorScheme.secondary;
    for (final corner in [
      rect.topLeft,
      rect.topRight,
      rect.bottomLeft,
      rect.bottomRight,
    ]) {
      canvas.drawRect(
          Rect.fromCenter(center: corner, width: 8, height: 8), handle);
    }
  }

  @override
  bool shouldRepaint(_DesignPainter oldDelegate) =>
      oldDelegate.document.revision != document.revision ||
      oldDelegate.selectedId != selectedId ||
      oldDelegate.hoopSize != hoopSize ||
      oldDelegate.viewport != viewport;
}
