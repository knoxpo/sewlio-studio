import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_embroidery/studio_embroidery.dart';

import '../workspace_view_model.dart';

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
            color: transparent
                ? AppTokens.field
                : Color(0xFF000000 | int.parse(hex.substring(1), radix: 16)),
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

/// FILL panel: the selection's fill colour (transparent = no fill).
class FillPanelContent extends StatelessWidget {
  const FillPanelContent({super.key, required this.model});
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final fill = model.activeStroke.fillHex ?? model.fillColorHex;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: StudioFormRow(
            label: 'Fill',
            child: Row(children: [
              StudioColorSwatch(
                key: const Key('color-fill-swatch'),
                color: model.activeStroke.fillHex,
                onChanged: model.setFillColor,
              ),
              const SizedBox(width: 8),
              Text(fill == StrokeProps.transparent ? 'None' : fill,
                  style: TextStyle(fontSize: 11, color: AppTokens.textMuted)),
            ]),
          ),
        );
      },
    );
  }
}

/// STROKE panel: colour (transparent = no stroke), width, cap, join.
class StrokePanelContent extends StatelessWidget {
  const StrokePanelContent({super.key, required this.model});
  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final s = model.activeStroke;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              StudioFormRow(
                label: 'Stroke',
                child: StudioColorSwatch(
                  key: const Key('color-stroke-swatch'),
                  color: s.colorHex,
                  onChanged: model.setStrokeColor,
                ),
              ),
              const SizedBox(height: 6),
              StudioFormRow(
                label: 'Width',
                child: StudioNumberField(
                  value: s.widthMm,
                  min: 0.05,
                  suffix: 'mm',
                  steppers: true,
                  width: 96,
                  onSubmitted: (v) =>
                      model.setStroke((p) => p.copyWith(widthMm: v)),
                ),
              ),
              const SizedBox(height: 6),
              StudioFormRow(
                label: 'Cap',
                child: StudioDropdown<String>(
                  value: s.cap,
                  width: 96,
                  items: const [
                    ('butt', 'Butt'),
                    ('round', 'Round'),
                    ('square', 'Square'),
                  ],
                  onChanged: (v) => model.setStroke((p) => p.copyWith(cap: v)),
                ),
              ),
              const SizedBox(height: 6),
              StudioFormRow(
                label: 'Join',
                child: StudioDropdown<String>(
                  value: s.join,
                  width: 96,
                  items: const [
                    ('miter', 'Mitre'),
                    ('round', 'Round'),
                    ('bevel', 'Bevel'),
                  ],
                  onChanged: (v) => model.setStroke((p) => p.copyWith(join: v)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
