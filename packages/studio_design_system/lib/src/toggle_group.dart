import 'package:flutter/material.dart';

import 'panel.dart';
import 'tokens.dart';

/// One button in a [StudioToggleGroup].
///
/// [active] is tri-state: `true` = on, `false` = off, `null` =
/// indeterminate/mixed (shown distinctly for mixed multi-object
/// selections). The group is stateless — it only reports taps; the
/// caller derives each item's [active] from the document.
class StudioToggleItem<T> {
  const StudioToggleItem({
    required this.value,
    required this.icon,
    this.tooltip,
    this.active = false,
  });

  final T value;
  final IconData icon;
  final String? tooltip;

  /// `true` on, `false` off, `null` indeterminate.
  final bool? active;
}

/// A horizontal segmented group of toggle buttons built on
/// [StudioIconButton]. Works for single-select (alignment L/C/R) and
/// multi-select (text decorations) alike — the caller decides how a tap
/// updates state and feeds each item's [StudioToggleItem.active] back in.
class StudioToggleGroup<T> extends StatelessWidget {
  const StudioToggleGroup({
    super.key,
    required this.items,
    required this.onToggled,
  });

  final List<StudioToggleItem<T>> items;
  final void Function(T value) onToggled;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTokens.border),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) Container(width: 1, height: 22, color: AppTokens.border),
            _segment(item),
          ],
        ],
      ),
    );
  }

  Widget _segment(StudioToggleItem<T> item) {
    final indeterminate = item.active == null;
    final button = StudioIconButton(
      icon: item.icon,
      tooltip: item.tooltip,
      active: item.active == true,
      size: 16,
      onPressed: () => onToggled(item.value),
    );
    if (!indeterminate) return button;
    // Distinct mixed look: a subtle underline dash under the glyph.
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        button,
        Positioned(
          bottom: 3,
          child: Container(
            key: const ValueKey('studio-toggle-indeterminate'),
            width: 8,
            height: 2,
            decoration: BoxDecoration(
              color: AppTokens.textMuted,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ],
    );
  }
}
