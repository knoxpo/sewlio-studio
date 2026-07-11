import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'text_field.dart';
import 'tokens.dart';

/// Numeric commit-on-Enter field bound to an external [value].
///
/// The external value is the source of truth: while unfocused the text
/// tracks it; while the user is typing it is never clobbered. Enter
/// parses, clamps to `[min, max]`, and calls [onSubmitted]; blur or
/// Escape reverts uncommitted edits.
class StudioNumberField extends StatefulWidget {
  const StudioNumberField({
    super.key,
    required this.value,
    required this.onSubmitted,
    this.min = double.negativeInfinity,
    this.max,
    this.integer = false,
    this.decimals = 2,
    this.suffix,
    this.steppers = false,
    this.step,
    this.defaultValue,
    this.mixed = false,
    this.width,
    this.textAlign = TextAlign.start,
  });

  final double value;

  /// Committed-value handler; `null` disables the field.
  final void Function(double value)? onSubmitted;

  final double min;
  final double? max;

  /// Round to whole numbers and display without decimals.
  final bool integer;

  /// Display precision for non-integer fields.
  final int decimals;

  /// Unit rendered as a muted suffix inside the field ('mm', '%').
  final String? suffix;

  /// Show − / + stepper buttons in the prefix/suffix slots.
  final bool steppers;

  /// Stepper increment; defaults to 1 for integers, else 1 when the
  /// value is ≥ 10 and 0.1 below that. Also the amount added per unit of
  /// horizontal drag-scrub distance.
  final double? step;

  /// Value restored on double-click. Null disables the reset gesture.
  final double? defaultValue;

  /// Show a blank field with a muted indicator instead of [value] (a
  /// mixed multi-object selection). The blank is not written back until
  /// the user edits or scrubs.
  final bool mixed;

  final double? width;
  final TextAlign textAlign;

  @override
  State<StudioNumberField> createState() => _StudioNumberFieldState();
}

class _StudioNumberFieldState extends State<StudioNumberField> {
  /// Logical pixels of horizontal drag that advance the value by one
  /// [_step].
  static const _pixelsPerStep = 4.0;

  late final _controller =
      TextEditingController(text: widget.mixed ? '' : _format(widget.value));
  final _focusNode = FocusNode();
  double _scrubStartValue = 0;
  Offset _scrubAccum = Offset.zero;
  bool _scrubbing = false;

  String _format(double v) => widget.integer
      ? v.round().toString()
      : v.toStringAsFixed(widget.decimals);

  double get _step =>
      widget.step ?? (widget.integer || widget.value >= 10 ? 1.0 : 0.1);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(StudioNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus) return;
    if (widget.mixed) {
      if (_controller.text.isNotEmpty) _controller.text = '';
    } else if (widget.value != oldWidget.value || oldWidget.mixed) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      // Discard uncommitted edits on blur.
      _controller.text = widget.mixed ? '' : _format(widget.value);
    }
  }

  double _clamp(double v) {
    var r = v.clamp(widget.min, widget.max ?? double.infinity).toDouble();
    if (widget.integer) r = r.roundToDouble();
    return r;
  }

  void _commit(String text) {
    final parsed = double.tryParse(text);
    if (parsed == null) {
      _controller.text = _format(widget.value);
      return;
    }
    final v = _clamp(parsed);
    widget.onSubmitted?.call(v);
    // Canonicalize immediately ("5.678" → "5.68"), even when the
    // committed value equals the current one and no rebuild follows.
    _controller.text = _format(v);
  }

  void _nudge(double delta) {
    final v = _clamp(widget.value + delta);
    widget.onSubmitted?.call(v);
    _controller.text = _format(v);
  }

  // Raw pointer scrubbing (rather than a HorizontalDragGestureRecognizer)
  // so the field's own text-selection drag doesn't win the gesture arena
  // and swallow the scrub. Vertical drags fall through untouched so the
  // field can still live inside a scrollable panel.
  void _onScrubPointerDown(PointerDownEvent _) {
    _scrubStartValue = widget.value;
    _scrubAccum = Offset.zero;
    _scrubbing = false;
  }

  void _onScrubPointerMove(PointerMoveEvent event) {
    _scrubAccum += event.delta;
    if (!_scrubbing) {
      if (_scrubAccum.dx.abs() > 4 &&
          _scrubAccum.dx.abs() > _scrubAccum.dy.abs()) {
        _scrubbing = true;
      } else {
        return;
      }
    }
    final v =
        _clamp(_scrubStartValue + (_scrubAccum.dx / _pixelsPerStep) * _step);
    widget.onSubmitted?.call(v);
    _controller.text = _format(v);
  }

  void _resetToDefault() {
    final v = _clamp(widget.defaultValue!);
    widget.onSubmitted?.call(v);
    _controller.text = _format(v);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _controller.text = _format(widget.value);
      _focusNode.unfocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onSubmitted != null;
    Widget field = Focus(
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: StudioTextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: enabled,
        textAlign: widget.textAlign,
        hint: widget.mixed ? '—' : null,
        style: const TextStyle(fontSize: 12),
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: true),
        prefix: widget.steppers
            ? _StepButton(
                icon: Icons.remove,
                onPressed: enabled ? () => _nudge(-_step) : null)
            : null,
        suffix: _suffix(enabled),
        onSubmitted: _commit,
      ),
    );
    if (enabled) {
      // Horizontal click-drag scrubs the value; double-click resets to
      // [defaultValue]. Taps still fall through to focus/edit the field.
      field = Listener(
        onPointerDown: _onScrubPointerDown,
        onPointerMove: _onScrubPointerMove,
        child: GestureDetector(
          onDoubleTap: widget.defaultValue == null ? null : _resetToDefault,
          child: field,
        ),
      );
    }
    return widget.width == null
        ? field
        : SizedBox(width: widget.width, child: field);
  }

  Widget? _suffix(bool enabled) {
    final unit = widget.suffix == null
        ? null
        : Text(widget.suffix!,
            style: TextStyle(color: AppTokens.textMuted, fontSize: 11));
    final plus = widget.steppers
        ? _StepButton(
            icon: Icons.add, onPressed: enabled ? () => _nudge(_step) : null)
        : null;
    if (unit != null && plus != null) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        unit,
        const SizedBox(width: 2),
        plus,
      ]);
    }
    return plus ?? unit;
  }
}

/// Compact stepper button sized to fit inside the field chrome.
class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(3),
        hoverColor: AppTokens.surfaceHigh,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(icon,
              size: 12,
              color: onPressed == null
                  ? AppTokens.textMuted.withValues(alpha: 0.4)
                  : AppTokens.textMuted),
        ),
      ),
    );
  }
}
