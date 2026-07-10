import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'viewport.dart';

typedef CanvasTapCallback = void Function(
  g.Point world, {
  required bool toggle,
  required bool extend,
});

typedef CanvasDragStartCallback = bool Function(
  g.Point world, {
  required bool toggle,
  required bool extend,
});

/// The design canvas: paints document objects through [viewport], pans
/// and pinch-zooms, and reports taps/drags in world coordinates so
/// tools can act on them.
class CanvasView extends StatefulWidget {
  const CanvasView({
    super.key,
    required this.document,
    required this.viewport,
    this.selectedIds = const {},
    this.selectionBounds,
    this.previewPaths = const [],
    this.markers = const [],
    this.stitches,
    this.highlightStitches = const [],
    this.showOutlines = true,
    this.showNeedleHoles = false,
    this.onTapWorld,
    this.onDoubleTapWorld,
    this.onHoverWorld,
    this.onDragStartWorld,
    this.onDragUpdateWorld,
    this.onDragEndWorld,
  });

  final Document document;
  final ViewportController viewport;

  /// Objects drawn with selection visuals.
  final Set<Id> selectedIds;
  final g.Bounds? selectionBounds;

  /// Live tool overlay geometry (rubber bands, ghosts).
  final List<g.Path> previewPaths;

  /// Anchor markers (node editing, pen points).
  final List<g.Point> markers;

  /// Digitized stitch preview drawn in thread colors over the fabric;
  /// null hides the stitch layer (view toggle, not document state).
  final StitchSequence? stitches;

  /// Inspection highlight (Stitches panel glyph selection): drawn on
  /// top of the stitch layer in the secondary accent so selected
  /// generated stitches read differently from editable outlines.
  final List<StitchOp> highlightStitches;

  /// Whether object outlines/fills are painted (view toggle). Selection
  /// visuals stay so hidden-outline objects remain editable.
  final bool showOutlines;

  /// Whether needle penetration points are marked on the stitch layer.
  final bool showNeedleHoles;

  final CanvasTapCallback? onTapWorld;
  final void Function(g.Point world)? onDoubleTapWorld;

  /// Pointer position in world mm (status bar readout).
  final void Function(g.Point world)? onHoverWorld;

  /// When a drag callback claims the gesture (returns true), drag
  /// updates go to the tool; otherwise the canvas pans.
  final CanvasDragStartCallback? onDragStartWorld;
  final void Function(g.Point world)? onDragUpdateWorld;
  final void Function()? onDragEndWorld;

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  var _toolDrag = false;
  double _lastScale = 1;

  bool get _toggle =>
      HardwareKeyboard.instance.isMetaPressed ||
      HardwareKeyboard.instance.isControlPressed;

  bool get _extend => HardwareKeyboard.instance.isShiftPressed;

  @override
  Widget build(BuildContext context) {
    final viewport = widget.viewport;
    return LayoutBuilder(builder: (context, constraints) {
      viewport.viewSize = constraints.biggest;
      return _gestures(viewport);
    });
  }

  Widget _gestures(ViewportController viewport) {
    return ClipRect(
      child: MouseRegion(
        onHover: (event) => widget.onHoverWorld
            ?.call(viewport.screenToWorld(event.localPosition)),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => widget.onTapWorld?.call(
            viewport.screenToWorld(details.localPosition),
            toggle: _toggle,
            extend: _extend,
          ),
          onDoubleTapDown: widget.onDoubleTapWorld == null
              ? null
              : (details) => widget.onDoubleTapWorld!(
                  viewport.screenToWorld(details.localPosition)),
          onScaleStart: (details) {
            _lastScale = 1;
            _toolDrag = details.pointerCount == 1 &&
                (widget.onDragStartWorld?.call(
                      viewport.screenToWorld(details.localFocalPoint),
                      toggle: _toggle,
                      extend: _extend,
                    ) ??
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
                selectedIds: widget.selectedIds,
                selectionBounds: widget.selectionBounds,
                previewPaths: widget.previewPaths,
                markers: widget.markers,
                stitches: widget.stitches,
                highlightStitches: widget.highlightStitches,
                showOutlines: widget.showOutlines,
                showNeedleHoles: widget.showNeedleHoles,
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
    required this.selectedIds,
    required this.selectionBounds,
    required this.previewPaths,
    required this.markers,
    required this.stitches,
    required this.highlightStitches,
    required this.showOutlines,
    required this.showNeedleHoles,
    required this.colorScheme,
  });

  final Document document;
  final ViewportController viewport;
  final Set<Id> selectedIds;
  final g.Bounds? selectionBounds;
  final List<g.Path> previewPaths;
  final List<g.Point> markers;
  final StitchSequence? stitches;
  final List<StitchOp> highlightStitches;
  final bool showOutlines;
  final bool showNeedleHoles;
  final ColorScheme colorScheme;

  static const defaultGuideColor = Color(0xFF26C6DA);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    _paintHoop(canvas);
    _paintGuides(canvas, size);

    for (final object in document.flattenVisibleObjects()) {
      if (!showOutlines) {
        // Outlines hidden: skip geometry but keep selection visuals so
        // the object stays discoverable/editable.
        if (selectedIds.contains(object.id)) {
          _paintObjectSelection(canvas, object.bounds());
        }
        continue;
      }
      // Fill/stroke v1 (ADR-028): objects carry stroke width, cap,
      // join, and color; width scales with zoom (min 1px on screen).
      final props = object.stroke;
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            (props.widthMm * viewport.zoom).clamp(1.0, double.infinity)
        ..strokeCap = switch (props.cap) {
          'butt' => StrokeCap.butt,
          'square' => StrokeCap.square,
          _ => StrokeCap.round,
        }
        ..strokeJoin = switch (props.join) {
          'miter' => StrokeJoin.miter,
          'bevel' => StrokeJoin.bevel,
          _ => StrokeJoin.round,
        }
        ..strokeMiterLimit = props.miterLimit
        ..color = props.colorHex == null
            ? colorScheme.primary
            : Color(0xFF000000 |
                int.parse(props.colorHex!.substring(1), radix: 16));
      for (final contour in object.renderPaths) {
        final points = contour.toPolyline();
        if (points.isEmpty) continue;
        final path = Path();
        final first = viewport.worldToScreen(points.first);
        path.moveTo(first.dx, first.dy);
        for (final p in points.skip(1)) {
          final o = viewport.worldToScreen(p);
          path.lineTo(o.dx, o.dy);
        }
        if (contour.closed) path.close();
        if (contour.closed && props.fillHex != null) {
          canvas.drawPath(
            path,
            Paint()
              ..style = PaintingStyle.fill
              ..color = Color(0xFF000000 |
                  int.parse(props.fillHex!.substring(1), radix: 16)),
          );
        }
        canvas.drawPath(path, stroke);
      }

      if (selectedIds.contains(object.id)) {
        _paintObjectSelection(canvas, object.bounds());
      }
    }

    _paintStitches(canvas);
    _paintHighlightStitches(canvas);

    if (selectionBounds != null) {
      _paintSelectionBounds(canvas, selectionBounds!);
    }

    final overlay = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colorScheme.primary;
    for (final p in previewPaths) {
      final points = p.toPolyline();
      final path = Path()
        ..moveTo(viewport.worldToScreen(points.first).dx,
            viewport.worldToScreen(points.first).dy);
      for (final point in points.skip(1)) {
        final o = viewport.worldToScreen(point);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, overlay);
    }
    final markerFill = Paint()..color = colorScheme.primary;
    for (final marker in markers) {
      canvas.drawRect(
        Rect.fromCenter(
            center: viewport.worldToScreen(marker), width: 6, height: 6),
        markerFill,
      );
    }
  }

  /// Stitch preview: thread-colored segments along the digitized
  /// sequence (jump/trim move the pen without drawing), plus needle
  /// penetration dots when enabled.
  void _paintStitches(Canvas canvas) {
    final sequence = stitches;
    if (sequence == null || sequence.ops.isEmpty) return;
    Color threadColor(int index) => sequence.threads.isEmpty
        ? colorScheme.primary
        : Color(0xFF000000 |
            int.parse(
                sequence.threads[index % sequence.threads.length].color
                    .substring(1),
                radix: 16));
    var thread = 0;
    final paint = Paint()
      ..strokeWidth = (0.4 * viewport.zoom).clamp(1.0, double.infinity)
      ..strokeCap = StrokeCap.round
      ..color = threadColor(0);
    Offset? pen;
    for (final op in sequence.ops) {
      final p = viewport.worldToScreen(op.position);
      switch (op.kind) {
        case StitchKind.stitch:
          if (pen != null) canvas.drawLine(pen, p, paint);
          pen = p;
        case StitchKind.jump:
          pen = p;
        case StitchKind.colorChange:
          thread++;
          paint.color = threadColor(thread);
        case StitchKind.trim:
        case StitchKind.stop:
          break;
      }
    }
    if (showNeedleHoles) {
      final radius = (0.12 * viewport.zoom).clamp(1.0, 3.0);
      final hole = Paint()..color = colorScheme.onSurface;
      for (final op in sequence.ops) {
        if (op.kind == StitchKind.stitch) {
          canvas.drawCircle(viewport.worldToScreen(op.position), radius, hole);
        }
      }
    }
  }

  /// Glyph-inspection highlight: the selected generated stitches drawn
  /// thicker in the secondary accent, with their needle points.
  void _paintHighlightStitches(Canvas canvas) {
    if (highlightStitches.isEmpty) return;
    final paint = Paint()
      ..strokeWidth = (0.5 * viewport.zoom).clamp(2.0, double.infinity)
      ..strokeCap = StrokeCap.round
      ..color = colorScheme.secondary;
    Offset? pen;
    for (final op in highlightStitches) {
      final p = viewport.worldToScreen(op.position);
      switch (op.kind) {
        case StitchKind.stitch:
          if (pen != null) canvas.drawLine(pen, p, paint);
          pen = p;
        case StitchKind.jump:
        case StitchKind.trim:
          pen = p;
        case StitchKind.colorChange:
        case StitchKind.stop:
          break;
      }
    }
  }

  void _paintGrid(Canvas canvas, Size size) {
    const step = 10.0;
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

  void _paintHoop(Canvas canvas) {
    final settings = document.hoop;
    final min = viewport.worldToScreen(g.Point.zero);
    final max =
        viewport.worldToScreen(g.Point(settings.widthMm, settings.heightMm));
    final rect = Rect.fromPoints(min, max);
    final outline = switch (settings.shape) {
      HoopShape.rectangle => Path()..addRect(rect),
      HoopShape.roundedRectangle => Path()
        ..addRRect(RRect.fromRectAndRadius(
            rect, Radius.circular(8 * viewport.zoom / 4))),
      HoopShape.oval => Path()..addOval(rect),
    };

    // Fabric fill + procedural texture, clipped to the hoop shape.
    final fabric = Color(0xFF000000 |
        int.parse(settings.fabricColorHex.substring(1), radix: 16));
    canvas.save();
    canvas.clipPath(outline);
    canvas.drawRect(rect, Paint()..color = fabric.withValues(alpha: 0.12));
    final texturePaint = Paint()
      ..color = fabric.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    switch (settings.texture) {
      case FabricTexture.none:
        break;
      case FabricTexture.weave:
        // 1 mm crosshatch.
        for (var mm = 0.0; mm <= settings.widthMm; mm += 1) {
          final x = viewport.worldToScreen(g.Point(mm, 0)).dx;
          canvas.drawLine(
              Offset(x, rect.top), Offset(x, rect.bottom), texturePaint);
        }
        for (var mm = 0.0; mm <= settings.heightMm; mm += 1) {
          final y = viewport.worldToScreen(g.Point(0, mm)).dy;
          canvas.drawLine(
              Offset(rect.left, y), Offset(rect.right, y), texturePaint);
        }
      case FabricTexture.aida:
        // 2.5 mm dot grid.
        final dot = Paint()..color = fabric.withValues(alpha: 0.25);
        for (var xMm = 1.25; xMm < settings.widthMm; xMm += 2.5) {
          for (var yMm = 1.25; yMm < settings.heightMm; yMm += 2.5) {
            canvas.drawCircle(
                viewport.worldToScreen(g.Point(xMm, yMm)), 1, dot);
          }
        }
    }
    canvas.restore();

    canvas.drawPath(
      outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = colorScheme.secondary.withValues(alpha: 0.5),
    );
  }

  void _paintGuides(Canvas canvas, Size size) {
    for (final guide in document.guides) {
      final color = guide.colorHex == null
          ? defaultGuideColor
          : Color(
              0xFF000000 | int.parse(guide.colorHex!.substring(1), radix: 16));
      final paint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = 1;
      final vertical = guide.axis == GuideAxis.vertical;
      final px = vertical
          ? viewport.worldToScreen(g.Point(guide.positionMm, 0)).dx
          : viewport.worldToScreen(g.Point(0, guide.positionMm)).dy;
      if (vertical) {
        canvas.drawLine(Offset(px, 0), Offset(px, size.height), paint);
      } else {
        canvas.drawLine(Offset(0, px), Offset(size.width, px), paint);
      }
      if (guide.name.isNotEmpty) {
        final label = TextPainter(
          text: TextSpan(
              text: guide.name, style: TextStyle(color: color, fontSize: 9)),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(canvas, vertical ? Offset(px + 4, 4) : Offset(4, px + 3));
      }
    }
  }

  void _paintObjectSelection(Canvas canvas, g.Bounds bounds) {
    final min = viewport.worldToScreen(g.Point(bounds.minX, bounds.minY));
    final max = viewport.worldToScreen(g.Point(bounds.maxX, bounds.maxY));
    canvas.drawRect(
      Rect.fromPoints(min, max),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = colorScheme.primary.withValues(alpha: 0.7),
    );
  }

  void _paintSelectionBounds(Canvas canvas, g.Bounds bounds) {
    final min = viewport.worldToScreen(g.Point(bounds.minX, bounds.minY));
    final max = viewport.worldToScreen(g.Point(bounds.maxX, bounds.maxY));
    final rect = Rect.fromPoints(min, max).inflate(4);
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = colorScheme.primary,
    );
    final handle = Paint()..color = colorScheme.primary;
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
      oldDelegate.selectedIds.length != selectedIds.length ||
      !oldDelegate.selectedIds.containsAll(selectedIds) ||
      oldDelegate.selectionBounds != selectionBounds ||
      oldDelegate.previewPaths != previewPaths ||
      oldDelegate.markers != markers ||
      oldDelegate.stitches != stitches ||
      oldDelegate.highlightStitches != highlightStitches ||
      oldDelegate.showOutlines != showOutlines ||
      oldDelegate.showNeedleHoles != showNeedleHoles ||
      oldDelegate.viewport != viewport;
}
