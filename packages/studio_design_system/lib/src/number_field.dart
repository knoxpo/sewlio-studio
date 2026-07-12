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

  // Local source of truth for the value being edited. Steppers/scrubbing
  // advance THIS, not [widget.value] — the parent's value only updates on
  // the next frame's rebuild, so reading it would make a rapid burst read
  // the same stale value ten times and collapse to one step. [_value] is
  // reconciled with the external value only on a genuine external change
  // (undo, selecting another object), never on the parent echoing back an
  // edit we just committed.
  late double _value;

  late final _controller =
      TextEditingController(text: widget.mixed ? '' : _format(widget.value));
  final _focusNode = FocusNode();
  double _scrubStartValue = 0;
  Offset _scrubAccum = Offset.zero;
  bool _scrubbing = false;

  String _format(double v) {
    final s = widget.integer
        ? v.round().toString()
        : v.toStringAsFixed(widget.decimals);
    // Zero is not negative: a value that rounds to 0 shows unsigned, never
    // "-0" / "-0.0" (e.g. stepping down from 0.1 past zero, or -0.04 → 0.0).
    return double.parse(s) == 0 ? s.replaceFirst('-', '') : s;
  }

  double get _step =>
      widget.step ?? (widget.integer || _value.abs() >= 10 ? 1.0 : 0.1);

  @override
  void initState() {
    super.initState();
    _value = widget.value;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(StudioNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusNode.hasFocus) return;
    if (widget.mixed) {
      _value = widget.value;
      if (_controller.text.isNotEmpty) _controller.text = '';
      return;
    }
    // Adopt only genuine external changes; ignore the parent echoing back
    // a value we just committed (which equals [_value] within fp noise).
    if (oldWidget.mixed || (widget.value - _value).abs() > 1e-9) {
      _value = widget.value;
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
      _controller.text = widget.mixed ? '' : _format(_value);
    }
  }

  double _clamp(double v) {
    var r = v.clamp(widget.min, widget.max ?? double.infinity).toDouble();
    if (widget.integer) r = r.roundToDouble();
    return r;
  }

  /// Sets the local value, reflects it in the field, and notifies.
  void _emit(double v) {
    _value = v;
    _controller.text = _format(v);
    widget.onSubmitted?.call(v);
  }

  void _commit(String text) {
    final parsed = double.tryParse(text);
    if (parsed == null) {
      _controller.text = _format(_value);
      return;
    }
    _emit(_clamp(parsed));
  }

  void _nudge(double delta) => _emit(_clamp(_value + delta));

  // Raw pointer scrubbing (rather than a HorizontalDragGestureRecognizer)
  // so the field's own text-selection drag doesn't win the gesture arena
  // and swallow the scrub. Vertical drags fall through untouched so the
  // field can still live inside a scrollable panel.
  void _onScrubPointerDown(PointerDownEvent _) {
    _scrubStartValue = _value;
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
    _emit(_clamp(_scrubStartValue + (_scrubAccum.dx / _pixelsPerStep) * _step));
  }

  void _resetToDefault() => _emit(_clamp(widget.defaultValue!));

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      _controller.text = _format(_value);
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
      //
      // Reset-on-double-tap is disabled when steppers are shown: a rapid
      // burst of +/- clicks would otherwise be recognized as double-taps
      // and snap the value back to the default. The − button already
      // covers going down, so nothing is lost.
      final onDoubleTap = (widget.defaultValue == null || widget.steppers)
          ? null
          : _resetToDefault;
      field = Listener(
        onPointerDown: _onScrubPointerDown,
        onPointerMove: _onScrubPointerMove,
        child: GestureDetector(
          onDoubleTap: onDoubleTap,
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
