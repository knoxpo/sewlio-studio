import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Small studio toggle. With [label] it renders a full-width tappable
/// `label … toggle` row (replaces SwitchListTile).
class StudioSwitch extends StatefulWidget {
  const StudioSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  final bool value;

  /// `null` disables the switch.
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  State<StudioSwitch> createState() => _StudioSwitchState();
}

class _StudioSwitchState extends State<StudioSwitch> {
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

  void _toggle() => widget.onChanged?.call(!widget.value);

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.space ||
            event.logicalKey == LogicalKeyboardKey.enter)) {
      _toggle();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onChanged != null;
    final focused = _focusNode.hasFocus;

    final track = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: 30,
      height: 16,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: (widget.value ? AppTokens.primary : AppTokens.surfaceHigh)
            .withValues(alpha: enabled ? 1 : 0.4),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: focused ? AppTokens.primary : AppTokens.border),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 120),
        alignment: widget.value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: enabled ? AppTokens.onPrimary : AppTokens.textMuted,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );

    final child = widget.label == null
        ? track
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              Expanded(
                child: Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: 12,
                    color: enabled
                        ? AppTokens.textPrimary
                        : AppTokens.textMuted.withValues(alpha: 0.5),
                  ),
                ),
              ),
              track,
            ]),
          );

    return Focus(
      focusNode: _focusNode,
      canRequestFocus: enabled,
      onKeyEvent: _onKey,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: child,
        ),
      ),
    );
  }
}
