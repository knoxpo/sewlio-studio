import 'package:flutter_test/flutter_test.dart';
import 'package:studio/src/panels/panel_registry.dart';
import 'package:studio/src/toolbox.dart';
import 'package:studio/src/tools/tool_contributions.dart';
import 'package:studio/src/workspace_view_model.dart';

void main() {
  test('contribution ids are unique and namespaced', () {
    final ids = [for (final c in toolContributions) c.id];
    expect(ids.toSet(), hasLength(ids.length));
    for (final id in ids) {
      expect(id, contains('.'), reason: 'ids are namespaced (core.*)');
    }
  });

  test('one contribution per tool kind, shortcuts collision-free', () {
    final kinds = [for (final c in toolContributions) c.kind];
    expect(kinds.toSet(), hasLength(kinds.length));
    final keys = [
      for (final c in toolContributions)
        if (c.shortcutKey != null) c.shortcutKey!,
    ];
    expect(keys.toSet(), hasLength(keys.length));
  });

  test('shortcut cycles start with the owning tool', () {
    for (final c in toolContributions) {
      final cycle = c.shortcutCycle;
      if (cycle != null) expect(cycle.first, c.kind, reason: c.id);
    }
  });

  test('every real toolbox entry resolves to a contribution', () {
    for (final group in toolboxGroups) {
      for (final tool in group.tools) {
        final kind = tool.kind;
        if (kind == null) continue; // "coming soon" placeholder
        final c = toolContributionFor(kind);
        expect(c, isNotNull, reason: '${tool.label} has no contribution');
        expect(c!.label, tool.label);
        expect(c.shortcutLabel, tool.shortcut);
      }
    }
    // The shapes slot is special-cased in the rail but still registered.
    expect(toolContributionFor(ToolKind.shape), isNotNull);
  });

  test('derived shortcut map matches the registry', () {
    final map = buildToolShortcuts();
    for (final c in toolContributions) {
      if (c.shortcutKey == null) continue;
      expect(map[c.shortcutKey], c.shortcutCycle ?? [c.kind]);
    }
  });

  test('contributed panel ids are unique across the whole registry', () {
    final ids = [for (final p in panelRegistry) p.id];
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('select tool owns the transform panel (ADR-044 reference)', () {
    final select = toolContributionById('core.select');
    expect([for (final p in select.panels) p.id], contains('transform'));
    expect(select.createTool, isNotNull);
    expect(panelById('transform').title, 'Transform');
  });
}
