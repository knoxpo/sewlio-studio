import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'text_field.dart';
import 'tokens.dart';

/// Like [StudioDropdown] but the open popover carries a type-to-search
/// box. A case-insensitive substring filters the list, ArrowUp/Down move
/// the highlight (keeping it scrolled into view), Enter commits the
/// highlighted item and Escape closes without changing the value. Fully
/// keyboard-operable: the search box takes focus on open.
// ponytail: menu always opens downward, same as StudioDropdown. Add
// flip logic if a call site ever lives in a bottom bar.
class StudioSearchableDropdown<T> extends StatefulWidget {
  const StudioSearchableDropdown({
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
  State<StudioSearchableDropdown<T>> createState() =>
      _StudioSearchableDropdownState<T>();
}

class _StudioSearchableDropdownState<T>
    extends State<StudioSearchableDropdown<T>> {
  static const _rowExtent = 28.0;

  final _focusNode = FocusNode();
  late final _searchFocus = FocusNode(onKeyEvent: _onSearchKey);
  final _searchController = TextEditingController();
  final _scroll = ScrollController();
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  int _highlighted = 0;
  double _menuWidth = 0;

  bool get _open => _portal.isShowing;

  List<(T, String)> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items.where((e) => e.$2.toLowerCase().contains(q)).toList();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchFocus.dispose();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_open) {
      _close();
      return;
    }
    _menuWidth = (context.findRenderObject() as RenderBox?)?.size.width ?? 160;
    _searchController.clear();
    final filtered = _filtered;
    _highlighted = filtered.indexWhere((e) => e.$1 == widget.value);
    if (_highlighted < 0) _highlighted = filtered.isEmpty ? -1 : 0;
    _portal.show();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
      _scrollToHighlighted();
    });
  }

  void _close() {
    if (!_open) return;
    _portal.hide();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _select(T value) {
    widget.onChanged(value);
    _portal.hide();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _onSearchTextChanged() {
    if (!mounted) return;
    setState(() {
      _highlighted = _filtered.isEmpty ? -1 : 0;
    });
    _scrollToHighlighted();
  }

  void _move(int delta) {
    final filtered = _filtered;
    if (filtered.isEmpty) return;
    setState(() {
      _highlighted = (_highlighted + delta).clamp(0, filtered.length - 1);
    });
    _scrollToHighlighted();
  }

  void _scrollToHighlighted() {
    if (!_scroll.hasClients || _highlighted < 0) return;
    final target = _highlighted * _rowExtent;
    final top = _scroll.offset;
    final bottom = top + _scroll.position.viewportDimension;
    final max = _scroll.position.maxScrollExtent;
    if (target < top) {
      _scroll.jumpTo(target.clamp(0, max));
    } else if (target + _rowExtent > bottom) {
      _scroll.jumpTo((target + _rowExtent - _scroll.position.viewportDimension)
          .clamp(0, max));
    }
  }

  KeyEventResult _onSearchKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      final filtered = _filtered;
      if (_highlighted >= 0 && _highlighted < filtered.length) {
        _select(filtered[_highlighted].$1);
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onTriggerKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _open) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.arrowDown) {
      _toggle();
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
            onKeyEvent: _onTriggerKey,
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
    final filtered = _filtered;
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
          child: SizedBox(
            width: _menuWidth < 180 ? 180 : _menuWidth,
            child: Container(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: StudioTextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      autofocus: true,
                      hint: 'Search',
                      style: const TextStyle(fontSize: 12),
                      prefix: Icon(Icons.search,
                          size: 14, color: AppTokens.textMuted),
                    ),
                  ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Text('No matches',
                          style: TextStyle(
                              fontSize: 12, color: AppTokens.textMuted)),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.only(bottom: 4),
                        shrinkWrap: true,
                        itemExtent: _rowExtent,
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final (v, l) = filtered[i];
                          return _MenuRow(
                            label: l,
                            selected: v == widget.value,
                            highlighted: i == _highlighted,
                            onTap: () => _select(v),
                            onHover: () => setState(() => _highlighted = i),
                          );
                        },
                      ),
                    ),
                ],
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
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.centerLeft,
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
