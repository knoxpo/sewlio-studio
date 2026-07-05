import 'package:flutter/material.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

/// Left "Object Properties" panel: transform fields for the selection.
/// Edits dispatch commands via [onCommand] — the panel never mutates.
class ObjectPropertiesPanel extends StatelessWidget {
  const ObjectPropertiesPanel({
    super.key,
    required this.document,
    required this.selectedId,
    required this.onCommand,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
  });

  final Document document;
  final Id? selectedId;
  final void Function(Command command) onCommand;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    final object = selectedId == null ? null : document.objectById(selectedId!);
    return StudioPanel(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppTokens.background,
              border: Border(bottom: BorderSide(color: AppTokens.border)),
            ),
            child: Row(
              children: [
                StudioIconButton(
                    icon: Icons.undo,
                    tooltip: 'Undo',
                    onPressed: canUndo ? onUndo : null),
                StudioIconButton(
                    icon: Icons.redo,
                    tooltip: 'Redo',
                    onPressed: canRedo ? onRedo : null),
                const SizedBox(width: 8),
                const StudioIconButton(
                    icon: Icons.content_copy, tooltip: 'Copy (soon)'),
                const StudioIconButton(
                    icon: Icons.content_paste, tooltip: 'Paste (soon)'),
              ],
            ),
          ),
          Expanded(
            child: object == null
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No selection',
                        style: TextStyle(color: AppTokens.textMuted)),
                  )
                : _Properties(object: object, onCommand: onCommand),
          ),
        ],
      ),
    );
  }
}

class _Properties extends StatelessWidget {
  const _Properties({required this.object, required this.onCommand});

  final EmbroideryObject object;
  final void Function(Command command) onCommand;

  @override
  Widget build(BuildContext context) {
    final bounds = object.path.bounds();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('Object Properties',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        const Text('Transform', style: TextStyle(color: AppTokens.textMuted)),
        const SizedBox(height: 8),
        _mmField(
          'X',
          bounds.minX,
          (v) => onCommand(TransformObject(
              object.id, g.Transform2.translation(v - bounds.minX, 0))),
        ),
        _mmField(
          'Y',
          bounds.minY,
          (v) => onCommand(TransformObject(
              object.id, g.Transform2.translation(0, v - bounds.minY))),
        ),
        _mmField(
          'W',
          bounds.width,
          bounds.width <= 0
              ? null
              : (v) => onCommand(TransformObject(
                  object.id, _scaleAbout(bounds, v / bounds.width, 1))),
        ),
        _mmField(
          'H',
          bounds.height,
          bounds.height <= 0
              ? null
              : (v) => onCommand(TransformObject(
                  object.id, _scaleAbout(bounds, 1, v / bounds.height))),
        ),
        const Divider(height: 24),
        const Text('Stitch', style: TextStyle(color: AppTokens.textMuted)),
        const SizedBox(height: 8),
        Text(switch (object) {
          RunningStitchObject() => 'Type: running stitch',
          SatinObject() => 'Type: satin (generator pending)',
          FillObject() => 'Type: fill (generator pending)',
        }),
        if (object case RunningStitchObject(:final stitchLength)) ...[
          const SizedBox(height: 8),
          _mmField(
            'Len',
            stitchLength,
            (v) {
              if (v <= 0) return;
              onCommand(ReplaceObject(RunningStitchObject(
                  id: object.id, path: object.path, stitchLength: v)));
            },
          ),
        ],
      ],
    );
  }

  /// Scale about the bounds origin so the object stays anchored.
  static g.Transform2 _scaleAbout(g.Bounds b, double sx, double sy) =>
      g.Transform2.translation(b.minX, b.minY) *
      g.Transform2.scaling(sx, sy) *
      g.Transform2.translation(-b.minX, -b.minY);

  Widget _mmField(String label, double value, void Function(double)? submit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text(label,
                  style: const TextStyle(color: AppTokens.textMuted))),
          Expanded(
            child: TextFormField(
              key: ValueKey('$label-${value.toStringAsFixed(2)}'),
              initialValue: value.toStringAsFixed(2),
              enabled: submit != null,
              style: const TextStyle(fontSize: 12),
              onFieldSubmitted: (text) {
                final v = double.tryParse(text);
                if (v != null) submit?.call(v);
              },
            ),
          ),
          const SizedBox(width: 6),
          const Text('mm', style: TextStyle(color: AppTokens.textMuted)),
        ],
      ),
    );
  }
}
