/// Embroidery object model, Stitch IR, and stitch generators.
///
/// Owns the **Stitch IR** (ARCH-001): the machine-independent
/// embroidery representation. Every stitch algorithm outputs Stitch IR;
/// it never contains machine bytes, needle indexes, or format encoding.
library;

export 'src/digitize.dart';
export 'src/objects.dart';
export 'src/running_stitch.dart';
export 'src/stitch_ir.dart';
