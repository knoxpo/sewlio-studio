import 'package:flutter/foundation.dart';

import '../file_io.dart';
import 'dock_layout.dart';

/// Owns the dock layout and persists it as application state
/// (`~/.sewlio_studio/workspace_layout.json`), following the
/// [RecentsStore] pattern: tolerant load, save on mutation, `.memory()`
/// for tests and platforms without file IO.
final class DockController extends ChangeNotifier {
  DockController(this.path, {required this.panelIds, List<List<String>>? rows})
      : defaultRows = rows ?? [panelIds],
        layout = DockLayout.grouped(rows ?? [panelIds]);

  /// No-persistence controller for tests and web.
  DockController.memory({required this.panelIds, List<List<String>>? rows})
      : path = null,
        defaultRows = rows ?? [panelIds],
        layout = DockLayout.grouped(rows ?? [panelIds]);

  final String? path;

  /// Registered panel ids, in default order.
  final List<String> panelIds;

  /// Out-of-the-box tab groups (one list per stacked row).
  final List<List<String>> defaultRows;

  DockLayout layout;

  bool isVisible(String id) =>
      layout.groups.any((g) => g.panelIds.contains(id));

  Future<void> load() async {
    final file = path;
    if (file == null || !fileExists(file)) return;
    try {
      layout = DockLayout.decode(await readFileString(file));
    } catch (_) {
      // Corrupt layout is not worth failing startup over — use defaults.
      layout = DockLayout.grouped(defaultRows);
    }
    layout.normalize(panelIds);
    notifyListeners();
  }

  void selectTab(String id) {
    final group = _groupOf(id);
    if (group == null || group.activeId == id) return;
    group.activeId = id;
    save();
  }

  /// Moves a panel tab into [group] at [tabIndex] (join / reorder).
  void movePanel(String id, {required DockGroup group, required int tabIndex}) {
    final from = _groupOf(id);
    if (from == null) return;
    final fromIndex = from.panelIds.indexOf(id);
    if (identical(from, group) && fromIndex < tabIndex) tabIndex -= 1;
    from.panelIds.remove(id);
    group.panelIds.insert(tabIndex.clamp(0, group.panelIds.length), id);
    group.activeId = id;
    _normalizeAndSave();
  }

  /// Tears a panel out into its own new group at [groupIndex].
  void splitOut(String id, {required int groupIndex}) {
    final from = _groupOf(id);
    if (from == null) return;
    if (from.panelIds.length == 1) {
      // Already alone: just reposition the group.
      final oldIndex = layout.groups.indexOf(from);
      layout.groups.remove(from);
      if (oldIndex < groupIndex) groupIndex -= 1;
      layout.groups.insert(groupIndex.clamp(0, layout.groups.length), from);
      _normalizeAndSave();
      return;
    }
    from.panelIds.remove(id);
    layout.groups.insert(
      groupIndex.clamp(0, layout.groups.length),
      DockGroup(panelIds: [id], flex: from.flex),
    );
    _normalizeAndSave();
  }

  /// Window-menu toggle: hidden panels leave the dock; showing appends
  /// to the last group and activates.
  void togglePanel(String id) {
    if (!panelIds.contains(id)) return;
    if (layout.hidden.remove(id)) {
      if (layout.groups.isEmpty) {
        layout.groups.add(DockGroup(panelIds: [id]));
      } else {
        layout.groups.last.panelIds.add(id);
      }
      layout.groups.last.activeId = id;
    } else {
      layout.hidden.add(id);
    }
    _normalizeAndSave();
  }

  void toggleCollapsed(DockGroup group) {
    group.collapsed = !group.collapsed;
    save();
  }

  /// Splitter drag: shifts [deltaFlex] from the group below to the one
  /// above (already clamped by the host, which knows pixel heights).
  /// Not persisted per-tick — call [save] on drag end.
  void resizePair(DockGroup above, DockGroup below, double deltaFlex) {
    above.flex += deltaFlex;
    below.flex -= deltaFlex;
    notifyListeners();
  }

  /// Width-handle drag; call [save] on drag end.
  void resizeWidth(double width) {
    layout.width = width.clamp(DockLayout.minWidth, DockLayout.maxWidth);
    notifyListeners();
  }

  void resetToDefault() {
    layout = DockLayout.grouped(defaultRows);
    save();
  }

  DockGroup? _groupOf(String id) {
    for (final group in layout.groups) {
      if (group.panelIds.contains(id)) return group;
    }
    return null;
  }

  void _normalizeAndSave() {
    layout.normalize(panelIds);
    save();
  }

  void save() {
    notifyListeners();
    final file = path;
    if (file == null) return;
    ensureParentDir(file);
    writeFileString(file, layout.encode());
  }
}
