import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

/// One studio icon: a stable id, the font glyph rendered today, and the
/// 24×24 monotone SVG asset that is the source of truth for future
/// theming/rendering. Active/disabled/selected states are applied by
/// the UI (color/opacity), never baked into per-state files.
final class StudioIcon {
  const StudioIcon({required this.id, required this.fallback, this.svgAsset});

  /// Naming convention: `^(tool|stitch|sim|panel)-[a-z0-9-]+$`.
  final String id;

  /// Font glyph rendered until an SVG rendering path exists.
  final IconData fallback;

  /// `assets/icons/<id>.svg` — placeholder art for now.
  final String? svgAsset;
}

StudioIcon _icon(String id, IconData fallback) =>
    StudioIcon(id: id, fallback: fallback, svgAsset: 'assets/icons/$id.svg');

/// Icon registry: id → glyph + SVG asset. Existing design-tool UI keeps
/// its inline font icons; new domain/simulation/panel UI resolves here.
final studioIcons = <String, StudioIcon>{
  for (final icon in [
    // Design tools
    _icon('tool-select', TablerIcons.pointer),
    _icon('tool-node', TablerIcons.vector),
    _icon('tool-pen', TablerIcons.ballpen),
    _icon('tool-pencil', TablerIcons.pencil),
    _icon('tool-rectangle', TablerIcons.rectangle),
    _icon('tool-ellipse', TablerIcons.oval_vertical),
    _icon('tool-line', TablerIcons.line),
    _icon('tool-bezier', TablerIcons.vector_bezier_2),
    _icon('tool-text', TablerIcons.typography),
    _icon('tool-knife', TablerIcons.scissors),
    _icon('tool-measure', TablerIcons.ruler_2),
    _icon('tool-pan', TablerIcons.hand_stop),
    // Embroidery / stitch tools
    _icon('stitch-select', TablerIcons.pointer),
    _icon('stitch-reshape', TablerIcons.vector_spline),
    _icon('stitch-entry-exit', TablerIcons.arrows_exchange),
    _icon('stitch-sequence', TablerIcons.list_numbers),
    _icon('stitch-run', TablerIcons.line_dashed),
    _icon('stitch-bean', TablerIcons.line_dotted),
    _icon('stitch-satin', TablerIcons.wave_saw_tool),
    _icon('stitch-fill', TablerIcons.texture),
    _icon('stitch-motif-run', TablerIcons.route),
    _icon('stitch-motif-fill', TablerIcons.grid_dots),
    _icon('stitch-zigzag', TablerIcons.activity),
    _icon('stitch-stem', TablerIcons.plant_2),
    _icon('stitch-manual', TablerIcons.hand_finger),
    _icon('stitch-applique', TablerIcons.sticker),
    _icon('stitch-underlay', TablerIcons.layers_subtract),
    _icon('stitch-travel', TablerIcons.arrow_ramp_right),
    _icon('stitch-trim', TablerIcons.cut),
    _icon('stitch-color-change', TablerIcons.color_swatch),
    _icon('stitch-angle', TablerIcons.angle),
    _icon('stitch-compensation', TablerIcons.arrows_horizontal),
    // Simulation transport
    _icon('sim-play', Icons.play_arrow),
    _icon('sim-pause', Icons.pause),
    _icon('sim-stop', Icons.stop),
    _icon('sim-step-forward', Icons.skip_next),
    _icon('sim-step-back', Icons.skip_previous),
    _icon('sim-scrub', Icons.linear_scale),
    _icon('sim-speed', Icons.speed),
    _icon('sim-jump-color', Icons.palette_outlined),
    _icon('sim-jump-trim', TablerIcons.cut),
    _icon('sim-jump-object', Icons.widgets_outlined),
    _icon('sim-loop', Icons.repeat),
    _icon('sim-needle', TablerIcons.needle_thread),
    _icon('sim-travel', TablerIcons.route_2),
    _icon('sim-machine-path', TablerIcons.topology_star_3),
    // Panels
    _icon('panel-layers', Icons.layers_outlined),
    _icon('panel-properties', Icons.tune),
    _icon('panel-transform', Icons.transform),
    _icon('panel-color-fill-stroke', Icons.format_color_fill),
    _icon('panel-assets', Icons.collections_outlined),
    _icon('panel-path-ops', TablerIcons.vector_triangle),
    _icon('panel-character', Icons.text_fields),
    _icon('panel-paragraph', Icons.notes),
    _icon('panel-align', Icons.align_horizontal_left),
    _icon('panel-stitch-objects', TablerIcons.list_details),
    _icon('panel-sequence', Icons.format_list_numbered),
    _icon('panel-stitch-properties', Icons.tune),
    _icon('panel-thread', TablerIcons.needle_thread),
    _icon('panel-underlay', TablerIcons.layers_subtract),
    _icon('panel-compensation', TablerIcons.arrows_horizontal),
    _icon('panel-validation', Icons.rule),
    _icon('panel-statistics', Icons.query_stats),
    _icon('panel-machine-hoop', TablerIcons.frame),
    _icon('panel-timeline', Icons.timeline),
    _icon('panel-playback-events', Icons.event_note_outlined),
    _icon('panel-color-sequence', Icons.palette_outlined),
    _icon('panel-event-log', Icons.receipt_long_outlined),
    _icon('panel-runtime-stats', Icons.insights),
    _icon('panel-warnings', Icons.warning_amber_outlined),
    _icon('panel-warp-setup', TablerIcons.grid_4x4),
    _icon('panel-weft-sequence', TablerIcons.arrows_left_right),
  ])
    icon.id: icon,
};

/// Icon glyph for [id]; unknown ids get an obvious placeholder box.
IconData iconFor(String id) =>
    studioIcons[id]?.fallback ?? Icons.crop_square;
