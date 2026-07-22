import 'package:studio_core/studio_core.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'text_style.dart';

/// Visual stroke properties of a design object (fill/stroke system
/// v1): rendered on the canvas; stitch generators may consume width
/// later (satin). Immutable value type.
final class StrokeProps {
  const StrokeProps({
    this.widthMm = 0.4,
    this.cap = 'round',
    this.join = 'round',
    this.miterLimit = 4,
    this.colorHex,
    this.fillHex,
  });

  final double widthMm;

  /// 'butt' | 'round' | 'square'.
  final String cap;

  /// 'miter' | 'round' | 'bevel'.
  final String join;
  final double miterLimit;

  /// `#rrggbb` stroke color; null = theme default; [transparent] = no
  /// stroke.
  final String? colorHex;

  /// Closed-contour fill color (`#rrggbb`); null or [transparent] = no
  /// fill.
  final String? fillHex;

  static const defaults = StrokeProps();

  /// Fully transparent colour ("no fill" / "no stroke"): alpha 00. Colours
  /// are `#rrggbb` (opaque) or `#rrggbbaa` (with alpha); any hex whose
  /// alpha byte is 00 means "none".
  static const transparent = '#00000000';

  /// Alpha byte 0–255 of a colour hex: 255 for null or 6-digit (opaque),
  /// else the trailing byte of an 8-digit `#rrggbbaa`.
  static int alphaOf(String? hex) {
    if (hex == null) return 255;
    final h = hex.replaceFirst('#', '');
    if (h.length == 8) return int.tryParse(h.substring(6), radix: 16) ?? 255;
    return 255;
  }

  /// Whether a visible fill should be painted (has a colour and alpha > 0).
  bool get hasFill => fillHex != null && alphaOf(fillHex) != 0;

  /// Whether a visible stroke should be painted (alpha > 0; null strokes
  /// with the theme default).
  bool get hasStroke => alphaOf(colorHex) != 0;

  bool get isDefault =>
      widthMm == defaults.widthMm &&
      cap == defaults.cap &&
      join == defaults.join &&
      miterLimit == defaults.miterLimit &&
      colorHex == null &&
      fillHex == null;

  StrokeProps copyWith({
    double? widthMm,
    String? cap,
    String? join,
    double? miterLimit,
    String? colorHex,
    String? fillHex,
    bool clearFill = false,
  }) =>
      StrokeProps(
        widthMm: widthMm ?? this.widthMm,
        cap: cap ?? this.cap,
        join: join ?? this.join,
        miterLimit: miterLimit ?? this.miterLimit,
        colorHex: colorHex ?? this.colorHex,
        fillHex: clearFill ? null : (fillHex ?? this.fillHex),
      );

  Map<String, dynamic> toJson() => {
        'widthMm': widthMm,
        'cap': cap,
        'join': join,
        'miterLimit': miterLimit,
        if (colorHex != null) 'colorHex': colorHex,
        if (fillHex != null) 'fillHex': fillHex,
      };

  factory StrokeProps.fromJson(Map<String, dynamic> json) => StrokeProps(
        widthMm: (json['widthMm'] as num).toDouble(),
        cap: json['cap'] as String,
        join: json['join'] as String,
        miterLimit: (json['miterLimit'] as num).toDouble(),
        colorHex: json['colorHex'] as String?,
        fillHex: json['fillHex'] as String?,
      );
}

/// An embroidery design element: geometry plus stitch parameters.
/// Immutable — editing replaces the object via commands.
sealed class EmbroideryObject {
  const EmbroideryObject({
    required this.id,
    required this.path,
    this.stroke = StrokeProps.defaults,
    this.name,
    this.rotationDeg = 0,
  });

  final Id id;
  final Path path;

  /// The object's orientation in degrees (ADR-045). Geometry is stored
  /// world-baked; this remembers how far it has been rotated so the
  /// selection box and handles stay aligned with the object instead of
  /// resetting to an axis-aligned rectangle after each rotation.
  final double rotationDeg;

  /// Canvas stroke rendering properties (ADR-028 fill/stroke v1).
  final StrokeProps stroke;

  /// User-facing display name (ADR-036); null = derived default
  /// (`<Text>` for text, `<Path>` otherwise).
  final String? name;

  /// A copy with [stroke] replaced (same type, id, geometry, params) —
  /// cloned through serialization so every kind supports it.
  EmbroideryObject withStroke(StrokeProps stroke) {
    final json = toJson()..['stroke'] = stroke.toJson();
    return EmbroideryObject.fromJson(json);
  }

  /// A copy with [name] replaced (ADR-036). Renaming in the UI is
  /// `ReplaceObject(object.withName(...))` — undoable for free.
  EmbroideryObject withName(String name) {
    final json = toJson()..['name'] = name;
    return EmbroideryObject.fromJson(json);
  }

  /// A copy with [rotationDeg] replaced (normalized to (-180, 180]),
  /// cloned through serialization like [withStroke]/[withName].
  EmbroideryObject withRotationDeg(double degrees) {
    var d = degrees % 360;
    if (d > 180) d -= 360;
    if (d <= -180) d += 360;
    final json = toJson()..['rotation'] = d;
    return EmbroideryObject.fromJson(json);
  }

  /// A copy of this object with [path] replaced (same id and params).
  EmbroideryObject withPath(Path path);

  /// Geometry consumed by rendering, hit-testing, and stitch
  /// generation. Single-path objects return `[path]`; composite
  /// objects (text) return every contour (ADR-028).
  List<Path> get renderPaths => [path];

  /// Bounding box of all render geometry.
  Bounds bounds() => path.bounds();

  /// A copy with [t] applied to all geometry. Commands transform
  /// objects through this so composites transform every contour.
  EmbroideryObject transformedBy(Transform2 t) => withPath(path.transformed(t));

  Map<String, dynamic> toJson() => {
        'type': switch (this) {
          RunningStitchObject() => 'running',
          SatinObject() => 'satin',
          FillObject() => 'fill',
          TextObject() => 'text',
        },
        'id': id.value,
        'path': path.toJson(),
        if (name != null) 'name': name,
        if (rotationDeg != 0) 'rotation': rotationDeg,
        if (!stroke.isDefault) 'stroke': stroke.toJson(),
        ...switch (this) {
          RunningStitchObject(:final stitchLength, :final widthProfile) => {
              'stitchLength': stitchLength,
              if (widthProfile != null) 'widthProfile': widthProfile,
            },
          SatinObject(:final width) => {'width': width},
          FillObject(:final spacing, :final holes) => {
              'spacing': spacing,
              if (holes.isNotEmpty)
                'holes': [for (final h in holes) h.toJson()],
            },
          TextObject(
            :final text,
            :final fontFamily,
            :final sizeMm,
            :final trackingMm,
            :final lineHeight,
            :final alignment,
            :final frameWidthMm,
            :final stitchLength,
            :final outlines,
            :final runs,
          ) =>
            {
              'text': text,
              'fontFamily': fontFamily,
              'sizeMm': sizeMm,
              'trackingMm': trackingMm,
              'lineHeight': lineHeight,
              'alignment': alignment,
              if (frameWidthMm != null) 'frameWidthMm': frameWidthMm,
              'stitchLength': stitchLength,
              'outlines': [for (final o in outlines) o.toJson()],
              if (runs.isNotEmpty) 'runs': [for (final r in runs) r.toJson()],
            },
        },
      };

  static EmbroideryObject fromJson(Map<String, dynamic> json) {
    final id = Id(json['id'] as String);
    final path = Path.fromJson(json['path'] as Map<String, dynamic>);
    final name = json['name'] as String?;
    // Legacy documents carry no rotation — axis-aligned (0°).
    final rotationDeg = (json['rotation'] as num?)?.toDouble() ?? 0;
    final stroke = json['stroke'] == null
        ? StrokeProps.defaults
        : StrokeProps.fromJson(json['stroke'] as Map<String, dynamic>);
    return switch (json['type']) {
      'running' => RunningStitchObject(
          id: id,
          path: path,
          stroke: stroke,
          name: name,
          rotationDeg: rotationDeg,
          stitchLength: (json['stitchLength'] as num).toDouble(),
          widthProfile: (json['widthProfile'] as List?)
              ?.map((w) => (w as num).toDouble())
              .toList(),
        ),
      'satin' => SatinObject(
          id: id,
          path: path,
          stroke: stroke,
          name: name,
          rotationDeg: rotationDeg,
          width: (json['width'] as num).toDouble()),
      'fill' => FillObject(
            id: id,
            path: path,
            stroke: stroke,
            name: name,
            rotationDeg: rotationDeg,
            spacing: (json['spacing'] as num).toDouble(),
            holes: [
              for (final h in (json['holes'] as List? ?? const []))
                Path.fromJson(h as Map<String, dynamic>)
            ]),
      'text' => TextObject(
          id: id,
          path: path,
          stroke: stroke,
          name: name,
          rotationDeg: rotationDeg,
          text: json['text'] as String,
          fontFamily: json['fontFamily'] as String,
          sizeMm: (json['sizeMm'] as num).toDouble(),
          trackingMm: (json['trackingMm'] as num).toDouble(),
          lineHeight: (json['lineHeight'] as num).toDouble(),
          alignment: json['alignment'] as String,
          frameWidthMm: (json['frameWidthMm'] as num?)?.toDouble(),
          stitchLength: (json['stitchLength'] as num).toDouble(),
          outlines: [
            for (final o in json['outlines'] as List)
              Path.fromJson(o as Map<String, dynamic>)
          ],
          runs: [
            for (final r in (json['runs'] as List? ?? const []))
              StyleRun.fromJson(r as Map<String, dynamic>)
          ],
        ),
      _ => throw FormatException('Unknown object type: ${json['type']}'),
    };
  }
}

/// A running stitch along the path.
final class RunningStitchObject extends EmbroideryObject {
  const RunningStitchObject({
    required super.id,
    required super.path,
    super.stroke,
    super.name,
    super.rotationDeg,
    this.stitchLength = 2.5,
    this.widthProfile,
  });

  /// Target stitch length in mm.
  final double stitchLength;

  /// Per-node stroke width in mm from stylus pressure (ADR-038): one
  /// entry per path node (`segments.length + 1`). Null = uniform
  /// [StrokeProps.widthMm]. Rendering interpolates between nodes;
  /// stitch generation ignores it until satin consumes width.
  final List<double>? widthProfile;

  @override
  RunningStitchObject withPath(Path path) => RunningStitchObject(
      id: id,
      path: path,
      stroke: stroke,
      name: name,
      rotationDeg: rotationDeg,
      stitchLength: stitchLength,
      // Node edits invalidate the node↔width mapping; transforms
      // preserve it (ADR-038).
      widthProfile: widthProfile?.length == path.segments.length + 1
          ? widthProfile
          : null);
}

// ponytail: satin/fill are declared so the object model is complete,
// but their generators land in a later sprint (skeleton per MVP-S4-T2).

/// A satin column along the path. Generator not implemented yet.
final class SatinObject extends EmbroideryObject {
  const SatinObject(
      {required super.id,
      required super.path,
      super.stroke,
      super.name,
      super.rotationDeg,
      this.width = 3.0});

  /// Column width in mm.
  final double width;

  @override
  SatinObject withPath(Path path) => SatinObject(
      id: id,
      path: path,
      stroke: stroke,
      name: name,
      rotationDeg: rotationDeg,
      width: width);
}

/// A region fill bounded by the (closed) path. Generator not
/// implemented yet.
final class FillObject extends EmbroideryObject {
  const FillObject(
      {required super.id,
      required super.path,
      super.stroke,
      super.name,
      super.rotationDeg,
      this.spacing = 0.4,
      this.holes = const []});

  /// Fill line spacing in mm.
  final double spacing;

  /// Inner boundary contours (ADR-042): the fill uses the even-odd rule
  /// over `[path, ...holes]`, so counters ('O', 'e') stay unstitched.
  final List<Path> holes;

  @override
  List<Path> get renderPaths => [path, ...holes];

  @override
  Bounds bounds() {
    var b = path.bounds();
    for (final h in holes) {
      b = b.union(h.bounds());
    }
    return b;
  }

  @override
  FillObject withPath(Path path) {
    // Transforms of a fill translate/scale its boundary; holes move with
    // it. A pure path swap (node edit) keeps the same holes.
    return FillObject(
        id: id,
        path: path,
        stroke: stroke,
        name: name,
        rotationDeg: rotationDeg,
        spacing: spacing,
        holes: holes);
  }

  @override
  FillObject transformedBy(Transform2 t) => FillObject(
        id: id,
        path: path.transformed(t),
        stroke: stroke,
        name: name,
        rotationDeg: rotationDeg,
        spacing: spacing,
        holes: [for (final h in holes) h.transformed(t)],
      );
}

/// A single editable text element (ADR-028): the design intent (string,
/// font, layout) stays authoritative; [outlines] cache the laid-out
/// glyph contours so rendering and stitch generation never depend on
/// the font engine. [path] carries the anchor (first baseline left).
final class TextObject extends EmbroideryObject {
  const TextObject({
    required super.id,
    required super.path,
    super.stroke,
    super.name,
    super.rotationDeg,
    required this.text,
    required this.fontFamily,
    this.sizeMm = 10,
    this.trackingMm = 0,
    this.lineHeight = 1.4,
    this.alignment = 'left',
    this.frameWidthMm,
    this.stitchLength = 2.5,
    this.outlines = const [],
    this.runs = const [],
  });

  final String text;
  final String fontFamily;
  final double sizeMm;
  final double trackingMm;
  final double lineHeight;

  /// 'left' | 'center' | 'right' (string keeps the domain free of the
  /// tools-layer alignment enum).
  final String alignment;

  /// Wrap width for area text; null = point text.
  final double? frameWidthMm;

  final double stitchLength;

  /// Cached glyph contours in world mm (derived; regenerated on edit).
  final List<Path> outlines;

  /// Per-range character attributes (ADR-040). Empty = whole string uses
  /// the scalar defaults above. Normalized (sorted, non-overlapping).
  final List<StyleRun> runs;

  /// Object-level defaults as a [CharAttrs] (what a gap between runs
  /// inherits): the scalar font/size/tracking plus the stroke fill.
  CharAttrs get defaultAttrs => CharAttrs(
        fontFamily: fontFamily,
        sizeMm: sizeMm,
        trackingMm: trackingMm,
        fillHex: stroke.fillHex,
        strokeHex: stroke.colorHex,
      );

  /// Attributes resolved (defaults ⊕ run) at rune [offset].
  CharAttrs attrsAt(int offset) =>
      defaultAttrs.merge(attrsAtOffset(runs, offset));

  /// A copy with [patch] applied over the rune range `[start, end)`.
  TextObject withRangeAttrs(int start, int end, CharAttrs patch) => _with(
        runs: applyPatchToRange(runs, text.runes.length, start, end, patch),
      );

  /// A copy with the cached glyph [outlines] replaced. Used by the UI to
  /// refresh outlines after a run/attribute edit (the font engine lives
  /// in the tools layer, so regeneration happens there, not here).
  TextObject withOutlines(List<Path> outlines) => _with(outlines: outlines);

  /// A copy with the base [fontFamily] replaced. Font family is
  /// object-level (layout resolves one font per object today), so the
  /// Character panel applies a family change through this rather than a
  /// per-range run.
  // ponytail: per-run font substitution needs a font resolver in layout;
  // until then family is whole-object.
  TextObject withFontFamily(String fontFamily) => _with(fontFamily: fontFamily);

  /// Paragraph alignment ('left'/'center'/'right'/'justify') — an
  /// object-level layout property, like the family above.
  TextObject withAlignment(String alignment) => _with(alignment: alignment);

  /// Replaces the style runs wholesale (carrying runs through a
  /// run-unaware text-tool commit).
  TextObject withRuns(List<StyleRun> runs) => _with(runs: runs);

  Point get anchor => path.start;

  @override
  List<Path> get renderPaths => outlines;

  @override
  Bounds bounds() {
    if (outlines.isEmpty) return path.bounds();
    var b = outlines.first.bounds();
    for (final outline in outlines.skip(1)) {
      b = b.union(outline.bounds());
    }
    return b;
  }

  @override
  TextObject withPath(Path path) {
    // Pure translation of the anchor: shift all outlines by the delta.
    final t = Transform2.translation(
        path.start.x - this.path.start.x, path.start.y - this.path.start.y);
    return _with(path: path, outlines: [
      for (final o in outlines) o.transformed(t),
    ]);
  }

  @override
  TextObject transformedBy(Transform2 t) => _with(
        path: path.transformed(t),
        outlines: [for (final o in outlines) o.transformed(t)],
      );

  TextObject _with(
          {Path? path,
          List<Path>? outlines,
          List<StyleRun>? runs,
          String? fontFamily,
          String? alignment}) =>
      TextObject(
        id: id,
        path: path ?? this.path,
        stroke: stroke,
        name: name,
        rotationDeg: rotationDeg,
        text: text,
        fontFamily: fontFamily ?? this.fontFamily,
        sizeMm: sizeMm,
        trackingMm: trackingMm,
        lineHeight: lineHeight,
        alignment: alignment ?? this.alignment,
        frameWidthMm: frameWidthMm,
        stitchLength: stitchLength,
        outlines: outlines ?? this.outlines,
        runs: runs ?? this.runs,
      );
}
