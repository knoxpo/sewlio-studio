import 'package:flutter/material.dart';

/// One resolved set of surface/text colors (dark or light).
class StudioPalette {
  const StudioPalette({
    required this.background,
    required this.panel,
    required this.surfaceHigh,
    required this.border,
    required this.field,
    required this.textPrimary,
    required this.textMuted,
    required this.popoverSurface,
    required this.popoverBorder,
  });

  final Color background;
  final Color panel;
  final Color surfaceHigh;
  final Color border;
  final Color field;
  final Color textPrimary;
  final Color textMuted;
  final Color popoverSurface;
  final Color popoverBorder;
}

const _dark = StudioPalette(
  background: Color(0xFF2E3032),
  panel: Color(0xFF262829),
  surfaceHigh: Color(0xFF3A3D40),
  border: Color(0xFF1B1C1E),
  field: Color(0xFF1F2123),
  textPrimary: Color(0xFFD6D8DA),
  textMuted: Color(0xFF9EA1A4),
  popoverSurface: Color(0xFF35383B),
  popoverBorder: Color(0xFF4C5054),
);

const _light = StudioPalette(
  background: Color(0xFFE9EAEC),
  panel: Color(0xFFF6F6F7),
  surfaceHigh: Color(0xFFDFE1E4),
  border: Color(0xFFCFD2D6),
  field: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF2A2C2E),
  textMuted: Color(0xFF6B6F73),
  popoverSurface: Color(0xFFFFFFFF),
  popoverBorder: Color(0xFFC4C8CC),
);

/// Design tokens for the studio workspace.
///
/// Accent colors are theme-invariant consts; surface/text tokens resolve
/// through the active [StudioPalette] so the whole app retints when the
/// theme switches (see `studioThemeMode` in theme.dart).
abstract final class AppTokens {
  /// Base spacing unit in logical pixels.
  static const double spacing = 8.0;

  /// Accent blue (active tool, selection, primary actions).
  static const Color seed = Color(0xFF3E8BFF);
  static const Color primary = Color(0xFF3E8BFF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Hoop/success accent (green).
  static const Color accentGreen = Color(0xFF34C759);

  /// Error accent.
  static const Color error = Color(0xFFFF6B6B);

  static StudioPalette _p = _dark;
  static bool get isDark => identical(_p, _dark);
  static void setDark(bool dark) => _p = dark ? _dark : _light;

  /// Canvas surround / window background (lighter than panels,
  /// Affinity-style).
  static Color get background => _p.background;

  /// Panel chrome.
  static Color get panel => _p.panel;

  /// Hover/raised surfaces.
  static Color get surfaceHigh => _p.surfaceHigh;

  /// Hairline separators — darker than the panels they divide.
  static Color get border => _p.border;

  /// Input field fill — recessed below the panel surface.
  static Color get field => _p.field;

  static Color get textPrimary => _p.textPrimary;
  static Color get textMuted => _p.textMuted;

  /// Floating popovers/flyouts — raised above panels: lighter surface,
  /// brighter border, so they read as a separate layer.
  static Color get popoverSurface => _p.popoverSurface;
  static Color get popoverBorder => _p.popoverBorder;
}
