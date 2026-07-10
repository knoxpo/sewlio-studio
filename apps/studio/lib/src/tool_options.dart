import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import 'font_library.dart';
import 'stroke_style.dart';
import 'workspace_view_model.dart';

/// Icon + label for each shape kind (rail flyout + options bar).
IconData shapeIcon(ShapeKind kind) => switch (kind) {
      ShapeKind.rectangle => TablerIcons.rectangle,
      ShapeKind.square => TablerIcons.square,
      ShapeKind.roundedRectangle => TablerIcons.square_rounded,
      ShapeKind.circle => TablerIcons.circle,
      ShapeKind.ellipse => TablerIcons.oval,
      ShapeKind.triangle => TablerIcons.triangle,
      ShapeKind.pentagon => TablerIcons.pentagon,
      ShapeKind.hexagon => TablerIcons.hexagon,
      ShapeKind.polygon => TablerIcons.polygon,
      ShapeKind.star => TablerIcons.star,
      ShapeKind.diamond => TablerIcons.diamond,
      ShapeKind.trapezoid => TablerIcons.lasso_polygon,
      ShapeKind.squareStar => TablerIcons.north_star,
      ShapeKind.arrow => TablerIcons.arrow_big_right,
      ShapeKind.pie => TablerIcons.chart_pie,
      ShapeKind.segment => TablerIcons.circle_half_2,
      ShapeKind.crescent => TablerIcons.moon,
      ShapeKind.cog => TablerIcons.settings,
      ShapeKind.heart => TablerIcons.heart,
      ShapeKind.teardrop => TablerIcons.droplet,
      ShapeKind.cloud => TablerIcons.cloud,
      ShapeKind.spiral => TablerIcons.spiral,
    };

String shapeLabel(ShapeKind kind) => switch (kind) {
      ShapeKind.rectangle => 'Rectangle',
      ShapeKind.square => 'Square',
      ShapeKind.roundedRectangle => 'Rounded Rectangle',
      ShapeKind.circle => 'Circle',
      ShapeKind.ellipse => 'Ellipse',
      ShapeKind.triangle => 'Triangle',
      ShapeKind.pentagon => 'Pentagon',
      ShapeKind.hexagon => 'Hexagon',
      ShapeKind.polygon => 'Polygon (N sides)',
      ShapeKind.star => 'Star',
      ShapeKind.diamond => 'Diamond',
      ShapeKind.trapezoid => 'Trapezoid',
      ShapeKind.squareStar => 'Square Star',
      ShapeKind.arrow => 'Arrow',
      ShapeKind.pie => 'Pie',
      ShapeKind.segment => 'Segment',
      ShapeKind.crescent => 'Crescent',
      ShapeKind.cog => 'Cog',
      ShapeKind.heart => 'Heart',
      ShapeKind.teardrop => 'Teardrop',
      ShapeKind.cloud => 'Cloud',
      ShapeKind.spiral => 'Spiral',
    };

/// Illustrator-style control bar: contextual options for the active
/// tool, shown above the canvas.
class ToolOptionsBar extends StatelessWidget {
  const ToolOptionsBar({
    super.key,
    required this.tool,
    required this.onChanged,
    this.model,
  });

  final Tool tool;

  /// Workspace model for options that reach beyond the tool itself
  /// (stroke defaults). Null in isolated previews/tests.
  final WorkspaceViewModel? model;

  /// Called after any option edit so the shell repaints.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final options = switch (tool) {
      ShapeTool shape => _shapeOptions(shape),
      TextTool text => _textOptions(text),
      PenTool pen => _penOptions(context, pen),
      PencilTool pencil => [
          _numberField('Smoothing', pencil.toleranceMm, suffix: 'mm', min: 0.05,
              (v) {
            pencil.toleranceMm = v;
            onChanged();
          }),
        ],
      _ => const <Widget>[],
    };
    if (options.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 34,
      // Fill the whole strip and keep content left-aligned — the bar
      // must never shrink-wrap and float centered over the canvas.
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppTokens.panel,
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      // Rich toolbars (Text) can outgrow narrow windows — scroll, never
      // overflow.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final (index, option) in options.indexed) ...[
            if (index > 0)
              Container(
                width: 1,
                height: 18,
                color: AppTokens.border,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
            option,
          ],
        ]),
      ),
    );
  }

  // -------------------------------------------------------------- pen tool

  List<Widget> _penOptions(BuildContext context, PenTool pen) {
    return [
      // Drawing mode strip (Smart mode arrives with curve fitting).
      Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (mode, icon, label) in const [
          (PenMode.pen, TablerIcons.ballpen, 'Pen mode — straight segments'),
          (
            PenMode.smart,
            TablerIcons.wand,
            'Smart mode — smooth curve through your points'
          ),
          (
            PenMode.polygon,
            TablerIcons.polygon,
            'Polygon mode — always closes the shape'
          ),
          (PenMode.line, TablerIcons.line, 'Line mode — one two-point segment'),
        ])
          StudioIconButton(
            icon: icon,
            tooltip: label,
            active: pen.mode == mode,
            onPressed: () {
              pen.mode = mode;
              onChanged();
            },
          ),
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        if (model != null) ...[
          _numberField('Width', model!.strokeStyle.widthMm,
              suffix: 'mm', min: 0.05, (v) {
            model!.strokeStyle.widthMm = v;
            onChanged();
          }),
          const SizedBox(width: 8),
          StudioButton(
            label: 'Stroke…',
            onPressed: () => showStrokeDialog(context, model!),
          ),
        ],
      ]),
      Row(mainAxisSize: MainAxisSize.min, children: [
        if (model != null)
          StudioIconButton(
            icon: TablerIcons.bucket_droplet,
            tooltip: 'Use fill — fill closed shapes with the fill chip color',
            active: model!.strokeStyle.useFill,
            onPressed: () {
              model!.setUseFill(!model!.strokeStyle.useFill);
              onChanged();
            },
          ),
      ]),
    ];
  }

  // ------------------------------------------------------------- text tool

  /// Style variants wait for family grouping (nameID 1/2) + a shaping
  /// engine; families list every installed TrueType face today.
  static const textFontStyles = ['Regular'];

  List<Widget> _textOptions(TextTool text) {
    return [
      // Font family (system fonts, scanned once) + style slot.
      Row(mainAxisSize: MainAxisSize.min, children: [
        FutureBuilder<List<String>>(
          future: FontLibrary.instance.families(),
          builder: (context, snapshot) {
            final families = snapshot.data ?? const [FontLibrary.builtinFamily];
            return StudioDropdown<String>(
              value: families.contains(text.font.family)
                  ? text.font.family
                  : FontLibrary.builtinFamily,
              width: 160,
              items: [for (final f in families) (f, f)],
              onChanged: (family) async {
                text.font = await FontLibrary.instance.load(family);
                onChanged();
              },
            );
          },
        ),
        const SizedBox(width: 6),
        StudioDropdown<String>(
          value: textFontStyles.first,
          width: 84,
          items: [for (final s in textFontStyles) (s, s)],
          onChanged: (_) => onChanged(),
        ),
      ]),
      // Typography numbers.
      Row(mainAxisSize: MainAxisSize.min, children: [
        _numberField('Size', text.sizeMm, suffix: 'mm', min: 1, (v) {
          text.sizeMm = v;
          onChanged();
        }),
        const SizedBox(width: 8),
        _numberField('Tracking', text.trackingMm, suffix: 'mm', min: -5, (v) {
          text.trackingMm = v;
          onChanged();
        }),
        const SizedBox(width: 8),
        _numberField('Leading ×', text.lineHeight, min: 0.5, max: 4, (v) {
          text.lineHeight = v;
          onChanged();
        }),
      ]),
      // Paragraph alignment (justify variants wait for a glyph engine
      // with per-word metrics).
      Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (align, icon, label) in [
          (MonoTextAlign.left, TablerIcons.align_left, 'Align Left'),
          (MonoTextAlign.center, TablerIcons.align_center, 'Align Center'),
          (MonoTextAlign.right, TablerIcons.align_right, 'Align Right'),
        ])
          StudioIconButton(
            icon: icon,
            tooltip: label,
            active: text.align == align,
            onPressed: () {
              text.align = align;
              onChanged();
            },
          ),
        const StudioIconButton(
          icon: TablerIcons.align_justified,
          tooltip: 'Justify — requires font engine',
        ),
      ]),
      // Text style + color slots: monoline is single-weight stroke
      // lettering, so these enable when TTF glyphs / the fill-stroke
      // system land. Disabled, not hidden — the workflow is visible.
      Row(mainAxisSize: MainAxisSize.min, children: const [
        StudioIconButton(
            icon: TablerIcons.bold, tooltip: 'Bold — requires font engine'),
        StudioIconButton(
            icon: TablerIcons.italic, tooltip: 'Italic — requires font engine'),
        StudioIconButton(
            icon: TablerIcons.underline,
            tooltip: 'Underline — requires font engine'),
        StudioIconButton(
            icon: TablerIcons.strikethrough,
            tooltip: 'Strikethrough — requires font engine'),
        StudioIconButton(
            icon: TablerIcons.palette,
            tooltip: 'Text color — arrives with the fill/stroke system'),
      ]),
    ];
  }

  List<Widget> _shapeOptions(ShapeTool shape) {
    return [
      // Shape kind picker: one icon per kind, Illustrator control-bar
      // style.
      Row(children: [
        for (final kind in ShapeKind.values)
          StudioIconButton(
            icon: shapeIcon(kind),
            tooltip: shapeLabel(kind),
            active: shape.kind == kind,
            onPressed: () {
              shape.kind = kind;
              onChanged();
            },
          ),
      ]),
      if (shape.kind == ShapeKind.polygon)
        _numberField('Sides', shape.sides.toDouble(), min: 3, integer: true,
            (v) {
          shape.sides = v.round();
          onChanged();
        }),
      if (shape.kind == ShapeKind.star) ...[
        _numberField('Points', shape.starPoints.toDouble(),
            min: 3, integer: true, (v) {
          shape.starPoints = v.round();
          onChanged();
        }),
        _numberField('Inner %', shape.starInnerRatio * 100, min: 5, max: 95,
            (v) {
          shape.starInnerRatio = v / 100;
          onChanged();
        }),
      ],
      if (shape.kind == ShapeKind.roundedRectangle)
        _numberField('Radius', shape.cornerRadiusMm, suffix: 'mm', min: 0.1,
            (v) {
          shape.cornerRadiusMm = v;
          onChanged();
        }),
      if (shape.kind == ShapeKind.spiral)
        _numberField('Turns', shape.spiralTurns, min: 0.5, (v) {
          shape.spiralTurns = v;
          onChanged();
        }),
    ];
  }

  /// Compact labeled number field with − / + steppers.
  Widget _numberField(
    String label,
    double value,
    void Function(double) submit, {
    String? suffix,
    double min = 0,
    double? max,
    bool integer = false,
  }) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label ',
          style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
      StudioNumberField(
        value: value,
        min: min,
        max: max,
        integer: integer,
        decimals: 1,
        suffix: suffix,
        steppers: true,
        width: suffix == null ? 84 : 104,
        textAlign: TextAlign.center,
        onSubmitted: submit,
      ),
    ]);
  }
}
