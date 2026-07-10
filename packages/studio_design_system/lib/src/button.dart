import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Visual weight of a [StudioButton].
enum StudioButtonVariant {
  /// Solid accent fill — the one main action on a surface.
  primary,

  /// Raised gray chrome — secondary actions (replaces OutlinedButton).
  secondary,

  /// Chromeless until hovered — low-emphasis actions like Cancel.
  ghost,

  /// Ghost with error coloring — destructive actions like Delete.
  danger,
}

/// Studio push button: custom chrome, no Material button underneath.
/// Keyboard: Enter/Space activate when focused; focus draws the accent
/// border.
class StudioButton extends StatefulWidget {
  const StudioButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = StudioButtonVariant.secondary,
    this.icon,
    this.expand = false,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final StudioButtonVariant variant;

  /// Optional leading icon.
  final IconData? icon;

  /// Stretch to the parent's full width.
  final bool expand;

  @override
  State<StudioButton> createState() => _StudioButtonState();
}

class _StudioButtonState extends State<StudioButton> {
  final _focusNode = FocusNode();
  var _hover = false;
  var _pressed = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      widget.onPressed?.call();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final focused = _focusNode.hasFocus;

    // (fill, foreground, border) per variant and interaction state.
    final Color fill;
    final Color foreground;
    Color border;
    switch (widget.variant) {
      case StudioButtonVariant.primary:
        fill = _hover && enabled
            ? Color.alphaBlend(
                Colors.white.withValues(alpha: 0.12), AppTokens.primary)
            : AppTokens.primary;
        foreground = AppTokens.onPrimary;
        border = Colors.transparent;
      case StudioButtonVariant.secondary:
        fill = _hover && enabled
            ? Color.alphaBlend(
                Colors.white.withValues(alpha: 0.06), AppTokens.surfaceHigh)
            : AppTokens.surfaceHigh;
        foreground = AppTokens.textPrimary;
        border = AppTokens.border;
      case StudioButtonVariant.ghost:
        fill = _hover && enabled ? AppTokens.surfaceHigh : Colors.transparent;
        foreground = AppTokens.textMuted;
        border = Colors.transparent;
      case StudioButtonVariant.danger:
        fill = _hover && enabled
            ? AppTokens.error.withValues(alpha: 0.15)
            : Colors.transparent;
        foreground = AppTokens.error;
        border = Colors.transparent;
    }
    if (focused) border = AppTokens.primary;

    Widget button = Focus(
      focusNode: _focusNode,
      canRequestFocus: enabled,
      onKeyEvent: _onKey,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTap: widget.onPressed,
          child: Opacity(
            opacity: enabled ? (_pressed ? 0.8 : 1) : 0.45,
            child: Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: fill,
                border: Border.all(color: border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize:
                    widget.expand ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 14, color: foreground),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: foreground,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.expand) {
      button = SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
