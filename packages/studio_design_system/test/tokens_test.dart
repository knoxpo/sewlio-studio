import 'package:flutter_test/flutter_test.dart';
import 'package:studio_design_system/studio_design_system.dart';

void main() {
  test('seed tokens are defined', () {
    expect(AppTokens.spacing, greaterThan(0));
    expect(AppTokens.seed.a, 1.0);
  });
}
