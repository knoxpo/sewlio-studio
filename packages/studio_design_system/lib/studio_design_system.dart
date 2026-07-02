/// Sewlio Studio design system — skeleton.
///
/// Real tokens, themes, and components land later (see docs/04-ui/100-design-system.md,
/// 101-color-system.md, 105-themes.md). For now this exposes a couple of seed tokens so
/// the package is a real, testable dependency for the app shell.
library;

import 'package:flutter/widgets.dart';

/// Seed design tokens. Placeholder values; replaced by the real token set.
abstract final class AppTokens {
  /// Base spacing unit in logical pixels.
  static const double spacing = 8.0;

  /// Primary brand seed color.
  static const Color seed = Color(0xFF3A6EA5);
}
