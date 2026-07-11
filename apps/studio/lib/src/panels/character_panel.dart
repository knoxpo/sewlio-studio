import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_tools/studio_tools.dart';

import '../font_library.dart';
import '../workspace_view_model.dart';

/// Professional character/typography panel (Affinity-Designer-style):
/// compact icon-labeled rows, dense collapsible sections. It is a pure
/// derived view — it reads the target text object's merged range
/// attributes from the view model and dispatches edits back through
/// [WorkspaceViewModel.applyCharAttrs] / character-style commands, and
/// the document-wide optical table through [SetOpticalRules]. No domain
/// logic lives here; unsupported controls are visibly disabled with an
/// explanatory tooltip rather than silently doing nothing.
class CharacterPanel extends StatefulWidget {
  const CharacterPanel({super.key, required this.model});

  final WorkspaceViewModel model;

  @override
  State<CharacterPanel> createState() => _CharacterPanelState();
}

class _CharacterPanelState extends State<CharacterPanel> {
  // Per-section open/closed state (Core is always visible).
  final _expanded = <String, bool>{
    'decorations': true,
    'transform': true,
    'language': false,
    'optical': false,
    'typography': false,
  };

  // Guards against re-triggering a font load every rebuild while one is
  // already in flight for the current family.
  String? _loadingFamily;

  WorkspaceViewModel get _model => widget.model;

  // ponytail: the icon registry has no typographic marks (VA, baseline,
  // scale arrows…), so the transform-grid "icons" are styled text glyphs.
  // Ceiling: swap for real SVG glyph icons when the registry gains them.
  TextStyle get _glyph => TextStyle(fontSize: 13, color: AppTokens.textMuted);

  void _apply(CharAttrs patch, {String? mergeKey}) {
    // Fire-and-forget: applyCharAttrs is async (regenerates outlines) and
    // emits its own document event, which rebuilds the panel.
    _model.applyCharAttrs(patch, mergeKey: mergeKey);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final target = _model.characterTarget;
        if (target == null) return _empty();

        final query = _model.characterAttrs;
        final shared = query?.shared ?? CharAttrs.empty;
        final mixed = query?.mixed ?? const <String>{};
        final font = _model.characterFont;

        // Font not cached yet (a system TrueType face): kick off a load
        // and rebuild once its capabilities are available. Monoline is
        // always cached, so this only runs for real installed fonts.
        if (font == null && _loadingFamily != target.fontFamily) {
          _loadingFamily = target.fontFamily;
          FontLibrary.instance.load(target.fontFamily).then((_) {
            if (mounted) setState(() {});
          });
        }

        return ListView(
          key: const Key('character-panel'),
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          children: [
            _core(target, shared, mixed, font),
            _section('decorations', 'Decorations', _decorations(shared, mixed)),
            _section(
                'transform', 'Position & Transform', _transform(shared, mixed)),
            _section('language', 'Language', _language(shared)),
            _section('optical', 'Optical Alignment', _optical()),
            _section('typography', 'Typography', _typography(shared, font)),
          ],
        );
      },
    );
  }

  Widget _empty() => Center(
        key: const Key('character-empty'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.text_fields_outlined,
                  size: 20, color: AppTokens.textMuted),
              const SizedBox(height: 8),
              Text('No text selected',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppTokens.textMuted)),
              const SizedBox(height: 2),
              Text('Select or edit a text object to format it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: AppTokens.textMuted)),
            ],
          ),
        ),
      );

  // ------------------------------------------------------------ scaffolding

  Widget _section(String id, String title, Widget child) =>
      StudioCollapsibleSection(
        title: title,
        expanded: _expanded[id],
        onExpandedChanged: (v) => setState(() => _expanded[id] = v),
        child: child,
      );

  /// Disable-in-place: render a real control non-interactive under an
  /// explanatory tooltip so the workflow reads as real but nothing lies.
  Widget _disabled(String tooltip, Widget child) => Tooltip(
        message: tooltip,
        child: Opacity(
          opacity: 0.5,
          child: IgnorePointer(child: child),
        ),
      );

  // ------------------------------------------------------------------ core

  Widget _core(
      TextObject target, CharAttrs shared, Set<String> mixed, TextFont? font) {
    final styleNames = font?.styleNames ?? const ['Regular'];
    final styles = _model.session.document.characterStyles;
    final hasStyle = shared.styleId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        // Row A — font-collection filter (one option today) + family.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: StudioDropdown<String>(
                value: 'all',
                width: double.infinity,
                items: const [('all', 'All Fonts')],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: FutureBuilder<List<String>>(
                future: FontLibrary.instance.families(),
                builder: (context, snapshot) {
                  final families =
                      snapshot.data ?? const [FontLibrary.builtinFamily];
                  final value = shared.fontFamily ?? target.fontFamily;
                  return StudioSearchableDropdown<String>(
                    key: const Key('char-font-family'),
                    value: families.contains(value) ? value : null,
                    hint: mixed.contains('fontFamily') ? 'Mixed' : value,
                    width: double.infinity,
                    items: [for (final f in families) (f, f)],
                    onChanged: (f) => _apply(CharAttrs(fontFamily: f)),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Row B — size, style, fill + stroke swatches, densely packed.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 92,
              child: StudioNumberField(
                key: const Key('char-field-sizeMm'),
                value: shared.sizeMm ?? target.sizeMm,
                defaultValue: target.sizeMm,
                mixed: mixed.contains('sizeMm'),
                min: 0.5,
                decimals: 1,
                // ponytail: the document stores millimetres — showing 'pt'
                // over a mm value would lie. Kept honest as 'mm'.
                suffix: 'mm',
                steppers: true,
                onSubmitted: (v) =>
                    _apply(CharAttrs(sizeMm: v), mergeKey: 'char-sizeMm'),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 92,
              child: StudioDropdown<String>(
                key: const Key('char-font-style'),
                value: shared.styleName ?? styleNames.first,
                hint: mixed.contains('styleName') ? 'Mixed' : null,
                width: double.infinity,
                items: [for (final s in styleNames) (s, s)],
                onChanged: (s) => _apply(CharAttrs(styleName: s)),
              ),
            ),
            const Spacer(),
            StudioColorSwatch(
              size: 20,
              color: mixed.contains('fillHex') ? null : shared.fillHex,
              onChanged: (hex) => _apply(CharAttrs(fillHex: hex)),
            ),
            const SizedBox(width: 4),
            StudioColorSwatch(
              size: 20,
              color: mixed.contains('strokeHex') ? null : shared.strokeHex,
              onChanged: (hex) => _apply(CharAttrs(strokeHex: hex)),
            ),
          ],
        ),
        const Divider(height: 18),
        // Row C — character style: full-width dropdown + compact actions.
        StudioDropdown<String>(
          key: const Key('char-style-select'),
          value: shared.styleId,
          hint: 'No Style',
          width: double.infinity,
          items: [for (final s in styles) (s.id, s.name)],
          onChanged: (id) => _apply(CharAttrs(styleId: id)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Wrap(
            spacing: 2,
            runSpacing: 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StudioIconButton(
                icon: Icons.add,
                size: 16,
                tooltip: 'Create character style from selection',
                onPressed: () => _createStyle(shared),
              ),
              StudioIconButton(
                icon: Icons.sync,
                size: 16,
                tooltip: 'Redefine selected style from this text',
                onPressed: hasStyle
                    ? () => _model.execute(UpdateCharacterStyle(
                        shared.styleId!, shared.copyWith(clearStyleId: true)))
                    : null,
              ),
              StudioIconButton(
                icon: Icons.content_copy,
                size: 16,
                tooltip: 'Duplicate style',
                onPressed: hasStyle
                    ? () => _model.execute(
                        DuplicateCharacterStyle(shared.styleId!, _newStyleId()))
                    : null,
              ),
              StudioIconButton(
                icon: Icons.delete_outline,
                size: 16,
                tooltip: 'Delete style',
                onPressed: hasStyle
                    ? () =>
                        _model.execute(DeleteCharacterStyle(shared.styleId!))
                    : null,
              ),
              const StudioIconButton(
                icon: Icons.link_off,
                size: 16,
                tooltip: 'Detach style / clear override — '
                    'requires the clear-override command (planned)',
              ),
              // Overrides only mean something relative to a referenced
              // style, so the indicator stays hidden until one is applied.
              if (hasStyle && shared.hasOverrides)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text('Overrides',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTokens.accentGreen)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _newStyleId() => 'cs-${DateTime.now().microsecondsSinceEpoch}';

  void _createStyle(CharAttrs shared) {
    final styles = _model.session.document.characterStyles;
    _model.execute(AddCharacterStyle(CharacterStyle(
      _newStyleId(),
      'Character Style ${styles.length + 1}',
      shared.copyWith(clearStyleId: true),
    )));
  }

  // ----------------------------------------------------------- decorations

  // Two segmented groups: line decorations then strike decorations.
  static const _underlines = <(TextDecorationLine, IconData, String)>[
    (TextDecorationLine.underline, Icons.format_underlined, 'Underline'),
    (
      TextDecorationLine.doubleUnderline,
      Icons.border_bottom,
      'Double underline'
    ),
    (TextDecorationLine.overline, Icons.border_top, 'Overline'),
  ];

  static const _strikes = <(TextDecorationLine, IconData, String)>[
    (TextDecorationLine.strikethrough, Icons.strikethrough_s, 'Strikethrough'),
    (
      TextDecorationLine.doubleStrikethrough,
      Icons.horizontal_rule,
      'Double strikethrough'
    ),
  ];

  Widget _decorations(CharAttrs shared, Set<String> mixed) {
    final isMixed = mixed.contains('decorations');
    final deco = shared.decorations ?? const TextDecorations();
    TextDecorations base() => shared.decorations ?? const TextDecorations();

    StudioToggleGroup<TextDecorationLine> group(
            List<(TextDecorationLine, IconData, String)> lines) =>
        StudioToggleGroup<TextDecorationLine>(
          items: [
            for (final (line, icon, tip) in lines)
              StudioToggleItem(
                value: line,
                icon: icon,
                tooltip: tip,
                active: isMixed ? null : deco.has(line),
              ),
          ],
          onToggled: (line) =>
              _apply(CharAttrs(decorations: base().toggle(line))),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          group(_underlines),
          const SizedBox(width: 8),
          group(_strikes),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: StudioDropdown<TextDecorationStyle>(
              value: deco.style,
              width: double.infinity,
              items: const [
                (TextDecorationStyle.solid, 'Solid'),
                (TextDecorationStyle.dashed, 'Dashed'),
                (TextDecorationStyle.dotted, 'Dotted'),
                (TextDecorationStyle.wavy, 'Wavy'),
              ],
              onChanged: (s) =>
                  _apply(CharAttrs(decorations: base().copyWith(style: s))),
            ),
          ),
          const SizedBox(width: 6),
          StudioColorSwatch(
            size: 20,
            color: deco.colorHex,
            onChanged: (hex) =>
                _apply(CharAttrs(decorations: base().copyWith(colorHex: hex))),
          ),
        ]),
      ],
    );
  }

  // ------------------------------------------------------- position/transform

  Widget _transform(CharAttrs shared, Set<String> mixed) {
    // Left column pairs with right column, cell for cell.
    final left = <Widget>[
      _disabledCell('V/A', 'Auto', 'Kerning needs the shaping engine'),
      _numCell('VA', _specs['trackingMm']!, shared, mixed),
      _numCell('A↓', _specs['baselineShiftMm']!, shared, mixed),
      _disabledCell('≡', 'Auto', 'Leading is set in the Paragraph panel'),
    ];
    final right = <Widget>[
      _numCell('A∠', _specs['skewDeg']!, shared, mixed),
      _numCell('↔', _specs['hScale']!, shared, mixed),
      _numCell('↕', _specs['vScale']!, shared, mixed),
      _numCell('A°', _specs['rotationDeg']!, shared, mixed),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < left.length; i++)
          Row(children: [
            Expanded(child: left[i]),
            const SizedBox(width: 8),
            Expanded(child: right[i]),
          ]),
        const SizedBox(height: 4),
        StudioSwitch(
          label: 'No break',
          value: shared.noBreak ?? false,
          onChanged: (v) => _apply(CharAttrs(noBreak: v)),
        ),
      ],
    );
  }

  /// One transform grid cell: a compact leading glyph-label + control.
  Widget _cell(String glyph, Widget field) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 26, child: Text(glyph, style: _glyph)),
            Expanded(child: field),
          ],
        ),
      );

  Widget _numCell(
          String glyph, _NumSpec spec, CharAttrs shared, Set<String> mixed) =>
      _cell(
        glyph,
        StudioNumberField(
          key: Key('char-field-${spec.key}'),
          value: (spec.get(shared) ?? spec.rawDefault) * spec.mul,
          defaultValue: spec.rawDefault * spec.mul,
          mixed: mixed.contains(spec.key),
          min: spec.min,
          decimals: 1,
          suffix: spec.suffix,
          steppers: true,
          onSubmitted: (v) =>
              _apply(spec.patch(v / spec.mul), mergeKey: 'char-${spec.key}'),
        ),
      );

  Widget _disabledCell(String glyph, String value, String tooltip) => _cell(
        glyph,
        _disabled(
          tooltip,
          StudioTextField(initialValue: value, enabled: false),
        ),
      );

  // Schema-driven transform fields keyed for the grid above. hScale/vScale
  // store a fraction but show a percentage, so they carry a ×100 display
  // multiplier (written back /100).
  static final _specs = <String, _NumSpec>{
    'trackingMm': _NumSpec('trackingMm', 'mm', (a) => a.trackingMm,
        (v) => CharAttrs(trackingMm: v)),
    'baselineShiftMm': _NumSpec('baselineShiftMm', 'mm',
        (a) => a.baselineShiftMm, (v) => CharAttrs(baselineShiftMm: v)),
    'hScale': _NumSpec(
        'hScale', '%', (a) => a.hScale, (v) => CharAttrs(hScale: v),
        mul: 100, rawDefault: 1, min: 1),
    'vScale': _NumSpec(
        'vScale', '%', (a) => a.vScale, (v) => CharAttrs(vScale: v),
        mul: 100, rawDefault: 1, min: 1),
    'skewDeg': _NumSpec(
        'skewDeg', '°', (a) => a.skewDeg, (v) => CharAttrs(skewDeg: v)),
    'rotationDeg': _NumSpec('rotationDeg', '°', (a) => a.rotationDeg,
        (v) => CharAttrs(rotationDeg: v)),
  };

  // --------------------------------------------------------------- language

  static const _languages = <(String, String)>[
    ('en-US', 'English (US)'),
    ('en-GB', 'English (UK)'),
    ('en-IN', 'English (India)'),
    ('de-DE', 'German'),
    ('fr-FR', 'French'),
    ('es-ES', 'Spanish'),
    ('it-IT', 'Italian'),
    ('hi-IN', 'Hindi'),
  ];

  static const _scripts = <(String, String)>[
    ('latn', 'Latin'),
    ('cyrl', 'Cyrillic'),
    ('grek', 'Greek'),
    ('arab', 'Arabic'),
    ('deva', 'Devanagari'),
  ];

  Widget _language(CharAttrs shared) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioFormRow(
          label: 'Spelling',
          child: StudioDropdown<String>(
            value: shared.language,
            hint: 'Auto',
            items: _languages,
            onChanged: (v) => _apply(CharAttrs(language: v)),
          ),
        ),
        StudioFormRow(
          label: 'Hyphenation',
          child: _disabled(
            'Hyphenation — requires the line-break engine (planned)',
            StudioDropdown<String>(
              value: 'auto',
              items: const [('auto', 'Auto')],
              onChanged: (_) {},
            ),
          ),
        ),
        StudioFormRow(
          label: 'Typography script',
          child: StudioDropdown<String>(
            value: shared.script,
            hint: 'Auto',
            items: _scripts,
            onChanged: (v) => _apply(CharAttrs(script: v)),
          ),
        ),
        StudioFormRow(
          label: 'Typography language',
          child: _disabled(
            'Typography language — requires the shaping engine (planned)',
            StudioDropdown<String>(
              value: 'auto',
              items: const [('auto', 'Auto')],
              onChanged: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------- optical alignment

  Widget _optical() {
    final doc = _model.session.document;
    // Show the seed table when the document has no explicit rules yet; the
    // first edit persists the full list through SetOpticalRules.
    final rules =
        doc.opticalRules.isEmpty ? OpticalRule.defaults : doc.opticalRules;

    void set(List<OpticalRule> next) => _model.execute(SetOpticalRules(next));

    List<OpticalRule> replace(int i, OpticalRule rule) {
      final next = [...rules];
      next[i] = rule;
      return next;
    }

    Widget header(String text, [int flex = 1]) => Expanded(
          flex: flex,
          child: Text(text,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.textMuted)),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Type (per-object) is honest-disabled — no apply field yet — while
        // Add operates on the shared preset table below.
        Row(children: [
          Expanded(
            child: _disabled(
              'Per-object optical alignment arrives with the optical engine',
              StudioDropdown<String>(
                value: 'none',
                width: double.infinity,
                items: const [('none', 'None'), ('optical', 'Optical')],
                onChanged: (_) {},
              ),
            ),
          ),
          const SizedBox(width: 6),
          StudioButton(
            key: const Key('char-optical-add'),
            label: 'Add',
            icon: Icons.add,
            onPressed: () => set([
              ...rules,
              const OpticalRule(leftPct: 0, rightPct: 0, chars: '')
            ]),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          header('Left'),
          const SizedBox(width: 4),
          header('Right'),
          const SizedBox(width: 4),
          header('Characters', 2),
          const SizedBox(width: 24),
        ]),
        const Divider(height: 10),
        for (final (i, rule) in rules.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: StudioNumberField(
                    key: Key('char-optical-left-$i'),
                    value: rule.leftPct,
                    min: 0,
                    max: 100,
                    decimals: 0,
                    suffix: '%',
                    steppers: true,
                    onSubmitted: (v) =>
                        set(replace(i, rule.copyWith(leftPct: v))),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: StudioNumberField(
                    key: Key('char-optical-right-$i'),
                    value: rule.rightPct,
                    min: 0,
                    max: 100,
                    decimals: 0,
                    suffix: '%',
                    steppers: true,
                    onSubmitted: (v) =>
                        set(replace(i, rule.copyWith(rightPct: v))),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: StudioTextField(
                    key: Key('char-optical-chars-$i'),
                    initialValue: rule.chars,
                    onSubmitted: (s) =>
                        set(replace(i, rule.copyWith(chars: s))),
                  ),
                ),
                StudioIconButton(
                  key: Key('char-optical-del-$i'),
                  icon: Icons.close,
                  size: 16,
                  tooltip: 'Remove rule',
                  onPressed: () => set([...rules]..removeAt(i)),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text('Applied at export — preview pending.',
            style: TextStyle(fontSize: 10, color: AppTokens.textMuted)),
      ],
    );
  }

  // ------------------------------------------------------------- typography

  // Common OpenType features (all disabled until a shaping engine ships;
  // enable per font via supportsFeature). Kept short and recognizable.
  static const _otFeatures = <String>[
    'liga',
    'dlig',
    'calt',
    'salt',
    'smcp',
    'c2sc',
    'frac',
    'ordn',
    'sups',
    'subs',
    'onum',
    'lnum',
    'tnum',
    'pnum',
    'zero',
    'swsh',
    'titl',
    'hist',
  ];

  Widget _typography(CharAttrs shared, TextFont? font) {
    final axes = font?.variationAxes() ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final tag in _otFeatures)
              _otChip(tag, shared, font?.supportsFeature(tag) ?? false),
          ],
        ),
        if (font == null || font.availableFeatures().isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'This font exposes no OpenType features. '
              'Feature application needs the shaping engine.',
              style: TextStyle(fontSize: 10, color: AppTokens.textMuted),
            ),
          ),
        if (axes.isNotEmpty) ...[
          const SizedBox(height: 10),
          StudioSectionLabel('Variable Axes', first: true),
          for (final axis in axes)
            StudioFormRow(
              label: axis.tag,
              child: StudioSlider(
                min: axis.min,
                max: axis.max,
                value: (shared.variableAxes[axis.tag] ?? axis.def)
                    .clamp(axis.min, axis.max),
                onChanged: (v) =>
                    _apply(CharAttrs(variableAxes: {axis.tag: v})),
              ),
            ),
        ],
      ],
    );
  }

  Widget _otChip(String tag, CharAttrs shared, bool supported) {
    final on = (shared.openTypeFeatures[tag] ?? 0) == 1;
    return Tooltip(
      message: supported
          ? 'OpenType: $tag'
          : 'Not supported by this font (requires shaping engine)',
      child: StudioButton(
        key: Key('char-otf-$tag'),
        label: tag,
        variant:
            on ? StudioButtonVariant.primary : StudioButtonVariant.secondary,
        onPressed: supported
            ? () => _apply(CharAttrs(openTypeFeatures: {tag: on ? 0 : 1}))
            : null,
      ),
    );
  }
}

/// One schema-driven numeric transform field: the field key used for
/// mixed-state lookup and scrub merge, unit suffix, a display multiplier
/// ([mul]) for fraction→percent fields, the raw (stored) default, a min
/// clamp, and the getter/patch that bind it to [CharAttrs].
class _NumSpec {
  const _NumSpec(this.key, this.suffix, this.get, this.patch,
      {this.mul = 1, this.rawDefault = 0, this.min = double.negativeInfinity});

  final String key;
  final String suffix;
  final double mul;
  final double rawDefault;
  final double min;
  final double? Function(CharAttrs) get;
  final CharAttrs Function(double) patch;
}
