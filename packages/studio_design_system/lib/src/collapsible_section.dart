import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// A titled section that expands/collapses its [child]. The header row is
/// a chevron plus an Affinity-style small-caps title.
///
/// Uncontrolled by default (seeded by [initiallyExpanded]). Pass
/// [expanded] and [onExpandedChanged] to drive it from the outside so a
/// panel can persist open/closed. The header is focusable; Enter/Space
/// toggles it.
class StudioCollapsibleSection extends StatefulWidget {
  const StudioCollapsibleSection({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = true,
    this.expanded,
    this.onExpandedChanged,
  });

  final String title;
  final Widget child;
  final bool initiallyExpanded;

  /// When non-null the section is controlled: it renders this value and
  /// never toggles itself — it only calls [onExpandedChanged].
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;

  @override
  State<StudioCollapsibleSection> createState() =>
      _StudioCollapsibleSectionState();
}

class _StudioCollapsibleSectionState extends State<StudioCollapsibleSection> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _isExpanded => widget.expanded ?? _expanded;

  void _toggle() {
    final next = !_isExpanded;
    if (widget.expanded == null) setState(() => _expanded = next);
    widget.onExpandedChanged?.call(next);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space)) {
      _toggle();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Focus(
          onKeyEvent: _onKey,
          child: Builder(builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Focus.of(context).requestFocus();
                  _toggle();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  color: focused
                      ? AppTokens.primary.withValues(alpha: 0.12)
                      : null,
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.chevron_right,
                        size: 16,
                        color: AppTokens.textMuted,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.title.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          letterSpacing: 0.8,
                          color: AppTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: widget.child,
          ),
      ],
    );
  }
}
