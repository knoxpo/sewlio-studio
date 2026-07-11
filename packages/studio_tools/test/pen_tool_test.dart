import 'package:flutter_test/flutter_test.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  test('line mode commits after two points', () {
    final created = <Path>[];
    final pen = PenTool(onCreate: created.add)..mode = PenMode.line;
    pen.tap(const Point(0, 0));
    expect(created, isEmpty);
    pen.tap(const Point(10, 5));
    expect(created, hasLength(1));
    expect(created.single.segments, hasLength(1));
    expect(created.single.closed, isFalse);
  });

  test('cursorAt: start ×, add +, minus over anchors, close over first', () {
    final pen = PenTool(onCreate: (_) {});
    expect(pen.cursorAt(const Point(5, 5)), ToolCursor.pen);
    pen.tap(const Point(0, 0));
    pen.tap(const Point(10, 0));
    pen.tap(const Point(10, 10));
    expect(pen.cursorAt(const Point(5, 5)), ToolCursor.penAdd);
    expect(pen.cursorAt(const Point(10, 0)), ToolCursor.penMinus);
    expect(pen.cursorAt(const Point(0, 0)), ToolCursor.penClose);
  });

  test('clicking an in-progress anchor removes it (pen-minus)', () {
    final created = <Path>[];
    final pen = PenTool(onCreate: created.add);
    pen.tap(const Point(0, 0));
    pen.tap(const Point(10, 0));
    pen.tap(const Point(10, 10));
    pen.tap(const Point(10, 0)); // remove the middle anchor
    pen.doubleTap(const Point(10, 10));
    expect(created.single.segments, hasLength(1)); // (0,0) → (10,10)
    expect(created.single.segments.single.end, const Point(10, 10));
  });

  test('Shift/Ctrl constrain snaps the next point to 45° rays', () {
    final created = <Path>[];
    final pen = PenTool(onCreate: created.add);
    pen.tap(const Point(0, 0));
    pen.constrainAngles = true;
    pen.tap(const Point(10, 1)); // near-horizontal → snaps to 0°
    pen.doubleTap(const Point(10, 1));
    final end = created.single.segments.first.end;
    expect(end.y, closeTo(0, 1e-9));
    expect(end.x, greaterThan(9)); // length preserved
  });

  test('smart mode fits cubic curves through the points', () {
    final created = <Path>[];
    final pen = PenTool(onCreate: created.add)..mode = PenMode.smart;
    pen.tap(const Point(0, 0));
    pen.tap(const Point(20, 10));
    pen.tap(const Point(40, 0));
    pen.doubleTap(const Point(40, 0));
    expect(created.single.segments.whereType<CubicSegment>(), isNotEmpty);
  });

  test('polygon mode always commits a closed shape', () {
    final created = <Path>[];
    final pen = PenTool(onCreate: created.add)..mode = PenMode.polygon;
    pen.tap(const Point(0, 0));
    pen.tap(const Point(20, 0));
    pen.tap(const Point(20, 20));
    pen.doubleTap(const Point(20, 20)); // finish WITHOUT clicking start
    expect(created.single.closed, isTrue);
  });

  test('editExisting continues a path and commits via onReplace', () {
    final created = <Path>[];
    final replaced = <(Id, Path)>[];
    final pen = PenTool(
        onCreate: created.add,
        onReplace: (id, path) => replaced.add((id, path)));
    pen.editExisting(const Id('e1'), const [Point(0, 0), Point(10, 0)]);
    expect(pen.markers, hasLength(2)); // anchors visible/editable
    pen.tap(const Point(20, 5));
    pen.doubleTap(const Point(20, 5));
    expect(created, isEmpty);
    expect(replaced.single.$1, const Id('e1'));
    expect(replaced.single.$2.segments, hasLength(2)); // extended
  });

  test('polygon/pen close on the first point', () {
    final created = <Path>[];
    final pen = PenTool(onCreate: created.add)..mode = PenMode.polygon;
    pen.tap(const Point(0, 0));
    pen.tap(const Point(10, 0));
    pen.tap(const Point(10, 10));
    pen.tap(const Point(0.5, 0.5)); // within close tolerance of start
    expect(created.single.closed, isTrue);
  });
}
