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
    this.onTapWorld,
    this.onDragStartWorld,
    this.onDragUpdateWorld,
    this.onDragEndWorld,
  });

  final Document document;
  final ViewportController viewport;

  /// Object drawn with selection visuals (bbox + handles).
  final Id? selectedId;

  final void Function(g.Point world)? onTapWorld;

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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => widget.onTapWorld
            ?.call(viewport.screenToWorld(details.localPosition)),
        // Scale gesture covers both one-pointer pan and pinch zoom.
        onScaleStart: (details) {
          _lastScale = 1;
          _toolDrag = details.pointerCount == 1 &&
              (widget.onDragStartWorld
                      ?.call(viewport.screenToWorld(details.localFocalPoint)) ??
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
              colorScheme: Theme.of(context).colorScheme,
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
    required this.colorScheme,
  });

  final Document document;
  final ViewportController viewport;
  final Id? selectedId;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
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
      oldDelegate.viewport != viewport;
}
