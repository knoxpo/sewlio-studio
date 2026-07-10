/// Hoop outline shape.
enum HoopShape { rectangle, roundedRectangle, oval }

/// Fabric texture drawn inside the hoop (procedural, preview only).
enum FabricTexture { none, weave, aida }

/// Document hoop + fabric setup (Illustrator "Document Setup").
/// Immutable — edits replace it via the UpdateHoop command.
final class HoopSettings {
  const HoopSettings({
    this.widthMm = 100,
    this.heightMm = 100,
    this.shape = HoopShape.roundedRectangle,
    this.fabricColorHex = '#f5f0e6',
    this.texture = FabricTexture.none,
  });

  final double widthMm;
  final double heightMm;
  final HoopShape shape;

  /// Fabric fill (`#RRGGBB`), rendered translucent behind the design.
  final String fabricColorHex;
  final FabricTexture texture;

  HoopSettings copyWith({
    double? widthMm,
    double? heightMm,
    HoopShape? shape,
    String? fabricColorHex,
    FabricTexture? texture,
  }) =>
      HoopSettings(
        widthMm: widthMm ?? this.widthMm,
        heightMm: heightMm ?? this.heightMm,
        shape: shape ?? this.shape,
        fabricColorHex: fabricColorHex ?? this.fabricColorHex,
        texture: texture ?? this.texture,
      );

  Map<String, dynamic> toJson() => {
        'width': widthMm,
        'height': heightMm,
        'shape': shape.name,
        'fabricColor': fabricColorHex,
        'texture': texture.name,
      };

  factory HoopSettings.fromJson(Map<String, dynamic> json) => HoopSettings(
        widthMm: (json['width'] as num).toDouble(),
        heightMm: (json['height'] as num).toDouble(),
        shape: HoopShape.values.byName(json['shape'] as String),
        fabricColorHex: json['fabricColor'] as String,
        texture: FabricTexture.values.byName(json['texture'] as String),
      );
}
