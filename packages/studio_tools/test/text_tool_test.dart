import 'package:flutter_test/flutter_test.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  late List<TextObject> created;
  late List<TextObject> replaced;
  late TextTool tool;
  var ids = 0;

  setUp(() {
    created = [];
    replaced = [];
    ids = 0;
    tool = TextTool(
      nextId: () => Id('t${ids++}'),
      onCreateObject: created.add,
      onReplaceObject: replaced.add,
    );
  });

  test('tap starts editing; typing builds preview; commit creates paths', () {
    expect(tool.editing, isFalse);
    tool.tap(const Point(10, 20));
    expect(tool.editing, isTrue);
    expect(tool.preview, hasLength(1)); // caret only

    tool.insert('HI');
    expect(tool.text, 'HI');
    expect(tool.preview.length, greaterThan(1));
    expect(created, isEmpty); // nothing committed while typing

    tool.commit();
    expect(tool.editing, isFalse);
    // One editable object, not per-stroke paths (ADR-028).
    expect(created, hasLength(1));
    final object = created.single;
    expect(object.text, 'HI');
    expect(object.fontFamily, 'Monoline');
    // H = 3 strokes, I = 3 strokes of cached outline geometry.
    expect(object.renderPaths, hasLength(6));
    expect(object.anchor, const Point(10, 20));
  });

  test('backspace edits the buffer; empty commit creates nothing', () {
    tool.tap(Point.zero);
    tool.insert('AB');
    tool.backspace();
    expect(tool.text, 'A');
    tool.backspace();
    tool.commit();
    expect(created, isEmpty);
  });

  test('caret navigation: insert/backspace/delete edit at the caret', () {
    tool.tap(Point.zero);
    tool.insert('AC');
    expect(tool.caret, 2);

    tool.moveCaret(-1); // A|C
    tool.insert('B'); // AB|C
    expect(tool.text, 'ABC');
    expect(tool.caret, 2);

    tool.backspace(); // A|C
    expect(tool.text, 'AC');
    tool.deleteForward(); // A|
    expect(tool.text, 'A');

    tool.moveCaretToEdge(home: true);
    expect(tool.caret, 0);
    tool.backspace(); // caret at start: no-op
    expect(tool.text, 'A');
    tool.moveCaretToEdge(home: false);
    expect(tool.caret, 1);
    tool.deleteForward(); // caret at end: no-op
    expect(tool.text, 'A');

    tool.moveCaret(-5); // clamped
    expect(tool.caret, 0);
    tool.moveCaret(9);
    expect(tool.caret, 1);
  });

  test('editExisting places the caret at the end of the text', () {
    tool.tap(Point.zero);
    tool.insert('HI');
    tool.commit();
    tool.editExisting(created.single, const MonolineTextFont());
    expect(tool.caret, 2);
    tool.moveCaret(-2);
    tool.insert('O'); // O|HI
    expect(tool.text, 'OHI');
  });

  test('cancel (tool switch / Esc) commits typed text', () {
    tool.tap(Point.zero);
    tool.insert('I');
    tool.cancel();
    expect(created, hasLength(1));
    expect(tool.editing, isFalse);
  });

  test('editExisting reloads a committed object; commit replaces it', () {
    tool.tap(Point.zero);
    tool.insert('HI');
    tool.commit();
    final original = created.single;

    tool.editExisting(original, const MonolineTextFont());
    expect(tool.editing, isTrue);
    expect(tool.text, 'HI');
    tool.backspace();
    tool.insert('O');
    tool.commit();

    expect(replaced, hasLength(1));
    expect(replaced.single.id, original.id); // same object, one undo step
    expect(replaced.single.text, 'HO');
    expect(created, hasLength(1)); // no duplicate creation
  });

  test('tap while editing commits and restarts at the new point', () {
    tool.tap(Point.zero);
    tool.insert('I');
    tool.tap(const Point(50, 50));
    expect(created, hasLength(1)); // first text committed
    expect(tool.editing, isTrue);
    expect(tool.text, isEmpty);
  });

  test('newline moves the caret down by leading', () {
    tool.tap(Point.zero);
    tool.insert('I');
    final before = monoCaretPosition('I', origin: Point.zero);
    tool.newline();
    final after = monoCaretPosition('I\n', origin: Point.zero);
    expect(after.y - before.y, closeTo(tool.lineHeight * tool.sizeMm, 1e-9));
    expect(after.x, 0); // new line starts at the left edge
  });

  test('drag creates a wrapping text frame (area text)', () {
    tool.dragStart(Point.zero);
    tool.dragUpdate(const Point(30, 10));
    tool.dragEnd();
    expect(tool.editing, isTrue);

    // ~3 chars fit in 30mm at size 10 (advance ≈ 9.17mm).
    tool.insert('AA AA');
    final lines = monoWrapText('AA AA', sizeMm: 10, frameWidthMm: 30);
    expect(lines, ['AA', 'AA']);

    tool.commit();
    // A = 2 strokes × 4 glyphs of cached outline geometry.
    expect(created.single.renderPaths, hasLength(8));
    expect(created.single.frameWidthMm, isNotNull);
  });

  test('tiny drag falls back to point text', () {
    tool.dragStart(Point.zero);
    tool.dragUpdate(const Point(2, 1));
    tool.dragEnd();
    expect(tool.editing, isTrue);
    tool.insert('I');
    tool.commit();
    expect(created.single.frameWidthMm, isNull); // point text
    expect(created.single.renderPaths, hasLength(3));
  });

  test('glyphOutlineGroups partitions outlines per glyph in layout order', () {
    const font = MonolineTextFont();
    const text = 'KNOXPO';
    final groups = glyphOutlineGroups(text, font);
    expect(groups, hasLength(6));
    expect([for (final g in groups) g.char], ['K', 'N', 'O', 'X', 'P', 'O']);
    // Repeated characters stay distinguishable by layout index.
    expect(groups[2].index, 2);
    expect(groups[5].index, 5);
    // Counts partition the laid-out outlines exactly.
    final outlines = layoutText(text, font, origin: Point.zero);
    final totalCount = groups.fold<int>(0, (sum, g) => sum + g.outlineCount);
    expect(totalCount, outlines.length);
    // Spaces contribute zero outlines but keep their index slot.
    final spaced = glyphOutlineGroups('A B', font);
    expect(spaced, hasLength(3));
    expect(spaced[1].char, ' ');
    expect(spaced[1].outlineCount, 0);
  });

  test('alignment shifts committed geometry', () {
    tool
      ..align = MonoTextAlign.right
      ..tap(Point.zero)
      ..insert('I')
      ..commit();
    // Right-aligned point text ends at the anchor: all x <= 0.
    for (final path in created.single.renderPaths) {
      expect(path.start.x, lessThanOrEqualTo(0));
    }
    expect(created.single.alignment, 'right');
  });

  // ------------------------------------------------------- run-aware layout

  test('run-aware layout: a larger run size widens the advance', () {
    const font = MonolineTextFont();
    final uniform = layoutCaret('AB', font, origin: Point.zero, sizeMm: 10);
    final run = layoutCaret('AB', font,
        origin: Point.zero,
        sizeMm: 10,
        attrsOf: (o) => o == 0 ? const CharAttrs(sizeMm: 20) : CharAttrs.empty);
    // The double-size first glyph pushes the end caret further right.
    expect(run.x, greaterThan(uniform.x));
  });

  test('run-aware layout: baseline shift and hScale move/scale bounds', () {
    const font = MonolineTextFont();
    final base = _bounds(layoutText('A', font, origin: Point.zero, sizeMm: 10));
    // Baseline shift up by 5mm (up = -Y): both edges move up by 5.
    final shifted = _bounds(layoutText('A', font,
        origin: Point.zero,
        sizeMm: 10,
        attrsOf: (_) => const CharAttrs(baselineShiftMm: 5)));
    expect(shifted.minY, closeTo(base.minY - 5, 1e-6));
    expect(shifted.maxY, closeTo(base.maxY - 5, 1e-6));
    // Horizontal scale 2x about the glyph origin doubles the width.
    final scaled = _bounds(layoutText('A', font,
        origin: Point.zero,
        sizeMm: 10,
        attrsOf: (_) => const CharAttrs(hScale: 2)));
    expect(scaled.width, closeTo(base.width * 2, 1e-6));
  });

  test('offset threading: glyph indices are absolute rune offsets', () {
    const font = MonolineTextFont();
    // '\n' at offset 2 is dropped from layout; the next line keeps its
    // absolute offsets (3, 4), proving offsets thread through wrapping.
    final groups = glyphOutlineGroups('AB\nCD', font);
    expect([for (final g in groups) g.index], [0, 1, 3, 4]);
  });

  test('offset threading: a run transforms only its own line', () {
    const font = MonolineTextFont();
    final uniform = layoutText('AB\nCD', font, origin: Point.zero, sizeMm: 10);
    final run = layoutText('AB\nCD', font,
        origin: Point.zero,
        sizeMm: 10,
        attrsOf: (o) =>
            o >= 3 ? const CharAttrs(baselineShiftMm: 100) : CharAttrs.empty);
    // A + B = 4 strokes on line 1: unchanged.
    for (var i = 0; i < 4; i++) {
      expect(run[i].start.y, closeTo(uniform[i].start.y, 1e-9));
    }
    // C + D on line 2: lifted up by 100 (Y decreased).
    for (var i = 4; i < run.length; i++) {
      expect(run[i].start.y, closeTo(uniform[i].start.y - 100, 1e-9));
    }
  });

  // ------------------------------------------------------------- selection

  test('selection: click-drag via offsetAtPoint selects a range', () {
    tool.tap(Point.zero);
    tool.insert('HELLO');
    final adv = tool.font.advanceMm(0x48, tool.sizeMm);
    tool.pointerSelectStart(const Point(0, 0)); // before H
    tool.pointerSelectUpdate(Point(adv * 3, 0)); // through 3 glyphs
    expect(tool.hasSelection, isTrue);
    expect(tool.selectionStart, 0);
    expect(tool.selectionEnd, 3);
  });

  test('selection: Shift+Arrow extends; a plain move collapses', () {
    tool.tap(Point.zero);
    tool.insert('ABC'); // caret 3
    tool.moveCaret(-1, extend: true); // anchor 3, caret 2
    expect(tool.hasSelection, isTrue);
    expect(tool.selectionStart, 2);
    expect(tool.selectionEnd, 3);
    tool.moveCaret(-1); // collapses
    expect(tool.hasSelection, isFalse);
    expect(tool.caret, 1);
  });

  test('selection: word, paragraph, and select-all ranges', () {
    tool.tap(Point.zero);
    tool.insert('AB CD\nEF');
    tool.selectWordAt(1);
    expect([tool.selectionStart, tool.selectionEnd], [0, 2]);
    tool.selectWordAt(4);
    expect([tool.selectionStart, tool.selectionEnd], [3, 5]);
    tool.selectParagraphAt(1);
    expect([tool.selectionStart, tool.selectionEnd], [0, 5]);
    tool.selectParagraphAt(7);
    expect([tool.selectionStart, tool.selectionEnd], [6, 8]);
    tool.selectAll();
    expect([tool.selectionStart, tool.selectionEnd], [0, 8]);
  });

  test('selection: typing and backspace replace the selection', () {
    tool.tap(Point.zero);
    tool.insert('ABCDE');
    tool.moveCaretToEdge(home: true);
    tool.moveCaret(3, extend: true); // select 'ABC'
    tool.insert('X'); // replaces the range
    expect(tool.text, 'XDE');
    expect(tool.caret, 1);
    expect(tool.hasSelection, isFalse);

    tool.selectAll();
    tool.backspace(); // deletes the whole selection
    expect(tool.text, '');
    expect(tool.hasSelection, isFalse);
  });

  test('selection: word-wise caret motion', () {
    tool.tap(Point.zero);
    tool.insert('AB CD');
    tool.moveCaretToEdge(home: true);
    tool.moveCaretByWord(1); // to end of first word
    expect(tool.caret, 2);
    tool.moveCaretByWord(1); // to end of second word
    expect(tool.caret, 5);
    tool.moveCaretByWord(-1, extend: true); // extend back to word start
    expect(tool.selectionStart, 3);
    expect(tool.selectionEnd, 5);
  });
}

/// Union bounds of a set of paths (test helper).
Bounds _bounds(List<Path> paths) {
  var b = paths.first.bounds();
  for (final p in paths.skip(1)) {
    b = b.union(p.bounds());
  }
  return b;
}
