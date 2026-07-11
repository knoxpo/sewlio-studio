import 'dart:math' as math;

import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_core/studio_core.dart';

import 'selection.dart';
import 'tool.dart';

enum _SelectDragMode { move, marquee, resize, rotate }

/// The transform bounding box's interactive handles: eight resize
/// handles plus the rotation grip above the top edge.
enum TransformHandle { nw, n, ne, e, se, s, sw, w, rotate }

/// Selects objects on tap and moves the selection by dragging.
/// The whole drag becomes one undoable [TransformSelection] command,
/// dispatched on release.
final class SelectTool extends Tool {
  SelectTool({
    required this.document,
    required this.history,
    required this.selection,
    this.hitToleranceMm = 1.5,
  }) {
    selection.addListener(notifyListeners);
  }

  final Document document;
  final History history;
  final SelectionController selection;

  /// How far (mm) a tap may miss an object's bounds and still hit it.
  final double hitToleranceMm;

  /// Rotation grip distance above the top edge / handle hit radius, in
  /// screen px (converted through [pxPerMm]). The canvas painter draws
  /// the box with the same numbers — keep them in sync.
  static const rotationOffsetPx = 22.0;
  static const handleHitPx = 6.0;

  /// Screen px per world mm (viewport zoom) — the shell updates this
  /// before pointer events so handle hit areas stay a constant screen
  /// size at any zoom.
  double pxPerMm = 1;

  /// Modifier state, fed by the shell: Shift = uniform corner scaling /
  /// 15° rotation snapping; Alt = scale from the selection center.
  bool uniformModifier = false;
  bool centerModifier = false;

  Point? _dragStart;
  Point _dragCurrent = Point.zero;
  _SelectDragMode? _dragMode;
  TransformHandle? _activeHandle;
  Bounds? _startBounds;
  Transform2? _liveTransform;
  double _liveAngleDeg = 0;
  (double, double) _liveScale = (1, 1);
  bool _toggle = false;
  bool _extend = false;

  @override
  void tap(Point world) => tapWithModifiers(world);

  void tapWithModifiers(
    Point world, {
    bool toggle = false,
    bool extend = false,
  }) {
    final hit = hitTest(world);
    if (hit == null) {
      if (!toggle && !extend) selection.clear();
      return;
    }
    if (toggle || extend) {
      selection.toggle(hit);
      return;
    }
    selection.replaceWith(hit);
  }

  /// Topmost visible, unlocked object whose bounds (inflated by
  /// [hitToleranceMm]) contain [world].
  // ponytail: bbox hit test — switch to distance-to-polyline when
  // overlapping objects make bbox picks feel wrong.
  DocumentNodeRef? hitTest(Point world) {
    for (final object in document.flattenVisibleObjects().reversed) {
      if (document.isObjectLocked(object.id)) continue;
      final b = object.bounds();
      final inflated = Bounds(
        b.minX - hitToleranceMm,
        b.minY - hitToleranceMm,
        b.maxX + hitToleranceMm,
        b.maxY + hitToleranceMm,
      );
      if (inflated.contains(world)) {
        return DocumentNodeRef(DocumentNodeKind.object, object.id);
      }
    }
    return null;
  }

  // ------------------------------------------------------ transform box

  /// Bounds of the current selection (the transform box), or null.
  Bounds? get selectionBounds => selection.selectedRefs.isEmpty
      ? null
      : document.selectionBounds(selection.selectedRefs);

  Point _handlePoint(Bounds b, TransformHandle handle) {
    final cx = (b.minX + b.maxX) / 2, cy = (b.minY + b.maxY) / 2;
    return switch (handle) {
      TransformHandle.nw => Point(b.minX, b.minY),
      TransformHandle.n => Point(cx, b.minY),
      TransformHandle.ne => Point(b.maxX, b.minY),
      TransformHandle.e => Point(b.maxX, cy),
      TransformHandle.se => Point(b.maxX, b.maxY),
      TransformHandle.s => Point(cx, b.maxY),
      TransformHandle.sw => Point(b.minX, b.maxY),
      TransformHandle.w => Point(b.minX, cy),
      TransformHandle.rotate => Point(cx, b.minY - rotationOffsetPx / pxPerMm),
    };
  }

  static const _opposite = {
    TransformHandle.nw: TransformHandle.se,
    TransformHandle.n: TransformHandle.s,
    TransformHandle.ne: TransformHandle.sw,
    TransformHandle.e: TransformHandle.w,
    TransformHandle.se: TransformHandle.nw,
    TransformHandle.s: TransformHandle.n,
    TransformHandle.sw: TransformHandle.ne,
    TransformHandle.w: TransformHandle.e,
  };

  /// The handle under [world], if the selection box is active.
  TransformHandle? handleAt(Point world) {
    final b = selectionBounds;
    if (b == null) return null;
    final tolerance = handleHitPx / pxPerMm;
    for (final handle in TransformHandle.values) {
      if (world.distanceTo(_handlePoint(b, handle)) <= tolerance) {
        return handle;
      }
    }
    return null;
  }

  @override
  bool dragStart(Point world) => dragStartWithModifiers(world);

  bool dragStartWithModifiers(
    Point world, {
    bool toggle = false,
    bool extend = false,
  }) {
    _toggle = toggle;
    _extend = extend;
    _dragStart = world;
    _dragCurrent = world;
    final handle = handleAt(world);
    if (handle != null) {
      _activeHandle = handle;
      _startBounds = selectionBounds;
      _liveTransform = null;
      _dragMode = handle == TransformHandle.rotate
          ? _SelectDragMode.rotate
          : _SelectDragMode.resize;
      notifyListeners();
      return true;
    }
    final hit = hitTest(world);
    if (hit != null && _selectedObjectIds.contains(hit.id)) {
      _dragMode = _SelectDragMode.move;
      notifyListeners();
      return true;
    }
    _dragMode = _SelectDragMode.marquee;
    notifyListeners();
    return true;
  }

  @override
  void dragUpdate(Point world) {
    _dragCurrent = world;
    switch (_dragMode) {
      case _SelectDragMode.resize:
        _liveTransform = _resizeTransform(world);
      case _SelectDragMode.rotate:
        _liveTransform = _rotateTransform(world);
      case _SelectDragMode.move:
        final delta = world - _dragStart!;
        _liveTransform = Transform2.translation(delta.x, delta.y);
      default:
        break;
    }
    notifyListeners();
  }

  /// The in-progress drag transform (move/resize/rotate), or null when
  /// idle — the canvas draws the transform box through it so the box
  /// follows the object live (rotates while rotating, etc.).
  Transform2? get liveTransform => _liveTransform;

  /// Live feedback for the pointer tooltip while transforming.
  String? get liveTransformLabel => switch (_dragMode) {
        _SelectDragMode.rotate => '${_liveAngleDeg.toStringAsFixed(1)}°',
        _SelectDragMode.resize => '${(_liveScale.$1 * 100).round()}% × '
            '${(_liveScale.$2 * 100).round()}%',
        _ => null,
      };

  /// Scale about the opposite handle (or the center with Alt); Shift
  /// keeps corner scaling uniform. One [Transform2], so the same code
  /// path extends to skew/free transform later.
  Transform2 _resizeTransform(Point world) {
    final b = _startBounds!;
    final handle = _activeHandle!;
    final anchor = centerModifier
        ? Point((b.minX + b.maxX) / 2, (b.minY + b.maxY) / 2)
        : _handlePoint(b, _opposite[handle]!);
    final from = _handlePoint(b, handle);
    final affectsX = handle != TransformHandle.n && handle != TransformHandle.s;
    final affectsY = handle != TransformHandle.e && handle != TransformHandle.w;
    double scaleFor(double current, double start, double anchorC) {
      final denominator = start - anchorC;
      if (denominator.abs() <= epsilon) return 1;
      final s = (current - anchorC) / denominator;
      if (!s.isFinite || s.abs() < 0.01) return s.isNegative ? -0.01 : 0.01;
      return s;
    }

    var sx = affectsX ? scaleFor(world.x, from.x, anchor.x) : 1.0;
    var sy = affectsY ? scaleFor(world.y, from.y, anchor.y) : 1.0;
    if (uniformModifier && affectsX && affectsY) {
      final s = sx.abs() > sy.abs() ? sx : sy;
      sx = s.abs() * sx.sign;
      sy = s.abs() * sy.sign;
    }
    _liveScale = (sx, sy);
    return Transform2.translation(anchor.x, anchor.y) *
        Transform2.scaling(sx, sy) *
        Transform2.translation(-anchor.x, -anchor.y);
  }

  /// Rotate about the selection center; Shift snaps to 15° steps.
  Transform2 _rotateTransform(Point world) {
    final b = _startBounds!;
    final pivot = Point((b.minX + b.maxX) / 2, (b.minY + b.maxY) / 2);
    final from = _handlePoint(b, TransformHandle.rotate);
    final a0 = math.atan2(from.y - pivot.y, from.x - pivot.x);
    final a1 = math.atan2(world.y - pivot.y, world.x - pivot.x);
    var angle = a1 - a0;
    if (uniformModifier) {
      const step = math.pi / 12; // 15°
      angle = (angle / step).round() * step;
    }
    _liveAngleDeg = angle * 180 / math.pi;
    return Transform2.translation(pivot.x, pivot.y) *
        Transform2.rotation(angle) *
        Transform2.translation(-pivot.x, -pivot.y);
  }

  @override
  void dragEnd() {
    final start = _dragStart;
    final mode = _dragMode;
    final transform = _liveTransform;
    _dragStart = null;
    _dragMode = null;
    _activeHandle = null;
    _startBounds = null;
    _liveTransform = null;
    notifyListeners();
    if (start == null || mode == null) return;

    if (mode == _SelectDragMode.resize || mode == _SelectDragMode.rotate) {
      if (transform != null) {
        history.execute(TransformSelection(selection.selectedRefs, transform));
      }
      return;
    }

    if (mode == _SelectDragMode.move) {
      final delta = _dragCurrent - start;
      if (delta.length <= epsilon) return;
      history.execute(
        TransformSelection(
            selection.selectedRefs, Transform2.translation(delta.x, delta.y)),
      );
      return;
    }

    final bounds = Bounds(
      start.x < _dragCurrent.x ? start.x : _dragCurrent.x,
      start.y < _dragCurrent.y ? start.y : _dragCurrent.y,
      start.x > _dragCurrent.x ? start.x : _dragCurrent.x,
      start.y > _dragCurrent.y ? start.y : _dragCurrent.y,
    );
    final hits = [
      for (final object in document.flattenVisibleObjects())
        if (!document.isObjectLocked(object.id) &&
            _overlaps(bounds, object.bounds()))
          DocumentNodeRef(DocumentNodeKind.object, object.id)
    ];
    if (_toggle || _extend) {
      final next = [...selection.selectedRefs];
      for (final ref in hits) {
        if (next.contains(ref)) {
          next.remove(ref);
        } else {
          next.add(ref);
        }
      }
      selection.setAll(next);
      return;
    }
    selection.setAll(hits);
  }

  bool _overlaps(Bounds a, Bounds b) =>
      a.minX <= b.maxX &&
      a.maxX >= b.minX &&
      a.minY <= b.maxY &&
      a.maxY >= b.minY;

  @override
  void cancel() {
    _dragStart = null;
    _dragMode = null;
    _activeHandle = null;
    _startBounds = null;
    _liveTransform = null;
    notifyListeners();
  }

  Set<Id> get _selectedObjectIds => {
        for (final ref in selection.selectedRefs)
          ...document.subtreeObjectIds(ref),
      };

  @override
  List<Path> get preview {
    final start = _dragStart;
    if (start == null || _dragMode == null) return const [];
    if (_dragMode == _SelectDragMode.resize ||
        _dragMode == _SelectDragMode.rotate) {
      final t = _liveTransform;
      if (t == null) return const [];
      return [
        for (final id in _selectedObjectIds)
          if (document.objectById(id) case final object?)
            for (final contour in object.renderPaths) contour.transformed(t),
      ];
    }
    if (_dragMode == _SelectDragMode.move) {
      final delta = _dragCurrent - start;
      return [
        for (final id in _selectedObjectIds)
          if (document.objectById(id) case final object?)
            for (final contour in object.renderPaths)
              contour.transformed(Transform2.translation(delta.x, delta.y)),
      ];
    }
    return [
      Path(
        start: start,
        segments: [
          LineSegment(Point(_dragCurrent.x, start.y)),
          LineSegment(_dragCurrent),
          LineSegment(Point(start.x, _dragCurrent.y)),
        ],
        closed: true,
      )
    ];
  }

  @override
  String? get status => switch (_dragMode) {
        _SelectDragMode.rotate => 'Rotate: '
            '${_liveAngleDeg.toStringAsFixed(1)}° — Shift snaps to 15°',
        _SelectDragMode.resize => 'Scale: '
            '${(_liveScale.$1 * 100).toStringAsFixed(0)}% × '
            '${(_liveScale.$2 * 100).toStringAsFixed(0)}% — '
            'Shift uniform, Alt from center',
        _ => 'Select: click to select, Cmd/Ctrl/Shift to multi-select, '
            'drag to move or marquee',
      };

  static const _handleCursors = {
    TransformHandle.nw: ToolCursor.resizeNWSE,
    TransformHandle.se: ToolCursor.resizeNWSE,
    TransformHandle.ne: ToolCursor.resizeNESW,
    TransformHandle.sw: ToolCursor.resizeNESW,
    TransformHandle.n: ToolCursor.resizeNS,
    TransformHandle.s: ToolCursor.resizeNS,
    TransformHandle.e: ToolCursor.resizeEW,
    TransformHandle.w: ToolCursor.resizeEW,
    TransformHandle.rotate: ToolCursor.rotate,
  };

  @override
  ToolCursor cursorAt(Point world) {
    // Mid-drag: the cursor reflects the active interaction.
    switch (_dragMode) {
      case _SelectDragMode.move:
        return ToolCursor.grabbing;
      case _SelectDragMode.marquee:
        return ToolCursor.crosshair;
      case _SelectDragMode.resize:
        return _handleCursors[_activeHandle]!;
      case _SelectDragMode.rotate:
        return ToolCursor.rotate;
      case null:
        break;
    }
    final handle = handleAt(world);
    if (handle != null) return _handleCursors[handle]!;
    final hit = hitTest(world);
    if (hit != null && _selectedObjectIds.contains(hit.id)) {
      // Inside the selection: open hand — press-and-drag closes it.
      return ToolCursor.grab;
    }
    return ToolCursor.basic;
  }
}
