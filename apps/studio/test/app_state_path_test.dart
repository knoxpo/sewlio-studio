import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/file_io.dart';

void main() {
  tearDown(() => appStateBaseDirOverride = null);

  test('appStatePath prefers the platform override (mobile)', () {
    appStateBaseDirOverride = '/data/app-support';
    expect(appStatePath('recents.json'), '/data/app-support/recents.json');
  });

  test('appStatePath falls back to HOME without an override', () {
    final path = appStatePath('recents.json');
    // Desktop test runner always has HOME.
    expect(path, isNotNull);
    expect(path, endsWith('/.sewlio_studio/recents.json'));
  });
}
