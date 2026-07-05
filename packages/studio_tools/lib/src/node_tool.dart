import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'selection.dart';
import 'tool.dart';

/// Edits path anchors of the selected object: tap to select an object,
/// drag an anchor to move it. Each drag commits one undoable
/// [ReplaceObject].
// ponytail: anchors only — cubic control handles keep their absolute
// positions (curve distorts near the moved anchor). Handle editing
// comes with the full node editor.
final class NodeTool extends Tool {
  NodeTool({
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
  final double hitToleranceMm;

  int? _dragIndex;
  Path? _previewPath;

  EmbroideryObjectView? get _selected {
    final id = selection.selected;
    if (id == null) return null;
    final object = document.objectById(id);
    if (object == null) return null;
    return EmbroideryObjectView(object);
  }

  @override
  void tap(Point world) {
    // Tap selects the topmost object whose bounds contain the point,
    // mirroring SelectTool, so the node tool works standalone.
    for (final object in document.objects.reversed) {
      final b = object.path.bounds();
      if (world.x >= b.minX - hitToleranceMm &&
          world.x <= b.maxX + hitToleranceMm &&
          world.y >= b.minY - hitToleranceMm &&
          world.y <= b.maxY + hitToleranceMm) {
        selection.select(object.id);
        return;
      }
    }
    selection.select(null);
  }

  @override
  bool dragStart(Point world) {
    final view = _selected;
    if (view == null) return false;
    final anchors = view.anchors;
    for (var i = 0; i < anchors.length; i++) {
      if (anchors[i].distanceTo(world) <= hitToleranceMm) {
        _dragIndex = i;
        _previewPath = view.withAnchor(i, world);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  @override
  void dragUpdate(Point world) {
    final view = _selected;
    final index = _dragIndex;
    if (view == null || index == null) return;
    _previewPath = view.withAnchor(index, world);
    notifyListeners();
  }

  @override
  void dragEnd() {
    final view = _selected;
    final path = _previewPath;
    _dragIndex = null;
    _previewPath = null;
    if (view != null && path != null) {
      history.execute(ReplaceObject(view.object.withPath(path)));
    }
    notifyListeners();
  }

  @override
  void cancel() {
    _dragIndex = null;
    _previewPath = null;
    notifyListeners();
  }

  @override
  List<Path> get preview => [if (_previewPath != null) _previewPath!];

  @override
  List<Point> get markers => _previewPath != null
      ? EmbroideryObjectView.anchorsOf(_previewPath!)
      : _selected?.anchors ?? const [];

  @override
  String? get status => _selected == null
      ? 'Node: tap an object to edit its points'
      : 'Node: drag an anchor to move it';
}

/// Anchor-level view over an object's path.
final class EmbroideryObjectView {
  EmbroideryObjectView(this.object);

  final EmbroideryObject object;

  List<Point> get anchors => anchorsOf(object.path);

  static List<Point> anchorsOf(Path path) =>
      [path.start, for (final s in path.segments) s.end];

  /// The path with anchor [index] moved to [position].
  Path withAnchor(int index, Point position) {
    final path = object.path;
    if (index == 0) {
      return Path(
          start: position, segments: path.segments, closed: path.closed);
    }
    final segments = List<Segment>.of(path.segments);
    segments[index - 1] = switch (segments[index - 1]) {
      LineSegment() => LineSegment(position),
      CubicSegment(:final c1, :final c2) => CubicSegment(c1, c2, position),
    };
    return Path(start: path.start, segments: segments, closed: path.closed);
  }
}
