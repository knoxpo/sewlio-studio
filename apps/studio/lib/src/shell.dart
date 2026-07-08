import 'package:barley/barley.dart';
import 'package:flutter/material.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import '../main.dart';
import 'bottom_panel.dart';
import 'flyout.dart';
import 'object_panel.dart';
import 'right_panel.dart';
import 'tool_options.dart';
import 'workspace_view_model.dart';

/// CAD-workspace shell (barley MVVM view): renders [WorkspaceViewModel]
/// and forwards gestures and dialog results to it. All state and logic
/// live in the model; every mutation goes through commands (ARCH-003).
class StudioShell extends StatelessWidget {
  const StudioShell({super.key, required this.session});

  final StudioSession session;

  @override
  Widget build(BuildContext context) {
    return BarleyView<WorkspaceViewModel>(
      create: () => WorkspaceViewModel(session: session),
      builder: (context, model) => _WorkspaceView(model: model),
    );
  }
}

class _WorkspaceView extends StatelessWidget {
  const _WorkspaceView({required this.model});

  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    model.onPromptText ??= () => _promptText(context);
    final sequence = model.sequence;
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: model.onKey,
        child: Column(
          children: [
            _header(context),
            _documentTab(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _toolRail(),
                  ObjectPropertiesPanel(
                    document: model.session.document,
                    selectedId: model.selection.selected,
                    onCommand: model.execute,
                    canUndo: model.canUndo,
                    canRedo: model.canRedo,
                    onUndo: model.undo,
                    onRedo: model.redo,
                  ),
                  Expanded(child: _canvasColumn(context)),
                  StitchListPanel(
                    document: model.session.document,
                    selectedId: model.selection.selected,
                    onSelect: model.selection.select,
                  ),
                ],
              ),
            ),
            BottomPanel(
              sequence: sequence,
              machine: model.machine,
              onMachineChanged: model.setMachine,
              onExport: (suffix) => _export(context, suffix),
            ),
            _statusBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppTokens.panel,
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.draw, color: AppTokens.primary, size: 18),
          const SizedBox(width: 6),
          const Text('Sewlio Studio',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 12),
          MenuBar(
            children: [
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                      onPressed: () => _renameDialog(context),
                      child: const Text('Rename…')),
                  MenuItemButton(
                      onPressed: () => _saveProject(context),
                      child: const Text('Save…')),
                  MenuItemButton(
                      onPressed: () => _openProject(context),
                      child: const Text('Open…')),
                  MenuItemButton(
                      onPressed: () => _importSvg(context),
                      child: const Text('Import SVG…')),
                  MenuItemButton(
                      onPressed: () => _export(context, '.dst'),
                      child: const Text('Export DST…')),
                  MenuItemButton(
                      onPressed: () => _export(context, '.exp'),
                      child: const Text('Export EXP…')),
                ],
                child: const Text('File'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: model.canUndo ? model.undo : null,
                    child: const Text('Undo'),
                  ),
                  MenuItemButton(
                    onPressed: model.canRedo ? model.redo : null,
                    child: const Text('Redo'),
                  ),
                ],
                child: const Text('Edit'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: Icon(
                      model.showRulers ? Icons.check : null,
                      size: 14,
                    ),
                    onPressed: model.toggleRulers,
                    child: const Text('Show Rulers'),
                  ),
                  MenuItemButton(
                    onPressed: model.fitCanvas,
                    child: const Text('Zoom to Fit'),
                  ),
                ],
                child: const Text('View'),
              ),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _saveProject(context),
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(0, 28),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _documentTab() {
    final dirty = model.canUndo;
    return Container(
      padding: const EdgeInsets.only(left: 8, top: 4),
      alignment: Alignment.bottomLeft,
      decoration: const BoxDecoration(
        color: AppTokens.background,
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: const BoxDecoration(
          color: AppTokens.panel,
          border: Border(
            top: BorderSide(color: AppTokens.border),
            left: BorderSide(color: AppTokens.border),
            right: BorderSide(color: AppTokens.border),
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
        child: Text(
          '${model.session.document.name}.embproj${dirty ? '*' : ''}',
          key: const Key('doc-title'),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- tool rail

  Widget _toolButton(ToolKind kind, IconData icon, String tooltip) {
    return StudioIconButton(
      icon: icon,
      tooltip: tooltip,
      active: model.activeKind == kind,
      onPressed: () => model.selectTool(kind),
    );
  }

  Widget _toolRail() {
    return Container(
      width: 44,
      decoration: const BoxDecoration(
        color: AppTokens.panel,
        border: Border(right: BorderSide(color: AppTokens.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _toolButton(ToolKind.select, Icons.near_me_outlined, 'Select (V)'),
          _toolButton(ToolKind.node, Icons.timeline, 'Node editing (A)'),
          const RailSeparator(),
          _toolButton(ToolKind.pen, Icons.edit_outlined, 'Pen (P)'),
          _toolButton(ToolKind.pencil, Icons.gesture, 'Pencil (B)'),
          ShapeFlyoutButton(
            shapeTool: model.shapeTool,
            active: model.activeKind == ToolKind.shape,
            onActivate: model.activateShape,
          ),
          _toolButton(ToolKind.text, Icons.title, 'Text (T)'),
          const RailSeparator(),
          _toolButton(ToolKind.pan, Icons.pan_tool_outlined, 'Pan (H)'),
          _toolButton(
              ToolKind.measure, Icons.straighten_outlined, 'Measure (R)'),
          const RailSeparator(),
          StudioIconButton(
              icon: Icons.zoom_in,
              tooltip: 'Zoom in',
              onPressed: () => model.zoomBy(1.25)),
          StudioIconButton(
              icon: Icons.zoom_out,
              tooltip: 'Zoom out',
              onPressed: () => model.zoomBy(0.8)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- canvas column

  Widget _canvasColumn(BuildContext context) {
    return Column(
      children: [
        // Canvas toolbar
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: AppTokens.panel,
            border: Border(bottom: BorderSide(color: AppTokens.border)),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility, size: 14, color: AppTokens.primary),
              const SizedBox(width: 4),
              const Text('Design View',
                  style: TextStyle(color: AppTokens.primary, fontSize: 11)),
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
            ],
          ),
        ),
        // Contextual tool options (Illustrator control bar).
        ToolOptionsBar(tool: model.tool, onChanged: model.notify),
        Expanded(child: _rulerFrame(context, _buildCanvas())),
        // Thread palette bar
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(
            color: AppTokens.panel,
            border: Border(top: BorderSide(color: AppTokens.border)),
          ),
          child: Row(
            children: [
              const Text('Colorway 1',
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
    return CanvasView(
      document: model.session.document,
      viewport: model.viewport,
      selectedId: model.selection.selected,
      hoopSize: Size(model.machine.hoopWidthMm, model.machine.hoopHeightMm),
      previewPaths: model.tool.preview,
      markers: model.tool.markers,
      onTapWorld: model.tool.tap,
      onDoubleTapWorld: model.tool.doubleTap,
      onHoverWorld: model.hover,
      onDragStartWorld: model.tool.dragStart,
      onDragUpdateWorld: model.tool.dragUpdate,
      onDragEndWorld: model.tool.dragEnd,
    );
  }

  /// Wraps the canvas in top/left mm rulers when enabled (View menu).
  Widget _rulerFrame(BuildContext context, Widget canvas) {
    if (!model.showRulers) return canvas;
    const corner = SizedBox(
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
            decoration: const BoxDecoration(
              color: AppTokens.panel,
              border: Border(bottom: BorderSide(color: AppTokens.border)),
            ),
            child: Ruler(
              viewport: model.viewport,
              axis: Axis.horizontal,
              cursor: model.cursor,
              markers: model.markersFor(GuideAxis.vertical),
              onTapMm: (mm) => _onRulerTap(context, GuideAxis.vertical, mm),
            ),
          ),
        ),
      ]),
      Expanded(
        child: Row(children: [
          DecoratedBox(
            decoration: const BoxDecoration(
              color: AppTokens.panel,
              border: Border(right: BorderSide(color: AppTokens.border)),
            ),
            child: Ruler(
              viewport: model.viewport,
              axis: Axis.vertical,
              cursor: model.cursor,
              markers: model.markersFor(GuideAxis.horizontal),
              onTapMm: (mm) => _onRulerTap(context, GuideAxis.horizontal, mm),
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
          width: 52,
          height: 22,
          child: TextFormField(
            key: ValueKey('zoom-${viewport.percent.round()}'),
            initialValue: '${viewport.percent.round()}%',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11),
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 3)),
            onFieldSubmitted: (text) {
              final value = double.tryParse(text.replaceAll('%', '').trim());
              if (value != null && value > 0) viewport.setPercent(value);
            },
          ),
        ),
        PopupMenuButton<double?>(
          tooltip: 'Zoom presets',
          color: AppTokens.popoverSurface,
          icon: const Icon(Icons.arrow_drop_down,
              size: 16, color: AppTokens.textMuted),
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
      decoration: const BoxDecoration(
        color: AppTokens.panel,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 10, color: AppTokens.textMuted),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppTokens.accentGreen, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(model.tool.status ?? 'Ready'),
            const Spacer(),
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
    _guideDialog(context, axis: axis, mm: mm, existing: model.guideAt(axis, mm));
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
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Add Guide' : 'Edit Guide'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: positionController,
                decoration: InputDecoration(
                    labelText:
                        '${axis == GuideAxis.vertical ? 'X' : 'Y'} position (mm)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const Text('Color',
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
          actions: [
            if (existing != null)
              TextButton(
                onPressed: () => Navigator.pop(context, 'delete'),
                child: const Text('Delete',
                    style: TextStyle(color: AppTokens.error)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, 'save'),
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
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

  // ---------------------------------------------------------------- actions

  Future<void> _saveProject(BuildContext context) async {
    final path =
        await _pathDialog(context, 'Save project', suffix: '.embproj');
    if (path == null || !context.mounted) return;
    try {
      // Never silently overwrite existing files (user data loss).
      // Confirm when the target exists.
      if (model.fileExistsAt(path) &&
          !(await _confirmOverwrite(context, path))) {
        return;
      }
      await model.saveTo(path);
      if (context.mounted) _toast(context, 'Saved $path');
    } catch (e) {
      if (context.mounted) _toast(context, 'Save failed: $e');
    }
  }

  Future<void> _openProject(BuildContext context) async {
    final path =
        await _pathDialog(context, 'Open project', suffix: '.embproj');
    if (path == null || !context.mounted) return;
    try {
      final name = await model.openFrom(path);
      if (context.mounted) _toast(context, 'Opened $name');
    } catch (e) {
      if (context.mounted) _toast(context, 'Open failed: $e');
    }
  }

  Future<void> _importSvg(BuildContext context) async {
    final path = await _pathDialog(context, 'Import SVG', suffix: '.svg');
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

  Future<void> _export(BuildContext context, String suffix) async {
    final path = await _pathDialog(context, 'Export $suffix', suffix: suffix);
    if (path == null || !context.mounted) return;
    final result = model.prepareExport(suffix);
    if (result.error != null) {
      _toast(context, result.error!);
      return;
    }
    try {
      if (model.fileExistsAt(path) &&
          !(await _confirmOverwrite(context, path))) {
        return;
      }
      await model.writeExport(path, result.bytes!);
      if (context.mounted) {
        _toast(
            context,
            'Exported $path'
            '${result.skipped == 0 ? '' : ' (${result.skipped} object(s) skipped)'}');
      }
    } catch (e) {
      if (context.mounted) _toast(context, 'Export failed: $e');
    }
  }

  Future<void> _renameDialog(BuildContext context) async {
    final controller =
        TextEditingController(text: model.session.document.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename document'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (name != null) model.rename(name);
  }

  Future<String?> _promptText(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration:
              const InputDecoration(hintText: 'A–Z, 0–9 (monoline font)'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Place')),
        ],
      ),
    );
  }

  Future<bool> _confirmOverwrite(BuildContext context, String path) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Overwrite file?'),
        content: Text('$path already exists.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ponytail: plain path text field instead of a native file picker —
  // swap in package:file_selector when the UX matters.
  Future<String?> _pathDialog(BuildContext context, String title,
      {required String suffix}) async {
    final controller = TextEditingController();
    final path = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: '/path/to/file$suffix'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (path == null || path.isEmpty) return null;
    return path.endsWith(suffix) ? path : '$path$suffix';
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
