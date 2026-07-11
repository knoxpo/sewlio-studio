import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/workspace/cursor_registry.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  test('every semantic ToolCursor resolves to a spec', () {
    for (final kind in ToolCursor.values) {
      expect(cursorRegistry.resolve('core.select', kind), isNotNull,
          reason: kind.name);
    }
  });

  test('pen family resolves to painted cursors over a hidden native', () {
    final spec = cursorRegistry.resolve('core.pen', ToolCursor.pen);
    expect(spec.native, SystemMouseCursors.none);
    expect(spec.painted, PaintedCursor.penStart);
  });

  test('tool override wins; unlisted kinds fall through to defaults', () {
    final registry = CursorRegistry()
      ..register('x.tool',
          const {ToolCursor.basic: CursorSpec(SystemMouseCursors.precise)});
    expect(registry.resolve('x.tool', ToolCursor.basic).native,
        SystemMouseCursors.precise);
    expect(registry.resolve('x.tool', ToolCursor.grab).native,
        SystemMouseCursors.grab);
  });

  test('unknown tool id falls back to semantic defaults', () {
    expect(cursorRegistry.resolve('nope.tool', ToolCursor.text).native,
        SystemMouseCursors.text);
  });

  test('stitch tool placeholders claim identity cursors', () {
    expect(cursorRegistry.resolve('stitch.run', ToolCursor.basic).native,
        SystemMouseCursors.precise);
  });
}
