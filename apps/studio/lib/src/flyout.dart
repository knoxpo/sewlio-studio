import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import 'tool_options.dart';

/// Affinity-style tool-group button: hovering (or clicking when already
/// active, long-press, right-click) opens a popover beside the rail
/// listing the group's variants. The slot shows the current variant and
/// a corner-triangle flyout indicator.
class ShapeFlyoutButton extends StatefulWidget {
  const ShapeFlyoutButton({
    super.key,
    required this.shapeTool,
    required this.active,
    required this.onActivate,
  });

  final ShapeTool shapeTool;
  final bool active;

  /// Called with the picked kind (or null to just activate the tool).
  final void Function(ShapeKind? kind) onActivate;

  @override
  State<ShapeFlyoutButton> createState() => _ShapeFlyoutButtonState();
}

class _ShapeFlyoutButtonState extends State<ShapeFlyoutButton>
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
            child: _ShapePopover(
              current: widget.shapeTool.kind,
              onPick: (kind) {
                _dismiss();
                widget.onActivate(kind);
              },
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
          icon: shapeIcon(widget.shapeTool.kind),
          tooltip: '${shapeLabel(widget.shapeTool.kind)} (M)',
          active: widget.active,
          flyoutIndicator: true,
          onPressed: () {
            if (widget.active) {
              _open();
            } else {
              widget.onActivate(null);
            }
          },
        ),
      ),
    );
  }
}

class _ShapePopover extends StatelessWidget {
  const _ShapePopover({required this.current, required this.onPick});

  final ShapeKind current;
  final void Function(ShapeKind kind) onPick;

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
            for (final kind in ShapeKind.values)
              InkWell(
                onTap: () => onPick(kind),
                hoverColor: AppTokens.primary.withValues(alpha: 0.25),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(children: [
                    Icon(shapeIcon(kind),
                        size: 16,
                        color: kind == current
                            ? AppTokens.primary
                            : AppTokens.textPrimary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(shapeLabel(kind),
                          style: TextStyle(
                              fontSize: 12,
                              color: kind == current
                                  ? AppTokens.primary
                                  : AppTokens.textPrimary)),
                    ),
                    if (kind == current)
                      const Icon(Icons.check,
                          size: 12, color: AppTokens.primary),
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
