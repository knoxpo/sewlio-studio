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

  /// Set while re-editing a committed object: commit replaces it.
  Id? _editingId;

  Point? _dragFrom;
  Point? _dragTo;

  /// True while an insertion point is active on the canvas.
  bool get editing => _anchor != null;

  String get text => _text;

  int get caret => _caret;

  /// The committed object being re-edited, if any.
  Id? get editingId => _editingId;

  @override
  void tap(Point world) {
    if (editing) commit();
    _anchor = world;
    _frameWidthMm = null;
    _text = '';
    _caret = 0;
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
    notifyListeners();
  }

  // ------------------------------------------------------------- editing
  //
  // The buffer is edited at the caret (rune-indexed). ponytail: no
  // selection range yet — add shift+arrows/select-all when asked.

  void insert(String characters) {
    if (!editing) return;
    final runes = _text.runes.toList()..insertAll(_caret, characters.runes);
    _text = String.fromCharCodes(runes);
    _caret += characters.runes.length;
    notifyListeners();
  }

  /// Deletes the rune before the caret (Backspace).
  void backspace() {
    if (!editing || _caret == 0) return;
    final runes = _text.runes.toList()..removeAt(_caret - 1);
    _text = String.fromCharCodes(runes);
    _caret--;
    notifyListeners();
  }

  /// Deletes the rune after the caret (Delete / Fn+Backspace).
  void deleteForward() {
    final runes = _text.runes.toList();
    if (!editing || _caret >= runes.length) return;
    runes.removeAt(_caret);
    _text = String.fromCharCodes(runes);
    notifyListeners();
  }

  /// Moves the caret by [delta] runes, clamped to the buffer.
  void moveCaret(int delta) {
    if (!editing) return;
    _caret = (_caret + delta).clamp(0, _text.runes.length);
    notifyListeners();
  }

  /// Moves the caret to the start (`home`) or end (`!home`) of the
  /// buffer.
  void moveCaretToEdge({required bool home}) {
    if (!editing) return;
    _caret = home ? 0 : _text.runes.length;
    notifyListeners();
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
    _editingId = object.id;
    notifyListeners();
  }

  /// Commits the buffer as one editable TextObject with cached glyph
  /// outlines, and leaves editing mode.
  void commit() {
    final anchor = _anchor;
    if (anchor != null && _text.trim().isNotEmpty) {
      final object = TextObject(
        id: _editingId ?? nextId(),
        path: Path(start: anchor),
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

  @override
  List<Path> get preview {
    final paths = <Path>[];
    // Frame rubber band while dragging.
    final from = _dragFrom, to = _dragTo;
    if (from != null && to != null) {
      paths.add(_rect(from, to));
    }
    final anchor = _anchor;
    if (anchor == null) return paths;
    // Frame outline for area text.
    final frame = _frameWidthMm;
    if (frame != null) {
      final lines = wrapText(_text, font,
          sizeMm: sizeMm, trackingMm: trackingMm, frameWidthMm: frame);
      final height = (lines.length - 1) * lineHeight * sizeMm + sizeMm;
      final topLeft = Point(anchor.x, anchor.y - sizeMm);
      paths.add(_rect(topLeft, Point(topLeft.x + frame, topLeft.y + height)));
    }
    paths.addAll(layoutText(
      _text,
      font,
      origin: anchor,
      sizeMm: sizeMm,
      trackingMm: trackingMm,
      lineHeight: lineHeight,
      align: align,
      frameWidthMm: _frameWidthMm,
    ));
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
      lineHeight: lineHeight,
      align: align,
      frameWidthMm: _frameWidthMm,
    );
    paths.add(Path(
      start: caret,
      segments: [LineSegment(Point(caret.x, caret.y - sizeMm))],
    ));
    return paths;
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
}
