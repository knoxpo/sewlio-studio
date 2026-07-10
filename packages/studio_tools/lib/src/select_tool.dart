import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_core/studio_core.dart';

import 'selection.dart';
import 'tool.dart';

enum _SelectDragMode { move, marquee }

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

  Point? _dragStart;
  Point _dragCurrent = Point.zero;
  _SelectDragMode? _dragMode;
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

  @override
  bool dragStart(Point world) => dragStartWithModifiers(world);

  bool dragStartWithModifiers(
    Point world, {
    bool toggle = false,
    bool extend = false,
  }) {
    _toggle = toggle;
    _extend = extend;
    final hit = hitTest(world);
    _dragStart = world;
    _dragCurrent = world;
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
    notifyListeners();
  }

  @override
  void dragEnd() {
    final start = _dragStart;
    final mode = _dragMode;
    _dragStart = null;
    _dragMode = null;
    notifyListeners();
    if (start == null || mode == null) return;

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
  String? get status =>
      'Select: click to select, Cmd/Ctrl/Shift to multi-select, drag to move or marquee';
}
