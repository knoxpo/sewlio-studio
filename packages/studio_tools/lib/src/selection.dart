import 'package:flutter/foundation.dart';
import 'package:studio_core/studio_core.dart';

/// Which object is selected. View state, not document state.
final class SelectionController extends ChangeNotifier {
  Id? _selected;

  Id? get selected => _selected;

  void select(Id? id) {
    if (id == _selected) return;
    _selected = id;
    notifyListeners();
  }
}
