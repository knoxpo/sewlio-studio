import 'package:flutter/material.dart';

import 'color_picker.dart';
import 'tokens.dart';

/// A small inline swatch button. Renders an opaque `#rrggbb` colour
/// directly, a partial-alpha `#rrggbbaa` colour over a checkerboard, and
/// the transparent sentinel (alpha 00) or null as the "none" (diagonal
/// slash) look. Tapping opens [showStudioColorPicker] and reports the
/// chosen hex via [onChanged]. Focusable and Enter/Space-activatable.
class StudioColorSwatch extends StatelessWidget {
  const StudioColorSwatch({
    super.key,
    required this.color,
    required this.onChanged,
    this.size = 22,
  });

  /// Current color as `#rrggbb`/`#rrggbbaa`, or null when unset/mixed.
  final String? color;
  final ValueChanged<String> onChanged;
  final double size;

  /// Opaque colour + alpha byte, or null when unset/malformed.
  static (Color, int)? _parse(String? hex) {
    if (hex == null) return null;
    final h = hex.replaceFirst('#', '').trim();
    if (h.length != 6 && h.length != 8) return null;
    final rgb = int.tryParse(h.substring(0, 6), radix: 16);
    if (rgb == null) return null;
    var alpha = 255;
    if (h.length == 8) {
      final a = int.tryParse(h.substring(6, 8), radix: 16);
      if (a == null) return null;
      alpha = a;
    }
    return (Color(0xFF000000 | rgb), alpha);
  }

  Future<void> _pick(BuildContext context) async {
    final result = await showStudioColorPicker(
      context: context,
      initialHex: color ?? '#ffffff',
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final parsed = _parse(color);
    // Transparent (alpha 00) and unset both read as "none".
    final isNone = parsed == null || parsed.$2 == 0;
    final Widget inner;
    if (isNone) {
      inner = CustomPaint(painter: _UnsetSlashPainter());
    } else if (parsed.$2 < 255) {
      // Partial alpha: show it over a checkerboard.
      inner = CustomPaint(
        painter: _CheckerPainter(),
        child: ColoredBox(color: parsed.$1.withValues(alpha: parsed.$2 / 255)),
      );
    } else {
      inner = const SizedBox.expand();
    }
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(4),
      focusColor: AppTokens.surfaceHigh,
      child: Container(
        key: const ValueKey('studio-color-swatch'),
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: (isNone || parsed.$2 < 255) ? AppTokens.field : parsed.$1,
          border: Border.all(color: AppTokens.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: inner,
      ),
    );
  }
}

/// Diagonal red slash marking an unset/none swatch.
class _UnsetSlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTokens.error
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(2, size.height - 2), Offset(size.width - 2, 2), paint);
  }

  @override
  bool shouldRepaint(_UnsetSlashPainter oldDelegate) => false;
}

/// Grey checkerboard backing for partial-alpha swatches.
class _CheckerPainter extends CustomPainter {
  static const _cell = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size, Paint()..color = const Color(0xFFBDBDBD));
    final dark = Paint()..color = const Color(0xFF8A8A8A);
    for (var y = 0.0; y < size.height; y += _cell) {
      for (var x = 0.0; x < size.width; x += _cell) {
        if (((x ~/ _cell) + (y ~/ _cell)).isEven) continue;
        canvas.drawRect(Rect.fromLTWH(x, y, _cell, _cell), dark);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => false;
}
