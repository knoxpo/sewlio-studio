import 'package:flutter/material.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

import 'prompts.dart';

/// Built-in project templates (UI-610): document defaults only —
/// hoop and material configuration, never artwork.
final class ProjectTemplate {
  const ProjectTemplate({
    required this.name,
    required this.description,
    required this.hoop,
  });

  final String name;
  final String description;
  final HoopSettings hoop;
}

const projectTemplates = <ProjectTemplate>[
  ProjectTemplate(
    name: 'Blank',
    description: 'Empty 100 × 100 mm hoop',
    hoop: HoopSettings(),
  ),
  ProjectTemplate(
    name: 'Left Chest Logo',
    description: '100 × 100 mm, white fabric',
    hoop: HoopSettings(fabricColorHex: '#ffffff'),
  ),
  ProjectTemplate(
    name: 'Cap Front',
    description: '130 × 60 mm oval',
    hoop: HoopSettings(widthMm: 130, heightMm: 60, shape: HoopShape.oval),
  ),
  ProjectTemplate(
    name: 'Patch',
    description: '80 × 80 mm, twill weave',
    hoop: HoopSettings(widthMm: 80, heightMm: 80, texture: FabricTexture.weave),
  ),
  ProjectTemplate(
    name: 'Sleeve Logo',
    description: '60 × 60 mm',
    hoop: HoopSettings(widthMm: 60, heightMm: 60),
  ),
  ProjectTemplate(
    name: 'Towel',
    description: '130 × 180 mm, aida weave',
    hoop:
        HoopSettings(widthMm: 130, heightMm: 180, texture: FabricTexture.aida),
  ),
  ProjectTemplate(
    name: 'Jacket Back',
    description: '200 × 280 mm',
    hoop: HoopSettings(widthMm: 200, heightMm: 280),
  ),
];

/// Fabric swatches shared by New Project and Document Setup.
const fabricSwatches = [
  '#f5f0e6', // natural
  '#ffffff',
  '#1c1c1e', // black
  '#d7263d', // red
  '#1b5e9e', // navy
  '#2e7d32', // forest
  '#f2b6c1', // pink
  '#c9b28a', // linen
];

/// Full-page New Embroidery Project workflow (UI-606): templates |
/// configuration | live preview. Errors block Create; the document is
/// only constructed on confirm, with no embroidery objects.
class NewProjectPage extends StatefulWidget {
  const NewProjectPage({
    super.key,
    required this.onCancel,
    required this.onCreate,
  });

  final VoidCallback onCancel;
  final void Function(String name, HoopSettings hoop, ProjectUnits units,
      ColorProfile colorProfile, String? location) onCreate;

  @override
  State<NewProjectPage> createState() => _NewProjectPageState();
}

class _NewProjectPageState extends State<NewProjectPage> {
  final _nameController = TextEditingController(text: 'Untitled');
  String? _location;
  int _template = 0;

  ProjectUnits _units = ProjectUnits.mm;
  ColorProfile _profile = ColorProfile.srgb;

  late final _widthController =
      TextEditingController(text: _fmt(projectTemplates[0].hoop.widthMm));
  late final _heightController =
      TextEditingController(text: _fmt(projectTemplates[0].hoop.heightMm));
  HoopShape _shape = projectTemplates[0].hoop.shape;
  FabricTexture _texture = projectTemplates[0].hoop.texture;
  String _fabric = projectTemplates[0].hoop.fabricColorHex;

  /// Preview chrome only: a scratch document rendered by CanvasView,
  /// never part of any session (ARCH-003 untouched).
  final _previewViewport = ViewportController();

  /// Trims trailing zeros so mm shows "100" and inches show "3.94".
  static String _fmt(double value) {
    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double? get _widthMm {
    final v = double.tryParse(_widthController.text);
    return v == null ? null : _units.toMm(v);
  }

  double? get _heightMm {
    final v = double.tryParse(_heightController.text);
    return v == null ? null : _units.toMm(v);
  }

  String? get _validationError {
    if (_nameController.text.trim().isEmpty) {
      return 'Project name is required';
    }
    final w = _widthMm, h = _heightMm;
    if (w == null || h == null || w <= 0 || h <= 0) {
      return 'Hoop dimensions must be positive numbers';
    }
    return null;
  }

  HoopSettings get _hoop => HoopSettings(
        widthMm: _widthMm ?? 100,
        heightMm: _heightMm ?? 100,
        shape: _shape,
        fabricColorHex: _fabric,
        texture: _texture,
      );

  void _applyTemplate(int index) {
    final hoop = projectTemplates[index].hoop;
    setState(() {
      _template = index;
      _widthController.text = _fmt(_units.fromMm(hoop.widthMm));
      _heightController.text = _fmt(_units.fromMm(hoop.heightMm));
      _shape = hoop.shape;
      _texture = hoop.texture;
      _fabric = hoop.fabricColorHex;
    });
  }

  /// Switching units converts the current field values in place.
  void _setUnits(ProjectUnits next) {
    final w = _widthMm, h = _heightMm;
    setState(() {
      _units = next;
      if (w != null) _widthController.text = _fmt(next.fromMm(w));
      if (h != null) _heightController.text = _fmt(next.fromMm(h));
    });
  }

  Future<void> _pickFabricColor() async {
    final hex = await showStudioColorPicker(
      context: context,
      initialHex: _fabric,
    );
    if (hex != null) setState(() => _fabric = hex);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Refit the preview after this frame so hoop edits stay in view.
    final hoop = _hoop;
    WidgetsBinding.instance.addPostFrameCallback((_) => _previewViewport
        .fitBounds(g.Bounds(0, 0, hoop.widthMm, hoop.heightMm)));
    // Hosted inside showNewProjectDialog — the dialog owns the title bar.
    return Container(
      color: AppTokens.background,
      child: Column(children: [
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _templatePane(),
            _configPane(),
            Expanded(child: _previewPane(hoop)),
          ]),
        ),
        _footer(context),
      ]),
    );
  }

  // ------------------------------------------------------------- templates

  Widget _templatePane() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(right: BorderSide(color: AppTokens.border)),
      ),
      child: ListView(children: [
        Padding(
          padding: EdgeInsets.all(10),
          child: Text('Templates',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.textMuted)),
        ),
        for (final (index, template) in projectTemplates.indexed)
          InkWell(
            key: Key('template-${template.name}'),
            onTap: () => _applyTemplate(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: _template == index ? AppTokens.background : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.name,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              _template == index ? AppTokens.primary : null)),
                  Text(template.description,
                      style:
                          TextStyle(fontSize: 10, color: AppTokens.textMuted)),
                ],
              ),
            ),
          ),
      ]),
    );
  }

  // ---------------------------------------------------------------- config

  Widget _configPane() {
    return Container(
      width: 320,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppTokens.border)),
      ),
      child: ListView(children: [
        const StudioSectionLabel('General', first: true),
        StudioTextField(
          key: const Key('new-project-name'),
          controller: _nameController,
          label: 'Project name',
          autofocus: true,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Text(
              _location ?? 'Not saved until you choose a location',
              style: TextStyle(fontSize: 10, color: AppTokens.textMuted),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          StudioButton(
            label: 'Location…',
            onPressed: () async {
              final path = await pickSavePath(
                suffix: '.embproj',
                suggestedName: '${_nameController.text.trim()}.embproj',
              );
              if (path != null) setState(() => _location = path);
            },
          ),
        ]),
        const SizedBox(height: 8),
        StudioFormRow(
          label: 'Units',
          child: StudioDropdown<ProjectUnits>(
            key: const Key('new-project-units'),
            value: _units,
            width: 140,
            items: const [
              (ProjectUnits.mm, 'Millimeters'),
              (ProjectUnits.cm, 'Centimeters'),
              (ProjectUnits.inch, 'Inches'),
            ],
            onChanged: _setUnits,
          ),
        ),
        const StudioSectionLabel('Hoop'),
        Row(children: [
          Expanded(
            child: StudioTextField(
              key: const Key('new-project-width'),
              controller: _widthController,
              label: 'Width (${_units.label})',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StudioTextField(
              key: const Key('new-project-height'),
              controller: _heightController,
              label: 'Height (${_units.label})',
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        StudioFormRow(
          label: 'Shape',
          child: StudioDropdown<HoopShape>(
            value: _shape,
            width: 140,
            items: const [
              (HoopShape.rectangle, 'Rectangle'),
              (HoopShape.roundedRectangle, 'Rounded'),
              (HoopShape.oval, 'Oval'),
            ],
            onChanged: (v) => setState(() => _shape = v),
          ),
        ),
        const StudioSectionLabel('Material'),
        StudioFormRow(
          label: 'Fabric texture',
          child: StudioDropdown<FabricTexture>(
            value: _texture,
            width: 140,
            items: const [
              (FabricTexture.none, 'None'),
              (FabricTexture.weave, 'Weave'),
              (FabricTexture.aida, 'Aida'),
            ],
            onChanged: (v) => setState(() => _texture = v),
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
                onTap: () => setState(() => _fabric = swatch),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Color(
                        0xFF000000 | int.parse(swatch.substring(1), radix: 16)),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _fabric == swatch
                          ? AppTokens.primary
                          : AppTokens.border,
                      width: _fabric == swatch ? 2 : 1,
                    ),
                  ),
                ),
              ),
            ),
          // Custom color: opens the picker; shows the current custom
          // choice when it isn't one of the preset swatches.
          InkWell(
            key: const Key('new-project-custom-color'),
            onTap: _pickFabricColor,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: fabricSwatches.contains(_fabric)
                    ? null
                    : Color(0xFF000000 |
                        int.parse(_fabric.substring(1), radix: 16)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: fabricSwatches.contains(_fabric)
                      ? AppTokens.border
                      : AppTokens.primary,
                  width: fabricSwatches.contains(_fabric) ? 1 : 2,
                ),
              ),
              child: fabricSwatches.contains(_fabric)
                  ? Icon(Icons.colorize, size: 12, color: AppTokens.textMuted)
                  : null,
            ),
          ),
        ]),
        const StudioSectionLabel('Color'),
        StudioFormRow(
          label: 'Color profile',
          child: StudioDropdown<ColorProfile>(
            value: _profile,
            width: 140,
            items: const [
              (ColorProfile.srgb, 'sRGB'),
              (ColorProfile.displayP3, 'Display P3'),
              (ColorProfile.adobeRgb, 'Adobe RGB'),
            ],
            onChanged: (v) => setState(() => _profile = v),
          ),
        ),
      ]),
    );
  }

  // --------------------------------------------------------------- preview

  Widget _previewPane(HoopSettings hoop) {
    // Fresh scratch document per build: cheap (empty except hoop) and
    // guarantees the preview always matches the form.
    final preview = Document(id: const Id('new-project-preview'), hoop: hoop);
    return Column(children: [
      Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppTokens.panel,
          border: Border(bottom: BorderSide(color: AppTokens.border)),
        ),
        child: Text(
          'Preview — ${_fmt(_units.fromMm(hoop.widthMm))} × '
          '${_fmt(_units.fromMm(hoop.heightMm))} ${_units.label}',
          style: TextStyle(fontSize: 11, color: AppTokens.textMuted),
        ),
      ),
      Expanded(
        child: CanvasView(document: preview, viewport: _previewViewport),
      ),
    ]);
  }

  // ---------------------------------------------------------------- footer

  Widget _footer(BuildContext context) {
    final error = _validationError;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      child: Row(children: [
        if (error != null)
          Text(error,
              key: const Key('new-project-error'),
              style: const TextStyle(fontSize: 11, color: AppTokens.error)),
        const Spacer(),
        StudioButton(
          label: 'Cancel',
          variant: StudioButtonVariant.ghost,
          onPressed: widget.onCancel,
        ),
        const SizedBox(width: 8),
        StudioButton(
          key: const Key('new-project-create'),
          label: 'Create',
          variant: StudioButtonVariant.primary,
          onPressed: error != null
              ? null
              : () => widget.onCreate(_nameController.text.trim(), _hoop,
                  _units, _profile, _location),
        ),
      ]),
    );
  }
}
