/// Persistent production type of a project (ARCH-034). NOT a UI mode:
/// the workspace modes (Design / Domain / Simulation) are view state,
/// while the project type is project metadata that resolves what the
/// Domain and Simulation modes contribute.
// ponytail: app-level enum until the type persists into .swl files —
// then it moves behind studio_document with an ADR.
enum ProjectType { embroidery, weaving }

extension ProjectTypeId on ProjectType {
  /// Stable string id ('embroidery', 'weaving') for persistence and
  /// registry lookups.
  String get id => name;
}
