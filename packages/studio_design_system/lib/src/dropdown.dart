import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Compact desktop select (Affinity-style): recessed field trigger with
/// a custom dark popover menu. Keyboard: Enter/Space/Down opens, arrows
/// move the highlight, Enter/Space commits, Escape closes.
// ponytail: menu always opens downward — no flip near the screen
// bottom. Add flip logic if a call site ever lives in a bottom bar.
class StudioDropdown<T> extends StatefulWidget {
  const StudioDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.width,
  });

  final T? value;

  /// (value, label) pairs.
  final List<(T, String)> items;
  final void Function(T value) onChanged;
  final String? hint;
  final double? width;

  @override
  State<StudioDropdown<T>> createState() => _StudioDropdownState<T>();
}

class _StudioDropdownState<T> extends State<StudioDropdown<T>> {
  final _focusNode = FocusNode();
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  int _highlighted = -1;
  double _menuWidth = 0;

  bool get _open => _portal.isShowing;

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

  void _toggle() {
    if (_open) {
      _portal.hide();
    } else {
      _menuWidth =
          (context.findRenderObject() as RenderBox?)?.size.width ?? 120;
      _highlighted = widget.items.indexWhere((e) => e.$1 == widget.value);
      _focusNode.requestFocus();
      _portal.show();
    }
    setState(() {});
  }

  void _close() {
    if (_open) {
      _portal.hide();
      setState(() {});
    }
  }

  void _select(T value) {
    widget.onChanged(value);
    _close();
    _focusNode.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (!_open) {
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.arrowDown) {
        _toggle();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final delta = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      setState(() => _highlighted =
          (_highlighted + delta).clamp(0, widget.items.length - 1));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      if (_highlighted >= 0 && _highlighted < widget.items.length) {
        _select(widget.items[_highlighted].$1);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    String? label = widget.hint;
    for (final (v, l) in widget.items) {
      if (v == widget.value) label = l;
    }
    final focused = _focusNode.hasFocus;

    final text = Text(
      label ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: AppTokens.textPrimary),
    );

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _buildMenu,
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(
          groupId: this,
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _onKey,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggle,
                child: Container(
                  width: widget.width,
                  height: 26,
                  padding: const EdgeInsets.only(left: 8, right: 4),
                  decoration: BoxDecoration(
                    color: AppTokens.field,
                    border: Border.all(
                      color: focused ? AppTokens.primary : AppTokens.border,
                      width: focused ? 1.2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: widget.width == null
                        ? MainAxisSize.min
                        : MainAxisSize.max,
                    children: [
                      widget.width == null ? text : Expanded(child: text),
                      const SizedBox(width: 4),
                      Icon(Icons.expand_more,
                          size: 14, color: AppTokens.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    return CompositedTransformFollower(
      link: _link,
      showWhenUnlinked: false,
      targetAnchor: Alignment.bottomLeft,
      offset: const Offset(0, 4),
      child: Align(
        alignment: Alignment.topLeft,
        child: TapRegion(
          groupId: this,
          onTapOutside: (_) => _close(),
          child: IntrinsicWidth(
            child: Container(
              constraints: BoxConstraints(minWidth: _menuWidth, maxHeight: 280),
              decoration: BoxDecoration(
                color: AppTokens.popoverSurface,
                border: Border.all(color: AppTokens.popoverBorder),
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x99000000),
                      blurRadius: 16,
                      offset: Offset(0, 6)),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, (v, l)) in widget.items.indexed)
                      _MenuRow(
                        label: l,
                        selected: v == widget.value,
                        highlighted: i == _highlighted,
                        onTap: () => _select(v),
                        onHover: () => setState(() => _highlighted = i),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.label,
    required this.selected,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });

  final String label;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: highlighted ? AppTokens.primary : null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      highlighted ? AppTokens.onPrimary : AppTokens.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check,
                  size: 12,
                  color:
                      highlighted ? AppTokens.onPrimary : AppTokens.textMuted),
          ]),
        ),
      ),
    );
  }
}
