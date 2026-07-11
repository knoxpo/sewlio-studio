import 'package:flutter/material.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_tools/studio_tools.dart';

/// What the canvas shows for one semantic [ToolCursor]: a native mouse
/// cursor, optionally replaced by a canvas-painted glyph (system cursor
/// hidden) where no OS cursor exists or tool identity matters.
final class CursorSpec {
  const CursorSpec(this.native, [this.painted]);

  final MouseCursor native;
  final PaintedCursor? painted;
}

/// Cursor foundation: semantic defaults for every [ToolCursor], plus
/// per-tool-id overrides so a domain tool can claim its own cursor
/// (pen nib vs satin cursor) without new ToolCursor values.
final class CursorRegistry {
  /// Semantic defaults (moved verbatim from WorkspaceViewModel).
  static const _defaults = <ToolCursor, CursorSpec>{
    ToolCursor.basic: CursorSpec(SystemMouseCursors.basic),
    ToolCursor.crosshair: CursorSpec(SystemMouseCursors.precise),
    ToolCursor.text: CursorSpec(SystemMouseCursors.text),
    ToolCursor.move: CursorSpec(SystemMouseCursors.move),
    ToolCursor.grab: CursorSpec(SystemMouseCursors.grab),
    ToolCursor.grabbing: CursorSpec(SystemMouseCursors.grabbing),
    ToolCursor.zoomIn: CursorSpec(SystemMouseCursors.zoomIn),
    ToolCursor.zoomOut: CursorSpec(SystemMouseCursors.zoomOut),
    ToolCursor.resizeNS: CursorSpec(SystemMouseCursors.resizeUpDown),
    ToolCursor.resizeEW: CursorSpec(SystemMouseCursors.resizeLeftRight),
    // Painted by the canvas (system cursor hidden): pen family, plus
    // rotation and diagonal resize — macOS ships no public cursors for
    // those, so native mapping renders a plain arrow there.
    ToolCursor.rotate: CursorSpec(SystemMouseCursors.none, PaintedCursor.rotate),
    ToolCursor.resizeNWSE:
        CursorSpec(SystemMouseCursors.none, PaintedCursor.resizeNWSE),
    ToolCursor.resizeNESW:
        CursorSpec(SystemMouseCursors.none, PaintedCursor.resizeNESW),
    ToolCursor.pen: CursorSpec(SystemMouseCursors.none, PaintedCursor.penStart),
    ToolCursor.penAdd:
        CursorSpec(SystemMouseCursors.none, PaintedCursor.penAdd),
    ToolCursor.penMinus:
        CursorSpec(SystemMouseCursors.none, PaintedCursor.penRemove),
    ToolCursor.penClose:
        CursorSpec(SystemMouseCursors.none, PaintedCursor.penClose),
  };

  final _overrides = <String, Map<ToolCursor, CursorSpec>>{};

  /// Overrides [kinds] for [toolId]; unlisted kinds keep the defaults.
  void register(String toolId, Map<ToolCursor, CursorSpec> kinds) {
    _overrides[toolId] = kinds;
  }

  /// The cursor to show for [toolId] wanting semantic [kind]. Unknown
  /// tool ids fall back to the semantic defaults.
  CursorSpec resolve(String toolId, ToolCursor kind) =>
      _overrides[toolId]?[kind] ?? _defaults[kind]!;
}

/// App-wide cursor registry. Built-in design tools ride the semantic
/// defaults; stitch tools claim a precise crosshair now and get painted
/// identity cursors when they become real.
// TODO: painted stitch cursors need additive PaintedCursor enum values
// in studio_canvas — added alongside the first live stitch tool.
final cursorRegistry = CursorRegistry()
  ..register('stitch.run',
      const {ToolCursor.basic: CursorSpec(SystemMouseCursors.precise)})
  ..register('stitch.satin',
      const {ToolCursor.basic: CursorSpec(SystemMouseCursors.precise)})
  ..register('stitch.fill',
      const {ToolCursor.basic: CursorSpec(SystemMouseCursors.precise)})
  ..register('stitch.trim',
      const {ToolCursor.basic: CursorSpec(SystemMouseCursors.precise)})
  ..register('stitch.sequence',
      const {ToolCursor.basic: CursorSpec(SystemMouseCursors.click)});
