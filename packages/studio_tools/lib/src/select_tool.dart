import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'selection.dart';

/// Selects objects on tap and moves the selection by dragging.
/// The whole drag becomes one undoable [TransformObject] command,
/// dispatched on release.
final class SelectTool {
  SelectTool({
    required this.document,
    required this.history,
    required this.selection,
    this.hitToleranceMm = 1.5,
  });

  final Document document;
  final History history;
  final SelectionController selection;

  /// How far (mm) a tap may miss an object's bounds and still hit it.
  final double hitToleranceMm;

  Point? _dragStart;
  Point _dragCurrent = Point.zero;

  /// Selects the topmost object at [world], or clears the selection.
  void tap(Point world) => selection.select(hitTest(world));

  /// Topmost object whose bounds (inflated by [hitToleranceMm])
  /// contain [world].
  // ponytail: bbox hit test — switch to distance-to-polyline when
  // overlapping objects make bbox picks feel wrong.
  Id? hitTest(Point world) {
    for (final object in document.objects.reversed) {
      final b = object.path.bounds();
      final inflated = Bounds(
        b.minX - hitToleranceMm,
        b.minY - hitToleranceMm,
        b.maxX + hitToleranceMm,
        b.maxY + hitToleranceMm,
      );
      if (inflated.contains(world)) return object.id;
    }
    return null;
  }

  /// Starts a move drag. Returns true (claims the gesture) when the
  /// drag begins on the current selection.
  bool dragStart(Point world) {
    final id = selection.selected;
    if (id == null) return false;
    final object = document.objectById(id);
    if (object == null) return false;
    final b = object.path.bounds();
    final inflated = Bounds(
      b.minX - hitToleranceMm,
      b.minY - hitToleranceMm,
      b.maxX + hitToleranceMm,
      b.maxY + hitToleranceMm,
    );
    if (!inflated.contains(world)) return false;
    _dragStart = world;
    _dragCurrent = world;
    return true;
  }

  void dragUpdate(Point world) => _dragCurrent = world;

  /// Commits the move as a single undoable command. No-op for a drag
  /// that went nowhere.
  void dragEnd() {
    final start = _dragStart;
    final id = selection.selected;
    _dragStart = null;
    if (start == null || id == null) return;
    final delta = _dragCurrent - start;
    if (delta.length <= epsilon) return;
    history
        .execute(TransformObject(id, Transform2.translation(delta.x, delta.y)));
  }
}
