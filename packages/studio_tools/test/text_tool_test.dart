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
}
