import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_tools/studio_tools.dart';

import '../../font_library.dart';
import '../../workspace_view_model.dart';
import '../tool_option_fields.dart';
import 'font_family_dropdown.dart';

/// Whether a face style name carries [flag] ('Bold' or 'Italic') —
/// 'Oblique' counts as italic (Helvetica-style naming).
bool styleHasFlag(String style, String flag) => flag == 'Italic'
    ? style.contains('Italic') || style.contains('Oblique')
    : style.contains(flag);

/// The style name after toggling [flag] ('Bold' or 'Italic') on
/// [current], composed Illustrator-style ('Bold Italic', accepting
/// Oblique/Normal naming synonyms); null when the family has no face
/// for the result.
String? toggledStyle(String current, String flag, List<String> available) {
  var bold = styleHasFlag(current, 'Bold');
  var italic = styleHasFlag(current, 'Italic');
  flag == 'Bold' ? bold = !bold : italic = !italic;
  final candidates = switch ((bold, italic)) {
    (false, false) => const ['Regular', 'Normal', 'Roman', 'Plain'],
    (true, false) => const ['Bold'],
    (false, true) => const ['Italic', 'Oblique'],
    (true, true) => const ['Bold Italic', 'Bold Oblique'],
  };
  for (final candidate in candidates) {
    if (available.contains(candidate)) return candidate;
  }
  return null;
}

/// Text tool options-bar content (ToolContribution.optionsBuilder).
List<Widget> textOptions(
  BuildContext context,
  Tool tool,
  VoidCallback onChanged,
  WorkspaceViewModel? model,
) {
  final text = tool as TextTool;
  // stylesFor is authoritative only after the system scan — kick it and
  // rebuild the bar when it lands (idempotent; scan result is cached).
  if (!FontLibrary.instance.scanned) {
    FontLibrary.instance.families().then((_) => onChanged());
  }
  final attrs = model?.characterAttrs;
  final shared = attrs?.shared;
  final family = shared?.fontFamily ??
      model?.characterTarget?.fontFamily ??
      text.font.family;
  final styles = FontLibrary.instance.stylesFor(family);
  final style = shared?.styleName ?? styles.first;
  final deco = shared?.decorations ?? const TextDecorations();

  void apply(CharAttrs patch) {
    model?.applyCharAttrs(patch);
    onChanged();
  }

  // Style/decoration edits need a text target (editing or selection).
  final canStyle = attrs != null;

  Widget styleToggle(String flag, IconData icon) {
    final next = canStyle ? toggledStyle(style, flag, styles) : null;
    return StudioIconButton(
      icon: icon,
      tooltip: next == null && canStyle
          ? '$flag — no $flag face installed for $family'
          : flag,
      active: canStyle && styleHasFlag(style, flag),
      onPressed:
          next == null ? null : () => apply(CharAttrs(styleName: next)),
    );
  }

  Widget decoToggle(TextDecorationLine line, IconData icon, String label) =>
      StudioIconButton(
        icon: icon,
        tooltip: label,
        active: canStyle && deco.has(line),
        onPressed: canStyle
            ? () => apply(CharAttrs(decorations: deco.toggle(line)))
            : null,
      );

  return [
    // Font family (system fonts, scanned once) + face style.
    Row(mainAxisSize: MainAxisSize.min, children: [
      FontFamilyDropdown(
        // Reflects the selection's family (same source and widget as
        // the Character panel — searchable, WYSIWYG previews).
        value: family,
        width: 160,
        onChanged: (picked) async {
          text.font = await FontLibrary.instance.load(picked);
          // Apply to the targeted text too — the toolbar and the
          // Character panel edit the same document state.
          model?.applyCharAttrs(CharAttrs(fontFamily: picked));
          onChanged();
        },
      ),
      const SizedBox(width: 6),
      StudioDropdown<String>(
        value: styles.contains(style) ? style : styles.first,
        width: 96,
        items: [for (final s in styles) (s, s)],
        onChanged:
            canStyle ? (s) => apply(CharAttrs(styleName: s)) : (_) {},
      ),
    ]),
    // Typography numbers.
    Row(mainAxisSize: MainAxisSize.min, children: [
      optionNumberField('Size', text.sizeMm, suffix: 'mm', min: 1, (v) {
        text.sizeMm = v;
        onChanged();
      }),
      const SizedBox(width: 8),
      optionNumberField('Tracking', text.trackingMm, suffix: 'mm', min: -5,
          (v) {
        text.trackingMm = v;
        onChanged();
      }),
      const SizedBox(width: 8),
      optionNumberField('Leading ×', text.lineHeight, min: 0.5, max: 4, (v) {
        text.lineHeight = v;
        onChanged();
      }),
    ]),
    // Paragraph alignment (justify pads word gaps in area text; point
    // text and the last paragraph line stay left).
    Row(mainAxisSize: MainAxisSize.min, children: [
      for (final (align, icon, label) in [
        (MonoTextAlign.left, TablerIcons.align_left, 'Align Left'),
        (MonoTextAlign.center, TablerIcons.align_center, 'Align Center'),
        (MonoTextAlign.right, TablerIcons.align_right, 'Align Right'),
        (MonoTextAlign.justify, TablerIcons.align_justified, 'Justify'),
      ])
        StudioIconButton(
          icon: icon,
          tooltip: label,
          active: text.align == align,
          onPressed: () {
            if (model != null) {
              model.setTextAlignment(align);
            } else {
              text.align = align;
            }
            onChanged();
          },
        ),
    ]),
    // Face styles, decorations, and per-range text color.
    Row(mainAxisSize: MainAxisSize.min, children: [
      styleToggle('Bold', TablerIcons.bold),
      styleToggle('Italic', TablerIcons.italic),
      decoToggle(
          TextDecorationLine.underline, TablerIcons.underline, 'Underline'),
      decoToggle(TextDecorationLine.strikethrough, TablerIcons.strikethrough,
          'Strikethrough'),
      StudioIconButton(
        icon: TablerIcons.palette,
        tooltip: 'Text color',
        onPressed: canStyle
            ? () async {
                final picked = await showStudioColorPicker(
                    context: context,
                    initialHex:
                        shared?.fillHex ?? model?.fillColorHex ?? '#000000');
                if (picked != null) apply(CharAttrs(fillHex: picked));
              }
            : null,
      ),
    ]),
  ];
}
