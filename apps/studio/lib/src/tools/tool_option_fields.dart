import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import '../stroke_style.dart';
import '../workspace_view_model.dart';

/// Shared building blocks for tool options bars (ADR-044): per-tool
/// option builders live in their tool's folder and compose these.

/// Compact labeled number field with − / + steppers.
Widget optionNumberField(
  String label,
  double value,
  void Function(double) submit, {
  String? suffix,
  double min = 0,
  double? max,
  bool integer = false,
}) {
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Text('$label ', style: TextStyle(color: AppTokens.textMuted, fontSize: 11)),
    StudioNumberField(
      value: value,
      min: min,
      max: max,
      integer: integer,
      decimals: 1,
      suffix: suffix,
      steppers: true,
      // Wide enough that a 3-digit value + suffix + steppers never
      // clips the digits.
      width: suffix == null ? 100 : 124,
      textAlign: TextAlign.center,
      onSubmitted: submit,
    ),
  ]);
}

/// Fill/stroke controls shared by drawing-tool bars (Affinity-style):
/// fill + stroke color chips, stroke width, stroke settings dialog.
List<Widget> fillStrokeOptions(
  BuildContext context,
  WorkspaceViewModel? model,
  VoidCallback onChanged,
) {
  final m = model;
  if (m == null) return const [];
  return [
    Row(mainAxisSize: MainAxisSize.min, children: [
      _colorChip(
        context,
        tooltip: 'Fill color',
        // Summary of the selection's style, else the defaults.
        hex: m.activeStroke.fillHex ?? m.fillColorHex,
        filled: true,
        onPicked: m.setFillColor,
        onChanged: onChanged,
      ),
      const SizedBox(width: 6),
      _colorChip(
        context,
        tooltip: 'Stroke color',
        hex: m.activeStroke.colorHex ?? m.strokeColorHex,
        filled: false,
        onPicked: m.setStrokeColor,
        onChanged: onChanged,
      ),
    ]),
    Row(mainAxisSize: MainAxisSize.min, children: [
      optionNumberField('Width', m.strokeStyle.widthMm, suffix: 'mm', min: 0.05,
          (v) {
        m.strokeStyle.widthMm = v;
        onChanged();
      }),
      const SizedBox(width: 8),
      StudioButton(
        label: 'Stroke…',
        onPressed: () => showStrokeDialog(context, m),
      ),
    ]),
  ];
}

/// Parses `#rrggbb` / `#rrggbbaa`; null for transparent (alpha 00).
Color? _chipColor(String hex) {
  if (isTransparent(hex)) return null;
  final h = hex.replaceFirst('#', '');
  if (h.length == 8) {
    final v = int.parse(h, radix: 16); // rrggbbaa
    return Color(((v & 0xff) << 24) | ((v >> 8) & 0xffffff));
  }
  return Color(0xFF000000 | int.parse(h, radix: 16));
}

Widget _colorChip(
  BuildContext context, {
  required String tooltip,
  required String hex,
  required bool filled,
  required void Function(String hex) onPicked,
  required VoidCallback onChanged,
}) {
  // null when transparent (alpha 00) — chip shows empty/none.
  final color = _chipColor(hex);
  return Tooltip(
    message: tooltip,
    waitDuration: const Duration(milliseconds: 400),
    child: InkWell(
      onTap: () async {
        final picked =
            await showStudioColorPicker(context: context, initialHex: hex);
        if (picked != null) {
          onPicked(picked);
          onChanged();
        }
      },
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: filled ? color : null,
          border: Border.all(color: AppTokens.border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: filled
            ? null
            : Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: color ?? AppTokens.textMuted, width: 3),
                  ),
                ),
              ),
      ),
    ),
  );
}
