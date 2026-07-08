import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

/// Icon + label for each shape kind (rail flyout + options bar).
IconData shapeIcon(ShapeKind kind) => switch (kind) {
      ShapeKind.rectangle => Icons.crop_square,
      ShapeKind.square => Icons.square_outlined,
      ShapeKind.roundedRectangle => Icons.rounded_corner,
      ShapeKind.circle => Icons.circle_outlined,
      ShapeKind.ellipse => Icons.egg_outlined,
      ShapeKind.triangle => Icons.change_history,
      ShapeKind.pentagon => Icons.pentagon_outlined,
      ShapeKind.hexagon => Icons.hexagon_outlined,
      ShapeKind.polygon => Icons.polyline,
      ShapeKind.star => Icons.star_border,
      ShapeKind.spiral => Icons.all_inclusive,
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
      ShapeKind.spiral => 'Spiral',
    };

/// Illustrator-style control bar: contextual options for the active
/// tool, shown above the canvas.
class ToolOptionsBar extends StatelessWidget {
  const ToolOptionsBar({
    super.key,
    required this.tool,
    required this.onChanged,
  });

  final Tool tool;

  /// Called after any option edit so the shell repaints.
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final options = switch (tool) {
      ShapeTool shape => _shapeOptions(shape),
      TextTool text => [
          _numberField('Size', text.sizeMm, suffix: 'mm', min: 1, (v) {
            text.sizeMm = v;
            onChanged();
          }),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppTokens.panel,
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
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
    );
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
    void apply(double v) {
      final clamped = v.clamp(min, max ?? double.infinity).toDouble();
      submit(integer ? clamped.roundToDouble() : clamped);
    }

    final step = integer ? 1.0 : (value >= 10 ? 1.0 : 0.1);
    final display =
        integer ? value.round().toString() : value.toStringAsFixed(1);
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label ',
          style: const TextStyle(color: AppTokens.textMuted, fontSize: 11)),
      StudioIconButton(
          icon: Icons.remove,
          tooltip: 'Decrease',
          onPressed: () => apply(value - step)),
      SizedBox(
        width: 44,
        height: 24,
        child: TextFormField(
          key: ValueKey('$label-$display'),
          initialValue: display,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11),
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 4)),
          onFieldSubmitted: (text) {
            final v = double.tryParse(text);
            if (v != null) apply(v);
          },
        ),
      ),
      StudioIconButton(
          icon: Icons.add,
          tooltip: 'Increase',
          onPressed: () => apply(value + step)),
      if (suffix != null)
        Text(suffix,
            style: const TextStyle(color: AppTokens.textMuted, fontSize: 11)),
    ]);
  }
}
