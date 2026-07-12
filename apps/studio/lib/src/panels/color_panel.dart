import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import '../workspace_view_model.dart';

/// Parses `#rrggbb` / `#rrggbbaa` into a Color (alpha last).
Color _parseHex(String hex) {
  final h = hex.replaceFirst('#', '');
  if (h.length == 8) {
    final v = int.parse(h, radix: 16);
    return Color(((v & 0xff) << 24) | ((v >> 8) & 0xffffff));
  }
  return Color(0xFF000000 | int.parse(h, radix: 16));
}

// A compact preset palette (Affinity-style). Global/managed palettes are
// future work; this is a sensible starter set.
const _palette = <String>[
  '#000000',
  '#5f5f5f',
  '#c8c8c8',
  '#ffffff',
  '#e53935',
  '#fb8c00',
  '#fdd835',
  '#43a047',
  '#1e88e5',
  '#3949ab',
  '#8e24aa',
  '#d81b60',
];

/// COLOR panel: preset swatches, recent colours, and a transparent
/// option — all applied to whichever chip (fill/stroke) is active.
class ColorPanelContent extends StatelessWidget {
  const ColorPanelContent({super.key, required this.model});
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                model.strokeChipActive
                    ? 'Applies to Stroke'
                    : 'Applies to Fill',
                style: TextStyle(fontSize: 10, color: AppTokens.textMuted)),
            const SizedBox(height: 6),
            _swatchGrid([
              StrokeProps.transparent,
              ..._palette,
            ]),
            if (model.recentColors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Recent',
                  style: TextStyle(fontSize: 10, color: AppTokens.textMuted)),
              const SizedBox(height: 6),
              _swatchGrid(model.recentColors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _swatchGrid(List<String> hexes) => Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final hex in hexes)
            _PaletteSwatch(hex: hex, onTap: () => model.applyActiveColor(hex)),
        ],
      );
}

class _PaletteSwatch extends StatelessWidget {
  const _PaletteSwatch({required this.hex, required this.onTap});
  final String hex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final transparent = hex == StrokeProps.transparent;
    return Tooltip(
      message: transparent ? 'None (transparent)' : hex,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: transparent ? AppTokens.field : _parseHex(hex),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTokens.border),
          ),
          child: transparent
              ? CustomPaint(painter: _SlashPainter(AppTokens.error))
              : null,
        ),
      ),
    );
  }
}

class _SlashPainter extends CustomPainter {
  _SlashPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
        Offset(2, size.height - 2),
        Offset(size.width - 2, 2),
        Paint()
          ..color = color
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_SlashPainter old) => old.color != color;
}

/// Key that reseeds an inline [StudioColorEditor] only when the selection
/// changes (not on the editor's own live edits, which would reset a drag).
Key _editorKey(WorkspaceViewModel model, String tag) =>
    ValueKey('$tag-${model.primarySelection?.id.value ?? 'defaults'}');

/// FILL panel: the full colour editor (wheel + opacity + RGB) bound to the
/// selection's fill (transparent = no fill).
class FillPanelContent extends StatelessWidget {
  const FillPanelContent({super.key, required this.model});
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: StudioColorEditor(
          key: _editorKey(model, 'fill'),
          initialHex: model.activeStroke.fillHex ?? model.fillColorHex,
          onChanged: (hex) => model.setFillColor(hex, mergeKey: 'panel-fill'),
        ),
      ),
    );
  }
}

/// STROKE panel: the full colour editor (transparent = no stroke) plus
/// width and icon-toggle cap / join.
class StrokePanelContent extends StatelessWidget {
  const StrokePanelContent({super.key, required this.model});
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final s = model.activeStroke;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              StudioColorEditor(
                key: _editorKey(model, 'stroke'),
                initialHex: s.colorHex ?? model.strokeColorHex,
                onChanged: (hex) =>
                    model.setStrokeColor(hex, mergeKey: 'panel-stroke'),
              ),
              const SizedBox(height: 12),
              StudioFormRow(
                label: 'Width',
                child: StudioNumberField(
                  value: s.widthMm,
                  min: 0.05,
                  suffix: 'mm',
                  steppers: true,
                  width: 96,
                  onSubmitted: (v) => model.setStroke(
                      (p) => p.copyWith(widthMm: v),
                      mergeKey: 'stroke-w'),
                ),
              ),
              const SizedBox(height: 8),
              StudioFormRow(
                label: 'Cap',
                child: StudioToggleGroup<String>(
                  onToggled: (v) => model.setStroke((p) => p.copyWith(cap: v)),
                  items: [
                    for (final (value, icon, tip) in const [
                      ('butt', Icons.horizontal_rule, 'Butt'),
                      ('round', Icons.circle, 'Round'),
                      ('square', Icons.crop_square, 'Square'),
                    ])
                      StudioToggleItem(
                          value: value,
                          icon: icon,
                          tooltip: tip,
                          active: s.cap == value),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              StudioFormRow(
                label: 'Join',
                child: StudioToggleGroup<String>(
                  onToggled: (v) => model.setStroke((p) => p.copyWith(join: v)),
                  items: [
                    for (final (value, icon, tip) in const [
                      ('miter', Icons.change_history, 'Mitre'),
                      ('round', Icons.rounded_corner, 'Round'),
                      ('bevel', Icons.hexagon_outlined, 'Bevel'),
                    ])
                      StudioToggleItem(
                          value: value,
                          icon: icon,
                          tooltip: tip,
                          active: s.join == value),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
