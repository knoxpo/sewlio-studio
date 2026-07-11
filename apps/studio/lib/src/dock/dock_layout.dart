import 'dart:convert';

/// One tabbed container in the dock: an ordered set of panel tabs, the
/// active tab, its share of the dock height, and a collapsed flag
/// (collapsed groups render their tab bar only).
final class DockGroup {
  DockGroup({
    required this.panelIds,
    String? activeId,
    this.flex = 1.0,
    this.collapsed = false,
  }) : activeId = activeId ?? panelIds.first;

  final List<String> panelIds;
  String activeId;
  double flex;
  bool collapsed;

  Map<String, Object?> toJson() => {
        'panels': panelIds,
        'active': activeId,
        'flex': flex,
        'collapsed': collapsed,
      };

  factory DockGroup.fromJson(Map<String, Object?> json) => DockGroup(
        panelIds: [for (final id in json['panels'] as List) id as String],
        activeId: json['active'] as String?,
        flex: (json['flex'] as num?)?.toDouble() ?? 1.0,
        collapsed: json['collapsed'] as bool? ?? false,
      );
}

/// The right-dock layout (FR-1204/FR-1003): a vertical stack of tabbed
/// groups plus the set of hidden panels. Application chrome, never
/// document state — shared across document tabs.
// ponytail: right dock only. Multi-zone (left/bottom) and floating
// windows extend this with a zone key per group when they arrive.
final class DockLayout {
  DockLayout({
    this.width = defaultWidth,
    required this.groups,
    Set<String>? hidden,
  }) : hidden = hidden ?? {};

  static const defaultWidth = 300.0;
  static const minWidth = 220.0;
  static const maxWidth = 480.0;

  double width;
  final List<DockGroup> groups;
  final Set<String> hidden;

  /// The out-of-the-box layout: one group with every registered panel;
  /// no groups at all for panel-less modes (planned domain modules).
  factory DockLayout.defaults(List<String> panelIds) =>
      DockLayout.grouped([panelIds]);

  /// A default layout of stacked tab groups, one per row.
  factory DockLayout.grouped(List<List<String>> rows) => DockLayout(groups: [
        for (final row in rows)
          if (row.isNotEmpty) DockGroup(panelIds: [...row])
      ]);

  String encode() => jsonEncode({
        'version': 1,
        'width': width,
        'hidden': hidden.toList(),
        'groups': [for (final g in groups) g.toJson()],
      });

  factory DockLayout.decode(String source) {
    final json = (jsonDecode(source) as Map).cast<String, Object?>();
    return DockLayout(
      width: (json['width'] as num?)?.toDouble() ?? defaultWidth,
      hidden: {for (final id in json['hidden'] as List? ?? []) id as String},
      groups: [
        for (final g in json['groups'] as List)
          DockGroup.fromJson((g as Map).cast<String, Object?>()),
      ],
    );
  }

  /// Repairs the layout against the current panel registry: unknown
  /// panel ids are dropped, panels missing from both groups and hidden
  /// are appended to the last group, empty groups are removed, active
  /// tabs and width are clamped to valid values.
  void normalize(List<String> registeredIds) {
    final known = registeredIds.toSet();
    hidden.retainWhere(known.contains);
    final placed = <String>{...hidden};
    for (final group in groups) {
      group.panelIds.retainWhere((id) => known.contains(id) && placed.add(id));
    }
    groups.removeWhere((g) => g.panelIds.isEmpty);
    final missing = registeredIds.where((id) => !placed.contains(id));
    if (missing.isNotEmpty) {
      if (groups.isEmpty) {
        groups.add(DockGroup(panelIds: [...missing]));
      } else {
        groups.last.panelIds.addAll(missing);
      }
    }
    for (final group in groups) {
      if (!group.panelIds.contains(group.activeId)) {
        group.activeId = group.panelIds.first;
      }
      if (group.flex <= 0) group.flex = 1.0;
    }
    width = width.clamp(minWidth, maxWidth);
  }
}
