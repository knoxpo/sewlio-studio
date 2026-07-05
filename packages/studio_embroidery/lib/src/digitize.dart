import 'objects.dart';
import 'running_stitch.dart';
import 'stitch_ir.dart';

/// Digitizes [objects] into one Stitch IR sequence: each object's
/// stitches, joined by a trim + jump to the next object's start.
/// Objects without a generator yet (satin/fill) are skipped and
/// reported in [skipped].
StitchSequence digitizeObjects(
  Iterable<EmbroideryObject> objects, {
  Thread thread = const Thread('#000000'),
  List<EmbroideryObject>? skipped,
}) {
  final ops = <StitchOp>[];
  for (final object in objects) {
    final List<StitchOp> stitches;
    try {
      stitches = generateStitches(object);
    } on UnimplementedError {
      skipped?.add(object);
      continue;
    }
    if (stitches.isEmpty) continue;
    if (ops.isNotEmpty) {
      ops
        ..add(StitchOp(StitchKind.trim, ops.last.position))
        ..add(StitchOp.jump(stitches.first.position));
    }
    ops.addAll(stitches);
  }
  return StitchSequence(threads: [thread], ops: ops);
}
