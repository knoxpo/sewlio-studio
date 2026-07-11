import 'package:flutter/material.dart';

import 'tokens.dart';

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
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTokens.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Affinity-style small-caps panel label.
                Text(title!.toUpperCase(),
                    style: TextStyle(
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
      decoration: BoxDecoration(
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
    this.size = 18,
    this.minTarget,
  });

  final IconData icon;

  /// Icon size; padding scales down with it (compact panel toolbars).
  final double size;

  /// Minimum tap-target edge in logical px (48 on touch devices per
  /// platform-requirements §14); null keeps the compact desktop hit
  /// area. Visuals stay the same size — only the hit area grows.
  final double? minTarget;

  /// Hover tooltip; null suppresses it (e.g. when a richer hover card
  /// wraps the button).
  final String? tooltip;
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
    final button = InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      hoverColor: AppTokens.surfaceHigh,
      child: Container(
        padding: EdgeInsets.all(size < 18 ? 4 : 6),
        constraints: minTarget == null
            ? null
            : BoxConstraints(minWidth: minTarget!, minHeight: minTarget!),
        alignment: minTarget == null ? null : Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTokens.primary : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: size, color: color),
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
    );
    if (tooltip == null) return button;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: button,
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
