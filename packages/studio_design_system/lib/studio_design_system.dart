/// Sewlio Studio design system.
///
/// Affinity-Designer-style dark theme (docs/04-ui/100-design-system.md,
/// 101-color-system.md): neutral gray chrome, hairline separators
/// darker than the panels, and a saturated blue accent for the active
/// tool and selection.
library;

import 'package:flutter/material.dart';

/// Design tokens for the studio workspace.
abstract final class AppTokens {
  /// Base spacing unit in logical pixels.
  static const double spacing = 8.0;

  /// Accent blue (active tool, selection, primary actions).
  static const Color seed = Color(0xFF3E8BFF);
  static const Color primary = Color(0xFF3E8BFF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Canvas surround / window background (lighter than panels,
  /// Affinity-style).
  static const Color background = Color(0xFF2E3032);

  /// Panel chrome.
  static const Color panel = Color(0xFF262829);

  /// Hover/raised surfaces.
  static const Color surfaceHigh = Color(0xFF3A3D40);

  /// Hairline separators — darker than the panels they divide.
  static const Color border = Color(0xFF1B1C1E);

  static const Color textPrimary = Color(0xFFD6D8DA);
  static const Color textMuted = Color(0xFF9EA1A4);

  /// Floating popovers/flyouts — raised above panels: lighter surface,
  /// brighter border, so they read as a separate layer.
  static const Color popoverSurface = Color(0xFF35383B);
  static const Color popoverBorder = Color(0xFF4C5054);

  /// Hoop/success accent (green).
  static const Color accentGreen = Color(0xFF34C759);

  /// Error accent.
  static const Color error = Color(0xFFFF6B6B);
}

/// The studio dark theme.
ThemeData studioTheme() {
  const scheme = ColorScheme.dark(
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
    textTheme: base.textTheme.apply(
      bodyColor: AppTokens.textPrimary,
      displayColor: AppTokens.textPrimary,
    ),
    menuBarTheme: const MenuBarThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppTokens.panel),
        elevation: WidgetStatePropertyAll(0),
      ),
    ),
    menuTheme: const MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppTokens.panel),
      ),
    ),
    cardTheme: const CardThemeData(
      color: AppTokens.panel,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTokens.border),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      isDense: true,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppTokens.primary),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    ),
  );
}

/// A workspace panel: dark chrome, hairline border, optional titled
/// header row.
class StudioPanel extends StatelessWidget {
  const StudioPanel({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.width,
  });

  final String? title;
  final Widget? trailing;
  final Widget child;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTokens.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Affinity-style small-caps panel label.
                Text(title!.toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: AppTokens.textMuted)),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
    final panel = DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTokens.panel,
        border: Border.fromBorderSide(BorderSide(color: AppTokens.border)),
      ),
      child: content,
    );
    return width == null ? panel : SizedBox(width: width, child: panel);
  }
}

/// A small icon button in the workspace chrome (tool rail, toolbars).
/// [flyoutIndicator] draws the Illustrator-style corner triangle that
/// marks a button with a hidden flyout menu.
class StudioIconButton extends StatelessWidget {
  const StudioIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.active = false,
    this.flyoutIndicator = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;
  final bool flyoutIndicator;

  @override
  Widget build(BuildContext context) {
    // Affinity-style: active tool sits on a solid accent square with a
    // white glyph.
    final color = onPressed == null
        ? AppTokens.textMuted.withValues(alpha: 0.4)
        : active
            ? AppTokens.onPrimary
            : AppTokens.textMuted;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        hoverColor: AppTokens.surfaceHigh,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? AppTokens.primary : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 18, color: color),
              if (flyoutIndicator)
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: CustomPaint(
                    size: const Size(5, 5),
                    painter: _FlyoutTrianglePainter(color),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlyoutTrianglePainter extends CustomPainter {
  _FlyoutTrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FlyoutTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
