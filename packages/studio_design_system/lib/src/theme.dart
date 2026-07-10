import 'package:flutter/material.dart';

import 'tokens.dart';

/// App-wide theme selection (Light / Dark / System). The shell writes
/// this; the app root listens, resolves it against the platform
/// brightness, calls [AppTokens.setDark], and rebuilds.
/// ponytail: not persisted across launches — add a settings file when
/// more preferences exist.
final ValueNotifier<ThemeMode> studioThemeMode =
    ValueNotifier(ThemeMode.system);

/// The studio theme, built from the active [AppTokens] palette.
ThemeData studioTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppTokens.seed,
    brightness: AppTokens.isDark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: AppTokens.primary,
    onPrimary: AppTokens.onPrimary,
    secondary: AppTokens.accentGreen,
    surface: AppTokens.background,
    onSurface: AppTokens.textPrimary,
    surfaceContainerHighest: AppTokens.surfaceHigh,
    outline: AppTokens.border,
    error: AppTokens.error,
  );
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppTokens.background,
    dividerColor: AppTokens.border,
    textTheme: base.textTheme
        .apply(
          bodyColor: AppTokens.textPrimary,
          displayColor: AppTokens.textPrimary,
        )
        .copyWith(
          // Body copy default style — desktop density.
          bodyLarge: TextStyle(fontSize: 12.5, color: AppTokens.textPrimary),
        ),
    menuBarTheme: MenuBarThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppTokens.panel),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppTokens.panel),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppTokens.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTokens.border),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppTokens.primary,
      selectionColor: AppTokens.primary.withValues(alpha: 0.35),
      selectionHandleColor: AppTokens.primary,
    ),
    // Desktop-density text inside fields and body copy.
    hoverColor: AppTokens.surfaceHigh.withValues(alpha: 0.4),
  );
}
