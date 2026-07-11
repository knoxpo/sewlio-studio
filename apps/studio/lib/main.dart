import 'package:flutter/material.dart';
import 'package:studio_ai/studio_ai.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_events/studio_events.dart';

import 'src/app_shell.dart';
import 'src/app_view_model.dart';
import 'src/dock/dock_controller.dart';
import 'src/file_io.dart';
import 'src/panels/panel_def.dart';
import 'src/recents.dart';
import 'src/tools/tool_contributions.dart';

void main() {
  // Tool-contributed dockable panels join the registry before the dock
  // builds its layout (ADR-037); plugin panels will append here too.
  panelRegistry.addAll(toolContributedPanels());
  final recentsPath = appStatePath('recents.json');
  final dockPath = appStatePath('workspace_layout.json');
  runApp(StudioApp(
    recents:
        recentsPath == null ? RecentsStore.memory() : RecentsStore(recentsPath),
    dock: dockPath == null
        ? null
        : DockController(dockPath, panelIds: defaultPanelIds),
  ));
}

/// Composition root: wires the pure-Dart engine (document, buses,
/// history) that the Flutter shell renders. Flutter never mutates state
/// directly — everything goes through [commands] (ARCH-003).
final class StudioSession {
  StudioSession({Document? document}) {
    registry
      ..register<Clock>(const SystemClock())
      ..register<IdGenerator>(SequentialIdGenerator(prefix: 'obj'));
    this.document =
        document ?? Document(id: registry.get<IdGenerator>().next());
    commands = CommandBus(events);
    history = History(commands);
    registerDocumentHandlers(commands, this.document);
    // Assistant hook (MVP): "rename to <name>" proposes a command; UI
    // for prompting arrives with the Phase 3 AI runtime.
    assistant.register((input) {
      final match =
          RegExp(r'^rename to (.+)$', caseSensitive: false).firstMatch(input);
      return match == null ? const [] : [RenameDocument(match.group(1)!)];
    });
  }

  final registry = ServiceRegistry();
  final events = EventBus();
  final assistant = Assistant();
  late final Document document;
  late final CommandBus commands;
  late final History history;
}

class StudioApp extends StatefulWidget {
  const StudioApp({super.key, this.session, this.recents, this.dock});

  /// When given, opens as an already-active document tab (test hook —
  /// production startup always lands on the Home Workspace).
  final StudioSession? session;
  final RecentsStore? recents;
  final DockController? dock;

  @override
  State<StudioApp> createState() => _StudioAppState();
}

class _StudioAppState extends State<StudioApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Rebuild on both the in-app theme choice and OS light/dark flips
    // (the latter matters when the mode is ThemeMode.system).
    WidgetsBinding.instance.addObserver(this);
    studioThemeMode.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    studioThemeMode.removeListener(_onThemeChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onThemeChanged() => setState(() {});

  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final dark = switch (studioThemeMode.value) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };
    AppTokens.setDark(dark);
    return MaterialApp(
      title: 'Sewlio Studio',
      theme: studioTheme(),
      debugShowCheckedModeBanner: false,
      home: AppShell(create: () {
        final app = AppViewModel(
            recents: widget.recents ?? RecentsStore.memory(),
            dock: widget.dock);
        if (widget.session != null) app.adoptSession(widget.session!);
        return app;
      }),
    );
  }
}
