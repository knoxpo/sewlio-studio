import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

/// One row in a tool-group flyout.
final class FlyoutEntry {
  const FlyoutEntry({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onPick,
  });

  final IconData icon;
  final String label;
  final bool selected;

  /// Null = future tool: rendered dimmed and inert.
  final VoidCallback? onPick;
}

/// Affinity-style tool-group slot: hovering (or clicking when already
/// active, long-press, right-click) opens a popover beside the rail
/// listing the group's tools. The slot shows the group's current tool
/// and a corner-triangle flyout indicator; the last-picked tool stays
/// on the slot.
class ToolFlyoutSlot extends StatefulWidget {
  const ToolFlyoutSlot({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onActivate,
    required this.entries,
  });

  final IconData icon;
  final String? tooltip;
  final bool active;

  /// Slot tap when the group is not active.
  final VoidCallback onActivate;
  final List<FlyoutEntry> entries;

  @override
  State<ToolFlyoutSlot> createState() => _ToolFlyoutSlotState();
}

class _ToolFlyoutSlotState extends State<ToolFlyoutSlot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      reverseDuration: const Duration(milliseconds: 110),
    );
  }

  OverlayEntry? _popover;
  Timer? _openTimer;
  Timer? _closeTimer;
  var _pointerInButton = false;
  var _pointerInPopover = false;

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    _popover?.remove();
    _popover = null;
    _animation.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_popover == null) return;
    await _animation.reverse();
    _popover?.remove();
    _popover = null;
  }

  void _open() {
    if (_popover != null || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final origin = box.localToGlobal(Offset(box.size.width + 8, -4));
    final fade = CurvedAnimation(
      parent: _animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    );
    final slide = Tween<Offset>(begin: const Offset(-10, 0), end: Offset.zero)
        .animate(fade);
    _popover = OverlayEntry(
      builder: (context) => Positioned(
        left: origin.dx,
        top: origin.dy,
        child: MouseRegion(
          onEnter: (_) => _pointerInPopover = true,
          onExit: (_) {
            _pointerInPopover = false;
            _scheduleClose();
          },
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => Opacity(
              opacity: fade.value,
              child: Transform.translate(offset: slide.value, child: child),
            ),
            child: _FlyoutPopover(
              entries: widget.entries,
              onPicked: _dismiss,
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_popover!);
    _animation.forward(from: 0);
  }

  void _scheduleClose() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 250), () {
      if (!_pointerInButton && !_pointerInPopover) _dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _pointerInButton = true;
        _openTimer = Timer(const Duration(milliseconds: 350), _open);
      },
      onExit: (_) {
        _pointerInButton = false;
        _openTimer?.cancel();
        _scheduleClose();
      },
      child: GestureDetector(
        onLongPress: _open,
        onSecondaryTap: _open,
        child: StudioIconButton(
          icon: widget.icon,
          tooltip: widget.tooltip,
          active: widget.active,
          flyoutIndicator: true,
          onPressed: () {
            if (widget.active) {
              _open();
            } else {
              widget.onActivate();
            }
          },
        ),
      ),
    );
  }
}

class _FlyoutPopover extends StatelessWidget {
  const _FlyoutPopover({required this.entries, required this.onPicked});

  final List<FlyoutEntry> entries;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: AppTokens.popoverSurface,
          border: Border.all(color: AppTokens.popoverBorder),
          borderRadius: BorderRadius.circular(7),
          boxShadow: const [
            // Deep drop + tight contact shadow lift the popover off the
            // panel chrome.
            BoxShadow(
                color: Color(0x99000000),
                blurRadius: 24,
                offset: Offset(0, 10)),
            BoxShadow(
                color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final entry in entries)
              InkWell(
                onTap: entry.onPick == null
                    ? null
                    : () {
                        onPicked();
                        entry.onPick!();
                      },
                hoverColor: AppTokens.primary.withValues(alpha: 0.25),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(children: [
                    Icon(entry.icon,
                        size: 16,
                        color: entry.onPick == null
                            ? AppTokens.textMuted.withValues(alpha: 0.4)
                            : entry.selected
                                ? AppTokens.primary
                                : AppTokens.textPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(entry.label,
                          style: TextStyle(
                              fontSize: 12,
                              color: entry.onPick == null
                                  ? AppTokens.textMuted.withValues(alpha: 0.4)
                                  : entry.selected
                                      ? AppTokens.primary
                                      : AppTokens.textPrimary)),
                    ),
                    if (entry.selected)
                      const Icon(Icons.check,
                          size: 12, color: AppTokens.primary),
                    if (entry.onPick == null)
                      Text('soon',
                          style: TextStyle(
                              fontSize: 9, color: AppTokens.textMuted)),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Short inset separator between rail tool groups (Affinity-style).
class RailSeparator extends StatelessWidget {
  const RailSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: AppTokens.surfaceHigh,
    );
  }
}
