/// Rich-text style model (ADR-040): character-range attributes, style
/// runs, and reusable character styles. Pure value types — headless and
/// deterministic. The [TextObject]'s scalar fields remain the
/// object-level defaults; runs override them per character range.
library;

/// A text decoration line. Underline/strikethrough double variants are
/// distinct entries so a run can carry, e.g., both an overline and a
/// double strikethrough.
enum TextDecorationLine {
  underline,
  doubleUnderline,
  overline,
  strikethrough,
  doubleStrikethrough,
}

/// How a decoration line is drawn.
enum TextDecorationStyle { solid, dashed, dotted, wavy }

/// Sentinel returned by [StyleRun] range queries when the runs spanning
/// a selection disagree on a field. The panel renders this as a blank
/// field with a "mixed" indicator and must not overwrite the underlying
/// runs until the user explicitly sets a value.
const Object mixedValue = _Mixed();

class _Mixed {
  const _Mixed();
  @override
  String toString() => 'Mixed';
}

/// Immutable set of decoration attributes for a run. Empty [lines] means
/// no decoration.
final class TextDecorations {
  const TextDecorations({
    this.lines = const {},
    this.style = TextDecorationStyle.solid,
    this.colorHex,
    this.offsetMm,
    this.thicknessMm,
  });

  final Set<TextDecorationLine> lines;
  final TextDecorationStyle style;

  /// `#rrggbb`; null = follow the run/object fill color.
  final String? colorHex;

  /// Baseline offset in mm; null = font-derived default.
  final double? offsetMm;

  /// Line thickness in mm; null = font-derived default.
  final double? thicknessMm;

  bool get isEmpty => lines.isEmpty;

  bool has(TextDecorationLine line) => lines.contains(line);

  TextDecorations toggle(TextDecorationLine line) => TextDecorations(
        lines: {
          for (final l in lines)
            if (l != line) l,
          if (!lines.contains(line)) line,
        },
        style: style,
        colorHex: colorHex,
        offsetMm: offsetMm,
        thicknessMm: thicknessMm,
      );

  TextDecorations copyWith({
    Set<TextDecorationLine>? lines,
    TextDecorationStyle? style,
    String? colorHex,
    double? offsetMm,
    double? thicknessMm,
  }) =>
      TextDecorations(
        lines: lines ?? this.lines,
        style: style ?? this.style,
        colorHex: colorHex ?? this.colorHex,
        offsetMm: offsetMm ?? this.offsetMm,
        thicknessMm: thicknessMm ?? this.thicknessMm,
      );

  Map<String, dynamic> toJson() => {
        'lines': [for (final l in lines) l.name],
        if (style != TextDecorationStyle.solid) 'style': style.name,
        if (colorHex != null) 'colorHex': colorHex,
        if (offsetMm != null) 'offsetMm': offsetMm,
        if (thicknessMm != null) 'thicknessMm': thicknessMm,
      };

  factory TextDecorations.fromJson(Map<String, dynamic> json) =>
      TextDecorations(
        lines: {
          for (final l in (json['lines'] as List? ?? const []))
            TextDecorationLine.values.byName(l as String),
        },
        style: json['style'] == null
            ? TextDecorationStyle.solid
            : TextDecorationStyle.values.byName(json['style'] as String),
        colorHex: json['colorHex'] as String?,
        offsetMm: (json['offsetMm'] as num?)?.toDouble(),
        thicknessMm: (json['thicknessMm'] as num?)?.toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      other is TextDecorations &&
      _setEq(other.lines, lines) &&
      other.style == style &&
      other.colorHex == colorHex &&
      other.offsetMm == offsetMm &&
      other.thicknessMm == thicknessMm;

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(lines),
        style,
        colorHex,
        offsetMm,
        thicknessMm,
      );
}

/// Per-range typography attributes (ADR-040). Every field is optional:
/// `null`/empty means "inherit the object (or referenced character
/// style) default". This nullability drives mixed-value display and
/// style-override detection.
final class CharAttrs {
  const CharAttrs({
    this.fontFamily,
    this.styleName,
    this.sizeMm,
    this.fillHex,
    this.strokeHex,
    this.trackingMm,
    this.baselineShiftMm,
    this.hScale,
    this.vScale,
    this.skewDeg,
    this.rotationDeg,
    this.decorations,
    this.openTypeFeatures = const {},
    this.variableAxes = const {},
    this.language,
    this.script,
    this.styleId,
    this.noBreak,
  });

  /// Empty patch (all fields unset). Identity for [merge].
  static const empty = CharAttrs();

  final String? fontFamily;

  /// Weight/italic style name, e.g. 'Bold', 'Italic', 'Regular'.
  final String? styleName;
  final double? sizeMm;

  /// `#rrggbb` text fill; null = inherit.
  final String? fillHex;

  /// `#rrggbb` text stroke; null = inherit.
  final String? strokeHex;
  final double? trackingMm;
  final double? baselineShiftMm;

  /// Horizontal / vertical glyph scale as a fraction (1.0 == 100%).
  final double? hScale;
  final double? vScale;
  final double? skewDeg;
  final double? rotationDeg;
  final TextDecorations? decorations;

  /// OpenType feature tag → value (1 = on, 0 = off, N = alt index).
  final Map<String, int> openTypeFeatures;

  /// Variable-font axis tag → coordinate (e.g. 'wght' → 700).
  final Map<String, double> variableAxes;

  /// BCP-47 spelling/typography language, e.g. 'en-IN'.
  final String? language;

  /// OpenType script tag, e.g. 'latn'.
  final String? script;

  /// Referenced [CharacterStyle] id; null = no style.
  final String? styleId;

  /// Suppress line breaking within this run.
  final bool? noBreak;

  bool get isEmpty =>
      fontFamily == null &&
      styleName == null &&
      sizeMm == null &&
      fillHex == null &&
      strokeHex == null &&
      trackingMm == null &&
      baselineShiftMm == null &&
      hScale == null &&
      vScale == null &&
      skewDeg == null &&
      rotationDeg == null &&
      (decorations == null || decorations!.isEmpty) &&
      openTypeFeatures.isEmpty &&
      variableAxes.isEmpty &&
      language == null &&
      script == null &&
      styleId == null &&
      noBreak == null;

  /// True when any field other than [styleId] is set — i.e. this run
  /// overrides its referenced character style.
  bool get hasOverrides => copyWith(clearStyleId: true).isEmpty == false;

  /// Returns a copy with the non-null fields of [patch] applied over
  /// this one (patch wins). Maps merge key-by-key.
  CharAttrs merge(CharAttrs patch) => CharAttrs(
        fontFamily: patch.fontFamily ?? fontFamily,
        styleName: patch.styleName ?? styleName,
        sizeMm: patch.sizeMm ?? sizeMm,
        fillHex: patch.fillHex ?? fillHex,
        strokeHex: patch.strokeHex ?? strokeHex,
        trackingMm: patch.trackingMm ?? trackingMm,
        baselineShiftMm: patch.baselineShiftMm ?? baselineShiftMm,
        hScale: patch.hScale ?? hScale,
        vScale: patch.vScale ?? vScale,
        skewDeg: patch.skewDeg ?? skewDeg,
        rotationDeg: patch.rotationDeg ?? rotationDeg,
        decorations: patch.decorations ?? decorations,
        openTypeFeatures: {...openTypeFeatures, ...patch.openTypeFeatures},
        variableAxes: {...variableAxes, ...patch.variableAxes},
        language: patch.language ?? language,
        script: patch.script ?? script,
        styleId: patch.styleId ?? styleId,
        noBreak: patch.noBreak ?? noBreak,
      );

  CharAttrs copyWith({
    String? fontFamily,
    String? styleName,
    double? sizeMm,
    String? fillHex,
    String? strokeHex,
    double? trackingMm,
    double? baselineShiftMm,
    double? hScale,
    double? vScale,
    double? skewDeg,
    double? rotationDeg,
    TextDecorations? decorations,
    Map<String, int>? openTypeFeatures,
    Map<String, double>? variableAxes,
    String? language,
    String? script,
    String? styleId,
    bool? noBreak,
    bool clearStyleId = false,
  }) =>
      CharAttrs(
        fontFamily: fontFamily ?? this.fontFamily,
        styleName: styleName ?? this.styleName,
        sizeMm: sizeMm ?? this.sizeMm,
        fillHex: fillHex ?? this.fillHex,
        strokeHex: strokeHex ?? this.strokeHex,
        trackingMm: trackingMm ?? this.trackingMm,
        baselineShiftMm: baselineShiftMm ?? this.baselineShiftMm,
        hScale: hScale ?? this.hScale,
        vScale: vScale ?? this.vScale,
        skewDeg: skewDeg ?? this.skewDeg,
        rotationDeg: rotationDeg ?? this.rotationDeg,
        decorations: decorations ?? this.decorations,
        openTypeFeatures: openTypeFeatures ?? this.openTypeFeatures,
        variableAxes: variableAxes ?? this.variableAxes,
        language: language ?? this.language,
        script: script ?? this.script,
        styleId: clearStyleId ? null : (styleId ?? this.styleId),
        noBreak: noBreak ?? this.noBreak,
      );

  Map<String, dynamic> toJson() => {
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (styleName != null) 'styleName': styleName,
        if (sizeMm != null) 'sizeMm': sizeMm,
        if (fillHex != null) 'fillHex': fillHex,
        if (strokeHex != null) 'strokeHex': strokeHex,
        if (trackingMm != null) 'trackingMm': trackingMm,
        if (baselineShiftMm != null) 'baselineShiftMm': baselineShiftMm,
        if (hScale != null) 'hScale': hScale,
        if (vScale != null) 'vScale': vScale,
        if (skewDeg != null) 'skewDeg': skewDeg,
        if (rotationDeg != null) 'rotationDeg': rotationDeg,
        if (decorations != null && !decorations!.isEmpty)
          'decorations': decorations!.toJson(),
        if (openTypeFeatures.isNotEmpty) 'openTypeFeatures': openTypeFeatures,
        if (variableAxes.isNotEmpty) 'variableAxes': variableAxes,
        if (language != null) 'language': language,
        if (script != null) 'script': script,
        if (styleId != null) 'styleId': styleId,
        if (noBreak != null) 'noBreak': noBreak,
      };

  factory CharAttrs.fromJson(Map<String, dynamic> json) => CharAttrs(
        fontFamily: json['fontFamily'] as String?,
        styleName: json['styleName'] as String?,
        sizeMm: (json['sizeMm'] as num?)?.toDouble(),
        fillHex: json['fillHex'] as String?,
        strokeHex: json['strokeHex'] as String?,
        trackingMm: (json['trackingMm'] as num?)?.toDouble(),
        baselineShiftMm: (json['baselineShiftMm'] as num?)?.toDouble(),
        hScale: (json['hScale'] as num?)?.toDouble(),
        vScale: (json['vScale'] as num?)?.toDouble(),
        skewDeg: (json['skewDeg'] as num?)?.toDouble(),
        rotationDeg: (json['rotationDeg'] as num?)?.toDouble(),
        decorations: json['decorations'] == null
            ? null
            : TextDecorations.fromJson(
                json['decorations'] as Map<String, dynamic>),
        openTypeFeatures: {
          for (final e
              in (json['openTypeFeatures'] as Map? ?? const {}).entries)
            e.key as String: (e.value as num).toInt(),
        },
        variableAxes: {
          for (final e in (json['variableAxes'] as Map? ?? const {}).entries)
            e.key as String: (e.value as num).toDouble(),
        },
        language: json['language'] as String?,
        script: json['script'] as String?,
        styleId: json['styleId'] as String?,
        noBreak: json['noBreak'] as bool?,
      );

  @override
  bool operator ==(Object other) =>
      other is CharAttrs &&
      other.fontFamily == fontFamily &&
      other.styleName == styleName &&
      other.sizeMm == sizeMm &&
      other.fillHex == fillHex &&
      other.strokeHex == strokeHex &&
      other.trackingMm == trackingMm &&
      other.baselineShiftMm == baselineShiftMm &&
      other.hScale == hScale &&
      other.vScale == vScale &&
      other.skewDeg == skewDeg &&
      other.rotationDeg == rotationDeg &&
      other.decorations == decorations &&
      _mapEq(other.openTypeFeatures, openTypeFeatures) &&
      _mapEq(other.variableAxes, variableAxes) &&
      other.language == language &&
      other.script == script &&
      other.styleId == styleId &&
      other.noBreak == noBreak;

  @override
  int get hashCode => Object.hash(
        fontFamily,
        styleName,
        sizeMm,
        fillHex,
        strokeHex,
        trackingMm,
        baselineShiftMm,
        hScale,
        vScale,
        skewDeg,
        rotationDeg,
        decorations,
        Object.hashAllUnordered(openTypeFeatures.entries.map((e) => e.key)),
        Object.hashAllUnordered(variableAxes.entries.map((e) => e.key)),
        Object.hash(language, script, styleId, noBreak),
      );
}

/// A contiguous character range `[start, start+length)` carrying
/// [attrs]. Offsets are rune offsets into the owning [TextObject.text].
final class StyleRun {
  const StyleRun(this.start, this.length, this.attrs);

  final int start;
  final int length;
  final CharAttrs attrs;

  int get end => start + length;

  StyleRun copyWith({int? start, int? length, CharAttrs? attrs}) =>
      StyleRun(start ?? this.start, length ?? this.length, attrs ?? this.attrs);

  Map<String, dynamic> toJson() =>
      {'start': start, 'length': length, 'attrs': attrs.toJson()};

  factory StyleRun.fromJson(Map<String, dynamic> json) => StyleRun(
        (json['start'] as num).toInt(),
        (json['length'] as num).toInt(),
        CharAttrs.fromJson(json['attrs'] as Map<String, dynamic>),
      );

  @override
  bool operator ==(Object other) =>
      other is StyleRun &&
      other.start == start &&
      other.length == length &&
      other.attrs == attrs;

  @override
  int get hashCode => Object.hash(start, length, attrs);
}

/// One optical-alignment rule (ADR-040): the leading- and trailing-edge
/// side-bearing adjustment (as a percent of the em) applied to any of the
/// listed [chars] when they sit at a line edge. Stored document-wide (a
/// shared preset table, like Affinity's Optical Alignment); editable in
/// the Character panel.
final class OpticalRule {
  const OpticalRule({
    required this.leftPct,
    required this.rightPct,
    required this.chars,
  });

  /// Left-edge inset as a percent of the em size (0–100).
  final double leftPct;

  /// Right-edge inset as a percent of the em size (0–100).
  final double rightPct;

  /// Characters this rule applies to (e.g. quotation marks, hyphens).
  final String chars;

  /// The default preset table shown in a fresh document (mirrors the
  /// common punctuation-hang defaults).
  static const defaults = <OpticalRule>[
    OpticalRule(leftPct: 100, rightPct: 100, chars: '“”‘’"\',.'),
    OpticalRule(leftPct: 75, rightPct: 75, chars: '—–-'),
    OpticalRule(leftPct: 50, rightPct: 50, chars: '·'),
    OpticalRule(leftPct: 25, rightPct: 25, chars: ':;'),
    OpticalRule(leftPct: 20, rightPct: 20, chars: 'ATWY'),
    OpticalRule(leftPct: 10, rightPct: 10, chars: 'CGOQ()'),
  ];

  OpticalRule copyWith({double? leftPct, double? rightPct, String? chars}) =>
      OpticalRule(
        leftPct: leftPct ?? this.leftPct,
        rightPct: rightPct ?? this.rightPct,
        chars: chars ?? this.chars,
      );

  Map<String, dynamic> toJson() =>
      {'leftPct': leftPct, 'rightPct': rightPct, 'chars': chars};

  factory OpticalRule.fromJson(Map<String, dynamic> json) => OpticalRule(
        leftPct: (json['leftPct'] as num).toDouble(),
        rightPct: (json['rightPct'] as num).toDouble(),
        chars: json['chars'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is OpticalRule &&
      other.leftPct == leftPct &&
      other.rightPct == rightPct &&
      other.chars == chars;

  @override
  int get hashCode => Object.hash(leftPct, rightPct, chars);
}

/// A reusable named character style (ADR-040). Stored on the document;
/// runs reference it by [id] and may override individual fields.
final class CharacterStyle {
  const CharacterStyle(this.id, this.name, this.base);

  final String id;
  final String name;
  final CharAttrs base;

  CharacterStyle copyWith({String? name, CharAttrs? base}) =>
      CharacterStyle(id, name ?? this.name, base ?? this.base);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'base': base.toJson()};

  factory CharacterStyle.fromJson(Map<String, dynamic> json) => CharacterStyle(
        json['id'] as String,
        json['name'] as String,
        CharAttrs.fromJson(json['base'] as Map<String, dynamic>),
      );

  @override
  bool operator ==(Object other) =>
      other is CharacterStyle &&
      other.id == id &&
      other.name == name &&
      other.base == base;

  @override
  int get hashCode => Object.hash(id, name, base);
}

/// Normalizes a run list over a string of [textLength] runes: clamps to
/// bounds, drops empty/off-string runs, sorts by start, splits overlaps
/// (later runs win), and coalesces adjacent runs with equal attrs.
/// Gaps are allowed (they inherit object defaults).
List<StyleRun> normalizeRuns(List<StyleRun> runs, int textLength) {
  if (runs.isEmpty || textLength <= 0) return const [];
  // Per-character attribute map (last writer wins), then coalesce.
  final attrsAt = List<CharAttrs?>.filled(textLength, null);
  for (final run in runs) {
    final lo = run.start.clamp(0, textLength);
    final hi = run.end.clamp(0, textLength);
    for (var i = lo; i < hi; i++) {
      attrsAt[i] = run.attrs;
    }
  }
  final out = <StyleRun>[];
  var i = 0;
  while (i < textLength) {
    final a = attrsAt[i];
    if (a == null || a.isEmpty) {
      i++;
      continue;
    }
    var j = i + 1;
    while (j < textLength && attrsAt[j] == a) {
      j++;
    }
    out.add(StyleRun(i, j - i, a));
    i = j;
  }
  return out;
}

/// Attributes at rune [offset] (empty if no run covers it).
CharAttrs attrsAtOffset(List<StyleRun> runs, int offset) {
  for (final run in runs) {
    if (offset >= run.start && offset < run.end) return run.attrs;
  }
  return CharAttrs.empty;
}

/// Applies [patch] over `[start, end)` and returns a normalized run
/// list. Existing attrs in the range are merged with [patch] (patch
/// wins); characters outside the range keep their runs.
List<StyleRun> applyPatchToRange(
  List<StyleRun> runs,
  int textLength,
  int start,
  int end,
  CharAttrs patch,
) {
  final lo = start.clamp(0, textLength);
  final hi = end.clamp(0, textLength);
  if (hi <= lo) return normalizeRuns(runs, textLength);
  final perChar =
      List<CharAttrs>.generate(textLength, (i) => attrsAtOffset(runs, i));
  for (var i = lo; i < hi; i++) {
    perChar[i] = perChar[i].merge(patch);
  }
  return normalizeRuns(
    [for (var i = 0; i < textLength; i++) StyleRun(i, 1, perChar[i])],
    textLength,
  );
}

/// Per-field query over `[start, end)`: for each field, the shared value
/// across every character, or [mixedValue] when they disagree. Fields
/// unset everywhere resolve to the supplied [defaults] value.
/// Returns a [CharAttrs] where a field is null only if it is null across
/// the whole range, alongside a set of field keys that are mixed.
({CharAttrs shared, Set<String> mixed}) queryRange(
  List<StyleRun> runs,
  CharAttrs defaults,
  int start,
  int end,
) {
  final resolved = <CharAttrs>[];
  for (var i = start; i < end; i++) {
    resolved.add(defaults.merge(attrsAtOffset(runs, i)));
  }
  if (resolved.isEmpty) return (shared: defaults, mixed: const {});
  final mixed = <String>{};
  T? uniform<T>(T? Function(CharAttrs) get, String key) {
    final first = get(resolved.first);
    for (final a in resolved.skip(1)) {
      if (get(a) != first) {
        mixed.add(key);
        return null;
      }
    }
    return first;
  }

  final shared = CharAttrs(
    fontFamily: uniform((a) => a.fontFamily, 'fontFamily'),
    styleName: uniform((a) => a.styleName, 'styleName'),
    sizeMm: uniform((a) => a.sizeMm, 'sizeMm'),
    fillHex: uniform((a) => a.fillHex, 'fillHex'),
    strokeHex: uniform((a) => a.strokeHex, 'strokeHex'),
    trackingMm: uniform((a) => a.trackingMm, 'trackingMm'),
    baselineShiftMm: uniform((a) => a.baselineShiftMm, 'baselineShiftMm'),
    hScale: uniform((a) => a.hScale, 'hScale'),
    vScale: uniform((a) => a.vScale, 'vScale'),
    skewDeg: uniform((a) => a.skewDeg, 'skewDeg'),
    rotationDeg: uniform((a) => a.rotationDeg, 'rotationDeg'),
    decorations: uniform((a) => a.decorations, 'decorations'),
    language: uniform((a) => a.language, 'language'),
    script: uniform((a) => a.script, 'script'),
    styleId: uniform((a) => a.styleId, 'styleId'),
    noBreak: uniform((a) => a.noBreak, 'noBreak'),
  );
  return (shared: shared, mixed: mixed);
}

bool _setEq<T>(Set<T> a, Set<T> b) => a.length == b.length && a.containsAll(b);

bool _mapEq<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}
