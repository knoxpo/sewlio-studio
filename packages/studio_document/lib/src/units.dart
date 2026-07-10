/// Display units for a project. Geometry is always stored in mm —
/// units only change how dimensions are entered and shown.
enum ProjectUnits {
  mm(1, 'mm'),
  cm(10, 'cm'),
  inch(25.4, 'in');

  const ProjectUnits(this.mmPerUnit, this.label);

  final double mmPerUnit;
  final String label;

  double toMm(double value) => value * mmPerUnit;
  double fromMm(double mm) => mm / mmPerUnit;

  String toJson() => name;

  static ProjectUnits fromJson(Object? json) => ProjectUnits.values
      .firstWhere((u) => u.name == json, orElse: () => ProjectUnits.mm);
}

/// Working color space of the project's artwork preview (UI-606 Color
/// Management). Stored as project metadata; embroidery output always
/// maps to physical thread libraries.
// ponytail: label only — no actual color conversion pipeline yet.
enum ColorProfile {
  srgb('sRGB'),
  displayP3('Display P3'),
  adobeRgb('Adobe RGB');

  const ColorProfile(this.label);

  final String label;

  String toJson() => name;

  static ColorProfile fromJson(Object? json) => ColorProfile.values
      .firstWhere((p) => p.name == json, orElse: () => ColorProfile.srgb);
}
