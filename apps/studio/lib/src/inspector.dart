import 'package:flutter/material.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

/// Property inspector for the current selection. Edits dispatch
/// [ReplaceObject] through [onReplace] — the panel never mutates.
class InspectorPanel extends StatelessWidget {
  const InspectorPanel({
    super.key,
    required this.document,
    required this.selectedId,
    required this.onReplace,
  });

  final Document document;
  final Id? selectedId;
  final void Function(EmbroideryObject object) onReplace;

  @override
  Widget build(BuildContext context) {
    final object = selectedId == null ? null : document.objectById(selectedId!);
    return Card(
      margin: const EdgeInsets.all(AppTokens.spacing / 2),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.spacing),
        child: object == null
            ? Text('Inspector', style: Theme.of(context).textTheme.titleSmall)
            : _properties(context, object),
      ),
    );
  }

  Widget _properties(BuildContext context, EmbroideryObject object) {
    final bounds = object.path.bounds();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inspector', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppTokens.spacing),
        Text('id: ${object.id}'),
        Text('type: ${switch (object) {
          RunningStitchObject() => 'running stitch',
          SatinObject() => 'satin',
          FillObject() => 'fill',
        }}'),
        Text('size: ${bounds.width.toStringAsFixed(1)} × '
            '${bounds.height.toStringAsFixed(1)} mm'),
        if (object is RunningStitchObject) ...[
          const SizedBox(height: AppTokens.spacing),
          TextFormField(
            key: ValueKey('stitch-length-${object.id}'),
            initialValue: object.stitchLength.toString(),
            decoration: const InputDecoration(
              labelText: 'Stitch length (mm)',
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onFieldSubmitted: (value) {
              final length = double.tryParse(value);
              if (length == null || length <= 0) return;
              onReplace(RunningStitchObject(
                id: object.id,
                path: object.path,
                stitchLength: length,
              ));
            },
          ),
        ],
      ],
    );
  }
}
