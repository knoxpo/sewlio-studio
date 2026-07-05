/// Machine units per millimeter. Embroidery hardware and formats (DST,
/// EXP) address in 0.1 mm steps.
const int unitsPerMm = 10;

/// Capabilities and limits of a target machine.
final class MachineModel {
  const MachineModel({
    required this.name,
    this.hoopWidthMm = 100,
    this.hoopHeightMm = 100,
    this.maxStitchLengthMm = 12.1,
    this.maxJumpLengthMm = 12.1,
    this.needleCount = 1,
  });

  final String name;

  /// Hoop size; the design origin sits at the hoop center.
  final double hoopWidthMm;
  final double hoopHeightMm;

  /// Longest encodable single stitch / jump movement. 12.1 mm matches
  /// DST's ±121-unit delta range.
  final double maxStitchLengthMm;
  final double maxJumpLengthMm;

  final int needleCount;

  /// A permissive default target for MVP work.
  static const generic = MachineModel(name: 'generic');
}
