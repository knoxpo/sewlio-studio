import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

/// One row of a [showStudioMenu] popover; `.divider()` draws a hairline.
final class StudioMenuEntry<T> {
  const StudioMenuEntry(this.label, this.value,
      {this.icon, this.enabled = true});

  const StudioMenuEntry.divider()
      : label = null,
        value = null,
        icon = null,
        enabled = false;

  final String? label;
  final T? value;
  final IconData? icon;
  final bool enabled;

  bool get isDivider => label == null;
}

/// Compact anchored context menu in the studio design language: fast
/// fade/scale-in, popover surface, hairline border, hover rows.
/// Replaces Material's showMenu (heavy chrome, slow grow animation).
// ponytail: lives in the app while the layers panel is the only
// consumer — lift into studio_design_system when the canvas needs it.
Future<T?> showStudioMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<StudioMenuEntry<T>> entries,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierLabel: 'context menu',
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 90),
    pageBuilder: (context, _, __) {
      const width = 190.0;
      final size = MediaQuery.sizeOf(context);
      final height =
          entries.fold<double>(8, (h, e) => h + (e.isDivider ? 9 : 26));
      final left = position.dx.clamp(8.0, size.width - width - 8);
      final top = position.dy.clamp(8.0, size.height - height - 8);
      return Stack(children: [
        Positioned(
          left: left,
          top: top,
          child: _StudioMenu<T>(entries: entries, width: width),
        ),
      ]);
    },
    transitionBuilder: (context, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(curved),
          alignment: Alignment.topLeft,
          child: child,
        ),
      );
    },
  );
}

class _StudioMenu<T> extends StatelessWidget {
  const _StudioMenu({required this.entries, required this.width});

  final List<StudioMenuEntry<T>> entries;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTokens.popoverSurface,
          border: Border.all(color: AppTokens.border),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in entries)
              if (entry.isDivider)
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: AppTokens.border,
                )
              else
                _row(context, entry),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, StudioMenuEntry<T> entry) {
    final color = entry.enabled
        ? AppTokens.textPrimary
        : AppTokens.textMuted.withValues(alpha: 0.45);
    return InkWell(
      onTap:
          entry.enabled ? () => Navigator.of(context).pop(entry.value) : null,
      hoverColor: AppTokens.surfaceHigh,
      child: Container(
        height: 26,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: entry.icon == null
                  ? null
                  : Icon(entry.icon, size: 14, color: color),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                entry.label!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
