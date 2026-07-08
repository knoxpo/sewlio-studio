import 'package:flutter/material.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_export/studio_export.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;
import 'package:studio_import/studio_import.dart';
import 'package:studio_machine/studio_machine.dart';
import 'package:studio_tools/studio_tools.dart';

import 'package:flutter/services.dart';

import '../main.dart';
import 'bottom_panel.dart';
import 'file_io.dart';
import 'flyout.dart';
import 'object_panel.dart';
import 'right_panel.dart';
import 'tool_options.dart';

/// CAD-workspace shell: header, tool rail, object properties, canvas,
/// stitch inspector, simulation strip, status bar. Renders engine
/// state; every mutation goes through commands (ARCH-003).
class StudioShell extends StatefulWidget {
  const StudioShell({super.key, required this.session});

  final StudioSession session;

  @override
  State<StudioShell> createState() => _StudioShellState();
}

enum ToolKind { select, node, pen, pencil, shape, text, pan, measure }

class _StudioShellState extends State<StudioShell> {
  late StudioSession session;

  final viewport = ViewportController();
  final selection = SelectionController();
  MachineModel machine = hoopPresets.first;
  final cursor = ValueNotifier<g.Point?>(null);

  late Map<ToolKind, Tool> tools;
  ToolKind activeKind = ToolKind.select;

  Tool get tool => tools[activeKind]!;

  @override
  void initState() {
    super.initState();
    selection.addListener(() => setState(() {}));
    _bindSession(widget.session);
    // Center + fit once the canvas has its first layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitCanvas());
  }

  /// Fits the design (or the hoop when empty) into the canvas area.
  /// The hoop is anchored with its top-left corner at world 0,0.
  void _fitCanvas() {
    var bounds = g.Bounds(0, 0, machine.hoopWidthMm, machine.hoopHeightMm);
    for (final object in session.document.objects) {
      bounds = bounds.union(object.path.bounds());
    }
    viewport.fitBounds(bounds);
  }

  /// Points the shell at [next] (startup or after Open…).
  void _bindSession(StudioSession next) {
    session = next;
    selection.select(null);
    tools = {
      ToolKind.select: SelectTool(
        document: session.document,
        history: session.history,
        selection: selection,
      ),
      ToolKind.node: NodeTool(
        document: session.document,
        history: session.history,
        selection: selection,
      ),
      ToolKind.pen: PenTool(onCreate: _addPath),
      ToolKind.pencil: PencilTool(onCreate: _addPath),
      ToolKind.shape: ShapeTool(onCreate: _addPath),
      ToolKind.text: TextTool(onRequestText: _promptText, onCreate: _addPath),
      ToolKind.pan: PanTool(),
      ToolKind.measure: MeasureTool(),
    };
    for (final t in tools.values) {
      t.addListener(_onToolChanged);
    }
    activeKind = ToolKind.select;
    // Any engine event may change what's on screen; a document revision
    // rebuild is cheap at MVP scale.
    session.events.events.listen((_) => setState(() {}));
  }

  void _onToolChanged() {
    if (mounted) setState(() {});
  }

  void _selectTool(ToolKind kind) {
    if (kind == activeKind) return;
    tool.cancel();
    setState(() => activeKind = kind);
  }

  /// Creation tools commit here: new running-stitch object per path.
  void _addPath(g.Path path) {
    session.history.execute(AddObject(RunningStitchObject(
      id: session.registry.get<IdGenerator>().next(),
      path: path,
    )));
  }

  /// Illustrator-style single-key tool shortcuts.
  static final _shortcuts = {
    LogicalKeyboardKey.keyV: ToolKind.select,
    LogicalKeyboardKey.keyA: ToolKind.node,
    LogicalKeyboardKey.keyP: ToolKind.pen,
    LogicalKeyboardKey.keyB: ToolKind.pencil,
    LogicalKeyboardKey.keyM: ToolKind.shape,
    LogicalKeyboardKey.keyT: ToolKind.text,
    LogicalKeyboardKey.keyH: ToolKind.pan,
    LogicalKeyboardKey.keyR: ToolKind.measure,
  };

  /// True while a text field owns focus — tool shortcuts must not
  /// steal typed characters.
  bool get _typing =>
      FocusManager.instance.primaryFocus?.context?.widget is EditableText;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _typing) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      tool.cancel();
      return KeyEventResult.handled;
    }
    final kind = _shortcuts[event.logicalKey];
    if (kind == null) return KeyEventResult.ignored;
    _selectTool(kind);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    // ponytail: re-digitized every build — cache per document revision
    // when designs get big enough to notice.
    final sequence = digitizeObjects(session.document.objects);
    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: _onKey,
        child: Column(
          children: [
            _header(),
            _documentTab(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _toolRail(),
                  ObjectPropertiesPanel(
                    document: session.document,
                    selectedId: selection.selected,
                    onCommand: (command) => session.history.execute(command),
                    canUndo: session.history.canUndo,
                    canRedo: session.history.canRedo,
                    onUndo: session.history.undo,
                    onRedo: session.history.redo,
                  ),
                  Expanded(child: _canvasColumn(sequence)),
                  StitchListPanel(
                    document: session.document,
                    selectedId: selection.selected,
                    onSelect: selection.select,
                  ),
                ],
              ),
            ),
            BottomPanel(
              sequence: sequence,
              machine: machine,
              onMachineChanged: (m) => setState(() => machine = m),
              onExport: _export,
            ),
            _statusBar(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _header() {
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
                      onPressed: _renameDialog, child: const Text('Rename…')),
                  MenuItemButton(
                      onPressed: _saveProject, child: const Text('Save…')),
                  MenuItemButton(
                      onPressed: _openProject, child: const Text('Open…')),
                  MenuItemButton(
                      onPressed: _importSvg, child: const Text('Import SVG…')),
                  MenuItemButton(
                      onPressed: () => _export('.dst'),
                      child: const Text('Export DST…')),
                  MenuItemButton(
                      onPressed: () => _export('.exp'),
                      child: const Text('Export EXP…')),
                ],
                child: const Text('File'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed:
                        session.history.canUndo ? session.history.undo : null,
                    child: const Text('Undo'),
                  ),
                  MenuItemButton(
                    onPressed:
                        session.history.canRedo ? session.history.redo : null,
                    child: const Text('Redo'),
                  ),
                ],
                child: const Text('Edit'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    leadingIcon: Icon(
                      _showRulers ? Icons.check : null,
                      size: 14,
                    ),
                    onPressed: () => setState(() => _showRulers = !_showRulers),
                    child: const Text('Show Rulers'),
                  ),
                  MenuItemButton(
                    onPressed: _fitCanvas,
                    child: const Text('Zoom to Fit'),
                  ),
                ],
                child: const Text('View'),
              ),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _saveProject,
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
    final dirty = session.history.canUndo;
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
          '${session.document.name}.embproj${dirty ? '*' : ''}',
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
      active: activeKind == kind,
      onPressed: () => _selectTool(kind),
    );
  }

  Widget _toolRail() {
    final shapeTool = tools[ToolKind.shape]! as ShapeTool;
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
            shapeTool: shapeTool,
            active: activeKind == ToolKind.shape,
            onActivate: (kind) {
              if (kind != null) shapeTool.kind = kind;
              _selectTool(ToolKind.shape);
              setState(() {}); // options bar picks up the new kind
            },
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
              onPressed: () => _zoom(1.25)),
          StudioIconButton(
              icon: Icons.zoom_out,
              tooltip: 'Zoom out',
              onPressed: () => _zoom(0.8)),
        ],
      ),
    );
  }

  Future<String?> _promptText() async {
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

  var _showRulers = true;

  Widget _buildCanvas() {
    return CanvasView(
      document: session.document,
      viewport: viewport,
      selectedId: selection.selected,
      hoopSize: Size(machine.hoopWidthMm, machine.hoopHeightMm),
      previewPaths: tool.preview,
      markers: tool.markers,
      onTapWorld: tool.tap,
      onDoubleTapWorld: tool.doubleTap,
      onHoverWorld: (p) {
        cursor.value = p;
        tool.hover(p);
      },
      onDragStartWorld: tool.dragStart,
      onDragUpdateWorld: tool.dragUpdate,
      onDragEndWorld: tool.dragEnd,
    );
  }

  Color _guideColor(Guide guide) => guide.colorHex == null
      ? const Color(0xFF26C6DA)
      : Color(0xFF000000 | int.parse(guide.colorHex!.substring(1), radix: 16));

  List<RulerMarker> _markersFor(GuideAxis axis) => [
        for (final guide in session.document.guides)
          if (guide.axis == axis)
            RulerMarker(
                positionMm: guide.positionMm, color: _guideColor(guide)),
      ];

  /// Ruler tap: edit the nearest guide on that axis, or create one.
  void _onRulerTap(GuideAxis axis, double mm) {
    final tolerance = 6 / viewport.zoom;
    Guide? hit;
    for (final guide in session.document.guides) {
      if (guide.axis == axis && (guide.positionMm - mm).abs() <= tolerance) {
        hit = guide;
        break;
      }
    }
    _guideDialog(axis: axis, mm: mm, existing: hit);
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

  Future<void> _guideDialog({
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
      session.history.execute(RemoveGuide(existing!.id));
      return;
    }
    final position = double.tryParse(positionController.text) ??
        (existing?.positionMm ?? mm);
    if (existing == null) {
      session.history.execute(AddGuide(Guide(
        id: session.registry.get<IdGenerator>().next(),
        axis: axis,
        positionMm: position,
        name: nameController.text.trim(),
        colorHex: colorHex,
      )));
    } else {
      session.history.execute(UpdateGuide(Guide(
        id: existing.id,
        axis: axis,
        positionMm: position,
        name: nameController.text.trim(),
        colorHex: colorHex,
      )));
    }
  }

  /// Wraps the canvas in top/left mm rulers when enabled (View menu).
  Widget _rulerFrame(Widget canvas) {
    if (!_showRulers) return canvas;
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
              viewport: viewport,
              axis: Axis.horizontal,
              cursor: cursor,
              markers: _markersFor(GuideAxis.vertical),
              onTapMm: (mm) => _onRulerTap(GuideAxis.vertical, mm),
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
              viewport: viewport,
              axis: Axis.vertical,
              cursor: cursor,
              markers: _markersFor(GuideAxis.horizontal),
              onTapMm: (mm) => _onRulerTap(GuideAxis.horizontal, mm),
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
              value == null ? _fitCanvas() : viewport.setPercent(value),
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

  void _zoom(double factor) {
    final box = context.findRenderObject() as RenderBox?;
    final center = box == null
        ? Offset.zero
        : Offset(box.size.width / 2, box.size.height / 2);
    viewport.zoomAt(center, factor);
    setState(() {});
  }

  // ---------------------------------------------------------- canvas column

  Widget _canvasColumn(StitchSequence sequence) {
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
                  onPressed: _fitCanvas),
              StudioIconButton(
                  icon: Icons.zoom_out,
                  tooltip: 'Zoom out',
                  onPressed: () => _zoom(0.8)),
              _zoomControl(),
              StudioIconButton(
                  icon: Icons.zoom_in,
                  tooltip: 'Zoom in',
                  onPressed: () => _zoom(1.25)),
            ],
          ),
        ),
        // Contextual tool options (Illustrator control bar).
        ToolOptionsBar(tool: tool, onChanged: () => setState(() {})),
        Expanded(child: _rulerFrame(_buildCanvas())),
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
              for (final (index, thread) in sequence.threads.indexed)
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
            Text(tool.status ?? 'Ready'),
            const Spacer(),
            ListenableBuilder(
              listenable: viewport,
              builder: (context, _) =>
                  Text('Zoom: ${viewport.percent.round()}%'),
            ),
            const SizedBox(width: 24),
            ValueListenableBuilder(
              valueListenable: cursor,
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

  // ---------------------------------------------------------------- actions

  Future<void> _saveProject() async {
    final path = await _pathDialog('Save project', suffix: '.embproj');
    if (path == null) return;
    try {
      // Never silently overwrite existing files (user data loss).
      // Confirm when the target exists.
      if (fileExists(path) && !(await _confirmOverwrite(path))) return;
      await writeFileString(path, encodeProject(session.document));
      _toast('Saved $path');
    } catch (e) {
      _toast('Save failed: $e');
    }
  }

  Future<void> _openProject() async {
    final path = await _pathDialog('Open project', suffix: '.embproj');
    if (path == null) return;
    try {
      final document = decodeProject(await readFileString(path));
      setState(() => _bindSession(StudioSession(document: document)));
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitCanvas());
      _toast('Opened ${document.name}');
    } catch (e) {
      _toast('Open failed: $e');
    }
  }

  Future<void> _importSvg() async {
    final path = await _pathDialog('Import SVG', suffix: '.svg');
    if (path == null) return;
    try {
      final paths = importSvg(await readFileString(path));
      if (paths.isEmpty) {
        _toast('No <path> outlines found in $path');
        return;
      }
      for (final p in paths) {
        session.history.execute(AddObject(RunningStitchObject(
          id: session.registry.get<IdGenerator>().next(),
          path: p,
        )));
      }
      _toast('Imported ${paths.length} path(s)');
    } catch (e) {
      _toast('Import failed: $e');
    }
  }

  Future<void> _export(String suffix) async {
    final path = await _pathDialog('Export $suffix', suffix: suffix);
    if (path == null) return;
    final skipped = <EmbroideryObject>[];
    final sequence =
        digitizeObjects(session.document.objects, skipped: skipped);
    if (sequence.ops.isEmpty) {
      _toast('Nothing to export');
      return;
    }
    // Machine coordinates are hoop-centered; design space anchors the
    // hoop's top-left at 0,0.
    final program = compileToMachine(
      sequence,
      machine: machine,
      origin: g.Point(machine.hoopWidthMm / 2, machine.hoopHeightMm / 2),
    );
    final sink = CollectingSink();
    if (!program.validate(machine, sink)) {
      _toast('Export blocked: ${sink.diagnostics.first.message}');
      return;
    }
    final bytes =
        suffix == '.dst' ? encodeDst(program) : encodeExp(program, sink: sink);
    if (sink.hasErrors) {
      _toast('Export blocked: ${sink.diagnostics.first.message}');
      return;
    }
    try {
      if (fileExists(path) && !(await _confirmOverwrite(path))) return;
      await writeFileBytes(path, bytes);
      _toast('Exported $path'
          '${skipped.isEmpty ? '' : ' (${skipped.length} object(s) skipped)'}');
    } catch (e) {
      _toast('Export failed: $e');
    }
  }

  Future<void> _renameDialog() async {
    final controller = TextEditingController(text: session.document.name);
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
    if (name != null && name.isNotEmpty) {
      session.history.execute(RenameDocument(name));
    }
  }

  Future<bool> _confirmOverwrite(String path) async {
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
  Future<String?> _pathDialog(String title, {required String suffix}) async {
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

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
