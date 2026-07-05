import 'package:studio_core/studio_core.dart';

/// Root of the in-memory project document.
///
/// Mutable, but only command handlers may mutate it — everything else
/// reads. Grows domain content (layers, objects, assets) in later
/// sprints; for now it carries identity, a name, and a revision counter
/// handlers bump on every mutation.
// ponytail: skeleton — layers/objects/assets land with the domain
// packages that own them (S3+).
final class Document {
  Document({required this.id, this.name = 'Untitled'});

  final Id id;
  String name;

  /// Incremented by handlers on every mutation. Lets observers cheaply
  /// detect "document changed" without diffing.
  int revision = 0;
}
