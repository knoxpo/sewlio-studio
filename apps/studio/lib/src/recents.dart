import 'dart:convert';

import 'file_io.dart';

/// One entry in the recent-projects index (UI-608): lightweight metadata
/// only — the project file is never loaded until opened.
final class RecentProject {
  const RecentProject({
    required this.name,
    required this.path,
    required this.hoopWidthMm,
    required this.hoopHeightMm,
    required this.lastOpened,
  });

  final String name;
  final String path;
  final double hoopWidthMm;
  final double hoopHeightMm;
  final DateTime lastOpened;

  Map<String, Object?> toJson() => {
        'name': name,
        'path': path,
        'hoopWidthMm': hoopWidthMm,
        'hoopHeightMm': hoopHeightMm,
        'lastOpened': lastOpened.toIso8601String(),
      };

  factory RecentProject.fromJson(Map<String, Object?> json) => RecentProject(
        name: json['name'] as String,
        path: json['path'] as String,
        hoopWidthMm: (json['hoopWidthMm'] as num).toDouble(),
        hoopHeightMm: (json['hoopHeightMm'] as num).toDouble(),
        lastOpened: DateTime.parse(json['lastOpened'] as String),
      );
}

/// Recent-projects index persisted as a JSON file (application state,
/// never document state). Most-recent-first, capped, tolerant of a
/// missing or corrupt file.
final class RecentsStore {
  RecentsStore(this.path);

  /// No-persistence store for tests and platforms without file IO.
  RecentsStore.memory() : path = null;

  static const _cap = 20;

  final String? path;
  final List<RecentProject> entries = [];

  Future<void> load() async {
    final file = path;
    if (file == null || !fileExists(file)) return;
    try {
      final decoded = jsonDecode(await readFileString(file)) as List;
      entries
        ..clear()
        ..addAll([
          for (final item in decoded)
            RecentProject.fromJson((item as Map).cast<String, Object?>()),
        ]);
    } catch (_) {
      // Corrupt index is not worth failing startup over — start empty.
      entries.clear();
    }
  }

  /// Upserts by project path, most-recent-first.
  void record(RecentProject project) {
    entries
      ..removeWhere((e) => e.path == project.path)
      ..insert(0, project);
    if (entries.length > _cap) entries.removeRange(_cap, entries.length);
    _save();
  }

  void remove(String projectPath) {
    entries.removeWhere((e) => e.path == projectPath);
    _save();
  }

  void clear() {
    entries.clear();
    _save();
  }

  void _save() {
    final file = path;
    if (file == null) return;
    ensureParentDir(file);
    writeFileString(file, jsonEncode([for (final e in entries) e.toJson()]));
  }
}
