import 'package:barley/barley.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';

import '../main.dart';
import 'dock/dock_controller.dart';
import 'file_io.dart';
import 'panels/panel_def.dart';
import 'recents.dart';
import 'workspace_view_model.dart';

/// One open document: engine session + editor state + tab bookkeeping.
/// The "Document Session" of UI-013 — the tab itself owns no data.
final class DocumentTab {
  DocumentTab(this.vm, {this.path, required this.savedRevision});

  final WorkspaceViewModel vm;

  /// Where the project was last saved/opened; null until first save.
  String? path;

  /// Document revision at last save — dirty tracks persistent data
  /// changes only (UI-013), not viewport/selection/undo availability.
  int savedRevision;

  /// Set by the shell after the tab's first frame ran [vm.onReady].
  bool readied = false;

  String get title => vm.session.document.name;
  bool get dirty => vm.session.document.revision != savedRevision;
}

/// Application-level state (UI-010/011/012): open document tabs, the
/// active workspace (Home vs Editor), and the recent-projects index.
/// No document is ever auto-created; the app boots to Home.
final class AppViewModel extends BarleyViewModel {
  AppViewModel({required this.recents, DockController? dock})
      : dock = dock ?? DockController.memory(panelIds: defaultPanelIds) {
    // Menus (Window > Show/Hide panel) reflect dock changes.
    this.dock.addListener(notify);
  }

  final RecentsStore recents;

  /// Workspace dock layout — application chrome shared across document
  /// tabs (FR-1003), never document state.
  final DockController dock;

  final tabs = <DocumentTab>[];

  /// Active tab index; -1 = the pinned Home tab.
  int active = -1;

  DocumentTab? get activeTab => active < 0 ? null : tabs[active];

  /// Whether the Save button should be visible (has an active dirty document).
  bool get canSave => activeTab != null && activeTab!.dirty;

  @override
  void onReady() {
    recents.load().then((_) => notify());
    dock.load();
  }

  void goHome() {
    active = -1;
    notify();
  }

  void activate(int index) {
    active = index;
    notify();
  }

  /// New Project "Create": the document is configured at construction
  /// (never mutated post-hoc), optionally saved when a location is given.
  Future<DocumentTab> createProject({
    required String name,
    required HoopSettings hoop,
    ProjectUnits units = ProjectUnits.mm,
    ColorProfile colorProfile = ColorProfile.srgb,
    String? location,
  }) async {
    final document = Document(
      id: Id('doc-${DateTime.now().microsecondsSinceEpoch}'),
      name: name,
      hoop: hoop,
      units: units,
      colorProfile: colorProfile,
    );
    final tab = _addTab(StudioSession(document: document));
    if (location != null) await saveTab(tab, location);
    notify();
    return tab;
  }

  Future<DocumentTab> openProject(String path) async {
    for (final tab in tabs) {
      if (tab.path == path) {
        activate(tabs.indexOf(tab));
        return tab;
      }
    }
    final document = decodeProject(await readFileString(path));
    final tab = _addTab(StudioSession(document: document), path: path);
    _recordRecent(tab);
    notify();
    return tab;
  }

  Future<void> saveTab(DocumentTab tab, String path) async {
    await tab.vm.saveTo(path);
    tab.path = path;
    tab.savedRevision = tab.vm.session.document.revision;
    _recordRecent(tab);
    notify();
  }

  /// Closes the tab; the view is responsible for the dirty-save prompt.
  /// Closing the last tab returns to Home — the app keeps running.
  void closeTab(int index) {
    final tab = tabs.removeAt(index);
    tab.vm.dispose();
    if (tabs.isEmpty) {
      active = -1;
    } else if (active >= index) {
      active = (active - 1).clamp(0, tabs.length - 1);
    }
    notify();
  }

  void removeRecent(String path) {
    recents.remove(path);
    notify();
  }

  void clearRecents() {
    recents.clear();
    notify();
  }

  bool projectFileExists(String path) => fileExists(path);

  /// Test hook: wraps a pre-built engine session in an active tab.
  DocumentTab adoptSession(StudioSession session) => _addTab(session);

  DocumentTab _addTab(StudioSession session, {String? path}) {
    final tab = DocumentTab(
      WorkspaceViewModel(session: session),
      path: path,
      savedRevision: session.document.revision,
    );
    // Tab chrome (title, dirty star) reflects editor changes.
    tab.vm.addListener(notify);
    tabs.add(tab);
    active = tabs.length - 1;
    return tab;
  }

  void _recordRecent(DocumentTab tab) {
    final path = tab.path;
    if (path == null) return;
    final doc = tab.vm.session.document;
    recents.record(RecentProject(
      name: doc.name,
      path: path,
      hoopWidthMm: doc.hoop.widthMm,
      hoopHeightMm: doc.hoop.heightMm,
      lastOpened: DateTime.now(),
    ));
  }
}
