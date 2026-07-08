import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import 'guide.dart';

/// Root of the in-memory project document.
///
/// Mutable, but only command handlers may mutate it — everything else
/// reads.
// ponytail: flat object list, no layers/groups — add a layer tree when
// a design outgrows one list.
final class Document {
  Document({required this.id, this.name = 'Untitled'});

  final Id id;
  String name;

  /// Design elements in stacking order.
  final List<EmbroideryObject> objects = [];

  /// Ruler guides.
  final List<Guide> guides = [];

  Guide? guideById(Id id) {
    for (final guide in guides) {
      if (guide.id == id) return guide;
    }
    return null;
  }

  /// Incremented by handlers on every mutation. Lets observers cheaply
  /// detect "document changed" without diffing.
  int revision = 0;

  EmbroideryObject? objectById(Id id) {
    for (final object in objects) {
      if (object.id == id) return object;
    }
    return null;
  }
}
