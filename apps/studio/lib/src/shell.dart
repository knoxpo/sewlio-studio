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

  final _shapeButtonKey = GlobalKey();

  Widget _toolRail() {
    final shapeTool = tools[ToolKind.shape]! as ShapeTool;
    return Container(
      width: 48,
      decoration: const BoxDecoration(
        color: AppTokens.panel,
        border: Border(right: BorderSide(color: AppTokens.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _toolButton(ToolKind.select, Icons.near_me_outlined, 'Select (V)'),
          _toolButton(ToolKind.node, Icons.timeline, 'Node editing (A)'),
          const Divider(indent: 10, endIndent: 10),
          _toolButton(ToolKind.pen, Icons.edit_outlined, 'Pen (P)'),
          _toolButton(ToolKind.pencil, Icons.gesture, 'Pencil (B)'),
          // Shape group: tap activates; re-tap, long-press, or
          // right-click opens the anchored flyout (corner triangle
          // marks it, Illustrator-style).
          GestureDetector(
            key: _shapeButtonKey,
            onLongPress: _showShapeFlyout,
            onSecondaryTap: _showShapeFlyout,
            child: StudioIconButton(
              icon: shapeIcon(shapeTool.kind),
              tooltip:
                  '${shapeLabel(shapeTool.kind)} (M) — hold for more shapes',
              active: activeKind == ToolKind.shape,
              flyoutIndicator: true,
              onPressed: () {
                if (activeKind == ToolKind.shape) {
                  _showShapeFlyout();
                } else {
                  _selectTool(ToolKind.shape);
                }
              },
            ),
          ),
          _toolButton(ToolKind.text, Icons.title, 'Text (T)'),
          const Divider(indent: 10, endIndent: 10),
          _toolButton(ToolKind.pan, Icons.pan_tool_outlined, 'Pan (H)'),
          _toolButton(
              ToolKind.measure, Icons.straighten_outlined, 'Measure (R)'),
          const Divider(indent: 10, endIndent: 10),
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

  /// Anchored flyout beside the shape button (Illustrator tool group).
  Future<void> _showShapeFlyout() async {
    final shapeTool = tools[ToolKind.shape]! as ShapeTool;
    final box = _shapeButtonKey.currentContext!.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset(box.size.width + 4, 0));
    final kind = await showMenu<ShapeKind>(
      context: context,
      position: RelativeRect.fromLTRB(origin.dx, origin.dy, origin.dx, 0),
      color: AppTokens.panel,
      items: [
        for (final kind in ShapeKind.values)
          PopupMenuItem(
            value: kind,
            height: 32,
            child: Row(children: [
              Icon(shapeIcon(kind),
                  size: 16,
                  color: kind == shapeTool.kind
                      ? AppTokens.primary
                      : AppTokens.textMuted),
              const SizedBox(width: 8),
              Text(shapeLabel(kind),
                  style: TextStyle(
                      fontSize: 12,
                      color: kind == shapeTool.kind
                          ? AppTokens.primary
                          : AppTokens.textPrimary)),
            ]),
          ),
      ],
    );
    if (kind == null) return;
    shapeTool.kind = kind;
    _selectTool(ToolKind.shape);
    setState(() {}); // sides/points now editable in the options bar
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
                  icon: Icons.zoom_out,
                  tooltip: 'Zoom out',
                  onPressed: () => _zoom(0.8)),
              ListenableBuilder(
                listenable: viewport,
                builder: (context, _) => Text(
                  '${(viewport.zoom / 4 * 100).round()}%',
                  style:
                      const TextStyle(color: AppTokens.textMuted, fontSize: 11),
                ),
              ),
              StudioIconButton(
                  icon: Icons.zoom_in,
                  tooltip: 'Zoom in',
                  onPressed: () => _zoom(1.25)),
            ],
          ),
        ),
        // Contextual tool options (Illustrator control bar).
        ToolOptionsBar(tool: tool, onChanged: () => setState(() {})),
        Expanded(
          child: CanvasView(
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
          ),
        ),
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
                  Text('Zoom: ${(viewport.zoom / 4 * 100).round()}%'),
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
    final program = compileToMachine(sequence, machine: machine);
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
