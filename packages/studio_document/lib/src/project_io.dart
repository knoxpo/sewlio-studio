import 'dart:convert';

import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import 'document.dart';
import 'guide.dart';
import 'hoop.dart';
import 'hierarchy.dart';
import 'units.dart';

/// `.embproj` schema version. Bump + migrate on breaking change (ADR).
const String projectVersion = '2';

// ponytail: .embproj is a JSON text file for the MVP — self-contained
// and diffable. Move to the libSQL container (ARCH-006/007) when
// assets/history need to live inside the project file.

/// Serializes [document] as `.embproj` JSON.
String encodeProject(Document document) =>
    const JsonEncoder.withIndent('  ').convert({
      'version': projectVersion,
      'id': document.id.value,
      'name': document.name,
      'objects': {
        for (final entry in document.objects.entries)
          entry.key.value: {
            'object': entry.value.toJson(),
            'state': document.objectState(entry.key).toJson(),
          }
      },
      'layers': [for (final layer in document.layers) layer.toJson()],
      'groups': {
        for (final entry in document.groups.entries)
          entry.key.value: entry.value.toJson(),
      },
      if (document.guides.isNotEmpty)
        'guides': [for (final guide in document.guides) guide.toJson()],
      'hoop': document.hoop.toJson(),
      // Additive metadata (defaults applied on decode) — older readers
      // ignore unknown keys, so the schema version stays '2'.
      'units': document.units.toJson(),
      'colorProfile': document.colorProfile.toJson(),
    });

/// Parses `.embproj` JSON into a fresh [Document].
/// Throws [FormatException] on unknown versions or malformed content.
Document decodeProject(String source) {
  final json = jsonDecode(source) as Map<String, dynamic>;
  final version = json['version'] as String?;
  if (version != projectVersion) {
    throw FormatException('Unsupported .embproj version: $version');
  }
  final document = Document(
    id: Id(json['id'] as String),
    name: json['name'] as String,
  );
  document.layers.clear();
  for (final entry in (json['objects'] as Map<String, dynamic>).entries) {
    final value = entry.value as Map<String, dynamic>;
    final object =
        EmbroideryObject.fromJson(value['object'] as Map<String, dynamic>);
    document.objects[Id(entry.key)] = object;
    document.objectStates[Id(entry.key)] =
        ObjectNodeState.fromJson(value['state'] as Map<String, dynamic>);
  }
  for (final layer in json['layers'] as List) {
    document.layers.add(LayerNode.fromJson(layer as Map<String, dynamic>));
  }
  for (final entry in (json['groups'] as Map<String, dynamic>).entries) {
    document.groups[Id(entry.key)] =
        GroupNode.fromJson(entry.value as Map<String, dynamic>);
  }
  for (final guide in (json['guides'] as List?) ?? const []) {
    document.guides.add(Guide.fromJson(guide as Map<String, dynamic>));
  }
  if (json['hoop'] case final Map<String, dynamic> hoop) {
    document.hoop = HoopSettings.fromJson(hoop);
  }
  document.units = ProjectUnits.fromJson(json['units']);
  document.colorProfile = ColorProfile.fromJson(json['colorProfile']);
  return document;
}
