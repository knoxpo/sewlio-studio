import 'package:flutter/foundation.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';

/// Which hierarchy nodes are selected. View state, not document state.
final class SelectionController extends ChangeNotifier {
  final List<DocumentNodeRef> _selected = [];

  List<DocumentNodeRef> get selectedRefs => List.unmodifiable(_selected);

  DocumentNodeRef? get primarySelectedRef =>
      _selected.isEmpty ? null : _selected.last;

  DocumentNodeRef? get firstSelectedRef =>
      _selected.isEmpty ? null : _selected.first;

  Id? get selected => primarySelectedRef?.kind == DocumentNodeKind.object
      ? primarySelectedRef!.id
      : null;

  List<Id> get selectedIds => [
        for (final ref in _selected)
          if (ref.kind == DocumentNodeKind.object) ref.id,
      ];

  bool contains(DocumentNodeRef ref) => _selected.contains(ref);

  void replaceWith(DocumentNodeRef? ref) {
    if (ref == null) {
      clear();
      return;
    }
    if (_selected.length == 1 && _selected.single == ref) return;
    _selected
      ..clear()
      ..add(ref);
    notifyListeners();
  }

  void select(Id? id) => replaceWith(
      id == null ? null : DocumentNodeRef(DocumentNodeKind.object, id));

  void setAll(Iterable<DocumentNodeRef> refs) {
    final next = refs.toList(growable: false);
    if (listEquals(_selected, next)) return;
    _selected
      ..clear()
      ..addAll(next);
    notifyListeners();
  }

  void add(DocumentNodeRef ref) {
    if (_selected.contains(ref)) return;
    _selected.add(ref);
    notifyListeners();
  }

  void toggle(DocumentNodeRef ref) {
    final index = _selected.indexOf(ref);
    if (index >= 0) {
      _selected.removeAt(index);
    } else {
      _selected.add(ref);
    }
    notifyListeners();
  }

  void clear() {
    if (_selected.isEmpty) return;
    _selected.clear();
    notifyListeners();
  }
}
