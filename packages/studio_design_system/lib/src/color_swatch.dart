import 'package:flutter/material.dart';

import 'color_picker.dart';
import 'tokens.dart';

/// A small inline swatch button. Shows the current `#rrggbb` [color], or
/// an "unset" (diagonal slash) look when null. Tapping opens
/// [showStudioColorPicker] and reports the chosen hex via [onChanged].
/// Focusable and Enter/Space-activatable (via [InkWell]).
class StudioColorSwatch extends StatelessWidget {
  const StudioColorSwatch({
    super.key,
    required this.color,
    required this.onChanged,
    this.size = 22,
  });

  /// Current color as `#rrggbb`, or null when unset/mixed.
  final String? color;
  final ValueChanged<String> onChanged;
  final double size;

  static Color? _parse(String? hex) {
    if (hex == null) return null;
    final h = hex.replaceFirst('#', '').trim();
    if (h.length != 6) return null;
    final v = int.tryParse(h, radix: 16);
    return v == null ? null : Color(0xFF000000 | v);
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
    final fill = _parse(color);
    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(4),
      focusColor: AppTokens.surfaceHigh,
      child: Container(
        key: const ValueKey('studio-color-swatch'),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill ?? AppTokens.field,
          border: Border.all(color: AppTokens.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: fill == null ? CustomPaint(painter: _UnsetSlashPainter()) : null,
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
