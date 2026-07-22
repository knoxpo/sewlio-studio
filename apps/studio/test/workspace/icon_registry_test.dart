import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/workspace/icon_registry.dart';

void main() {
  final naming = RegExp(r'^(tool|stitch|sim|panel)-[a-z0-9-]+$');

  test('icon ids follow the naming convention', () {
    for (final id in studioIcons.keys) {
      expect(naming.hasMatch(id), isTrue, reason: id);
    }
  });

  test('every registered SVG asset exists on disk', () {
    for (final icon in studioIcons.values) {
      expect(File(icon.svgAsset!).existsSync(), isTrue, reason: icon.svgAsset);
    }
  });

  test('iconFor resolves registered ids and falls back for unknown', () {
    expect(iconFor('sim-play'), Icons.play_arrow);
    expect(iconFor('does-not-exist'), Icons.crop_square);
  });
}
