/// Machine model, Machine IR, compiler and validation.
///
/// Owns the **Machine IR** (ARCH-001): the machine-independent hardware
/// representation bridging Stitch IR and binary export formats. It
/// stores integer machine-unit deltas — never DST/PES/JEF bytes.
library;

export 'src/compiler.dart';
export 'src/machine_ir.dart';
export 'src/machine_model.dart';
