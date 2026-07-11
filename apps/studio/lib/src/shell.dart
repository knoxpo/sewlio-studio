import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'app_shell.dart';
import 'app_view_model.dart';
import 'bottom_panel.dart';
import 'dock/dock_host.dart';
import 'form_factor.dart';
import 'menu/app_menus.dart';
import 'menu/menu_renderers.dart';
import 'new_project_page.dart';
import 'panels/context_menu.dart';
import 'prompts.dart';
import 'shape_palette.dart';
import 'tool_options.dart';
import 'toolbox.dart';
import 'tools/tool_contributions.dart';
import 'workspace/domain_module.dart';
import 'workspace/overlay_def.dart';
import 'workspace/project_type_registry.dart';
import 'workspace_view_model.dart';

/// CAD editor workspace (barley MVVM view): renders [WorkspaceViewModel]
/// and forwards gestures and dialog results to it. All state and logic
/// live in the model; every mutation goes through commands (ARCH-003).
/// Hosted by [AppShell] under the active document tab.
class EditorWorkspace extends StatelessWidget {
  const EditorWorkspace({super.key, required this.model, required this.app});

  final WorkspaceViewModel model;
  final AppViewModel app;

  @override
  Widget build(BuildContext context) {
    // Reassigned every build so the closure captures the live context.
    model.onOpenHoopSetup = () => showDocumentSetup(context, model);
    final sequence = model.sequence;
    if (model.mode == WorkspaceMode.domain) return _domainWorkspace(context);
    if (model.mode == WorkspaceMode.simulation) {
      // ponytail: full-bleed playback strip until the simulation
      // workspace (transport bar + panels) lands.
      return Column(children: [
        Expanded(child: SimulationSection(sequence: sequence)),
        _statusBar(),
      ]);
    }
    return Focus(
        autofocus: true,
        onKeyEvent: model.onKey,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return _workspaceBody(
                    context, formFactorFor(constraints.maxWidth));
              }),
            ),
            BottomPanel(
              sequence: sequence,
              hoop: model.hoop,
              onEditHoop: () => showDocumentSetup(context, model),
              onExport: (suffix) => exportWithPicker(context, model, suffix),
            ),
            _statusBar(),
          ],
        ));
  }

  /// Workspace layout per breakpoint (platform-requirements §14):
  /// desktop keeps permanent edge panels; tablet landscape makes the
  /// dock collapsible; tablet portrait floats toolbox and dock over a
  /// full-bleed canvas.
  Widget _workspaceBody(BuildContext context, FormFactor formFactor) {
    final touch = isTouchPlatform;
    switch (formFactor) {
      case FormFactor.desktop:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolboxRail(model: model, touchMode: touch),
            Expanded(child: _canvasColumn(context, formFactor)),
            DockHost(controller: app.dock, model: model),
          ],
        );
      case FormFactor.tabletLandscape:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToolboxRail(model: model, touchMode: touch),
            Expanded(child: _canvasColumn(context, formFactor)),
            if (model.dockVisible) DockHost(controller: app.dock, model: model),
          ],
        );
      case FormFactor.tabletPortrait:
        return Stack(children: [
          Positioned.fill(child: _canvasColumn(context, formFactor)),
          Positioned(
            left: 8,
            top: 40,
            bottom: 40,
            // ponytail: always-visible floating rail — auto-hide-on-idle
            // arrives if it proves to cover too much canvas in practice.
            child: ToolboxRail(model: model, touchMode: touch, floating: true),
          ),
          if (model.dockVisible)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: DockHost(controller: app.dock, model: model),
            ),
        ]);
    }
  }

  /// The multi-tool toolbox group containing the active tool, if any —
  /// its floating palette shows while one of its tools is active.
  ToolboxGroup? _activeToolGroup() {
    for (final group in toolboxGroups) {
      if (group.tools.length > 1 &&
          group.tools.any((tool) => tool.kind == model.activeKind)) {
        return group;
      }
    }
    return null;
  }

  /// The floating palette for the active tool/group, if any: the
  /// tool's registered quick options (ADR-037), else the flyout grid
  /// for multi-tool toolbox groups.
  Widget? _paletteDock() {
    final quick = toolContributionFor(model.activeKind)?.quickOptions;
    if (quick != null) {
      return PaletteDock(
        model: model,
        id: quick.paletteId,
        paletteKey: quick.paletteKey,
        gripKey: quick.gripKey,
        child: Builder(builder: (context) => quick.builder(context, model)),
      );
    }
    if (_activeToolGroup() case final group?) {
      return PaletteDock(
        model: model,
        id: group.id,
        paletteKey: Key('palette-${group.id}'),
        gripKey: Key('palette-grip-${group.id}'),
        child: ToolGroupPaletteGrid(model: model, group: group),
      );
    }
    return null;
  }

  // -------------------------------------------------------- domain view

  /// Domain workspace: production authoring for the active project type
  /// (ARCH-038). Structurally the design layout — rail, mode toolbar,
  /// shared canvas, dock — with every surface resolved from the
  /// project type's module. This is an editing view, not a preview:
  /// selection works on the shared canvas.
  // ponytail: desktop layout on every form factor — tablet variants
  // arrive with the design ones once domain tools are real.
  Widget _domainWorkspace(BuildContext context) {
    final module = moduleFor(model.projectType);
    return Focus(
      autofocus: true,
      onKeyEvent: model.onKey,
      child: Column(children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ToolboxRail(
                  model: model,
                  groups: module.domainToolbox,
                  touchMode: isTouchPlatform),
              Expanded(
                child: Column(children: [
                  _domainToolbar(module),
                  Expanded(
                    child: Builder(
                      builder: (context) => Stack(children: [
                        _buildCanvas(),
                        // Contributed overlays: presentation-only layers
                        // above the shared canvas (ARCH-038).
                        for (final overlay
                            in model.activeOverlays(WorkspaceMode.domain))
                          Positioned.fill(
                              child: overlay.builder(context, model)),
                      ]),
                    ),
                  ),
                ]),
              ),
              DockHost(
                  controller: app.dockFor(model.mode, model.projectType),
                  model: model),
            ],
          ),
        ),
        _statusBar(),
      ]),
    );
  }

  /// Mode-aware top toolbar: domain label + the module's quick actions
  /// (disabled placeholders until their commands exist).
  Widget _domainToolbar(DomainUiModule module) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      child: Row(children: [
        const Icon(Icons.edit_outlined, size: 14, color: AppTokens.primary),
        const SizedBox(width: 4),
        Text('${module.domainLabel} View',
            style: const TextStyle(color: AppTokens.primary, fontSize: 11)),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              for (final action in module.quickActions)
                StudioIconButton(
                  key: Key('quick-${action.id}'),
                  icon: action.icon,
                  tooltip: '${action.label} — coming soon',
                  onPressed: null,
                ),
            ]),
          ),
        ),
        _overlayToggles(module),
        StudioIconButton(
            icon: Icons.fit_screen_outlined,
            tooltip: 'Fit to canvas',
            onPressed: model.fitCanvas),
      ]),
    );
  }

  /// Overlay visibility menu for the current mode's contributed overlays.
  Widget _overlayToggles(DomainUiModule module) {
    final overlays = model.mode == WorkspaceMode.simulation
        ? module.simulationOverlays
        : module.domainOverlays;
    if (overlays.isEmpty) return const SizedBox.shrink();
    return PopupMenuButton<OverlayDef>(
      key: const Key('overlay-toggles'),
      tooltip: 'Overlays',
      color: AppTokens.popoverSurface,
      icon: Icon(Icons.visibility_outlined,
          size: 15, color: AppTokens.textMuted),
      onSelected: (overlay) => model.toggleOverlay(model.mode, overlay),
      itemBuilder: (context) => [
        for (final overlay in overlays)
          PopupMenuItem(
            key: Key('overlay-toggle-${overlay.id}'),
            value: overlay,
            height: 30,
            child: Row(children: [
              Icon(
                Icons.check,
                size: 14,
                color: model.overlayVisible(model.mode, overlay)
                    ? AppTokens.primary
                    : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(overlay.label, style: const TextStyle(fontSize: 12)),
            ]),
          ),
      ],
    );
  }

  // ---------------------------------------------------------- canvas column

  Widget _canvasColumn(BuildContext context, FormFactor formFactor) {
    return Column(
      children: [
        // Canvas toolbar
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppTokens.panel,
            border: Border(bottom: BorderSide(color: AppTokens.border)),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility, size: 14, color: AppTokens.primary),
              const SizedBox(width: 4),
              const Text('Design View',
                  style: TextStyle(color: AppTokens.primary, fontSize: 11)),
              const SizedBox(width: 16),
              // View toggles: visualization only, never document state.
              // Grouped pill, same design language as the header's
              // workspace switcher (multi-select: each segment toggles).
              _ViewToggleGroup(segments: [
                (
                  Icons.gesture,
                  'Show stitches (S)',
                  model.showStitches,
                  model.toggleShowStitches,
                ),
                (
                  Icons.polyline_outlined,
                  'Show outlines (O)',
                  model.showOutlines,
                  model.toggleShowOutlines,
                ),
                (
                  Icons.grain,
                  'Show needle holes (N)',
                  model.showNeedleHoles,
                  model.toggleShowNeedleHoles,
                ),
              ]),
              const Spacer(),
              StudioIconButton(
                  icon: Icons.fit_screen_outlined,
                  tooltip: 'Fit to canvas',
                  onPressed: model.fitCanvas),
              StudioIconButton(
                  icon: Icons.zoom_out,
                  tooltip: 'Zoom out',
                  onPressed: () => model.zoomBy(0.8)),
              _zoomControl(),
              StudioIconButton(
                  icon: Icons.zoom_in,
                  tooltip: 'Zoom in',
                  onPressed: () => model.zoomBy(1.25)),
              // Collapsible dock (tablet form factors only).
              if (formFactor != FormFactor.desktop)
                StudioIconButton(
                    key: const Key('toggle-dock'),
                    icon:
                        model.dockVisible ? Icons.last_page : Icons.first_page,
                    tooltip: model.dockVisible ? 'Hide panels' : 'Show panels',
                    active: model.dockVisible,
                    onPressed: model.toggleDock),
            ],
          ),
        ),
        // Contextual tool options (Illustrator control bar).
        ToolOptionsBar(tool: model.tool, onChanged: model.notify, model: model),
        Expanded(
          child: _rulerFrame(
            context,
            Stack(children: [
              _buildCanvas(),
              // Floating tool palette: docked inside the canvas cell so
              // it can never cover rulers, toolbars, or panels.
              if (_paletteDock() case final dock?) Positioned.fill(child: dock),
            ]),
          ),
        ),
        // Thread palette bar
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppTokens.panel,
            border: Border(top: BorderSide(color: AppTokens.border)),
          ),
          child: Row(
            children: [
              Text('Colorway 1',
                  style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
              const SizedBox(width: 12),
              for (final (index, thread) in model.sequence.threads.indexed)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFF000000 |
                          int.parse(thread.color.substring(1), radix: 16)),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: AppTokens.border),
                    ),
                    child: Text('${index + 1}',
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCanvas() {
    return ValueListenableBuilder<MouseCursor>(
      valueListenable: model.canvasCursor,
      builder: (context, cursor, _) => ValueListenableBuilder<PaintedCursor?>(
        valueListenable: model.paintedCursor,
        builder: (context, penBadge, _) => penBadge == null
            ? _canvasView(context, cursor, null, null)
            // Pen active: track the pointer so the painted pen cursor
            // follows every move (only then — other tools don't pay
            // the per-move rebuild).
            : ValueListenableBuilder<g.Point?>(
                valueListenable: model.cursor,
                builder: (context, world, _) =>
                    _canvasView(context, cursor, penBadge, world),
              ),
      ),
    );
  }

  Widget _canvasView(BuildContext context, MouseCursor cursor,
      PaintedCursor? penBadge, g.Point? penWorld) {
    return CanvasView(
      document: model.session.document,
      viewport: model.viewport,
      // Transform box + per-object frames: Select tool only. Pen/Node
      // show the selected object's anchor points instead.
      selectedIds: model.showsTransformBox ? model.selectedObjectIds : const {},
      selectionBounds: model.showsTransformBox ? model.selectionBounds : null,
      previewPaths: model.tool.preview,
      previewWidths: model.previewWidths,
      markers: model.canvasMarkers,
      stitches: model.showStitches ? model.sequence : null,
      highlightStitches: model.highlightedStitchOps,
      showOutlines: model.showOutlines,
      showNeedleHoles: model.showNeedleHoles,
      cursor: cursor,
      paintedCursor: penBadge,
      paintedCursorWorld: penWorld,
      boxTransform: model.liveBoxTransform,
      cursorLabel: model.liveTransformLabel,
      cursorLabelWorld:
          model.liveTransformLabel == null ? null : model.cursor.value,
      onTapWorld: model.onCanvasTap,
      onLongPressWorld: (world, globalPosition) =>
          _showCanvasContextMenu(context, world, globalPosition),
      onHoverWorld: model.hover,
      onHoverExit: model.pointerExited,
      onDragStartWorld: model.onCanvasDragStart,
      onDragUpdateWorld: model.onCanvasDragUpdate,
      onDragEndWorld: model.onCanvasDragEnd,
      liveGuide: model.liveGuide,
      hideGuideId: model.hiddenGuideId,
    );
  }

  /// Touch long-press context menu (tablets). With the Select tool a
  /// press over an unselected object selects it first, so the menu
  /// acts on what's under the finger.
  Future<void> _showCanvasContextMenu(
      BuildContext context, g.Point world, Offset globalPosition) async {
    if (model.activeKind == ToolKind.select && model.primarySelection == null) {
      model.onCanvasTap(world, toggle: false, extend: false);
    }
    final hasSelection = model.primarySelection != null;
    final action = await showStudioMenu<String>(
      context: context,
      position: globalPosition,
      entries: [
        StudioMenuEntry('Duplicate', 'duplicate', enabled: hasSelection),
        StudioMenuEntry('Delete', 'delete', enabled: hasSelection),
        const StudioMenuEntry.divider(),
        const StudioMenuEntry('Zoom to Fit', 'fit'),
      ],
    );
    switch (action) {
      case 'duplicate':
        model.duplicatePrimary();
      case 'delete':
        model.deleteSelection();
      case 'fit':
        model.fitCanvas();
    }
  }

  /// Wraps the canvas in top/left mm rulers when enabled (View menu).
  Widget _rulerFrame(BuildContext context, Widget canvas) {
    if (!model.showRulers) return canvas;
    final corner = SizedBox(
      width: rulerThickness,
      height: rulerThickness,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTokens.panel,
          border: Border(
            right: BorderSide(color: AppTokens.border),
            bottom: BorderSide(color: AppTokens.border),
          ),
        ),
        child: Center(
          child: Text('mm',
              style: TextStyle(fontSize: 7, color: AppTokens.textMuted)),
        ),
      ),
    );
    return Column(children: [
      Row(children: [
        corner,
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTokens.panel,
              border: Border(bottom: BorderSide(color: AppTokens.border)),
            ),
            child: Ruler(
              viewport: model.viewport,
              axis: Axis.horizontal,
              cursor: model.cursor,
              markers: model.markersFor(GuideAxis.vertical),
              onTapMm: (mm) => _onRulerTap(context, GuideAxis.vertical, mm),
              // Illustrator pull-out: top ruler births a horizontal guide.
              onGuidePullStart: (mm) =>
                  model.beginGuidePull(GuideAxis.horizontal, mm),
              onGuidePullUpdate: model.updateGuidePull,
              onGuidePullEnd: model.endGuidePull,
            ),
          ),
        ),
      ]),
      Expanded(
        child: Row(children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppTokens.panel,
              border: Border(right: BorderSide(color: AppTokens.border)),
            ),
            child: Ruler(
              viewport: model.viewport,
              axis: Axis.vertical,
              cursor: model.cursor,
              markers: model.markersFor(GuideAxis.horizontal),
              onTapMm: (mm) => _onRulerTap(context, GuideAxis.horizontal, mm),
              // Left ruler births a vertical guide.
              onGuidePullStart: (mm) =>
                  model.beginGuidePull(GuideAxis.vertical, mm),
              onGuidePullUpdate: model.updateGuidePull,
              onGuidePullEnd: model.endGuidePull,
            ),
          ),
          Expanded(child: canvas),
        ]),
      ),
    ]);
  }

  static const _zoomPresets = [25.0, 50.0, 75.0, 100.0, 150.0, 200.0, 400.0];

  /// Editable zoom percentage with a preset dropdown ("Fit" + %).
  Widget _zoomControl() {
    final viewport = model.viewport;
    return ListenableBuilder(
      listenable: viewport,
      builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: 60,
          child: StudioTextField(
            key: ValueKey('zoom-${viewport.percent.round()}'),
            initialValue: '${viewport.percent.round()}%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
            onSubmitted: (text) {
              final value = double.tryParse(text.replaceAll('%', '').trim());
              if (value != null && value > 0) viewport.setPercent(value);
            },
          ),
        ),
        PopupMenuButton<double?>(
          tooltip: 'Zoom presets',
          color: AppTokens.popoverSurface,
          icon:
              Icon(Icons.arrow_drop_down, size: 16, color: AppTokens.textMuted),
          padding: EdgeInsets.zero,
          onSelected: (value) =>
              value == null ? model.fitCanvas() : viewport.setPercent(value),
          itemBuilder: (context) => [
            const PopupMenuItem<double?>(
              value: null,
              height: 30,
              child: Text('Fit', style: TextStyle(fontSize: 12)),
            ),
            for (final preset in _zoomPresets)
              PopupMenuItem<double?>(
                value: preset,
                height: 30,
                child: Text('${preset.round()}%',
                    style: const TextStyle(fontSize: 12)),
              ),
          ],
        ),
      ]),
    );
  }

  // -------------------------------------------------------------- statusbar

  Widget _statusBar() {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 10, color: AppTokens.textMuted),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppTokens.accentGreen, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            // Ellipsize: tool hints outgrow narrow (tablet) windows.
            Expanded(
              child: Text(model.tool.status ?? 'Ready',
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 10),
            ListenableBuilder(
              listenable: model.viewport,
              builder: (context, _) =>
                  Text('Zoom: ${model.viewport.percent.round()}%'),
            ),
            const SizedBox(width: 24),
            ValueListenableBuilder(
              valueListenable: model.cursor,
              builder: (context, g.Point? p, _) => Text(
                p == null
                    ? 'Cursor: —'
                    : 'Cursor: ${p.x.toStringAsFixed(2)} mm, '
                        '${p.y.toStringAsFixed(2)} mm',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- guides

  /// Ruler tap: edit the nearest guide on that axis, or create one.
  void _onRulerTap(BuildContext context, GuideAxis axis, double mm) {
    _guideDialog(context,
        axis: axis, mm: mm, existing: model.guideAt(axis, mm));
  }

  /// Guide swatches: null = default guide color.
  static const _guideSwatches = <String?>[
    null,
    '#ff6b6b',
    '#ffb74d',
    '#ffd54f',
    '#66bb6a',
    '#5c9dff',
    '#ba68c8',
    '#f06292',
  ];

  Future<void> _guideDialog(
    BuildContext context, {
    required GuideAxis axis,
    required double mm,
    Guide? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final positionController = TextEditingController(
        text: (existing?.positionMm ?? mm).toStringAsFixed(1));
    String? colorHex = existing?.colorHex;
    final result = await showStudioDialog<String>(
      context: context,
      title: existing == null ? 'Add Guide' : 'Edit Guide',
      body: StatefulBuilder(
        builder: (context, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudioTextField(
              controller: nameController,
              autofocus: true,
              label: 'Name',
            ),
            const SizedBox(height: 12),
            StudioTextField(
              controller: positionController,
              label: '${axis == GuideAxis.vertical ? 'X' : 'Y'} position (mm)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Text('Color',
                style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
            const SizedBox(height: 6),
            Row(children: [
              for (final swatch in _guideSwatches)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => setDialogState(() => colorHex = swatch),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: swatch == null
                            ? const Color(0xFF26C6DA)
                            : Color(0xFF000000 |
                                int.parse(swatch.substring(1), radix: 16)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorHex == swatch
                              ? Colors.white
                              : AppTokens.border,
                          width: colorHex == swatch ? 2 : 1,
                        ),
                      ),
                      child: swatch == null
                          ? const Icon(Icons.star,
                              size: 10, color: Colors.white70)
                          : null,
                    ),
                  ),
                ),
            ]),
          ],
        ),
      ),
      actions: [
        if (existing != null)
          Builder(
            builder: (context) => StudioButton(
              label: 'Delete',
              variant: StudioButtonVariant.danger,
              onPressed: () => Navigator.pop(context, 'delete'),
            ),
          ),
        Builder(
          builder: (context) => StudioButton(
            label: 'Cancel',
            variant: StudioButtonVariant.ghost,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Builder(
          builder: (context) => StudioButton(
            label: existing == null ? 'Add' : 'Save',
            variant: StudioButtonVariant.primary,
            onPressed: () => Navigator.pop(context, 'save'),
          ),
        ),
      ],
    );
    if (result == null) return;
    if (result == 'delete') {
      model.removeGuide(existing!.id);
      return;
    }
    final position = double.tryParse(positionController.text) ??
        (existing?.positionMm ?? mm);
    final name = nameController.text.trim();
    if (existing == null) {
      model.addGuide(axis, position, name, colorHex);
    } else {
      model.updateGuide(existing, position, name, colorHex);
    }
  }
}

/// Connected multi-select toggle pill for canvas view options: each
/// segment flips independently; active segments sit on an accent tint
/// with an accent glyph.
class _ViewToggleGroup extends StatelessWidget {
  const _ViewToggleGroup({required this.segments});

  /// (icon, tooltip, active, onToggle) per segment.
  final List<(IconData, String, bool, VoidCallback)> segments;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: AppTokens.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (index, (icon, tooltip, active, onToggle))
            in segments.indexed) ...[
          if (index > 0) VerticalDivider(width: 1, color: AppTokens.border),
          Tooltip(
            message: tooltip,
            waitDuration: const Duration(milliseconds: 400),
            child: InkWell(
              onTap: onToggle,
              hoverColor: AppTokens.surfaceHigh,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 34,
                alignment: Alignment.center,
                color: active
                    ? AppTokens.primary.withValues(alpha: 0.22)
                    : Colors.transparent,
                child: Icon(icon,
                    size: 14,
                    color: active ? AppTokens.primary : AppTokens.textMuted),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

// ------------------------------------------------------------ file actions
//
// Top-level so both the in-app header (web/Windows/Linux) and the native
// macOS menu bar (app_shell) share them.

/// Whether to use the real system menu bar instead of the in-app header:
/// desktop macOS only — web, Windows, and Linux have no global-menu API
/// in Flutter, so the in-app header is the platform convention there.
bool get useNativeMenus =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

void _toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Save/export toast. On touch platforms the file lives in the app
/// documents sandbox, so the toast carries a Share action (system
/// share sheet → Files/Drive/AirDrop) as the way to get it out.
void _toastSaved(BuildContext context, String message, String path) {
  if (!isTouchPlatform) {
    _toast(context, message);
    return;
  }
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: 'Share…',
      onPressed: () =>
          SharePlus.instance.share(ShareParams(files: [XFile(path)])),
    ),
  ));
}

/// Saves the active tab; [saveAs] (or an unsaved project) asks via the
/// native dialog, which confirms overwrites itself.
Future<void> saveActiveProject(BuildContext context, AppViewModel app,
    {bool saveAs = false}) async {
  final tab = app.activeTab;
  if (tab == null) return;
  final path = (saveAs ? null : tab.path) ??
      await pickSavePath(
        suffix: '.swl',
        suggestedName: '${tab.title}.swl',
      );
  if (path == null || !context.mounted) return;
  try {
    await app.saveTab(tab, path);
    if (context.mounted) _toastSaved(context, 'Saved $path', path);
  } catch (e) {
    if (context.mounted) _toast(context, 'Save failed: $e');
  }
}

Future<void> openProjectWithPicker(
    BuildContext context, AppViewModel app) async {
  final path = await pickOpenPath(suffix: '.swl');
  if (path == null || !context.mounted) return;
  try {
    final tab = await app.openProject(path);
    if (context.mounted) _toast(context, 'Opened ${tab.title}');
  } catch (e) {
    if (context.mounted) _toast(context, 'Open failed: $e');
  }
}

Future<void> importSvgWithPicker(
    BuildContext context, WorkspaceViewModel model) async {
  final path = await pickOpenPath(suffix: '.svg');
  if (path == null || !context.mounted) return;
  try {
    final count = await model.importSvgFrom(path);
    if (!context.mounted) return;
    _toast(
        context,
        count == 0
            ? 'No <path> outlines found in $path'
            : 'Imported $count path(s)');
  } catch (e) {
    if (context.mounted) _toast(context, 'Import failed: $e');
  }
}

Future<void> exportWithPicker(
    BuildContext context, WorkspaceViewModel model, String suffix) async {
  final path = await pickSavePath(
    suffix: suffix,
    suggestedName: '${model.session.document.name}$suffix',
  );
  if (path == null || !context.mounted) return;
  final result = model.prepareExport(suffix);
  if (result.error != null) {
    _toast(context, result.error!);
    return;
  }
  try {
    await model.writeExport(path, result.bytes!);
    if (context.mounted) {
      _toastSaved(
          context,
          'Exported $path'
          '${result.skipped == 0 ? '' : ' (${result.skipped} object(s) skipped)'}',
          path);
    }
  } catch (e) {
    if (context.mounted) _toast(context, 'Export failed: $e');
  }
}

Future<void> showRenameDialog(
    BuildContext context, WorkspaceViewModel model) async {
  final controller = TextEditingController(text: model.session.document.name);
  final name = await showStudioDialog<String>(
    context: context,
    title: 'Rename Document',
    body: StudioTextField(controller: controller, autofocus: true),
    actions: [
      Builder(
        builder: (context) => StudioButton(
          label: 'Cancel',
          variant: StudioButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      Builder(
        builder: (context) => StudioButton(
          label: 'Rename',
          variant: StudioButtonVariant.primary,
          onPressed: () => Navigator.pop(context, controller.text),
        ),
      ),
    ],
  );
  if (name != null) model.rename(name);
}

/// Compact keyboard-shortcut reference (Help menu).
Future<void> showShortcutsDialog(BuildContext context) {
  const rows = [
    ('V', 'Select tool'),
    ('A', 'Node editing'),
    ('P', 'Pen'),
    ('B', 'Pencil'),
    ('M', 'Shape'),
    ('T', 'Text'),
    ('H', 'Pan'),
    ('R', 'Measure'),
    ('S', 'Toggle stitch preview'),
    ('O', 'Toggle outlines'),
    ('N', 'Toggle needle holes'),
    ('Esc', 'Cancel current tool action'),
    ('⌘N', 'New project'),
    ('⌘O', 'Open project'),
    ('⌘S', 'Save'),
    ('⇧⌘S', 'Save as'),
    ('⌘W', 'Close project'),
    ('⌘Z / ⇧⌘Z', 'Undo / redo'),
    ('⌘D', 'Duplicate selection'),
    ('⌘= / ⌘-', 'Zoom in / out'),
    ('⌘0', 'Fit design to window'),
    ('⌘1', 'Actual size'),
  ];
  return showStudioDialog<void>(
    context: context,
    title: 'Keyboard Shortcuts',
    body: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (keys, action) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(children: [
              SizedBox(
                width: 90,
                child: Text(keys,
                    style: TextStyle(fontSize: 11, color: AppTokens.textMuted)),
              ),
              Expanded(child: Text(action)),
            ]),
          ),
      ],
    ),
  );
}

/// Illustrator-style Document Setup: hoop size/shape, fabric color
/// and texture. Applies as one undoable UpdateHoop command.
Future<void> showDocumentSetup(
    BuildContext context, WorkspaceViewModel model) async {
  final hoop = model.hoop;
  final widthController =
      TextEditingController(text: hoop.widthMm.toStringAsFixed(0));
  final heightController =
      TextEditingController(text: hoop.heightMm.toStringAsFixed(0));
  var shape = hoop.shape;
  var texture = hoop.texture;
  var fabric = hoop.fabricColorHex;
  final apply = await showStudioDialog<bool>(
    context: context,
    title: 'Document Setup',
    width: 360,
    floating: true, // OS-utility-window feel: undimmed + draggable
    body: StatefulBuilder(
      builder: (context, setDialogState) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StudioSectionLabel('Hoop', first: true),
          Row(children: [
            Expanded(
              child: StudioTextField(
                controller: widthController,
                label: 'Width (mm)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StudioTextField(
                controller: heightController,
                label: 'Height (mm)',
                keyboardType: TextInputType.number,
              ),
            ),
          ]),
          const SizedBox(height: 8),
          StudioFormRow(
            label: 'Shape',
            child: StudioDropdown<HoopShape>(
              value: shape,
              width: 140,
              items: const [
                (HoopShape.rectangle, 'Rectangle'),
                (HoopShape.roundedRectangle, 'Rounded'),
                (HoopShape.oval, 'Oval'),
              ],
              onChanged: (v) => setDialogState(() => shape = v),
            ),
          ),
          const StudioSectionLabel('Material'),
          StudioFormRow(
            label: 'Fabric texture',
            child: StudioDropdown<FabricTexture>(
              value: texture,
              width: 140,
              items: const [
                (FabricTexture.none, 'None'),
                (FabricTexture.weave, 'Weave'),
                (FabricTexture.aida, 'Aida'),
              ],
              onChanged: (v) => setDialogState(() => texture = v),
            ),
          ),
          const SizedBox(height: 8),
          Text('Fabric color',
              style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
          const SizedBox(height: 6),
          Row(children: [
            for (final swatch in fabricSwatches)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: InkWell(
                  onTap: () => setDialogState(() => fabric = swatch),
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color(0xFF000000 |
                          int.parse(swatch.substring(1), radix: 16)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: fabric == swatch
                            ? AppTokens.primary
                            : AppTokens.border,
                        width: fabric == swatch ? 2 : 1,
                      ),
                    ),
                  ),
                ),
              ),
            InkWell(
              onTap: () async {
                final hex = await showStudioColorPicker(
                    context: context, initialHex: fabric);
                if (hex != null) setDialogState(() => fabric = hex);
              },
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: fabricSwatches.contains(fabric)
                      ? null
                      : Color(0xFF000000 |
                          int.parse(fabric.substring(1), radix: 16)),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: fabricSwatches.contains(fabric)
                        ? AppTokens.border
                        : AppTokens.primary,
                    width: fabricSwatches.contains(fabric) ? 1 : 2,
                  ),
                ),
                child: fabricSwatches.contains(fabric)
                    ? Icon(Icons.colorize, size: 12, color: AppTokens.textMuted)
                    : null,
              ),
            ),
          ]),
        ],
      ),
    ),
    actions: [
      Builder(
        builder: (context) => StudioButton(
          label: 'Cancel',
          variant: StudioButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      Builder(
        builder: (context) => StudioButton(
          label: 'Apply',
          variant: StudioButtonVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
    ],
  );
  if (apply != true) return;
  final width = double.tryParse(widthController.text) ?? hoop.widthMm;
  final height = double.tryParse(heightController.text) ?? hoop.heightMm;
  if (width <= 0 || height <= 0) return;
  model.updateHoop(HoopSettings(
    widthMm: width,
    heightMm: height,
    shape: shape,
    fabricColorHex: fabric,
    texture: texture,
  ));
}

/// Native macOS menu bar: full desktop-convention structure. Built at
/// app level so File menus work from Home too; document actions grey
/// out (null onSelected) when no project is open.
List<PlatformMenu> buildPlatformMenus(BuildContext context, AppViewModel app) {
  // Thin adapter: the single menu definition (ADR-039) rendered
  // natively. The in-app menu bar renders the same tree.
  return toPlatformMenus(buildAppMenus(context, app));
}
