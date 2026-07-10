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
  /// value is ≥ 10 and 0.1 below that.
  final double? step;

  final double? width;
  final TextAlign textAlign;

  @override
  State<StudioNumberField> createState() => _StudioNumberFieldState();
}

class _StudioNumberFieldState extends State<StudioNumberField> {
  late final _controller = TextEditingController(text: _format(widget.value));
  final _focusNode = FocusNode();

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
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
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
      _controller.text = _format(widget.value);
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
    final field = Focus(
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: StudioTextField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: enabled,
        textAlign: widget.textAlign,
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
