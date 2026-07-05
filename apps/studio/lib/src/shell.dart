import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';

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

  @override
  void initState() {
    super.initState();
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
          _Toolbar(session: session),
          Expanded(
            child: Row(
              children: [
                const _Panel(title: 'Layers', width: 200),
                Expanded(
                    child: _CanvasPlaceholder(name: session.document.name)),
                const _Panel(title: 'Inspector', width: 240),
              ],
            ),
          ),
        ],
      ),
    );
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
  const _Toolbar({required this.session});

  final StudioSession session;

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

/// Placeholder until studio_canvas lands (MVP-S9).
class _CanvasPlaceholder extends StatelessWidget {
  const _CanvasPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppTokens.spacing / 2),
      child: Center(
        child: Text('$name — canvas', key: const Key('canvas-placeholder')),
      ),
    );
  }
}
