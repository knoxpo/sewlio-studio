import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:remix_icons_flutter/remixicon_ids.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'stylus_gesture.dart';
import 'viewport.dart';

/// Cursors the canvas paints itself (system cursor hidden): the pen
/// family (Affinity-style nib + action badge) plus cursors no OS
/// provides reliably — rotation and diagonal resize (macOS has no
/// public diagonal-resize NSCursor). The shell maps tool state onto
/// this — the canvas has no tools dependency.
enum PaintedCursor {
  penStart,
  penAdd,
  penRemove,
  penClose,
  rotate,
  resizeNWSE,
  resizeNESW,
}

typedef CanvasTapCallback = void Function(
  g.Point world, {
  required bool toggle,
  required bool extend,
});

typedef CanvasDragStartCallback = bool Function(
  g.Point world, {
  required bool toggle,
  required bool extend,
  double? pressure,
});

/// [pressure] is normalized stylus pressure (0–1), null for devices
/// without pressure (mouse, touch, trackpad).
typedef CanvasDragUpdateCallback = void Function(
  g.Point world, {
  double? pressure,
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
    this.previewFillPaths = const [],
    this.selectionHighlights = const [],
    this.previewFillColor,
    this.hiddenObjectId,
    this.previewWidths,
    this.markers = const [],
    this.stitches,
    this.highlightStitches = const [],
    this.showOutlines = true,
    this.showNeedleHoles = false,
    this.cursor = MouseCursor.defer,
    this.paintedCursor,
    this.paintedCursorWorld,
    this.boxTransform,
    this.cursorLabel,
    this.cursorLabelWorld,
    this.liveGuide,
    this.hideGuideId,
    this.onTapWorld,
    this.onDoubleTapWorld,
    this.onLongPressWorld,
    this.onHoverWorld,
    this.onHoverExit,
    this.onDragStartWorld,
    this.onDragUpdateWorld,
    this.onDragEndWorld,
  });

  final Document document;
  final ViewportController viewport;

  /// Objects drawn with selection visuals.
  final Set<Id> selectedIds;
  final g.Bounds? selectionBounds;

  /// Live tool overlay geometry (rubber bands, ghosts) — stroked.
  final List<g.Path> previewPaths;

  /// Closed contours filled live in [previewFillColor] (editing glyphs),
  /// so live text renders solid like the committed object.
  final List<g.Path> previewFillPaths;

  /// Filled translucent quads drawn behind the preview (text selection).
  final List<g.Path> selectionHighlights;

  /// `#rrggbb` fill for [previewFillPaths]; null skips the fill.
  final String? previewFillColor;

  /// Object hidden from the vector pass — the text object being edited,
  /// so its committed geometry doesn't double up with the live preview.
  final Id? hiddenObjectId;

  /// Per-node widths in mm for the first preview path (in-progress
  /// pressure stroke, ADR-038); null draws all previews as hairlines.
  final List<double>? previewWidths;

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

  /// Pointer cursor (tool + hover context, resolved by the shell).
  /// The canvas overrides it with the closed hand while panning.
  final MouseCursor cursor;

  /// When set (pen tool active), the system cursor should be hidden
  /// ([cursor] = none) and the canvas paints a pen glyph with this
  /// badge at [paintedCursorWorld].
  final PaintedCursor? paintedCursor;
  final g.Point? paintedCursorWorld;

  /// In-progress drag transform applied to the transform box drawing,
  /// so the box follows the object live (rotated box while rotating).
  final g.Transform2? boxTransform;

  /// Small tooltip chip painted beside the pointer (rotation angle,
  /// scale percentages) while transforming, anchored at
  /// [cursorLabelWorld].
  final String? cursorLabel;
  final g.Point? cursorLabelWorld;

  /// In-flight guide drag (create-from-ruler or reposition): drawn on
  /// top of the document guides, while [hideGuideId] hides the stored
  /// guide being moved so it doesn't show twice.
  final Guide? liveGuide;
  final Id? hideGuideId;

  final CanvasTapCallback? onTapWorld;
  final void Function(g.Point world)? onDoubleTapWorld;

  /// Touch long-press (tablet context menu). Never fires for stylus
  /// or mouse. The callback also receives the global screen position
  /// so the shell can anchor a menu.
  final void Function(g.Point world, Offset globalPosition)? onLongPressWorld;

  /// Pointer position in world mm (status bar readout).
  final void Function(g.Point world)? onHoverWorld;

  /// Pointer left the canvas — painted cursors and hover previews must
  /// clear rather than freeze at the last known position.
  final VoidCallback? onHoverExit;

  /// When a drag callback claims the gesture (returns true), drag
  /// updates go to the tool; otherwise the canvas pans.
  final CanvasDragStartCallback? onDragStartWorld;
  final CanvasDragUpdateCallback? onDragUpdateWorld;
  final void Function()? onDragEndWorld;

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  var _toolDrag = false;
  var _panning = false;
  double _lastScale = 1;

  /// Active stylus contact, if any. While set, touch gestures are
  /// suppressed (palm rejection) and the stylus is driven by
  /// [_stylus] instead of the gesture arena.
  int? _stylusPointer;
  var _stylusToolDrag = false;
  Offset? _stylusPanLast;

  /// Touch pointers that landed while the stylus was down (the resting
  /// palm). They stay rejected until they lift, even after stylus-up.
  final _rejectedTouches = <int>{};

  late final _stylus = StylusGestureHandler(
    onTap: (position) => widget.onTapWorld?.call(
      widget.viewport.screenToWorld(position),
      toggle: _toggle,
      extend: _extend,
    ),
    onDragStart: (position, pressure) {
      _stylusToolDrag = widget.onDragStartWorld?.call(
            widget.viewport.screenToWorld(position),
            toggle: _toggle,
            extend: _extend,
            pressure: pressure,
          ) ??
          false;
      _stylusPanLast = _stylusToolDrag ? null : position;
      if (!_stylusToolDrag) setState(() => _panning = true);
    },
    onDragUpdate: (position, pressure) {
      if (_stylusToolDrag) {
        widget.onDragUpdateWorld?.call(
          widget.viewport.screenToWorld(position),
          pressure: pressure,
        );
        return;
      }
      widget.viewport.panBy(position - _stylusPanLast!);
      _stylusPanLast = position;
    },
    onDragEnd: () {
      if (_stylusToolDrag) widget.onDragEndWorld?.call();
      _stylusToolDrag = false;
      _stylusPanLast = null;
      if (_panning) setState(() => _panning = false);
    },
  );

  bool _isStylusKind(PointerDeviceKind kind) =>
      kind == PointerDeviceKind.stylus ||
      kind == PointerDeviceKind.invertedStylus;

  /// Normalized 0–1 stylus pressure.
  double _normalizedPressure(PointerEvent event) {
    final range = event.pressureMax - event.pressureMin;
    if (range <= 0) return 1.0;
    return ((event.pressure - event.pressureMin) / range).clamp(0.0, 1.0);
  }

  /// Touch gestures are ignored while a stylus is in contact or palm
  /// touches from a stroke are still down.
  bool get _touchSuppressed =>
      _stylusPointer != null || _rejectedTouches.isNotEmpty;

  /// Device kind and position of the most recent pointer-down, so
  /// gesture-arena callbacks can discriminate (long press) and anchor
  /// drags where the pointer actually landed — the scale recognizer
  /// only fires onScaleStart after its touch slop, which would offset
  /// every drag origin (and miss thin targets like guides) by ~18 px.
  PointerDeviceKind? _lastDownKind;
  Offset? _lastDownLocal;

  void _onPointerDown(PointerDownEvent event) {
    _lastDownKind = event.kind;
    _lastDownLocal = event.localPosition;
    if (_isStylusKind(event.kind)) {
      if (_stylusPointer != null) return; // second stylus: ignore
      _stylusPointer = event.pointer;
      _stylus.down(event.localPosition, _normalizedPressure(event));
      return;
    }
    if (event.kind == PointerDeviceKind.touch && _stylusPointer != null) {
      _rejectedTouches.add(event.pointer);
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.pointer == _stylusPointer) {
      _stylus.move(event.localPosition, _normalizedPressure(event));
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (event.pointer == _stylusPointer) {
      _stylusPointer = null;
      _stylus.up(event.localPosition);
    }
    _releaseRejected(event.pointer);
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (event.pointer == _stylusPointer) {
      _stylusPointer = null;
      _stylus.cancel();
    }
    _releaseRejected(event.pointer);
  }

  /// Rejected palm touches are released a microtask later: the gesture
  /// arena fires its callbacks after this Listener sees the up event,
  /// and the suppression guard must still hold when they run.
  void _releaseRejected(int pointer) {
    if (!_rejectedTouches.contains(pointer)) return;
    scheduleMicrotask(() => _rejectedTouches.remove(pointer));
  }

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
        cursor: _panning ? SystemMouseCursors.grabbing : widget.cursor,
        onHover: (event) => widget.onHoverWorld
            ?.call(viewport.screenToWorld(event.localPosition)),
        onExit: (_) => widget.onHoverExit?.call(),
        child: Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          onPointerCancel: _onPointerCancel,
          // Pencil/S Pen hover: MouseTracker feeds MouseRegion above on
          // most platforms; this direct path covers the rest.
          onPointerHover: (event) {
            if (_isStylusKind(event.kind)) {
              widget.onHoverWorld
                  ?.call(viewport.screenToWorld(event.localPosition));
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Stylus contacts never enter the gesture arena — the
            // Listener above drives them (low latency, live pressure).
            supportedDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.unknown,
            },
            onTapUp: (details) {
              if (_touchSuppressed) return;
              widget.onTapWorld?.call(
                viewport.screenToWorld(details.localPosition),
                toggle: _toggle,
                extend: _extend,
              );
            },
            onDoubleTapDown: widget.onDoubleTapWorld == null
                ? null
                : (details) => widget.onDoubleTapWorld!(
                    viewport.screenToWorld(details.localPosition)),
            onLongPressStart: widget.onLongPressWorld == null
                ? null
                : (details) {
                    // Touch only: mouse right-clicks, stylus draws.
                    if (_touchSuppressed ||
                        _lastDownKind != PointerDeviceKind.touch) {
                      return;
                    }
                    widget.onLongPressWorld!(
                      viewport.screenToWorld(details.localPosition),
                      details.globalPosition,
                    );
                  },
            onScaleStart: (details) {
              if (_touchSuppressed) return;
              _lastScale = 1;
              _toolDrag = details.pointerCount == 1 &&
                  (widget.onDragStartWorld?.call(
                        viewport.screenToWorld(
                            _lastDownLocal ?? details.localFocalPoint),
                        toggle: _toggle,
                        extend: _extend,
                      ) ??
                      false);
            },
            onScaleUpdate: (details) {
              if (_touchSuppressed) return;
              if (_toolDrag) {
                widget.onDragUpdateWorld
                    ?.call(viewport.screenToWorld(details.localFocalPoint));
                return;
              }
              if (!_panning) setState(() => _panning = true);
              if (details.scale != 1) {
                viewport.zoomAt(
                    details.localFocalPoint, details.scale / _lastScale);
                _lastScale = details.scale;
              }
              viewport.panBy(details.focalPointDelta);
              // Pan/zoom changes what's under the (stationary) pointer:
              // re-emit its world position so ruler cursor lines and the
              // status readout track the content instead of going stale.
              widget.onHoverWorld
                  ?.call(viewport.screenToWorld(details.localFocalPoint));
            },
            onScaleEnd: (_) {
              // No suppression guard: a pan interrupted by a stylus
              // landing must still reset its state here.
              if (_toolDrag) widget.onDragEndWorld?.call();
              _toolDrag = false;
              if (_panning && !_stylus.isActive) {
                setState(() => _panning = false);
              }
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
                  previewFillPaths: widget.previewFillPaths,
                  selectionHighlights: widget.selectionHighlights,
                  previewFillColor: widget.previewFillColor,
                  hiddenObjectId: widget.hiddenObjectId,
                  previewWidths: widget.previewWidths,
                  markers: widget.markers,
                  stitches: widget.stitches,
                  highlightStitches: widget.highlightStitches,
                  showOutlines: widget.showOutlines,
                  showNeedleHoles: widget.showNeedleHoles,
                  paintedCursor: widget.paintedCursor,
                  paintedCursorWorld: widget.paintedCursorWorld,
                  boxTransform: widget.boxTransform,
                  cursorLabel: widget.cursorLabel,
                  cursorLabelWorld: widget.cursorLabelWorld,
                  liveGuide: widget.liveGuide,
                  hideGuideId: widget.hideGuideId,
                  colorScheme: Theme.of(context).colorScheme,
                ),
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
    required this.previewFillPaths,
    required this.selectionHighlights,
    required this.previewFillColor,
    required this.hiddenObjectId,
    required this.previewWidths,
    required this.markers,
    required this.stitches,
    required this.highlightStitches,
    required this.showOutlines,
    required this.showNeedleHoles,
    required this.paintedCursor,
    required this.paintedCursorWorld,
    required this.boxTransform,
    required this.cursorLabel,
    required this.cursorLabelWorld,
    required this.liveGuide,
    required this.hideGuideId,
    required this.colorScheme,
  });

  final Document document;
  final ViewportController viewport;
  final Set<Id> selectedIds;
  final g.Bounds? selectionBounds;
  final List<g.Path> previewPaths;
  final List<g.Path> previewFillPaths;
  final List<g.Path> selectionHighlights;
  final String? previewFillColor;
  final Id? hiddenObjectId;
  final List<double>? previewWidths;
  final List<g.Point> markers;
  final StitchSequence? stitches;
  final List<StitchOp> highlightStitches;
  final bool showOutlines;
  final bool showNeedleHoles;
  final PaintedCursor? paintedCursor;
  final g.Point? paintedCursorWorld;
  final g.Transform2? boxTransform;
  final String? cursorLabel;
  final g.Point? cursorLabelWorld;
  final Guide? liveGuide;
  final Id? hideGuideId;
  final ColorScheme colorScheme;

  static const defaultGuideColor = Color(0xFF26C6DA);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGrid(canvas, size);
    _paintHoop(canvas);

    for (final object in document.flattenVisibleObjects()) {
      // The text object being edited is drawn by the live preview
      // instead — skip its committed geometry so they don't double up.
      if (object.id == hiddenObjectId) continue;
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
      // Pressure stroke (ADR-038): per-node widths, one round-capped
      // segment per node pair with the mean of its end widths.
      if (object case RunningStitchObject(:final widthProfile?)) {
        final points = object.path.toPolyline();
        if (points.length == widthProfile.length) {
          _paintVariableWidthPolyline(
              canvas, points, widthProfile, stroke.color);
          if (selectedIds.contains(object.id)) {
            _paintObjectSelection(canvas, object.bounds());
          }
          continue;
        }
      }
      // Build one screen path per contour; fill all closed contours as a
      // single even-odd path so holes (glyph counters 'O'/'e', fill holes)
      // stay empty, then stroke each contour on top.
      final screenPaths = <Path>[];
      final fillPath = Path()..fillType = PathFillType.evenOdd;
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
        screenPaths.add(path);
        if (contour.closed && props.fillHex != null) {
          fillPath.addPath(path, Offset.zero);
        }
      }
      if (props.fillHex != null) {
        canvas.drawPath(
          fillPath,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Color(
                0xFF000000 | int.parse(props.fillHex!.substring(1), radix: 16)),
        );
      }
      for (final path in screenPaths) {
        canvas.drawPath(path, stroke);
      }

      if (selectedIds.contains(object.id)) {
        _paintObjectSelection(canvas, object.bounds());
      }
    }

    _paintStitches(canvas);
    _paintHighlightStitches(canvas);
    // Guides sit above artwork and stitches (Illustrator convention) —
    // they are alignment chrome, not content, and must stay visible.
    _paintGuides(canvas, size);

    if (selectionBounds != null) {
      _paintSelectionBounds(canvas, selectionBounds!);
    }

    // Live selection highlight: translucent filled blocks behind the
    // preview glyphs (text selection reads as a block, not a border).
    if (selectionHighlights.isNotEmpty) {
      final highlight = Paint()
        ..style = PaintingStyle.fill
        ..color = colorScheme.primary.withValues(alpha: 0.3);
      for (final rect in selectionHighlights) {
        canvas.drawPath(_screenPath(rect), highlight);
      }
    }
    // Live glyph fill: editing text renders solid like the committed
    // object (even-odd so counters stay open).
    if (previewFillColor != null && previewFillPaths.isNotEmpty) {
      final fillPath = Path()..fillType = PathFillType.evenOdd;
      for (final p in previewFillPaths) {
        fillPath.addPath(_screenPath(p), Offset.zero);
      }
      canvas.drawPath(
        fillPath,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Color(0xFF000000 |
              int.parse(previewFillColor!.substring(1), radix: 16)),
      );
    }

    final overlay = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = colorScheme.primary;
    for (final (i, p) in previewPaths.indexed) {
      final points = p.toPolyline();
      // In-progress pencil stroke with pressure: preview the variable
      // width live instead of a hairline (ADR-038).
      if (i == 0 &&
          previewWidths != null &&
          previewWidths!.length == points.length) {
        _paintVariableWidthPolyline(
            canvas, points, previewWidths!, colorScheme.primary);
        continue;
      }
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

    _paintCursorGlyph(canvas);
    _paintCursorLabel(canvas);
  }

  /// One round-capped segment per node pair, width interpolated as the
  /// mean of its end widths (mm, zoom-scaled, min 1px) — ADR-038.
  void _paintVariableWidthPolyline(
      Canvas canvas, List<g.Point> points, List<double> widths, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    for (var i = 0; i < points.length - 1; i++) {
      paint.strokeWidth = ((widths[i] + widths[i + 1]) / 2 * viewport.zoom)
          .clamp(1.0, double.infinity);
      canvas.drawLine(viewport.worldToScreen(points[i]),
          viewport.worldToScreen(points[i + 1]), paint);
    }
  }

  /// Live transform feedback ("47.3°", "120% × 80%") in a small chip
  /// below-right of the pointer.
  void _paintCursorLabel(Canvas canvas) {
    final label = cursorLabel;
    final world = cursorLabelWorld;
    if (label == null || world == null) return;
    final p = viewport.worldToScreen(world);
    final text = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: 10, color: colorScheme.onSurface),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final rect =
        Rect.fromLTWH(p.dx + 14, p.dy + 14, text.width + 10, text.height + 6);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));
    canvas.drawRRect(rrect, Paint()..color = colorScheme.surface);
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = colorScheme.outline,
    );
    text.paint(canvas, rect.topLeft + const Offset(5, 3));
  }

  /// Painted cursor (system cursor is hidden): the pen nib with an
  /// action badge, a rotation arrow, or a diagonal resize arrow.
  void _paintCursorGlyph(Canvas canvas) {
    final kind = paintedCursor;
    final world = paintedCursorWorld;
    if (kind == null || world == null) return;
    final p = viewport.worldToScreen(world);
    switch (kind) {
      case PaintedCursor.rotate:
        _paintIconAt(canvas, LucideIcons.rotateCw, p, size: 16);
        return;
      case PaintedCursor.resizeNWSE:
        _paintDiagonalArrow(canvas, p, nwse: true);
        return;
      case PaintedCursor.resizeNESW:
        _paintDiagonalArrow(canvas, p, nwse: false);
        return;
      default:
        break; // pen family below
    }
    // Precision dot at the exact tip.
    canvas.drawCircle(p, 1.5, Paint()..color = colorScheme.onSurface);
    // Ink-pen nib glyph (Remix pen-nib-fill), tip anchored at the
    // pointer. The glyph points down, so its bottom-center sits on the
    // pointer position.
    const nib = RemixIcon.penNibFill;
    final pen = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(nib.codePoint),
        style: TextStyle(
          fontFamily: nib.fontFamily,
          package: nib.fontPackage,
          fontSize: 16,
          color: colorScheme.onSurface,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pen.paint(canvas, p + Offset(-pen.width / 2, -pen.height + 1));
    // State badge below-right of the glyph.
    final symbol = switch (kind) {
      PaintedCursor.penStart => '×',
      PaintedCursor.penAdd => '+',
      PaintedCursor.penRemove => '−',
      PaintedCursor.penClose => 'o',
      _ => '',
    };
    final center = p + const Offset(15, 6);
    canvas.drawCircle(center, 6, Paint()..color = colorScheme.surface);
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = colorScheme.onSurface.withValues(alpha: 0.6),
    );
    final label = TextPainter(
      text: TextSpan(
        text: symbol,
        style: TextStyle(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    label.paint(
        canvas, center - Offset(label.width / 2, label.height / 2 - 0.5));
  }

  /// Icon-font glyph centered at [p], with a surface halo for contrast.
  void _paintIconAt(Canvas canvas, IconData icon, Offset p,
      {double size = 16}) {
    canvas.drawCircle(p, size * 0.62,
        Paint()..color = colorScheme.surface.withValues(alpha: 0.7));
    final painter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: size,
          color: colorScheme.onSurface,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, p - Offset(painter.width / 2, painter.height / 2));
  }

  /// Double-headed diagonal resize arrow centered at [p] — macOS has no
  /// public diagonal-resize cursor, so the canvas paints one.
  void _paintDiagonalArrow(Canvas canvas, Offset p, {required bool nwse}) {
    const arm = 7.0, head = 4.0;
    final d = nwse ? const Offset(1, 1) : const Offset(1, -1);
    final a = p - d * arm, b = p + d * arm;
    final halo = Paint()
      ..color = colorScheme.surface
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final line = Paint()
      ..color = colorScheme.onSurface
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (final paint in [halo, line]) {
      canvas.drawLine(a, b, paint);
      // Arrowheads: two short strokes per end, perpendicular-ish.
      final along = d / d.distance;
      final side = Offset(-along.dy, along.dx);
      canvas.drawLine(a, a + along * head + side * head, paint);
      canvas.drawLine(a, a + along * head - side * head, paint);
      canvas.drawLine(b, b - along * head + side * head, paint);
      canvas.drawLine(b, b - along * head - side * head, paint);
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
    // Stroked paths with round joins (not per-segment drawLine): the
    // joint wedge at each needle point is filled, so the stitch layer
    // covers corners exactly like the outline stroke does.
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (0.4 * viewport.zoom).clamp(1.0, double.infinity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = threadColor(0);
    var run = Path();
    var penDown = false;
    void flush() {
      if (penDown) canvas.drawPath(run, paint);
      run = Path();
      penDown = false;
    }

    for (final op in sequence.ops) {
      final p = viewport.worldToScreen(op.position);
      switch (op.kind) {
        case StitchKind.stitch:
          penDown ? run.lineTo(p.dx, p.dy) : run.moveTo(p.dx, p.dy);
          penDown = true;
        case StitchKind.jump:
          flush();
          run.moveTo(p.dx, p.dy);
          penDown = true;
        case StitchKind.colorChange:
          flush();
          thread++;
          paint.color = threadColor(thread);
        case StitchKind.trim:
        case StitchKind.stop:
          break;
      }
    }
    flush();
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
      ..style = PaintingStyle.stroke
      ..strokeWidth = (0.5 * viewport.zoom).clamp(2.0, double.infinity)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colorScheme.secondary;
    final run = Path();
    var penDown = false;
    for (final op in highlightStitches) {
      final p = viewport.worldToScreen(op.position);
      switch (op.kind) {
        case StitchKind.stitch:
          penDown ? run.lineTo(p.dx, p.dy) : run.moveTo(p.dx, p.dy);
          penDown = true;
        case StitchKind.jump:
        case StitchKind.trim:
          run.moveTo(p.dx, p.dy);
          penDown = true;
        case StitchKind.colorChange:
        case StitchKind.stop:
          break;
      }
    }
    if (penDown) canvas.drawPath(run, paint);
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
    final guides = [
      for (final guide in document.guides)
        if (guide.id != hideGuideId) guide,
      if (liveGuide != null) liveGuide!,
    ];
    for (final guide in guides) {
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

  /// Transform box: hairline frame, eight resize handles, and the
  /// rotation grip above the top edge. Handle positions must match
  /// SelectTool's hit-testing (same bounds, 22 px rotation offset).
  /// During a drag [boxTransform] is applied first, so the box follows
  /// the object live — a rotating object shows a rotating box.
  void _paintSelectionBounds(Canvas canvas, g.Bounds bounds) {
    final t = boxTransform;
    Offset at(double x, double y) {
      final p = g.Point(x, y);
      return viewport.worldToScreen(t == null ? p : t.apply(p));
    }

    final cx = (bounds.minX + bounds.maxX) / 2;
    final cy = (bounds.minY + bounds.maxY) / 2;
    // Corner + edge-midpoint handle positions, clockwise from NW.
    final nw = at(bounds.minX, bounds.minY);
    final n = at(cx, bounds.minY);
    final ne = at(bounds.maxX, bounds.minY);
    final e = at(bounds.maxX, cy);
    final se = at(bounds.maxX, bounds.maxY);
    final s = at(cx, bounds.maxY);
    final sw = at(bounds.minX, bounds.maxY);
    final w = at(bounds.minX, cy);

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = colorScheme.primary;
    final fill = Paint()..color = colorScheme.surface;

    canvas.drawPath(
      Path()
        ..moveTo(nw.dx, nw.dy)
        ..lineTo(ne.dx, ne.dy)
        ..lineTo(se.dx, se.dy)
        ..lineTo(sw.dx, sw.dy)
        ..close(),
      edge,
    );
    // Rotation grip: stem + circle 22 px outward along the top edge's
    // normal (points "up" for an unrotated box).
    final topEdge = ne - nw;
    final normal = topEdge.distance <= 1e-6
        ? const Offset(0, -1)
        : Offset(topEdge.dy, -topEdge.dx) / topEdge.distance;
    final grip = n + normal * 22;
    canvas.drawLine(n, grip, edge);
    canvas.drawCircle(grip, 4.5, fill);
    canvas.drawCircle(grip, 4.5, edge);
    for (final center in [nw, n, ne, e, se, s, sw, w]) {
      final handleRect = Rect.fromCenter(center: center, width: 8, height: 8);
      canvas.drawRect(handleRect, fill);
      canvas.drawRect(handleRect, edge);
    }
  }

  /// Flattens a world-space contour into a screen-space [Path].
  Path _screenPath(g.Path contour) {
    final points = contour.toPolyline();
    final path = Path();
    if (points.isEmpty) return path;
    final first = viewport.worldToScreen(points.first);
    path.moveTo(first.dx, first.dy);
    for (final p in points.skip(1)) {
      final o = viewport.worldToScreen(p);
      path.lineTo(o.dx, o.dy);
    }
    if (contour.closed) path.close();
    return path;
  }

  @override
  bool shouldRepaint(_DesignPainter oldDelegate) =>
      oldDelegate.document.revision != document.revision ||
      oldDelegate.selectedIds.length != selectedIds.length ||
      !oldDelegate.selectedIds.containsAll(selectedIds) ||
      oldDelegate.selectionBounds != selectionBounds ||
      oldDelegate.previewPaths != previewPaths ||
      oldDelegate.previewFillPaths != previewFillPaths ||
      oldDelegate.selectionHighlights != selectionHighlights ||
      oldDelegate.previewFillColor != previewFillColor ||
      oldDelegate.hiddenObjectId != hiddenObjectId ||
      oldDelegate.markers != markers ||
      oldDelegate.stitches != stitches ||
      oldDelegate.highlightStitches != highlightStitches ||
      oldDelegate.paintedCursor != paintedCursor ||
      oldDelegate.paintedCursorWorld != paintedCursorWorld ||
      oldDelegate.boxTransform != boxTransform ||
      oldDelegate.cursorLabel != cursorLabel ||
      oldDelegate.cursorLabelWorld != cursorLabelWorld ||
      oldDelegate.showOutlines != showOutlines ||
      oldDelegate.showNeedleHoles != showNeedleHoles ||
      oldDelegate.viewport != viewport;
}
