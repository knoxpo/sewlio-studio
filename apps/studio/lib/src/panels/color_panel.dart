import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import '../workspace_view_model.dart';

/// Design-mode fill/stroke colour controls (Illustrator/Affinity-style),
/// available as a docked panel. Reads the active stroke (selection or
/// defaults) and dispatches through the view model's colour methods.
class ColorFillStrokePanelContent extends StatelessWidget {
  const ColorFillStrokePanelContent({super.key, required this.model});

  final WorkspaceViewModel model;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final stroke = model.activeStroke;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StudioFormRow(
                label: 'Fill',
                child: Row(children: [
                  StudioColorSwatch(
                    key: const Key('color-fill-swatch'),
                    color: stroke.fillHex ?? model.fillColorHex,
                    onChanged: model.setFillColor,
                  ),
                  const SizedBox(width: 8),
                  StudioSwitch(
                    value: stroke.fillHex != null,
                    onChanged: model.setUseFill,
                  ),
                ]),
              ),
              const SizedBox(height: 6),
              StudioFormRow(
                label: 'Stroke',
                child: StudioColorSwatch(
                  key: const Key('color-stroke-swatch'),
                  color: stroke.colorHex ?? model.strokeColorHex,
                  onChanged: model.setStrokeColor,
                ),
              ),
              const SizedBox(height: 6),
              StudioFormRow(
                label: 'Width',
                child: StudioNumberField(
                  value: stroke.widthMm,
                  min: 0.05,
                  suffix: 'mm',
                  steppers: true,
                  width: 96,
                  onSubmitted: (v) =>
                      model.setStroke((p) => p.copyWith(widthMm: v)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
