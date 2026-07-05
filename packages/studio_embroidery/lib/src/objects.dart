import 'package:studio_core/studio_core.dart';
import 'package:studio_geometry/studio_geometry.dart';

/// An embroidery design element: geometry plus stitch parameters.
/// Immutable — editing replaces the object via commands.
sealed class EmbroideryObject {
  const EmbroideryObject({required this.id, required this.path});

  final Id id;
  final Path path;

  /// A copy of this object with [path] replaced (same id and params).
  EmbroideryObject withPath(Path path);
}

/// A running stitch along the path.
final class RunningStitchObject extends EmbroideryObject {
  const RunningStitchObject({
    required super.id,
    required super.path,
    this.stitchLength = 2.5,
  });

  /// Target stitch length in mm.
  final double stitchLength;

  @override
  RunningStitchObject withPath(Path path) =>
      RunningStitchObject(id: id, path: path, stitchLength: stitchLength);
}

// ponytail: satin/fill are declared so the object model is complete,
// but their generators land in a later sprint (skeleton per MVP-S4-T2).

/// A satin column along the path. Generator not implemented yet.
final class SatinObject extends EmbroideryObject {
  const SatinObject({required super.id, required super.path, this.width = 3.0});

  /// Column width in mm.
  final double width;

  @override
  SatinObject withPath(Path path) =>
      SatinObject(id: id, path: path, width: width);
}

/// A region fill bounded by the (closed) path. Generator not
/// implemented yet.
final class FillObject extends EmbroideryObject {
  const FillObject(
      {required super.id, required super.path, this.spacing = 0.4});

  /// Fill line spacing in mm.
  final double spacing;

  @override
  FillObject withPath(Path path) =>
      FillObject(id: id, path: path, spacing: spacing);
}
