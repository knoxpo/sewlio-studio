import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/workspace/project_type.dart';
import 'package:studio/src/workspace/project_type_registry.dart';

void main() {
  test('embroidery registers as the active MVP domain (ARCH-036)', () {
    final module = moduleFor(ProjectType.embroidery);
    expect(module.domainLabel, 'Stitch');
    expect(module.planned, isFalse);
  });

  test('project type ids are stable strings', () {
    expect(ProjectType.embroidery.id, 'embroidery');
    expect(ProjectType.weaving.id, 'weaving');
  });
}
