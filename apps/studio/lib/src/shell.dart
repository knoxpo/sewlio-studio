import 'dart:io';

import 'package:flutter/material.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:studio_export/studio_export.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;
import 'package:studio_import/studio_import.dart';
import 'package:studio_machine/studio_machine.dart';
import 'package:studio_tools/studio_tools.dart';

import '../main.dart';
import 'inspector.dart';

/// Desktop shell: menu bar, toolbar, side panels, canvas placeholder.
/// Rebuilds on engine events — it renders state, never mutates it.
class StudioShell extends StatefulWidget {
  const StudioShell({super.key, required this.session});

  final StudioSession session;

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  late StudioSession session;

  final viewport = ViewportController();
  final selection = SelectionController();
  late SelectTool tool;

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
    tool = SelectTool(
      document: session.document,
      history: session.history,
      selection: selection,
    );
    // Any engine event may change what's on screen; a document revision
    // rebuild is cheap at MVP scale.
    session.events.events.listen((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final history = session.history;
    return Scaffold(
      body: Column(
        children: [
          MenuBar(
            children: [
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: _renameDialog,
                    child: const Text('Rename…'),
                  ),
                  MenuItemButton(
                    onPressed: _saveProject,
                    child: const Text('Save…'),
                  ),
                  MenuItemButton(
                    onPressed: _openProject,
                    child: const Text('Open…'),
                  ),
                  MenuItemButton(
                    onPressed: _importSvg,
                    child: const Text('Import SVG…'),
                  ),
                  MenuItemButton(
                    onPressed: () => _export('.dst'),
                    child: const Text('Export DST…'),
                  ),
                  MenuItemButton(
                    onPressed: () => _export('.exp'),
                    child: const Text('Export EXP…'),
                  ),
                ],
                child: const Text('File'),
              ),
              SubmenuButton(
                menuChildren: [
                  MenuItemButton(
                    onPressed: history.canUndo ? history.undo : null,
                    child: const Text('Undo'),
                  ),
                  MenuItemButton(
                    onPressed: history.canRedo ? history.redo : null,
                    child: const Text('Redo'),
                  ),
                ],
                child: const Text('Edit'),
              ),
            ],
          ),
          _Toolbar(session: session, onAddSquare: _addSquare),
          Expanded(
            child: Row(
              children: [
                const _Panel(title: 'Layers', width: 200),
                Expanded(
                  child: Card(
                    margin: const EdgeInsets.all(AppTokens.spacing / 2),
                    clipBehavior: Clip.antiAlias,
                    child: CanvasView(
                      document: session.document,
                      viewport: viewport,
                      selectedId: selection.selected,
                      onTapWorld: tool.tap,
                      onDragStartWorld: tool.dragStart,
                      onDragUpdateWorld: tool.dragUpdate,
                      onDragEndWorld: tool.dragEnd,
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: InspectorPanel(
                    document: session.document,
                    selectedId: selection.selected,
                    onReplace: (object) =>
                        session.history.execute(ReplaceObject(object)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProject() async {
    final path = await _pathDialog('Save project', suffix: '.embproj');
    if (path == null) return;
    // Never silently overwrite existing files (non-negotiable #10-ish:
    // user data loss). Confirm when the target exists.
    final file = File(path);
    if (file.existsSync() && !(await _confirmOverwrite(path))) return;
    await file.writeAsString(encodeProject(session.document));
    _toast('Saved $path');
  }

  Future<void> _openProject() async {
    final path = await _pathDialog('Open project', suffix: '.embproj');
    if (path == null) return;
    try {
      final document = decodeProject(await File(path).readAsString());
      setState(() => _bindSession(StudioSession(document: document)));
      _toast('Opened ${document.name}');
    } on Exception catch (e) {
      _toast('Open failed: $e');
    }
  }

  Future<void> _importSvg() async {
    final path = await _pathDialog('Import SVG', suffix: '.svg');
    if (path == null) return;
    try {
      final paths = importSvg(await File(path).readAsString());
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
    } on Exception catch (e) {
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
    final program = compileToMachine(sequence);
    final sink = CollectingSink();
    if (!program.validate(MachineModel.generic, sink)) {
      _toast('Export blocked: ${sink.diagnostics.first.message}');
      return;
    }
    final bytes =
        suffix == '.dst' ? encodeDst(program) : encodeExp(program, sink: sink);
    if (sink.hasErrors) {
      _toast('Export blocked: ${sink.diagnostics.first.message}');
      return;
    }
    final file = File(path);
    if (file.existsSync() && !(await _confirmOverwrite(path))) return;
    await file.writeAsBytes(bytes);
    _toast('Exported $path'
        '${skipped.isEmpty ? '' : ' (${skipped.length} object(s) skipped)'}');
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

  /// Demo shape until draw tools land: a 20×20 mm running-stitch square.
  void _addSquare() {
    final id = session.registry.get<IdGenerator>().next();
    const size = 20.0;
    final origin = g.Point(
      10.0 * session.document.objects.length,
      10.0 * session.document.objects.length,
    );
    session.history.execute(AddObject(RunningStitchObject(
      id: id,
      path: g.Path(
        start: origin,
        segments: [
          g.LineSegment(origin + const g.Point(size, 0)),
          g.LineSegment(origin + const g.Point(size, size)),
          g.LineSegment(origin + const g.Point(0, size)),
        ],
        closed: true,
      ),
    )));
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
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.session, required this.onAddSquare});

  final StudioSession session;
  final VoidCallback onAddSquare;

  @override
  Widget build(BuildContext context) {
    final history = session.history;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spacing),
      height: 40,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: history.canUndo ? history.undo : null,
          ),
          IconButton(
            tooltip: 'Redo',
            icon: const Icon(Icons.redo),
            onPressed: history.canRedo ? history.redo : null,
          ),
          IconButton(
            tooltip: 'Add square',
            icon: const Icon(Icons.crop_square),
            onPressed: onAddSquare,
          ),
          const Spacer(),
          Text(session.document.name, key: const Key('doc-title')),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.width});

  final String title;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        margin: const EdgeInsets.all(AppTokens.spacing / 2),
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.spacing),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(title, style: Theme.of(context).textTheme.titleSmall),
          ),
        ),
      ),
    );
  }
}
