import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import 'workspace_view_model.dart';

/// Stroke settings edited from the Pen options bar (Affinity-style
/// Stroke popup).
// ponytail: stored as the workspace stroke defaults — objects don't
// carry stroke properties yet, so these apply to rendering/stitching
// once the fill/stroke system lands. The UI and model are final; only
// the downstream hookup is pending. Dash/line-style designer waits for
// the same system.
final class StrokeStyle {
  StrokePaintStyle paintStyle = StrokePaintStyle.solid;

  /// New closed objects get filled with the fill chip's color.
  bool useFill = false;
  double widthMm = 0.4;
  LineCapStyle cap = LineCapStyle.round;
  LineJoinStyle join = LineJoinStyle.round;
  double miterLimit = 4;
  StrokeAlignStyle align = StrokeAlignStyle.center;
  bool drawBehind = false;
  bool scaleWithObject = true;
  ArrowheadStyle startArrow = ArrowheadStyle.none;
  ArrowheadStyle endArrow = ArrowheadStyle.none;
  ArrowPlacement arrowPlacement = ArrowPlacement.atLineEnd;

  /// Default on so stylus pressure "just works" on tablets (ADR-038);
  /// mouse/touch never vary pressure, so desktop strokes stay uniform.
  /// None = explicitly ignore hardware pressure.
  PressureProfile pressure = PressureProfile.pressure;

  /// Arrowhead sizes as % of stroke width; [scalesLinked] keeps them
  /// in sync.
  double startScale = 100;
  double endScale = 100;
  bool scalesLinked = true;

  void swapArrowheads() {
    final a = startArrow;
    startArrow = endArrow;
    endArrow = a;
    final sc = startScale;
    startScale = endScale;
    endScale = sc;
  }

  void clearArrowheads() {
    startArrow = ArrowheadStyle.none;
    endArrow = ArrowheadStyle.none;
    startScale = 100;
    endScale = 100;
  }
}

/// Line rendering style (Affinity Stroke panel "Style" row).
// ponytail: dashed and brush enable with the dash designer / brush
// engine.
enum StrokePaintStyle { none, solid, dashed, brush }

enum LineCapStyle { butt, round, square }

enum LineJoinStyle { miter, round, bevel }

enum StrokeAlignStyle { center, inside, outside }

enum ArrowheadStyle {
  none('None'),
  arrow('Arrow'),
  barbed('Barbed'),
  triangle('Triangle'),
  triangleWide('Triangle Wide'),
  circle('Circle'),
  circleSolid('Circle Solid'),
  square('Square'),
  squareSolid('Square Solid'),
  bar('Bar');

  const ArrowheadStyle(this.label);

  final String label;
}

enum ArrowPlacement { atLineEnd, withinLine }

enum PressureProfile {
  none('None'),
  pressure('Pressure'),
  velocity('Velocity'),
  velocityInverse('Velocity Inverse');

  const PressureProfile(this.label);

  final String label;
}

/// Stroke popup (Affinity Stroke panel layout). With a selection it
/// edits the selected objects (undoable ReplaceObject per change) and
/// keeps the tool defaults in sync; with nothing selected it edits the
/// defaults for new objects. Width/cap/join/mitre/color are rendered
/// live on the canvas; align/order/arrowheads/pressure are defaults
/// for systems that arrive later (dash designer, arrow rendering).
Future<void> showStrokeDialog(
    BuildContext context, WorkspaceViewModel model) async {
  final stroke = model.strokeStyle;
  await showStudioDialog<void>(
    context: context,
    title: 'Stroke',
    width: 330,
    floating: true,
    body: StatefulBuilder(
      builder: (context, setDialogState) {
        void update(void Function() change) {
          setDialogState(change);
          model.notify();
        }

        void setProps(StrokeProps Function(StrokeProps) mutate) =>
            update(() => model.setStroke(mutate));

        final active = model.activeStroke;

        Widget label(String text) => SizedBox(
              width: 44,
              child: Text(text,
                  style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
            );

        Widget row(String text, Widget child, {Widget? trailing}) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                label(text),
                child,
                if (trailing != null) ...[const Spacer(), trailing],
              ]),
            );

        Widget glyphChoice(
          List<(String, StrokeGlyphKind, String)> options,
          String value,
          void Function(String) pick,
        ) {
          return Row(mainAxisSize: MainAxisSize.min, children: [
            for (final (option, glyph, tip) in options)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: StrokeGlyphButton(
                  glyph: glyph,
                  tooltip: tip,
                  selected: option == value,
                  onTap: () => pick(option),
                ),
              ),
          ]);
        }

        Widget arrowheadRow(
          String text,
          ArrowheadStyle value,
          double scale,
          void Function(ArrowheadStyle) pickStyle,
          void Function(double) pickScale,
        ) =>
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                label(text),
                StudioDropdown<ArrowheadStyle>(
                  value: value,
                  width: 118,
                  items: [for (final a in ArrowheadStyle.values) (a, a.label)],
                  onChanged: (v) => update(() => pickStyle(v)),
                ),
                const SizedBox(width: 6),
                StudioNumberField(
                  value: scale,
                  min: 10,
                  max: 1000,
                  decimals: 0,
                  suffix: '%',
                  width: 66,
                  onSubmitted: (v) => update(() => pickScale(v)),
                ),
              ]),
            );

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(
              'Style',
              Row(mainAxisSize: MainAxisSize.min, children: [
                for (final (option, icon, tip, enabled) in [
                  (
                    StrokePaintStyle.none,
                    TablerIcons.circle_off,
                    'No stroke',
                    true
                  ),
                  (
                    StrokePaintStyle.solid,
                    TablerIcons.minus,
                    'Solid line',
                    true
                  ),
                  (
                    StrokePaintStyle.dashed,
                    TablerIcons.line_dashed,
                    'Dashed — arrives with the dash designer',
                    false
                  ),
                  (
                    StrokePaintStyle.brush,
                    TablerIcons.brush,
                    'Brush — arrives with the brush engine',
                    false
                  ),
                ])
                  StudioIconButton(
                    icon: icon,
                    tooltip: tip,
                    active: stroke.paintStyle == option,
                    onPressed: enabled
                        ? () => update(() => stroke.paintStyle = option)
                        : null,
                  ),
              ]),
            ),
            Divider(height: 14, color: AppTokens.border),
            row(
              'Width',
              Expanded(
                child: StudioSlider(
                  value: active.widthMm.clamp(0.05, 10),
                  min: 0.05,
                  max: 10,
                  onChanged: (v) => setProps((p) => p.copyWith(widthMm: v)),
                ),
              ),
              trailing: StudioNumberField(
                value: active.widthMm,
                min: 0.05,
                decimals: 2,
                suffix: 'mm',
                width: 78,
                onSubmitted: (v) => setProps((p) => p.copyWith(widthMm: v)),
              ),
            ),
            row(
              'Cap',
              glyphChoice(const [
                ('butt', StrokeGlyphKind.capButt, 'Butt cap'),
                ('round', StrokeGlyphKind.capRound, 'Round cap'),
                ('square', StrokeGlyphKind.capSquare, 'Square cap'),
              ], active.cap, (v) => setProps((p) => p.copyWith(cap: v))),
            ),
            row(
              'Join',
              glyphChoice(const [
                ('miter', StrokeGlyphKind.joinMiter, 'Mitre join'),
                ('round', StrokeGlyphKind.joinRound, 'Round join'),
                ('bevel', StrokeGlyphKind.joinBevel, 'Bevel join'),
              ], active.join, (v) => setProps((p) => p.copyWith(join: v))),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('Mitre ',
                    style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
                IgnorePointer(
                  ignoring: active.join != 'miter',
                  child: Opacity(
                    opacity: active.join == 'miter' ? 1 : 0.4,
                    child: StudioNumberField(
                      value: active.miterLimit,
                      min: 1,
                      decimals: 1,
                      width: 58,
                      onSubmitted: (v) =>
                          setProps((p) => p.copyWith(miterLimit: v)),
                    ),
                  ),
                ),
              ]),
            ),
            row(
              'Align',
              glyphChoice(const [
                (
                  'center',
                  StrokeGlyphKind.alignCenter,
                  'Align stroke to center'
                ),
                (
                  'inside',
                  StrokeGlyphKind.alignInside,
                  'Align stroke to inside'
                ),
                (
                  'outside',
                  StrokeGlyphKind.alignOutside,
                  'Align stroke to outside'
                ),
              ], stroke.align.name, (v) {
                update(() => stroke.align =
                    StrokeAlignStyle.values.asNameMap()[v] ??
                        StrokeAlignStyle.center);
              }),
            ),
            Divider(height: 14, color: AppTokens.border),
            row(
              'Order',
              Row(mainAxisSize: MainAxisSize.min, children: [
                StudioIconButton(
                  icon: TablerIcons.stack_front,
                  tooltip: 'Draw stroke in front',
                  active: !stroke.drawBehind,
                  onPressed: () => update(() => stroke.drawBehind = false),
                ),
                StudioIconButton(
                  icon: TablerIcons.stack_back,
                  tooltip: 'Draw stroke behind',
                  active: stroke.drawBehind,
                  onPressed: () => update(() => stroke.drawBehind = true),
                ),
              ]),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                StudioSwitch(
                  value: stroke.scaleWithObject,
                  onChanged: (v) => update(() => stroke.scaleWithObject = v),
                ),
                Text(' Scale with object',
                    style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
              ]),
            ),
            Divider(height: 14, color: AppTokens.border),
            // Start/End with a bracket-style link control on the right
            // (reference design): the chain visibly spans both rows.
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                child: Column(children: [
                  arrowheadRow('Start', stroke.startArrow, stroke.startScale,
                      (v) => stroke.startArrow = v, (v) {
                    stroke.startScale = v;
                    if (stroke.scalesLinked) stroke.endScale = v;
                  }),
                  arrowheadRow('End', stroke.endArrow, stroke.endScale,
                      (v) => stroke.endArrow = v, (v) {
                    stroke.endScale = v;
                    if (stroke.scalesLinked) stroke.startScale = v;
                  }),
                ]),
              ),
              _LinkBracket(
                linked: stroke.scalesLinked,
                onToggle: () =>
                    update(() => stroke.scalesLinked = !stroke.scalesLinked),
              ),
            ]),
            Row(children: [
              label(''),
              StrokeGlyphButton(
                glyph: StrokeGlyphKind.arrowAtEnd,
                tooltip: 'Arrowhead extends past the line end',
                selected: stroke.arrowPlacement == ArrowPlacement.atLineEnd,
                onTap: () => update(
                    () => stroke.arrowPlacement = ArrowPlacement.atLineEnd),
              ),
              const SizedBox(width: 4),
              StrokeGlyphButton(
                glyph: StrokeGlyphKind.arrowWithin,
                tooltip: 'Arrowhead stays within the line length',
                selected: stroke.arrowPlacement == ArrowPlacement.withinLine,
                onTap: () => update(
                    () => stroke.arrowPlacement = ArrowPlacement.withinLine),
              ),
              const Spacer(),
              StudioIconButton(
                icon: TablerIcons.arrows_left_right,
                tooltip: 'Swap arrowheads',
                onPressed: () => update(stroke.swapArrowheads),
              ),
              StudioIconButton(
                icon: TablerIcons.trash,
                tooltip: 'Remove arrowheads',
                onPressed: () => update(stroke.clearArrowheads),
              ),
            ]),
            Divider(height: 14, color: AppTokens.border),
            Row(children: [
              StudioButton(
                label: 'Properties…',
                onPressed: () => _showStrokeProperties(context, model),
              ),
              const Spacer(),
              Text('Pressure ',
                  style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
              StudioDropdown<PressureProfile>(
                value: stroke.pressure,
                width: 118,
                items: [for (final p in PressureProfile.values) (p, p.label)],
                onChanged: (v) => update(() => stroke.pressure = v),
              ),
            ]),
          ],
        );
      },
    ),
  );
}

/// Properties…: manages the stroke DEFAULTS applied to newly drawn
/// objects — shows where the current values came from and resets them.
Future<void> _showStrokeProperties(
    BuildContext context, WorkspaceViewModel model) async {
  final reset = await showStudioDialog<bool>(
    context: context,
    title: 'Stroke Properties',
    floating: true,
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'These stroke settings are applied to every newly drawn '
          'object (pen, pencil, shapes, text). Selecting objects and '
          'editing the Stroke panel restyles them and updates these '
          'defaults.',
          style: TextStyle(color: AppTokens.textMuted),
        ),
        const SizedBox(height: 10),
        Text(
          'Width ${model.strokeDefaults.widthMm.toStringAsFixed(2)} mm · '
          '${model.strokeDefaults.cap} cap · '
          '${model.strokeDefaults.join} join · '
          'color ${model.strokeDefaults.colorHex ?? 'theme'}',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    ),
    actions: [
      Builder(
        builder: (context) => StudioButton(
          label: 'Cancel',
          variant: StudioButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      Builder(
        builder: (context) => StudioButton(
          label: 'Reset to Defaults',
          variant: StudioButtonVariant.primary,
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
    ],
  );
  if (reset == true) {
    model.setStroke((_) => StrokeProps.defaults);
    model.resetFillStroke();
  }
}

/// Square-bracket + chain control linking the Start/End arrowhead
/// scales: one bracket spans both rows, chain icon dead-center.
class _LinkBracket extends StatelessWidget {
  const _LinkBracket({required this.linked, required this.onToggle});

  final bool linked;
  final VoidCallback onToggle;

  static const _height = 60.0;

  @override
  Widget build(BuildContext context) {
    final color = linked ? AppTokens.primary : AppTokens.textMuted;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(4),
        child: Tooltip(
          message: linked
              ? 'Start/End scales linked — click to unlink'
              : 'Start/End scales independent — click to link',
          waitDuration: const Duration(milliseconds: 400),
          child: SizedBox(
            width: 20,
            height: _height,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(
                size: const Size(20, _height),
                painter: _BracketPainter(color),
              ),
              Icon(linked ? TablerIcons.link : TablerIcons.unlink,
                  size: 14, color: color),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A right-facing square bracket with a gap in the middle for the
/// chain icon: two arms reaching left toward the Start/End rows.
class _BracketPainter extends CustomPainter {
  const _BracketPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const armLength = 7.0;
    final spineX = size.width / 2 + 4;
    final gapTop = size.height / 2 - 10;
    final gapBottom = size.height / 2 + 10;
    // Top arm: left → spine → down to the icon gap.
    canvas.drawPath(
      Path()
        ..moveTo(spineX - armLength, 3)
        ..lineTo(spineX, 3)
        ..lineTo(spineX, gapTop),
      paint,
    );
    // Bottom arm: from below the gap → down → left.
    canvas.drawPath(
      Path()
        ..moveTo(spineX, gapBottom)
        ..lineTo(spineX, size.height - 3)
        ..lineTo(spineX - armLength, size.height - 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BracketPainter old) => old.color != color;
}

/// Professional cap/join/align/placement glyphs, painted so the icon is
/// literally the geometry it selects (reference: Affinity Designer).
enum StrokeGlyphKind {
  capButt,
  capRound,
  capSquare,
  joinMiter,
  joinRound,
  joinBevel,
  alignCenter,
  alignInside,
  alignOutside,
  arrowAtEnd,
  arrowWithin,
}

class StrokeGlyphButton extends StatelessWidget {
  const StrokeGlyphButton({
    super.key,
    required this.glyph,
    required this.tooltip,
    required this.selected,
    required this.onTap,
  });

  final StrokeGlyphKind glyph;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? AppTokens.primary : AppTokens.field;
    return Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        hoverColor: AppTokens.surfaceHigh,
        child: Container(
          width: 34,
          height: 28,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: selected ? AppTokens.primary : AppTokens.border),
          ),
          child: CustomPaint(
            painter: _StrokeGlyphPainter(
              glyph,
              selected ? AppTokens.onPrimary : AppTokens.textPrimary,
              background,
            ),
          ),
        ),
      ),
    );
  }
}

class _StrokeGlyphPainter extends CustomPainter {
  const _StrokeGlyphPainter(this.glyph, this.color, this.background);

  final StrokeGlyphKind glyph;
  final Color color;
  final Color background;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final thick = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9;
    final spine = Paint()
      ..color = color
      ..strokeWidth = 1;

    switch (glyph) {
      case StrokeGlyphKind.capButt:
      case StrokeGlyphKind.capRound:
      case StrokeGlyphKind.capSquare:
        // Reference style: thick stub entering from the left, real
        // StrokeCap terminating it; spine + end dot mark the path.
        thick.strokeCap = switch (glyph) {
          StrokeGlyphKind.capButt => StrokeCap.butt,
          StrokeGlyphKind.capRound => StrokeCap.round,
          _ => StrokeCap.square,
        };
        final endX = size.width / 2 + 2;
        canvas.drawLine(Offset(-2, cy), Offset(endX, cy), thick);
        canvas.drawLine(Offset(-2, cy), Offset(endX, cy), spine);
        // Path-end anchor: bg-punched dot with an outline ring.
        canvas.drawCircle(Offset(endX, cy), 2.6, Paint()..color = background);
        canvas.drawCircle(
            Offset(endX, cy),
            2.6,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.1);
      case StrokeGlyphKind.joinMiter:
      case StrokeGlyphKind.joinRound:
      case StrokeGlyphKind.joinBevel:
        // Right-angle elbow: real StrokeJoin shapes the outer corner;
        // hairline spine shows the path itself.
        thick
          ..strokeJoin = switch (glyph) {
            StrokeGlyphKind.joinMiter => StrokeJoin.miter,
            StrokeGlyphKind.joinRound => StrokeJoin.round,
            _ => StrokeJoin.bevel,
          }
          ..strokeCap = StrokeCap.butt
          ..strokeMiterLimit = 8;
        final corner = Path()
          ..moveTo(size.width * 0.34, size.height + 2)
          ..lineTo(size.width * 0.34, cy + 1)
          ..lineTo(size.width + 2, cy + 1);
        canvas.drawPath(corner, thick);
        canvas.drawPath(corner, spine);
      case StrokeGlyphKind.alignCenter:
      case StrokeGlyphKind.alignInside:
      case StrokeGlyphKind.alignOutside:
        // Object corner (hairline) + thick stroke on / inside /
        // outside its edges.
        final inset = switch (glyph) {
          StrokeGlyphKind.alignCenter => 0.0,
          StrokeGlyphKind.alignInside => 2.6,
          _ => -2.6,
        };
        final ex = size.width * 0.38; // object corner x
        final ey = size.height * 0.42; // object corner y
        final band = Paint()
          ..color = color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.miter;
        final strokePath = Path()
          ..moveTo(ex + inset, size.height + 2)
          ..lineTo(ex + inset, ey + inset)
          ..lineTo(size.width + 2, ey + inset);
        canvas.drawPath(strokePath, band);
        // Object edge on top so the offset reads clearly.
        final edge = Path()
          ..moveTo(ex, size.height + 2)
          ..lineTo(ex, ey)
          ..lineTo(size.width + 2, ey);
        canvas.drawPath(edge, spine);
      case StrokeGlyphKind.arrowAtEnd:
      case StrokeGlyphKind.arrowWithin:
        // Line with an end tick; the arrowhead either extends past the
        // tick (at end) or stops inside it (within line).
        final tickX = size.width - 9.0;
        canvas.drawLine(Offset(tickX, cy - 7), Offset(tickX, cy + 7), spine);
        final head = Path();
        if (glyph == StrokeGlyphKind.arrowAtEnd) {
          canvas.drawLine(Offset(5, cy), Offset(tickX, cy), spine);
          head
            ..moveTo(size.width - 2, cy)
            ..lineTo(tickX - 1, cy - 4.5)
            ..lineTo(tickX - 1, cy + 4.5)
            ..close();
        } else {
          canvas.drawLine(Offset(5, cy), Offset(tickX - 8, cy), spine);
          head
            ..moveTo(tickX, cy)
            ..lineTo(tickX - 9, cy - 4.5)
            ..lineTo(tickX - 9, cy + 4.5)
            ..close();
        }
        canvas.drawPath(head, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_StrokeGlyphPainter old) =>
      old.glyph != glyph || old.color != color || old.background != background;
}
