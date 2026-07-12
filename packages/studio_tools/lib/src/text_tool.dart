import 'dart:math' as math;

import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';

import 'monoline_font.dart';
import 'text_font.dart';
import 'tool.dart';

/// In-place canvas text (Illustrator-style): click for point text, drag
/// for a wrapped text frame, type directly on the canvas — no dialog.
/// Enter commits (Shift+Enter breaks the line); Esc or a tool switch
/// commits too. Commits ONE editable [TextObject] (ADR-028) whose
/// cached glyph outlines feed rendering and stitch generation;
/// [editExisting] re-enters editing for a committed object.
final class TextTool extends Tool {
  TextTool({
    required this.nextId,
    required this.onCreateObject,
    required this.onReplaceObject,
  });

  final Id Function() nextId;
  final void Function(TextObject object) onCreateObject;
  final void Function(TextObject object) onReplaceObject;

  // Typography settings driven by the contextual toolbar.
  TextFont font = const MonolineTextFont();
  double sizeMm = 10;
  double trackingMm = 0;
  double lineHeight = 1.4;
  MonoTextAlign align = MonoTextAlign.left;

  Point? _anchor;
  double? _frameWidthMm;
  String _text = '';

  /// Caret position as a rune index into [text] (0 = before the first
  /// character).
  int _caret = 0;

  /// The other end of the selection (rune index). Equal to [_caret]
  /// means a collapsed caret; otherwise `[selectionStart, selectionEnd)`
  /// is selected. Runs live on the committed [TextObject]; the tool only
  /// tracks text + caret + anchor.
  int _selectionAnchor = 0;

  /// Set while re-editing a committed object: commit replaces it.
  Id? _editingId;

  Point? _dragFrom;
  Point? _dragTo;

  /// True while an insertion point is active on the canvas.
  bool get editing => _anchor != null;

  String get text => _text;

  int get caret => _caret;

  /// Ordered selection bounds (rune indices) and whether a range is
  /// selected (vs. a collapsed caret).
  int get selectionStart => math.min(_selectionAnchor, _caret);
  int get selectionEnd => math.max(_selectionAnchor, _caret);
  bool get hasSelection => _selectionAnchor != _caret;

  /// The committed object being re-edited, if any.
  Id? get editingId => _editingId;

  @override
  void tap(Point world) {
    if (editing) commit();
    _anchor = world;
    _frameWidthMm = null;
    _text = '';
    _caret = 0;
    _selectionAnchor = 0;
    notifyListeners();
  }

  @override
  bool dragStart(Point world) {
    if (editing) commit();
    _dragFrom = world;
    _dragTo = world;
    notifyListeners();
    return true;
  }

  @override
  void dragUpdate(Point world) {
    _dragTo = world;
    notifyListeners();
  }

  @override
  void dragEnd() {
    final from = _dragFrom, to = _dragTo;
    _dragFrom = null;
    _dragTo = null;
    if (from == null || to == null) return;
    final width = (to.x - from.x).abs();
    final left = from.x < to.x ? from.x : to.x;
    final top = from.y < to.y ? from.y : to.y;
    if (width < font.advanceMm(0x4D /* M */, sizeMm)) {
      tap(from); // Too small for a frame: treat as point text.
      return;
    }
    _anchor = Point(left, top + sizeMm); // First baseline inside frame.
    _frameWidthMm = width;
    _text = '';
    _caret = 0;
    _selectionAnchor = 0;
    notifyListeners();
  }

  // ------------------------------------------------------------- editing
  //
  // The buffer is edited at the caret (rune-indexed). A non-collapsed
  // selection is replaced by inserts/deletes. Runs live on the committed
  // TextObject, so the tool only tracks text + caret + anchor.

  /// Removes the current selection from the buffer and collapses the
  /// caret to its start. No-op when nothing is selected.
  void _deleteSelection() {
    final start = selectionStart, end = selectionEnd;
    final runes = _text.runes.toList()..removeRange(start, end);
    _text = String.fromCharCodes(runes);
    _caret = _selectionAnchor = start;
  }

  void insert(String characters) {
    if (!editing) return;
    if (hasSelection) _deleteSelection();
    final runes = _text.runes.toList()..insertAll(_caret, characters.runes);
    _text = String.fromCharCodes(runes);
    _caret += characters.runes.length;
    _selectionAnchor = _caret;
    notifyListeners();
  }

  /// Deletes the selection, or the rune before the caret (Backspace).
  void backspace() {
    if (!editing) return;
    if (hasSelection) {
      _deleteSelection();
      notifyListeners();
      return;
    }
    if (_caret == 0) return;
    final runes = _text.runes.toList()..removeAt(_caret - 1);
    _text = String.fromCharCodes(runes);
    _caret--;
    _selectionAnchor = _caret;
    notifyListeners();
  }

  /// Deletes the selection, or the rune after the caret (Delete).
  void deleteForward() {
    if (!editing) return;
    if (hasSelection) {
      _deleteSelection();
      notifyListeners();
      return;
    }
    final runes = _text.runes.toList();
    if (_caret >= runes.length) return;
    runes.removeAt(_caret);
    _text = String.fromCharCodes(runes);
    _selectionAnchor = _caret;
    notifyListeners();
  }

  /// Moves the caret by [delta] runes, clamped to the buffer. [extend]
  /// keeps the selection anchor (Shift+Arrow); otherwise the selection
  /// collapses to the new caret.
  void moveCaret(int delta, {bool extend = false}) {
    if (!editing) return;
    _caret = (_caret + delta).clamp(0, _text.runes.length);
    if (!extend) _selectionAnchor = _caret;
    notifyListeners();
  }

  /// Moves the caret to the start (`home`) or end (`!home`) of the
  /// buffer. [extend] keeps the selection anchor (Shift+Home/End).
  void moveCaretToEdge({required bool home, bool extend = false}) {
    if (!editing) return;
    _caret = home ? 0 : _text.runes.length;
    if (!extend) _selectionAnchor = _caret;
    notifyListeners();
  }

  /// Moves the caret to the previous (`dir < 0`) or next (`dir > 0`)
  /// word boundary. [extend] keeps the selection anchor (word-extend).
  void moveCaretByWord(int dir, {bool extend = false}) {
    if (!editing) return;
    final runes = _text.runes.toList();
    var c = _caret;
    if (dir < 0) {
      while (c > 0 && _charClass(runes[c - 1]) == 0) {
        c--;
      }
      if (c > 0) {
        final cls = _charClass(runes[c - 1]);
        while (c > 0 && _charClass(runes[c - 1]) == cls) {
          c--;
        }
      }
    } else {
      while (c < runes.length && _charClass(runes[c]) == 0) {
        c++;
      }
      if (c < runes.length) {
        final cls = _charClass(runes[c]);
        while (c < runes.length && _charClass(runes[c]) == cls) {
          c++;
        }
      }
    }
    _caret = c;
    if (!extend) _selectionAnchor = _caret;
    notifyListeners();
  }

  // ----------------------------------------------------------- selection

  /// Selects the whole buffer (Cmd/Ctrl+A).
  void selectAll() {
    if (!editing) return;
    _selectionAnchor = 0;
    _caret = _text.runes.length;
    notifyListeners();
  }

  /// Selects the word around rune [offset] (double-click).
  void selectWordAt(int offset) {
    if (!editing) return;
    final runes = _text.runes.toList();
    if (runes.isEmpty) {
      _selectionAnchor = _caret = 0;
      notifyListeners();
      return;
    }
    final o = offset.clamp(0, runes.length);
    final idx = o >= runes.length ? runes.length - 1 : o;
    final cls = _charClass(runes[idx]);
    var start = idx, end = idx + 1;
    while (start > 0 && _charClass(runes[start - 1]) == cls) {
      start--;
    }
    while (end < runes.length && _charClass(runes[end]) == cls) {
      end++;
    }
    _selectionAnchor = start;
    _caret = end;
    notifyListeners();
  }

  /// Selects the paragraph (between '\n' boundaries) around rune
  /// [offset] (triple-click).
  void selectParagraphAt(int offset) {
    if (!editing) return;
    final runes = _text.runes.toList();
    var start = offset.clamp(0, runes.length);
    var end = start;
    while (start > 0 && runes[start - 1] != 0x0A) {
      start--;
    }
    while (end < runes.length && runes[end] != 0x0A) {
      end++;
    }
    _selectionAnchor = start;
    _caret = end;
    notifyListeners();
  }

  // ponytail: simple char-class word rule — a run of letters/digits, a
  // run of whitespace, or a run of other (punctuation). No Unicode word
  // segmentation; good enough for Latin editing.
  static int _charClass(int rune) {
    if (rune == 0x20 || rune == 0x09 || rune == 0x0A) return 0; // whitespace
    final s = String.fromCharCode(rune);
    if (rune > 0x7F || RegExp(r'[A-Za-z0-9]').hasMatch(s)) return 1; // word
    return 2; // punctuation
  }

  /// Maps a canvas [world] point to the nearest rune boundary, using the
  /// same layout metrics as rendering. attrsOf is null: the tool buffer
  /// carries no runs (they live on the committed object), so the live
  /// caret/selection layout is uniform.
  int offsetAtPoint(Point world) {
    final anchor = _anchor;
    if (anchor == null) return _caret;
    final metrics = layoutLineMetrics(
      _text,
      font,
      origin: anchor,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      lineHeight: lineHeight,
      align: align,
      frameWidthMm: _frameWidthMm,
    );
    if (metrics.isEmpty) return 0;
    var line = metrics.first;
    var bestDy = (world.y - line.baselineY).abs();
    for (final m in metrics.skip(1)) {
      final dy = (world.y - m.baselineY).abs();
      if (dy < bestDy) {
        bestDy = dy;
        line = m;
      }
    }
    var bestI = 0;
    var bestDx = (world.x - line.xs.first).abs();
    for (var i = 1; i < line.xs.length; i++) {
      final dx = (world.x - line.xs[i]).abs();
      if (dx < bestDx) {
        bestDx = dx;
        bestI = i;
      }
    }
    return line.offsets[bestI];
  }

  /// Pointer-down inside the active text: collapse the selection to the
  /// nearest boundary. ponytail: the shell decides a pointer landed
  /// inside the editing box (vs. outside → commit) via hit-testing; the
  /// tool just maps the point.
  void pointerSelectStart(Point world) {
    if (!editing) return;
    _caret = _selectionAnchor = offsetAtPoint(world);
    notifyListeners();
  }

  /// Pointer-drag: extend the selection to the nearest boundary.
  void pointerSelectUpdate(Point world) {
    if (!editing) return;
    _caret = offsetAtPoint(world);
    notifyListeners();
  }

  @override
  void doubleTap(Point world) {
    if (editing) selectWordAt(offsetAtPoint(world));
  }

  void newline() => insert('\n');

  /// Loads a committed [object] back into in-place editing; the next
  /// commit replaces it (single undo step). [resolvedFont] is the
  /// loaded face for `object.fontFamily`.
  void editExisting(TextObject object, TextFont resolvedFont) {
    if (editing) commit();
    font = resolvedFont;
    sizeMm = object.sizeMm;
    trackingMm = object.trackingMm;
    lineHeight = object.lineHeight;
    align = MonoTextAlign.values.asNameMap()[object.alignment] ??
        MonoTextAlign.left;
    _anchor = object.anchor;
    _frameWidthMm = object.frameWidthMm;
    _text = object.text;
    _caret = object.text.runes.length;
    _selectionAnchor = _caret;
    _editingId = object.id;
    _stroke = object.stroke;
    notifyListeners();
  }

  // New text renders as solid glyphs by default (ADR-042): a fill plus a
  // matching outline. A single-stroke font (Monoline) has no interior, so
  // the fill branch is a no-op there — it stays an outline skeleton.
  // ponytail: one object color; per-run fill colors are a future add.
  static const _defaultTextStroke =
      StrokeProps(fillHex: '#111111', colorHex: '#111111');
  StrokeProps _stroke = _defaultTextStroke;

  /// Commits the buffer as one editable TextObject with cached glyph
  /// outlines, and leaves editing mode.
  void commit() {
    final anchor = _anchor;
    if (anchor != null && _text.trim().isNotEmpty) {
      final object = TextObject(
        id: _editingId ?? nextId(),
        path: Path(start: anchor),
        stroke: _editingId == null ? _defaultTextStroke : _stroke,
        text: _text,
        fontFamily: font.family,
        sizeMm: sizeMm,
        trackingMm: trackingMm,
        lineHeight: lineHeight,
        alignment: align.name,
        frameWidthMm: _frameWidthMm,
        outlines: layoutText(
          _text,
          font,
          origin: anchor,
          sizeMm: sizeMm,
          trackingMm: trackingMm,
          lineHeight: lineHeight,
          align: align,
          frameWidthMm: _frameWidthMm,
        ),
      );
      _editingId == null ? onCreateObject(object) : onReplaceObject(object);
    }
    _anchor = null;
    _frameWidthMm = null;
    _text = '';
    _caret = 0;
    _selectionAnchor = 0;
    _editingId = null;
    notifyListeners();
  }

  /// Tool switch / Escape: commit whatever was typed (Illustrator
  /// behavior) rather than losing it.
  @override
  void cancel() {
    if (editing) commit();
    _dragFrom = null;
    _dragTo = null;
  }

  // ------------------------------------------------------------- preview

  /// Stroked overlays only: the drag rubber band, the area-text frame,
  /// and the insertion caret. Glyph fills and the selection block are
  /// returned by [previewFills] / [selectionHighlights] so the canvas
  /// fills them instead of stroking (solid text, blue selection block).
  @override
  List<Path> get preview {
    final paths = <Path>[];
    final from = _dragFrom, to = _dragTo;
    if (from != null && to != null) {
      paths.add(_rect(from, to));
    }
    final anchor = _anchor;
    if (anchor == null) return paths;
    final frame = _frameWidthMm;
    if (frame != null) {
      final lines = wrapText(_text, font,
          sizeMm: sizeMm, trackingMm: trackingMm, frameWidthMm: frame);
      final height = (lines.length - 1) * lineHeight * sizeMm + sizeMm;
      final topLeft = Point(anchor.x, anchor.y - sizeMm);
      paths.add(_rect(topLeft, Point(topLeft.x + frame, topLeft.y + height)));
    }
    // Insertion caret: vertical bar at the caret position. ponytail:
    // computed by laying out the prefix — near a wrap boundary in area
    // text the prefix may wrap differently than the full text, shifting
    // the bar a word; exact caret geometry comes with selection support.
    final prefix = String.fromCharCodes(_text.runes.take(_caret));
    final caret = layoutCaret(
      prefix,
      font,
      origin: anchor,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      align: align,
      lineHeight: lineHeight,
      frameWidthMm: _frameWidthMm,
    );
    paths.add(Path(
      start: caret,
      segments: [LineSegment(Point(caret.x, caret.y - sizeMm))],
    ));
    return paths;
  }

  /// Glyph contours to fill live, so editing text renders solid like the
  /// committed object (not a stroked outline).
  @override
  List<Path> get previewFills {
    final anchor = _anchor;
    if (anchor == null) return const [];
    return layoutText(
      _text,
      font,
      origin: anchor,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      lineHeight: lineHeight,
      align: align,
      frameWidthMm: _frameWidthMm,
    );
  }

  @override
  String? get previewFillColor => _stroke.fillHex;

  @override
  List<Path> get selectionHighlights {
    final anchor = _anchor;
    if (anchor == null) return const [];
    return _selectionRects(anchor);
  }

  /// One filled rect per visual line spanning the selected runes, using
  /// the same layout metrics as the glyphs.
  List<Path> _selectionRects(Point anchor) {
    if (!hasSelection) return const [];
    final metrics = layoutLineMetrics(
      _text,
      font,
      origin: anchor,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      lineHeight: lineHeight,
      align: align,
      frameWidthMm: _frameWidthMm,
    );
    final start = selectionStart, end = selectionEnd;
    final rects = <Path>[];
    for (final m in metrics) {
      int? lo, hi;
      for (var i = 0; i < m.offsets.length; i++) {
        final o = m.offsets[i];
        if (o >= start && o <= end) {
          lo ??= i;
          hi = i;
        }
      }
      if (lo == null || hi == null || hi == lo) continue;
      final top = m.baselineY - sizeMm, bottom = m.baselineY;
      rects.add(_rect(Point(m.xs[lo], top), Point(m.xs[hi], bottom)));
    }
    return rects;
  }

  static Path _rect(Point a, Point b) => Path(
        start: a,
        segments: [
          LineSegment(Point(b.x, a.y)),
          LineSegment(b),
          LineSegment(Point(a.x, b.y)),
        ],
        closed: true,
      );

  @override
  String? get status => editing
      ? 'Text: type on canvas — Enter commits, Shift+Enter breaks the line'
      : 'Text: click for point text, drag for a text frame';

  @override
  ToolCursor cursorAt(Point world) =>
      _dragFrom != null ? ToolCursor.crosshair : ToolCursor.text;
}
