import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import '../form_factor.dart';
import '../panels/panel_def.dart';
import '../workspace_view_model.dart';
import 'dock_controller.dart';
import 'dock_layout.dart';

/// The right-dock workspace: a resizable vertical stack of tabbed panel
/// groups. Tabs drag to reorder, join another group, or split out into
/// a new group via the gap zones; splitters resize adjacent groups.
class DockHost extends StatefulWidget {
  const DockHost({super.key, required this.controller, required this.model});

  final DockController controller;
  final WorkspaceViewModel model;

  @override
  State<DockHost> createState() => _DockHostState();
}

class _DockHostState extends State<DockHost> {
  /// Chrome hit areas grow to touch size on touch platforms
  /// (platform-requirements §14); visuals stay compact.
  bool get _touch => isTouchPlatform;
  double get _splitterThickness => _touch ? 12.0 : 6.0;
  double get _widthHandleThickness => _touch ? 16.0 : 5.0;

  /// Hover state for drop indicators while a tab drag is in flight.
  String? _hoverTabId; // tab whose edge is targeted
  bool _hoverTabAfter = false; // insert after (right of) the hovered tab
  int? _hoverGapIndex; // gap targeted for split-out
  bool _tabDragging = false; // any tab drag in flight (shows gap zones)

  DockController get controller => widget.controller;
  DockLayout get layout => controller.layout;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (layout.groups.isEmpty) return const SizedBox.shrink();
        // One flat surface: single left hairline against the canvas,
        // no per-group borders, no transparent strips.
        return Container(
          width: layout.width,
          decoration: BoxDecoration(
            color: AppTokens.panel,
            border: Border(left: BorderSide(color: AppTokens.border)),
          ),
          child: LayoutBuilder(builder: _dockBody),
        );
      },
    );
  }

  Widget _dockBody(BuildContext context, BoxConstraints constraints) {
    return Stack(children: [
      _groupColumn(constraints),
      // Width handle overlays the left edge — costs no layout space.
      Positioned(top: 0, bottom: 0, left: 0, child: _widthHandle()),
      // Split-out zones at the dock's top/bottom exist only while a
      // tab drag is in flight, so they never show as idle gaps.
      if (_tabDragging) ...[
        Positioned(top: 0, left: 0, right: 0, child: _gapZone(0, height: 14)),
        Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _gapZone(layout.groups.length, height: 14)),
      ],
    ]);
  }

  // ------------------------------------------------------------ width

  Widget _widthHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        key: const Key('dock-width-handle'),
        behavior: HitTestBehavior.translucent,
        // Dock sits on the right edge: dragging left widens it.
        onHorizontalDragUpdate: (details) =>
            controller.resizeWidth(layout.width - details.delta.dx),
        onHorizontalDragEnd: (_) => controller.save(),
        child: SizedBox(width: _widthHandleThickness),
      ),
    );
  }

  // ----------------------------------------------------------- groups

  Widget _groupColumn(BoxConstraints constraints) {
    final groups = layout.groups;
    final children = <Widget>[];
    for (var i = 0; i < groups.length; i++) {
      if (i > 0) children.add(_splitter(i, constraints.maxHeight));
      children.add(_group(groups[i]));
    }
    return Column(children: children);
  }

  Widget _group(DockGroup group) {
    final tabBar = _tabBar(group);
    if (group.collapsed) return tabBar;
    final panel = panelById(group.activeId);
    return Expanded(
      flex: (group.flex * 1000).round().clamp(1, 1 << 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tabBar,
          Expanded(
            child: KeyedSubtree(
              key: Key('dock-panel-${panel.id}'),
              child: panel.builder(context, widget.model),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- tab bar

  /// Affinity-style header: grip, compact left-aligned tabs (active tab
  /// is a filled chip), collapse button. The bar itself accepts tab
  /// drops (append to this group) where no tab claims the hit.
  Widget _tabBar(DockGroup group) {
    return DragTarget<String>(
      // Fallback drop zone where no tab claims the hit: append here.
      onAcceptWithDetails: (details) => controller.movePanel(details.data,
          group: group, tabIndex: group.panelIds.length),
      builder: (context, _, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        decoration: BoxDecoration(
          color: AppTokens.background,
          border: Border(bottom: BorderSide(color: AppTokens.border)),
        ),
        child: Row(
          children: [
            // Grip: visual handle marking the group header.
            Container(
              width: 3,
              height: 14,
              margin: const EdgeInsets.only(right: 7),
              decoration: BoxDecoration(
                color: AppTokens.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Tabs take natural width, shrinking to ellipsis when tight.
            Expanded(
              child: Row(children: [
                for (final (index, id) in group.panelIds.indexed)
                  Flexible(child: _tab(group, index, id)),
              ]),
            ),
            _collapseChevron(group),
          ],
        ),
      ),
    );
  }

  Widget _tab(DockGroup group, int index, String id) {
    final def = panelById(id);
    final active = group.activeId == id && !group.collapsed;
    final tab = InkWell(
      key: Key('dock-tab-$id'),
      borderRadius: BorderRadius.circular(4),
      onTap: () {
        controller.selectTab(id);
        if (group.collapsed) controller.toggleCollapsed(group);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 2),
        padding: EdgeInsets.symmetric(
            horizontal: _touch ? 14 : 10, vertical: _touch ? 14 : 4),
        decoration: BoxDecoration(
          // Affinity-style: the active tab is a filled chip.
          color: active ? AppTokens.surfaceHigh : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          def.title,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? AppTokens.textPrimary : AppTokens.textMuted,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
    BuildContext? tabContext;
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => details.data != id,
      onMove: (details) {
        final box = tabContext?.findRenderObject() as RenderBox?;
        if (box == null || !box.hasSize) return;
        final after = box.globalToLocal(details.offset).dx > box.size.width / 2;
        if (_hoverTabId != id || _hoverTabAfter != after) {
          setState(() {
            _hoverTabId = id;
            _hoverTabAfter = after;
            _hoverGapIndex = null;
          });
        }
      },
      onLeave: (_) => setState(() => _hoverTabId = null),
      onAcceptWithDetails: (details) {
        final tabIndex = index + (_hoverTabAfter ? 1 : 0);
        setState(() => _hoverTabId = null);
        controller.movePanel(details.data, group: group, tabIndex: tabIndex);
      },
      builder: (context, candidates, _) {
        tabContext = context;
        final caretSide = _hoverTabId == id && candidates.isNotEmpty
            ? (_hoverTabAfter ? 1.0 : -1.0)
            : null;
        return Draggable<String>(
          data: id,
          // Anchor the feedback to the pointer so DragTarget.onMove's
          // offset IS the pointer position (edge/zone math relies on it).
          dragAnchorStrategy: pointerDragAnchorStrategy,
          onDragStarted: () => setState(() => _tabDragging = true),
          onDragEnd: (_) => setState(() => _tabDragging = false),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTokens.surfaceHigh,
                border: Border.all(color: AppTokens.primary),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(def.title,
                  style: TextStyle(color: AppTokens.textPrimary, fontSize: 12)),
            ),
          ),
          child: caretSide == null
              ? tab
              : Stack(children: [
                  tab,
                  // 2px insertion caret at the targeted tab edge.
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: caretSide < 0 ? 0 : null,
                    right: caretSide > 0 ? 0 : null,
                    child: Container(width: 2, color: AppTokens.primary),
                  ),
                ]),
        );
      },
    );
  }

  Widget _collapseChevron(DockGroup group) {
    return InkWell(
      key: Key('dock-collapse-${layout.groups.indexOf(group)}'),
      borderRadius: BorderRadius.circular(4),
      onTap: () => controller.toggleCollapsed(group),
      child: Container(
        width: _touch ? 40 : 20,
        height: _touch ? 40 : 20,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTokens.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          group.collapsed ? Icons.expand_more : Icons.expand_less,
          size: 13,
          color: AppTokens.textMuted,
        ),
      ),
    );
  }

  // ------------------------------------------------- splitters / gaps

  /// Splitter above group [below]: resizes the adjacent expanded pair
  /// and doubles as a split-out drop zone.
  Widget _splitter(int below, double columnHeight) {
    final above = layout.groups[below - 1];
    final under = layout.groups[below];
    final resizable = !above.collapsed && !under.collapsed;
    final handle = MouseRegion(
      cursor: resizable
          ? SystemMouseCursors.resizeUpDown
          : SystemMouseCursors.basic,
      child: GestureDetector(
        key: Key('dock-splitter-$below'),
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: resizable
            ? (details) =>
                _dragSplitter(above, under, details.delta.dy, columnHeight)
            : null,
        onVerticalDragEnd: resizable ? (_) => controller.save() : null,
        // Flat separator: reads as chrome, not as a gap to the backdrop.
        child: Container(
          height: _splitterThickness,
          decoration: BoxDecoration(
            color: AppTokens.background,
            border: Border(
              top: BorderSide(color: AppTokens.border),
              bottom: BorderSide(color: AppTokens.border),
            ),
          ),
        ),
      ),
    );
    return _splitOutTarget(below, handle);
  }

  void _dragSplitter(
      DockGroup above, DockGroup below, double deltaPx, double columnHeight) {
    final expanded = [
      for (final g in layout.groups)
        if (!g.collapsed) g
    ];
    final totalFlex = expanded.fold<double>(0, (sum, g) => sum + g.flex);
    if (totalFlex <= 0 || columnHeight <= 0) return;
    // Approximate px-per-flex from the column height; exactness doesn't
    // matter — the drag is continuous feedback.
    final pxPerFlex = columnHeight / totalFlex;
    var deltaFlex = deltaPx / pxPerFlex;
    final minAbove = panelById(above.activeId).minHeight / pxPerFlex;
    final minBelow = panelById(below.activeId).minHeight / pxPerFlex;
    deltaFlex = deltaFlex.clamp(minAbove - above.flex, below.flex - minBelow);
    if (deltaFlex == 0) return;
    controller.resizePair(above, below, deltaFlex);
  }

  /// Drop zone at the dock's top/bottom that tears a dragged tab out
  /// into its own group. Only mounted while a tab drag is in flight.
  Widget _gapZone(int groupIndex, {required double height}) {
    return _splitOutTarget(
      groupIndex,
      SizedBox(height: height, width: double.infinity),
    );
  }

  Widget _splitOutTarget(int groupIndex, Widget child) {
    return DragTarget<String>(
      key: Key('dock-gap-$groupIndex'),
      onWillAcceptWithDetails: (_) => true,
      onMove: (_) {
        if (_hoverGapIndex != groupIndex) {
          setState(() {
            _hoverGapIndex = groupIndex;
            _hoverTabId = null;
          });
        }
      },
      onLeave: (_) => setState(() => _hoverGapIndex = null),
      onAcceptWithDetails: (details) {
        setState(() => _hoverGapIndex = null);
        controller.splitOut(details.data, groupIndex: groupIndex);
      },
      builder: (context, candidates, _) {
        final active = _hoverGapIndex == groupIndex && candidates.isNotEmpty;
        // Overlay the highlight so the hit area never changes size
        // mid-hover.
        return Stack(children: [
          child,
          if (active)
            Positioned.fill(
              child: ColoredBox(
                color: AppTokens.primary.withValues(alpha: 0.6),
              ),
            ),
        ]);
      },
    );
  }
}
