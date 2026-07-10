import 'dart:async';
import 'dart:collection';

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
import 'file_io.dart';
import 'font_library.dart';
import 'stroke_style.dart';

enum ToolKind {
  select,
  node,
  hoop,
  pen,
  pencil,
  shape,
  text,
  pan,
  zoom,
  measure,
}

/// Prepared machine-file bytes, or the reason there are none.
final class ExportResult {
  const ExportResult({this.bytes, this.error, this.skipped = 0});
  final Uint8List? bytes;
  final String? error;
  final int skipped;
}

/// Primary editor workspaces, switched from the app header.
enum WorkspaceMode { design, stitchPreview, simulation }

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
  var showRulers = true;

  /// Which workspace the editor shows (header segmented control).
  var mode = WorkspaceMode.design;

  // View-only visualization toggles (canvas toolbar). Never touch the
  // document — they only change what the canvas paints.
  var showStitches = true;
  var showOutlines = true;
  var showNeedleHoles = false;

  void toggleShowStitches() {
    showStitches = !showStitches;
    notify();
  }

  void toggleShowOutlines() {
    showOutlines = !showOutlines;
    notify();
  }

  void toggleShowNeedleHoles() {
    showNeedleHoles = !showNeedleHoles;
    notify();
  }

  void setMode(WorkspaceMode value) {
    if (mode == value) return;
    mode = value;
    notify();
  }

  /// Bound by the view each build: the Hoop tool opens Document Setup.
  void Function()? onOpenHoopSetup;

  /// Last-used tool per toolbox flyout group (slot memory).
  final toolGroupMemory = <String, ToolKind>{};

  /// Stroke defaults edited via the Pen options bar's Stroke popup.
  final strokeStyle = StrokeStyle();

  /// Object-backed stroke defaults stamped onto new objects
  /// (fill/stroke v1: width, cap, join, miter limit, color).
  StrokeProps get strokeDefaults => StrokeProps(
        widthMm: strokeStyle.widthMm,
        cap: strokeStyle.cap.name,
        join: strokeStyle.join.name,
        miterLimit: strokeStyle.miterLimit,
        colorHex: strokeColorHex,
        fillHex: strokeStyle.useFill ? fillColorHex : null,
      );

  /// Stroke shown by the Stroke popup: the primary selection's when
  /// something is selected, else the defaults.
  StrokeProps get activeStroke =>
      primarySelectedObject?.stroke ?? strokeDefaults;

  /// Applies [mutate] to every selected object (one undoable
  /// ReplaceObject each) and mirrors the change into the defaults so
  /// the next drawn object matches.
  void setStroke(StrokeProps Function(StrokeProps) mutate) {
    final d = mutate(strokeDefaults);
    strokeStyle
      ..widthMm = d.widthMm
      ..miterLimit = d.miterLimit
      ..cap = LineCapStyle.values.asNameMap()[d.cap] ?? LineCapStyle.round
      ..join = LineJoinStyle.values.asNameMap()[d.join] ?? LineJoinStyle.round;
    if (d.colorHex != null) strokeColorHex = d.colorHex!;
    for (final id in selectedObjectIds) {
      final object = session.document.objectById(id);
      if (object != null) {
        execute(ReplaceObject(object.withStroke(mutate(object.stroke))));
      }
    }
    notify();
  }

  // Fill/stroke chips (toolbox). ponytail: stored as the upcoming
  // defaults — objects gain fill/stroke when the color system lands.
  String fillColorHex = '#ffffff';
  String strokeColorHex = '#1c1c1e';
  bool strokeChipActive = false;

  void swapFillStroke() {
    final f = fillColorHex;
    fillColorHex = strokeColorHex;
    strokeColorHex = f;
    notify();
  }

  void resetFillStroke() {
    fillColorHex = '#ffffff';
    strokeColorHex = '#1c1c1e';
    notify();
  }

  StreamSubscription<Object?>? _eventSub;

  Tool get tool => tools[activeKind]!;
  ShapeTool get shapeTool => tools[ToolKind.shape]! as ShapeTool;
  bool get canUndo => session.history.canUndo;
  bool get canRedo => session.history.canRedo;

  /// Hoop + fabric setup (document content).
  HoopSettings get hoop => session.document.hoop;

  /// Machine limits derived from the document hoop.
  MachineModel get machine => MachineModel(
        name: '${hoop.widthMm.round()} × ${hoop.heightMm.round()} mm',
        hoopWidthMm: hoop.widthMm,
        hoopHeightMm: hoop.heightMm,
      );

  /// Replaces the hoop/fabric setup (undoable command).
  void updateHoop(HoopSettings settings) =>
      session.history.execute(UpdateHoop(settings));
  DocumentNodeRef? get primarySelection => selection.primarySelectedRef;
  EmbroideryObject? get primarySelectedObject =>
      primarySelection?.kind == DocumentNodeKind.object
          ? session.document.objectById(primarySelection!.id)
          : null;
  Set<Id> get selectedObjectIds => LinkedHashSet<Id>.from(selection.selectedIds)
    ..addAll([
      for (final ref in selection.selectedRefs)
        ...session.document.subtreeObjectIds(ref),
    ]);
  g.Bounds? get selectionBounds =>
      session.document.selectionBounds(selection.selectedRefs);

  /// The digitized Stitch IR for the current document.
  // ponytail: re-digitized on every read — cache per document revision
  // when designs get big enough to notice.
  StitchSequence get sequence =>
      digitizeObjects(session.document.flattenVisibleObjects());

  /// Stitches-panel glyph highlight: a text object's outline range
  /// [start, end). View state only — never touches the document.
  ({Id id, int start, int end})? stitchHighlight;

  void setStitchHighlight(({Id id, int start, int end})? value) {
    stitchHighlight = value;
    notify();
  }

  /// Stitch ops for the highlighted glyph, re-derived on every read
  /// (same generator as the real sequence) so undo/redo and text edits
  /// can never desynchronize it. Empty when the object or range no
  /// longer exists — stale highlights degrade silently.
  List<StitchOp> get highlightedStitchOps {
    final h = stitchHighlight;
    if (h == null) return const [];
    final object = session.document.objectById(h.id);
    if (object is! TextObject ||
        h.start < 0 ||
        h.start >= h.end ||
        h.end > object.outlines.length) {
      return const [];
    }
    final ops = <StitchOp>[];
    for (final outline in object.outlines.sublist(h.start, h.end)) {
      final run =
          generateRunningStitch(outline, stitchLength: object.stitchLength);
      if (run.isEmpty) continue;
      // Pen break between contours so the highlight doesn't draw a
      // connecting line across glyph parts.
      if (ops.isNotEmpty) ops.add(StitchOp.jump(run.first.position));
      ops.addAll(run);
    }
    return ops;
  }

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
      ToolKind.pen: PenTool(
        onCreate: addPath,
        onReplace: (id, path) {
          final object = session.document.objectById(id);
          if (object != null) execute(ReplaceObject(object.withPath(path)));
        },
      ),
      ToolKind.pencil: PencilTool(onCreate: addPath),
      ToolKind.shape: ShapeTool(onCreate: addPath),
      ToolKind.text: TextTool(
        nextId: nextId,
        onCreateObject: (object) => execute(
            AddObject(object.withStroke(strokeDefaults), parent: activeParent)),
        onReplaceObject: (object) => execute(ReplaceObject(object)),
      ),
      ToolKind.pan: PanTool(),
      ToolKind.zoom: ZoomTool(onZoom: (world, magnify) {
        viewport.zoomAt(viewport.worldToScreen(world), magnify);
        notify();
      }),
      ToolKind.hoop: HoopTool(onOpenSetup: () => onOpenHoopSetup?.call()),
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
    // Illustrator behavior: activating the Pen with an open polyline
    // selected loads it for continuation — anchors editable, commit
    // replaces the object.
    if (kind == ToolKind.pen) _loadPenContinuation();
    notify();
  }

  void _loadPenContinuation() {
    final object = primarySelectedObject;
    if (object is! RunningStitchObject || object.path.closed) return;
    final segments = object.path.segments;
    if (!segments.every((s) => s is g.LineSegment)) return;
    (tools[ToolKind.pen]! as PenTool).editExisting(object.id, [
      object.path.start,
      for (final segment in segments) segment.end,
    ]);
  }

  /// Pen bar "Use fill": fills new closed objects with the fill chip
  /// color; with a selection it fills / unfills the selected objects.
  void setUseFill(bool value) {
    strokeStyle.useFill = value;
    for (final id in selectedObjectIds) {
      final object = session.document.objectById(id);
      if (object != null) {
        execute(ReplaceObject(object.withStroke(value
            ? object.stroke.copyWith(fillHex: fillColorHex)
            : object.stroke.copyWith(clearFill: true))));
      }
    }
    notify();
  }

  /// Fill chip color: remembered for new objects; re-fills the
  /// selection when fill is enabled.
  void setFillColor(String hex) {
    fillColorHex = hex;
    if (strokeStyle.useFill) setUseFill(true);
    notify();
  }

  /// Stroke chip color: applies to selection + defaults.
  void setStrokeColor(String hex) =>
      setStroke((p) => p.copyWith(colorHex: hex));

  /// Shape flyout pick: optionally switch the shape kind, activate.
  void activateShape(ShapeKind? kind) {
    if (kind != null) shapeTool.kind = kind;
    if (activeKind != ToolKind.shape) {
      tool.cancel();
      activeKind = ToolKind.shape;
    }
    notify();
  }

  /// Active insertion target (ADR-028): the selected layer, or the
  /// ancestor layer of the selected node; default layer as fallback.
  HierarchyParentRef get activeParent {
    var ref = primarySelection;
    while (ref != null && ref.kind != DocumentNodeKind.layer) {
      final parent = session.document.parentOf(ref);
      ref = parent == null ? null : DocumentNodeRef(parent.kind, parent.id);
    }
    return HierarchyParentRef(
        DocumentNodeKind.layer, ref?.id ?? session.document.defaultLayer.id);
  }

  /// Creation tools commit here: new running-stitch object per path,
  /// inserted into the active layer with the current stroke defaults.
  void addPath(g.Path path) {
    execute(AddObject(
      RunningStitchObject(id: nextId(), path: path, stroke: strokeDefaults),
      parent: activeParent,
    ));
  }

  /// Double-click: with the Select tool, a hit on a text object
  /// re-enters in-place text editing (ADR-028); otherwise the active
  /// tool gets the event (pen finishes its path here).
  void onCanvasDoubleTap(g.Point world) {
    if (activeKind == ToolKind.select) {
      final hit = _textObjectAt(world);
      if (hit != null) {
        _beginTextEdit(hit);
        return;
      }
    }
    tool.doubleTap(world);
  }

  Future<void> _beginTextEdit(TextObject object) async {
    final font = await FontLibrary.instance.load(object.fontFamily);
    selectTool(ToolKind.text);
    selection.select(null);
    (tools[ToolKind.text]! as TextTool).editExisting(object, font);
    notify();
  }

  DateTime? _lastTapAt;
  g.Point? _lastTapWorld;

  /// Manual double-click detection. The canvas deliberately has no
  /// DoubleTapGestureRecognizer: its 100px slop swallowed pairs of
  /// rapid pen clicks (points vanished) and added 300ms latency to
  /// every single click.
  bool _isDoubleTap(g.Point world) {
    final now = DateTime.now();
    final isDouble = _lastTapAt != null &&
        now.difference(_lastTapAt!).inMilliseconds < 350 &&
        _lastTapWorld != null &&
        world.distanceTo(_lastTapWorld!) <= 8 / viewport.zoom;
    if (isDouble) {
      _lastTapAt = null; // a triple click is not two doubles
      _lastTapWorld = null;
    } else {
      _lastTapAt = now;
      _lastTapWorld = world;
    }
    return isDouble;
  }

  void onCanvasTap(
    g.Point world, {
    required bool toggle,
    required bool extend,
  }) {
    if (_isDoubleTap(world)) {
      onCanvasDoubleTap(world);
      return;
    }
    if (tool case final SelectTool selectTool) {
      selectTool.tapWithModifiers(world, toggle: toggle, extend: extend);
      return;
    }
    if (tool case final ZoomTool zoom) {
      zoom.outModifier = HardwareKeyboard.instance.isAltPressed;
    }
    // Text tool on an existing text object: re-enter editing instead
    // of opening a new insertion point on top of it.
    if (tool case final TextTool text) {
      final hit = _textObjectAt(world);
      if (hit != null) {
        // Already editing this object — keep the session (don't
        // recommit and reset the caret on every click).
        if (text.editing && text.editingId == hit.id) return;
        _beginTextEdit(hit);
        return;
      }
    }
    _feedPenModifiers();
    tool.tap(world);
  }

  /// Topmost visible, unlocked text object under [world], if any.
  TextObject? _textObjectAt(g.Point world) {
    for (final object in session.document.flattenVisibleObjects().reversed) {
      if (object is TextObject &&
          !session.document.isObjectLocked(object.id) &&
          object.bounds().contains(world)) {
        return object;
      }
    }
    return null;
  }

  /// Shift/Ctrl constrain pen points to 45° (both, covering macOS and
  /// Windows/Linux conventions).
  void _feedPenModifiers() {
    if (tools[ToolKind.pen] case final PenTool pen) {
      pen.constrainAngles = HardwareKeyboard.instance.isShiftPressed ||
          HardwareKeyboard.instance.isControlPressed;
    }
  }

  bool onCanvasDragStart(
    g.Point world, {
    required bool toggle,
    required bool extend,
  }) {
    if (tool case final SelectTool selectTool) {
      return selectTool.dragStartWithModifiers(
        world,
        toggle: toggle,
        extend: extend,
      );
    }
    return tool.dragStart(world);
  }

  void undo() => session.history.undo();
  void redo() => session.history.redo();

  void execute(Command command) => session.history.execute(command);

  /// Next free object id. Opened documents restore their stored ids
  /// ('obj-N'), while each session's sequential generator restarts at
  /// 1 — skip anything already taken so new nodes never collide.
  Id nextId() {
    final generator = session.registry.get<IdGenerator>();
    final document = session.document;
    var id = generator.next();
    while (document.objects.containsKey(id) ||
        document.groupById(id) != null ||
        document.layerById(id) != null ||
        document.guideById(id) != null) {
      id = generator.next();
    }
    return id;
  }

  void selectRef(
    DocumentNodeRef? ref, {
    bool toggle = false,
    bool extend = false,
  }) {
    if (ref == null) {
      if (!toggle && !extend) selection.clear();
      return;
    }
    if (toggle || extend) {
      selection.toggle(ref);
      return;
    }
    selection.replaceWith(ref);
  }

  void createLayer() {
    final index = session.document.layers.length;
    final layer = LayerNode(id: nextId(), name: 'Layer ${index + 1}');
    execute(AddLayer(layer));
    selectRef(DocumentNodeRef(DocumentNodeKind.layer, layer.id));
  }

  void createGroupFromSelection() {
    if (selection.selectedRefs.isEmpty) return;
    final group = GroupNode(id: nextId(), name: 'Group');
    execute(GroupSelection(group, selection.selectedRefs));
    selectRef(DocumentNodeRef(DocumentNodeKind.group, group.id));
  }

  void ungroupPrimary() {
    final ref = primarySelection;
    if (ref == null || ref.kind != DocumentNodeKind.group) return;
    execute(UngroupGroup(ref.id));
    selectRef(null);
  }

  void deletePrimary() {
    final ref = primarySelection;
    if (ref == null) return;
    execute(DeleteNode(ref));
    selectRef(null);
  }

  void duplicatePrimary() {
    final ref = primarySelection;
    if (ref == null) return;
    final subtree = session.document.duplicateSubtree(ref, nextId);
    if (ref.kind == DocumentNodeKind.layer) {
      final index = session.document.indexOfLayer(ref.id);
      execute(DuplicateNode(subtree, index: index + 1));
    } else {
      final parent = session.document.parentOf(ref);
      if (parent == null) return;
      final index = session.document.indexOfChild(parent, ref);
      execute(DuplicateNode(subtree, parent: parent, index: index + 1));
    }
    selectRef(subtree.root);
  }

  void moveNode(
    DocumentNodeRef ref, {
    HierarchyParentRef? parent,
    int? index,
  }) {
    execute(MoveNode(ref, parent: parent, index: index));
  }

  void rename(String name) {
    if (name.isNotEmpty) session.history.execute(RenameDocument(name));
  }

  // -------------------------------------------------------------- shortcuts

  /// Shortcut → tool group. A repeated press cycles through the
  /// group's tools (Affinity-style).
  static final _shortcuts = {
    LogicalKeyboardKey.keyV: [ToolKind.select],
    LogicalKeyboardKey.keyA: [ToolKind.node],
    LogicalKeyboardKey.keyD: [ToolKind.hoop],
    LogicalKeyboardKey.keyP: [ToolKind.pen, ToolKind.pencil],
    LogicalKeyboardKey.keyB: [ToolKind.pencil],
    LogicalKeyboardKey.keyM: [ToolKind.shape],
    LogicalKeyboardKey.keyT: [ToolKind.text],
    LogicalKeyboardKey.keyH: [ToolKind.pan],
    LogicalKeyboardKey.keyZ: [ToolKind.zoom],
    LogicalKeyboardKey.keyR: [ToolKind.measure],
  };

  /// True while a text field owns focus — tool shortcuts must not
  /// steal typed characters.
  bool get _typing =>
      FocusManager.instance.primaryFocus?.context?.widget is EditableText;

  KeyEventResult onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || _typing) return KeyEventResult.ignored;
    // In-place text editing captures the keyboard: characters go to the
    // buffer, not to tool shortcuts.
    if (tool case final TextTool text when text.editing) {
      return _onTextKey(text, event);
    }
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    // Modifier chords (⌘S save, ⌘Z undo, …) belong to the menus —
    // single-key tool/view shortcuts must not steal them.
    if (HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isAltPressed) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      tool.cancel();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyX) {
      swapFillStroke();
      return KeyEventResult.handled;
    }
    // View toggles (canvas toolbar).
    if (event.logicalKey == LogicalKeyboardKey.keyS) {
      toggleShowStitches();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyO) {
      toggleShowOutlines();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyN) {
      toggleShowNeedleHoles();
      return KeyEventResult.handled;
    }
    final group = _shortcuts[event.logicalKey];
    if (group == null) return KeyEventResult.ignored;
    final index = group.indexOf(activeKind);
    selectTool(index < 0 ? group.first : group[(index + 1) % group.length]);
    return KeyEventResult.handled;
  }

  /// Canvas typing (KeyDown + KeyRepeat): Enter commits, Shift+Enter
  /// breaks the line, Esc commits, Backspace deletes.
  KeyEventResult _onTextKey(TextTool text, KeyEvent event) {
    // Let menu chords (⌘S, ⌘Z, …) through even while typing.
    if (HardwareKeyboard.instance.isMetaPressed ||
        HardwareKeyboard.instance.isControlPressed) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.enter &&
            !HardwareKeyboard.instance.isShiftPressed) {
      text.commit();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter) {
      text.newline();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      text.backspace();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete) {
      text.deleteForward();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      text.moveCaret(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      text.moveCaret(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.home) {
      text.moveCaretToEdge(home: true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.end) {
      text.moveCaretToEdge(home: false);
      return KeyEventResult.handled;
    }
    final character = event.character;
    if (character != null &&
        character.isNotEmpty &&
        !character.codeUnits.every((c) => c < 32)) {
      text.insert(character);
      return KeyEventResult.handled;
    }
    // Swallow everything else so tool shortcuts can't fire mid-typing.
    return KeyEventResult.handled;
  }

  // --------------------------------------------------------------- viewport

  /// Fits the design (or the hoop when empty) into the canvas area.
  /// The hoop is anchored with its top-left corner at world 0,0.
  void fitCanvas() {
    var bounds = g.Bounds(0, 0, machine.hoopWidthMm, machine.hoopHeightMm);
    for (final object in session.document.flattenVisibleObjects()) {
      bounds = bounds.union(object.bounds());
    }
    viewport.fitBounds(bounds);
  }

  void zoomBy(double factor) {
    final size = viewport.viewSize;
    final center =
        size == null ? Offset.zero : Offset(size.width / 2, size.height / 2);
    viewport.zoomAt(center, factor);
  }

  void toggleRulers() {
    showRulers = !showRulers;
    notify();
  }

  /// Hoop preset picked in the hoop panel.
  void setMachine(MachineModel value) => updateHoop(
      hoop.copyWith(widthMm: value.hoopWidthMm, heightMm: value.hoopHeightMm));

  void hover(g.Point world) {
    cursor.value = world;
    _feedPenModifiers();
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

  void addGuide(
      GuideAxis axis, double positionMm, String name, String? colorHex) {
    session.history.execute(AddGuide(Guide(
      id: nextId(),
      axis: axis,
      positionMm: positionMm,
      name: name,
      colorHex: colorHex,
    )));
  }

  void updateGuide(
      Guide existing, double positionMm, String name, String? colorHex) {
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
    final seq = digitizeObjects(session.document.flattenVisibleObjects(),
        skipped: skipped);
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
