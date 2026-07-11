import 'dart:convert';

import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:test/test.dart';

void main() {
  test('unit conversions round-trip through mm', () {
    expect(ProjectUnits.inch.toMm(4), closeTo(101.6, 1e-9));
    expect(ProjectUnits.cm.toMm(10), 100);
    expect(ProjectUnits.inch.fromMm(25.4), closeTo(1, 1e-9));
    expect(ProjectUnits.mm.toMm(42), 42);
  });

  test('units and color profile persist through .swl', () {
    final doc = Document(
      id: const Id('u1'),
      units: ProjectUnits.inch,
      colorProfile: ColorProfile.displayP3,
    );
    final decoded = decodeProject(encodeProject(doc));
    expect(decoded.units, ProjectUnits.inch);
    expect(decoded.colorProfile, ColorProfile.displayP3);
  });

  test('missing keys decode to defaults (older files)', () {
    final map = jsonDecode(encodeProject(Document(id: const Id('u2'))))
        as Map<String, dynamic>
      ..remove('units')
      ..remove('colorProfile');
    final decoded = decodeProject(jsonEncode(map));
    expect(decoded.units, ProjectUnits.mm);
    expect(decoded.colorProfile, ColorProfile.srgb);
  });
}
