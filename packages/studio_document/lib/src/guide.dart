import 'package:studio_core/studio_core.dart';

enum GuideAxis {
  /// Vertical guide line at x = [Guide.positionMm].
  vertical,

  /// Horizontal guide line at y = [Guide.positionMm].
  horizontal,
}

/// A named ruler guide. Immutable — edits replace the guide via
/// commands.
final class Guide {
  const Guide({
    required this.id,
    required this.axis,
    required this.positionMm,
    this.name = '',
    this.colorHex,
  });

  final Id id;
  final GuideAxis axis;
  final double positionMm;
  final String name;

  /// Optional `#RRGGBB` override; null = app default guide color.
  final String? colorHex;

  Guide copyWith({double? positionMm, String? name, String? colorHex}) => Guide(
        id: id,
        axis: axis,
        positionMm: positionMm ?? this.positionMm,
        name: name ?? this.name,
        colorHex: colorHex ?? this.colorHex,
      );

  Map<String, dynamic> toJson() => {
        'id': id.value,
        'axis': axis.name,
        'position': positionMm,
        if (name.isNotEmpty) 'name': name,
        if (colorHex != null) 'color': colorHex,
      };

  factory Guide.fromJson(Map<String, dynamic> json) => Guide(
        id: Id(json['id'] as String),
        axis: GuideAxis.values.byName(json['axis'] as String),
        positionMm: (json['position'] as num).toDouble(),
        name: (json['name'] as String?) ?? '',
        colorHex: json['color'] as String?,
      );
}
