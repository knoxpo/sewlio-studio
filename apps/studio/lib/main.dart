import 'package:flutter/material.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_events/studio_events.dart';

import 'src/shell.dart';

void main() {
  runApp(StudioApp(session: StudioSession()));
}

/// Composition root: wires the pure-Dart engine (document, buses,
/// history) that the Flutter shell renders. Flutter never mutates state
/// directly — everything goes through [commands] (ARCH-003).
final class StudioSession {
  StudioSession() {
    registry
      ..register<Clock>(const SystemClock())
      ..register<IdGenerator>(SequentialIdGenerator(prefix: 'doc'));
    document = Document(id: registry.get<IdGenerator>().next());
    commands = CommandBus(events);
    history = History(commands);
    registerDocumentHandlers(commands, document);
  }

  final registry = ServiceRegistry();
  final events = EventBus();
  late final Document document;
  late final CommandBus commands;
  late final History history;
}

class StudioApp extends StatelessWidget {
  const StudioApp({super.key, required this.session});

  final StudioSession session;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sewlio Studio',
      theme: ThemeData(colorSchemeSeed: AppTokens.seed, useMaterial3: true),
      home: StudioShell(session: session),
    );
  }
}
