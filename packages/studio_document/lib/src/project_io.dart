import 'dart:convert';

import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import 'document.dart';
import 'guide.dart';

/// `.embproj` schema version. Bump + migrate on breaking change (ADR).
const String projectVersion = '1';

// ponytail: .embproj is a JSON text file for the MVP — self-contained
// and diffable. Move to the libSQL container (ARCH-006/007) when
// assets/history need to live inside the project file.

/// Serializes [document] as `.embproj` JSON.
String encodeProject(Document document) =>
    const JsonEncoder.withIndent('  ').convert({
      'version': projectVersion,
      'id': document.id.value,
      'name': document.name,
      'objects': [for (final object in document.objects) object.toJson()],
      if (document.guides.isNotEmpty)
        'guides': [for (final guide in document.guides) guide.toJson()],
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
  for (final object in json['objects'] as List) {
    document.objects
        .add(EmbroideryObject.fromJson(object as Map<String, dynamic>));
  }
  for (final guide in (json['guides'] as List?) ?? const []) {
    document.guides.add(Guide.fromJson(guide as Map<String, dynamic>));
  }
  return document;
}
