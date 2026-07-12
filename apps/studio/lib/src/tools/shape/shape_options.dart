import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../workspace_view_model.dart';
import '../tool_option_fields.dart';

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

/// Shape tool options-bar content (ToolContribution.optionsBuilder).
List<Widget> shapeOptions(
  BuildContext context,
  Tool tool,
  VoidCallback onChanged,
  WorkspaceViewModel? model,
) {
  final shape = tool as ShapeTool;
  return [
    // Affinity-style: the bar names the current shape, carries the
    // fill/stroke controls, then the shape's own settings; picking a
    // different shape happens in the floating shape palette.
    Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(shapeIcon(shape.kind), size: 15, color: AppTokens.primary),
      const SizedBox(width: 6),
      Text(shapeLabel(shape.kind),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTokens.textPrimary)),
    ]),
    ...fillStrokeOptions(context, model, onChanged),
    if (shape.kind == ShapeKind.polygon)
      optionNumberField('Sides', shape.sides.toDouble(), min: 3, integer: true,
          (v) {
        shape.sides = v.round();
        onChanged();
      }),
    if (shape.kind == ShapeKind.star) ...[
      optionNumberField('Points', shape.starPoints.toDouble(),
          min: 3, integer: true, (v) {
        shape.starPoints = v.round();
        onChanged();
      }),
      optionNumberField('Inner %', shape.starInnerRatio * 100, min: 5, max: 95,
          (v) {
        shape.starInnerRatio = v / 100;
        onChanged();
      }),
    ],
    if (shape.kind == ShapeKind.roundedRectangle)
      optionNumberField('Radius', shape.cornerRadiusMm, suffix: 'mm', min: 0.1,
          (v) {
        shape.cornerRadiusMm = v;
        onChanged();
      }),
    if (shape.kind == ShapeKind.spiral)
      optionNumberField('Turns', shape.spiralTurns, min: 0.5, (v) {
        shape.spiralTurns = v;
        onChanged();
      }),
  ];
}
