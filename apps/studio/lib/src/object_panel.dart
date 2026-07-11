import 'package:flutter/material.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'workspace_view_model.dart' show StitchTarget;

/// Properties panel: object transform fields for a single object
/// selection, or basic hierarchy controls for layers/groups.
class ObjectPropertiesPanel extends StatelessWidget {
  const ObjectPropertiesPanel({
    super.key,
    required this.document,
    required this.selectedRefs,
    required this.primarySelection,
    required this.onCommand,
    this.onConvertText,
    this.framed = true,
  });

  final Document document;
  final List<DocumentNodeRef> selectedRefs;
  final DocumentNodeRef? primarySelection;
  final void Function(Command command) onCommand;

  /// Converts the text object with the given id into stitch objects
  /// (ADR-042). Null hides the convert control.
  final void Function(Id id, StitchTarget target)? onConvertText;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final content = primarySelection == null
        ? Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text('No selection',
                  style: TextStyle(color: AppTokens.textMuted)),
            ),
          )
        : _bodyFor(primarySelection!);
    return framed ? StudioPanel(width: 240, child: content) : content;
  }

  Widget _bodyFor(DocumentNodeRef ref) {
    if (selectedRefs.length > 1) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Properties',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Text('${selectedRefs.length} items selected',
                style: TextStyle(color: AppTokens.textMuted)),
          ],
        ),
      );
    }
    return switch (ref.kind) {
      DocumentNodeKind.object => _ObjectProperties(
          object: document.objectById(ref.id)!,
          onCommand: onCommand,
          onConvertText: onConvertText,
        ),
      DocumentNodeKind.group => _HierarchyProperties(
          name: document.groupById(ref.id)!.name,
          visible: document.groupById(ref.id)!.visible,
          locked: document.groupById(ref.id)!.locked,
          onRename: (name) => onCommand(RenameGroup(ref.id, name)),
          onVisible: (value) => onCommand(SetNodeVisible(ref, value)),
          onLocked: (value) => onCommand(SetNodeLocked(ref, value)),
          title: 'Group Properties',
        ),
      DocumentNodeKind.layer => _HierarchyProperties(
          name: document.layerById(ref.id)!.name,
          visible: document.layerById(ref.id)!.visible,
          locked: document.layerById(ref.id)!.locked,
          onRename: (name) => onCommand(RenameLayer(ref.id, name)),
          onVisible: (value) => onCommand(SetNodeVisible(ref, value)),
          onLocked: (value) => onCommand(SetNodeLocked(ref, value)),
          title: 'Layer Properties',
        ),
    };
  }
}

class _HierarchyProperties extends StatelessWidget {
  const _HierarchyProperties({
    required this.name,
    required this.visible,
    required this.locked,
    required this.onRename,
    required this.onVisible,
    required this.onLocked,
    required this.title,
  });

  final String name;
  final bool visible;
  final bool locked;
  final void Function(String name) onRename;
  final void Function(bool value) onVisible;
  final void Function(bool value) onLocked;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Text('Name', style: TextStyle(color: AppTokens.textMuted)),
        const SizedBox(height: 8),
        StudioTextField(
          key: ValueKey('name-$name'),
          initialValue: name,
          onSubmitted: (value) {
            if (value.isNotEmpty) onRename(value);
          },
        ),
        const SizedBox(height: 12),
        StudioSwitch(label: 'Visible', value: visible, onChanged: onVisible),
        StudioSwitch(label: 'Locked', value: locked, onChanged: onLocked),
      ],
    );
  }
}

class _ObjectProperties extends StatelessWidget {
  const _ObjectProperties(
      {required this.object, required this.onCommand, this.onConvertText});

  final EmbroideryObject object;
  final void Function(Command command) onCommand;
  final void Function(Id id, StitchTarget target)? onConvertText;

  @override
  Widget build(BuildContext context) {
    final bounds = object.bounds();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text('Object Properties',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Text('Transform', style: TextStyle(color: AppTokens.textMuted)),
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
          min: 0.01,
          bounds.width <= 0
              ? null
              : (v) => onCommand(TransformObject(
                  object.id, _scaleAbout(bounds, v / bounds.width, 1))),
        ),
        _mmField(
          'H',
          bounds.height,
          min: 0.01,
          bounds.height <= 0
              ? null
              : (v) => onCommand(TransformObject(
                  object.id, _scaleAbout(bounds, 1, v / bounds.height))),
        ),
        const Divider(height: 24),
        Text('Stitch', style: TextStyle(color: AppTokens.textMuted)),
        const SizedBox(height: 8),
        Text(switch (object) {
          RunningStitchObject() => 'Type: running stitch',
          SatinObject() => 'Type: satin',
          FillObject() => 'Type: fill',
          TextObject(:final text) => 'Type: text — "$text"',
        }),
        if (object is TextObject && onConvertText != null) ...[
          const SizedBox(height: 8),
          Text('Convert to stitches',
              style: TextStyle(fontSize: 11, color: AppTokens.textMuted)),
          const SizedBox(height: 4),
          Row(children: [
            for (final (target, label) in const [
              (StitchTarget.running, 'Running'),
              (StitchTarget.satin, 'Satin'),
              (StitchTarget.fill, 'Fill'),
            ]) ...[
              StudioButton(
                key: Key('convert-${target.name}'),
                label: label,
                variant: StudioButtonVariant.secondary,
                onPressed: () => onConvertText!(object.id, target),
              ),
              const SizedBox(width: 6),
            ],
          ]),
        ],
        if (object case RunningStitchObject(:final stitchLength)) ...[
          const SizedBox(height: 8),
          _mmField(
            'Len',
            stitchLength,
            min: 0.1,
            (v) => onCommand(ReplaceObject(RunningStitchObject(
                id: object.id,
                path: object.path,
                stroke: object.stroke,
                stitchLength: v))),
          ),
        ],
        const Divider(height: 24),
        Text('Stroke', style: TextStyle(color: AppTokens.textMuted)),
        const SizedBox(height: 8),
        _mmField(
          'W',
          object.stroke.widthMm,
          min: 0.05,
          (v) => onCommand(ReplaceObject(
              object.withStroke(object.stroke.copyWith(widthMm: v)))),
        ),
        const SizedBox(height: 6),
        Row(children: [
          StudioDropdown<String>(
            value: object.stroke.cap,
            width: 92,
            items: const [
              ('butt', 'Butt'),
              ('round', 'Round'),
              ('square', 'Square'),
            ],
            onChanged: (v) => onCommand(ReplaceObject(
                object.withStroke(object.stroke.copyWith(cap: v)))),
          ),
          const SizedBox(width: 6),
          StudioDropdown<String>(
            value: object.stroke.join,
            width: 92,
            items: const [
              ('miter', 'Mitre'),
              ('round', 'Round'),
              ('bevel', 'Bevel'),
            ],
            onChanged: (v) => onCommand(ReplaceObject(
                object.withStroke(object.stroke.copyWith(join: v)))),
          ),
        ]),
      ],
    );
  }

  static g.Transform2 _scaleAbout(g.Bounds b, double sx, double sy) =>
      g.Transform2.translation(b.minX, b.minY) *
      g.Transform2.scaling(sx, sy) *
      g.Transform2.translation(-b.minX, -b.minY);

  Widget _mmField(String label, double value, void Function(double)? submit,
      {double min = double.negativeInfinity}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text(label, style: TextStyle(color: AppTokens.textMuted))),
          Expanded(
            child: StudioNumberField(
              value: value,
              min: min,
              suffix: 'mm',
              onSubmitted: submit,
            ),
          ),
        ],
      ),
    );
  }
}
