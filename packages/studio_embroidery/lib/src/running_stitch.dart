import 'package:studio_geometry/studio_geometry.dart';

import 'objects.dart';
import 'stitch_ir.dart';

/// Generates stitch ops for one object. Dispatches on object type;
/// satin/fill throw [UnimplementedError] until their sprint.
List<StitchOp> generateStitches(EmbroideryObject object) => switch (object) {
      RunningStitchObject(:final path, :final stitchLength) =>
        generateRunningStitch(path, stitchLength: stitchLength),
      SatinObject() =>
        throw UnimplementedError('Satin generator lands post-MVP-S4'),
      FillObject() =>
        throw UnimplementedError('Fill generator lands post-MVP-S4'),
    };

/// Resamples [path] into evenly spaced stitches of ~[stitchLength] mm.
///
/// Deterministic: same path + params → same ops. The spacing is
/// recomputed per polyline span so stitches divide the span evenly and
/// the last stitch always lands exactly on the path end.
List<StitchOp> generateRunningStitch(
  Path path, {
  double stitchLength = 2.5,
  double tolerance = 0.01,
}) {
  if (stitchLength <= 0) {
    throw ArgumentError.value(stitchLength, 'stitchLength', 'must be > 0 mm');
  }
  final polyline = path.toPolyline(tolerance: tolerance);
  final ops = <StitchOp>[StitchOp.stitch(polyline.first)];
  var last = polyline.first;
  var carried = 0.0; // distance already walked toward the next stitch
  for (var i = 1; i < polyline.length; i++) {
    final target = polyline[i];
    var span = last.distanceTo(target);
    var from = last;
    while (carried + span >= stitchLength) {
      final t = (stitchLength - carried) / span;
      final p = from.lerp(target, t);
      ops.add(StitchOp.stitch(p));
      span -= stitchLength - carried;
      carried = 0;
      from = p;
    }
    carried += span;
    last = target;
  }
  // Close out on the exact path end (skip if it coincides with the
  // previous stitch).
  if (!ops.last.position.almostEquals(last, tolerance: 1e-6)) {
    ops.add(StitchOp.stitch(last));
  }
  return ops;
}
