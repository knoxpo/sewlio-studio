import 'package:flutter/material.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;
import 'package:studio_tools/studio_tools.dart';

import '../main.dart';

/// Desktop shell: menu bar, toolbar, side panels, canvas placeholder.
/// Rebuilds on engine events — it renders state, never mutates it.
class StudioShell extends StatefulWidget {
  const StudioShell({super.key, required this.session});

  final StudioSession session;

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  StudioSession get session => widget.session;

  final viewport = ViewportController();
  final selection = SelectionController();
  late final SelectTool tool = SelectTool(
    document: session.document,
    history: session.history,
    selection: selection,
  );

  @override
  void initState() {
    super.initState();
    // Any engine event may change what's on screen; a document revision
    // rebuild is cheap at MVP scale.
    session.events.events.listen((_) => setState(() {}));
    selection.addListener(() => setState(() {}));
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
                const _Panel(title: 'Inspector', width: 240),
              ],
            ),
          ),
        ],
      ),
    );
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
