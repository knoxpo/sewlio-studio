import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Horizontal studio slider: hairline track, filled portion in the
/// accent color, circular thumb. Emits [onChanged] continuously while
/// dragging; Left/Right arrows step 1% of the range.
class StudioSlider extends StatefulWidget {
  const StudioSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 1,
  });

  final double value;

  /// `null` disables the slider.
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  @override
  State<StudioSlider> createState() => _StudioSliderState();
}

class _StudioSliderState extends State<StudioSlider> {
  final _focusNode = FocusNode();

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

  void _setFromDx(double dx, double width) {
    if (width <= 0) return;
    final t = (dx / width).clamp(0.0, 1.0);
    widget.onChanged?.call(widget.min + t * (widget.max - widget.min));
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final step = (widget.max - widget.min) / 100;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      widget.onChanged
          ?.call((widget.value - step).clamp(widget.min, widget.max));
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      widget.onChanged
          ?.call((widget.value + step).clamp(widget.min, widget.max));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final range = widget.max - widget.min;
    final t = range == 0
        ? 0.0
        : ((widget.value - widget.min) / range).clamp(0.0, 1.0);

    return Focus(
      focusNode: _focusNode,
      canRequestFocus: enabled,
      onKeyEvent: _onKey,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: enabled
                ? (d) {
                    _focusNode.requestFocus();
                    _setFromDx(d.localPosition.dx, width);
                  }
                : null,
            onHorizontalDragUpdate:
                enabled ? (d) => _setFromDx(d.localPosition.dx, width) : null,
            child: SizedBox(
              height: 20,
              width: double.infinity,
              child: CustomPaint(
                painter: _SliderPainter(
                  t: t,
                  enabled: enabled,
                  focused: _focusNode.hasFocus,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SliderPainter extends CustomPainter {
  _SliderPainter(
      {required this.t, required this.enabled, required this.focused});

  final double t;
  final bool enabled;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    const trackHeight = 3.0;
    const thumbRadius = 6.0;
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(thumbRadius, cy - trackHeight / 2,
          size.width - thumbRadius * 2, trackHeight),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(trackRect, Paint()..color = AppTokens.field);
    canvas.drawRRect(
        trackRect,
        Paint()
          ..color = AppTokens.border
          ..style = PaintingStyle.stroke);

    final thumbX = thumbRadius + t * (size.width - thumbRadius * 2);
    if (t > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(thumbRadius, cy - trackHeight / 2, thumbX - thumbRadius,
              trackHeight),
          const Radius.circular(1.5),
        ),
        Paint()..color = enabled ? AppTokens.primary : AppTokens.textMuted,
      );
    }
    final thumbPaint = Paint()
      ..color = enabled ? AppTokens.primary : AppTokens.textMuted;
    canvas.drawCircle(Offset(thumbX, cy), thumbRadius, thumbPaint);
    if (focused) {
      canvas.drawCircle(
          Offset(thumbX, cy),
          thumbRadius + 2,
          Paint()
            ..color = AppTokens.primary.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(_SliderPainter oldDelegate) =>
      oldDelegate.t != t ||
      oldDelegate.enabled != enabled ||
      oldDelegate.focused != focused;
}
