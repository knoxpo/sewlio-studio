import 'dart:async';

import 'package:barley/barley.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_export/studio_export.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;
import 'package:studio_import/studio_import.dart';
import 'package:studio_machine/studio_machine.dart';
import 'package:studio_tools/studio_tools.dart';

import '../main.dart';
import 'bottom_panel.dart';
import 'file_io.dart';

enum ToolKind { select, node, pen, pencil, shape, text, pan, measure }

/// Prepared machine-file bytes, or the reason there are none.
final class ExportResult {
  const ExportResult({this.bytes, this.error, this.skipped = 0});
  final Uint8List? bytes;
  final String? error;
  final int skipped;
}

/// All workspace state and logic (barley MVVM). The view renders this
/// model and forwards gestures/dialog results; every document mutation
/// still flows through commands (ARCH-003).
final class WorkspaceViewModel extends BarleyViewModel {
  WorkspaceViewModel({required StudioSession session}) {
    _bind(session);
  }

  late StudioSession session;
  final viewport = ViewportController();
  final selection = SelectionController();
  final cursor = ValueNotifier<g.Point?>(null);

  late Map<ToolKind, Tool> tools;
  ToolKind activeKind = ToolKind.select;
  MachineModel machine = hoopPresets.first;
  var showRulers = true;

  /// Bound by the view: asks the user for a string (Text tool).
  Future<String?> Function()? onPromptText;

  StreamSubscription<Object?>? _eventSub;

  Tool get tool => tools[activeKind]!;
  ShapeTool get shapeTool => tools[ToolKind.shape]! as ShapeTool;
  bool get canUndo => session.history.canUndo;
  bool get canRedo => session.history.canRedo;

  /// The digitized Stitch IR for the current document.
  // ponytail: re-digitized on every read — cache per document revision
  // when designs get big enough to notice.
  StitchSequence get sequence => digitizeObjects(session.document.objects);

  void _bind(StudioSession next) {
    _eventSub?.cancel();
    session = next;
    selection.select(null);
    tools = {
      ToolKind.select: SelectTool(
        document: session.document,
        history: session.history,
        selection: selection,
      ),
      ToolKind.node: NodeTool(
        document: session.document,
        history: session.history,
        selection: selection,
      ),
      ToolKind.pen: PenTool(onCreate: addPath),
      ToolKind.pencil: PencilTool(onCreate: addPath),
      ToolKind.shape: ShapeTool(onCreate: addPath),
      ToolKind.text: TextTool(
        onRequestText: () async => onPromptText == null
            ? null
            : await onPromptText!(),
        onCreate: addPath,
      ),
      ToolKind.pan: PanTool(),
      ToolKind.measure: MeasureTool(),
    };
    for (final t in tools.values) {
      t.addListener(notify);
    }
    activeKind = ToolKind.select;
    selection.addListener(notify);
    _eventSub = session.events.events.listen((_) => notify());
    notify();
  }

  @override
  void onReady() => fitCanvas();

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  // ------------------------------------------------------------------ tools

  void selectTool(ToolKind kind) {
    if (kind == activeKind) return;
    tool.cancel();
    activeKind = kind;
    notify();
  }

  /// Shape flyout pick: optionally switch the shape kind, activate.
  void activateShape(ShapeKind? kind) {
    if (kind != null) shapeTool.kind = kind;
    if (activeKind != ToolKind.shape) {
      tool.cancel();
      activeKind = ToolKind.shape;
    }
    notify();
  }

  /// Creation tools commit here: new running-stitch object per path.
  void addPath(g.Path path) {
    session.history.execute(AddObject(RunningStitchObject(
      id: session.registry.get<IdGenerator>().next(),
      path: path,
    )));
  }

  void undo() => session.history.undo();
  void redo() => session.history.redo();

  void execute(Command command) => session.history.execute(command);

  void rename(String name) {
    if (name.isNotEmpty) session.history.execute(RenameDocument(name));
  }

  // -------------------------------------------------------------- shortcuts

  static final _shortcuts = {
    LogicalKeyboardKey.keyV: ToolKind.select,
    LogicalKeyboardKey.keyA: ToolKind.node,
    LogicalKeyboardKey.keyP: ToolKind.pen,
    LogicalKeyboardKey.keyB: ToolKind.pencil,
    LogicalKeyboardKey.keyM: ToolKind.shape,
    LogicalKeyboardKey.keyT: ToolKind.text,
    LogicalKeyboardKey.keyH: ToolKind.pan,
    LogicalKeyboardKey.keyR: ToolKind.measure,
  };

  /// True while a text field owns focus — tool shortcuts must not
  /// steal typed characters.
  bool get _typing =>
      FocusManager.instance.primaryFocus?.context?.widget is EditableText;

  KeyEventResult onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || _typing) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      tool.cancel();
      return KeyEventResult.handled;
    }
    final kind = _shortcuts[event.logicalKey];
    if (kind == null) return KeyEventResult.ignored;
    selectTool(kind);
    return KeyEventResult.handled;
  }

  // --------------------------------------------------------------- viewport

  /// Fits the design (or the hoop when empty) into the canvas area.
  /// The hoop is anchored with its top-left corner at world 0,0.
  void fitCanvas() {
    var bounds = g.Bounds(0, 0, machine.hoopWidthMm, machine.hoopHeightMm);
    for (final object in session.document.objects) {
      bounds = bounds.union(object.path.bounds());
    }
    viewport.fitBounds(bounds);
  }

  void zoomBy(double factor) {
    final size = viewport.viewSize;
    final center = size == null
        ? Offset.zero
        : Offset(size.width / 2, size.height / 2);
    viewport.zoomAt(center, factor);
  }

  void toggleRulers() {
    showRulers = !showRulers;
    notify();
  }

  void setMachine(MachineModel value) {
    machine = value;
    notify();
  }

  void hover(g.Point world) {
    cursor.value = world;
    tool.hover(world);
  }

  // ----------------------------------------------------------------- guides

  Color guideColorOf(Guide guide) => guide.colorHex == null
      ? const Color(0xFF26C6DA)
      : Color(0xFF000000 | int.parse(guide.colorHex!.substring(1), radix: 16));

  List<RulerMarker> markersFor(GuideAxis axis) => [
        for (final guide in session.document.guides)
          if (guide.axis == axis)
            RulerMarker(
                positionMm: guide.positionMm, color: guideColorOf(guide)),
      ];

  /// Nearest guide on [axis] within ruler-click tolerance, or null.
  Guide? guideAt(GuideAxis axis, double mm) {
    final tolerance = 6 / viewport.zoom;
    for (final guide in session.document.guides) {
      if (guide.axis == axis && (guide.positionMm - mm).abs() <= tolerance) {
        return guide;
      }
    }
    return null;
  }

  void addGuide(GuideAxis axis, double positionMm, String name,
      String? colorHex) {
    session.history.execute(AddGuide(Guide(
      id: session.registry.get<IdGenerator>().next(),
      axis: axis,
      positionMm: positionMm,
      name: name,
      colorHex: colorHex,
    )));
  }

  void updateGuide(Guide existing, double positionMm, String name,
      String? colorHex) {
    session.history.execute(UpdateGuide(Guide(
      id: existing.id,
      axis: existing.axis,
      positionMm: positionMm,
      name: name,
      colorHex: colorHex,
    )));
  }

  void removeGuide(Id id) => session.history.execute(RemoveGuide(id));

  // -------------------------------------------------------------- files

  bool fileExistsAt(String path) => fileExists(path);

  Future<void> saveTo(String path) =>
      writeFileString(path, encodeProject(session.document));

  /// Opens the project at [path], rebinding the whole session.
  /// Returns the document name.
  Future<String> openFrom(String path) async {
    final document = decodeProject(await readFileString(path));
    _bind(StudioSession(document: document));
    WidgetsBinding.instance.addPostFrameCallback((_) => fitCanvas());
    return document.name;
  }

  /// Imports SVG outlines as objects; returns how many paths landed.
  Future<int> importSvgFrom(String path) async {
    final paths = importSvg(await readFileString(path));
    for (final p in paths) {
      addPath(p);
    }
    return paths.length;
  }

  /// Digitizes, compiles, validates, and encodes the design for
  /// [suffix] ('.dst' or '.exp').
  ExportResult prepareExport(String suffix) {
    final skipped = <EmbroideryObject>[];
    final seq = digitizeObjects(session.document.objects, skipped: skipped);
    if (seq.ops.isEmpty) return const ExportResult(error: 'Nothing to export');
    // Machine coordinates are hoop-centered; design space anchors the
    // hoop's top-left at 0,0.
    final program = compileToMachine(
      seq,
      machine: machine,
      origin: g.Point(machine.hoopWidthMm / 2, machine.hoopHeightMm / 2),
    );
    final sink = CollectingSink();
    if (!program.validate(machine, sink)) {
      return ExportResult(
          error: 'Export blocked: ${sink.diagnostics.first.message}');
    }
    final bytes =
        suffix == '.dst' ? encodeDst(program) : encodeExp(program, sink: sink);
    if (sink.hasErrors) {
      return ExportResult(
          error: 'Export blocked: ${sink.diagnostics.first.message}');
    }
    return ExportResult(bytes: bytes, skipped: skipped.length);
  }

  Future<void> writeExport(String path, Uint8List bytes) =>
      writeFileBytes(path, bytes);
}
