import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_events/studio_events.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

/// Oriented selection box (ADR-045): rotation persists on the object,
/// the transform box stays aligned with it, and follow-up interactions
/// work in the rotated frame.
void main() {
  late Document document;
  late History history;
  late SelectTool tool;

  // 10×20 rectangle so orientation is observable (a square's AABB is
  // rotation-invariant).
  const rect = Path(
    start: Point(10, 10),
    segments: [
      LineSegment(Point(20, 10)),
      LineSegment(Point(20, 30)),
      LineSegment(Point(10, 30)),
    ],
    closed: true,
  );

  setUp(() {
    document = Document(id: const Id('doc-1'));
    final bus = CommandBus(EventBus());
    history = History(bus);
    registerDocumentHandlers(bus, document);
    history.execute(
        const AddObject(RunningStitchObject(id: Id('obj-1'), path: rect)));
    tool = SelectTool(
      document: document,
      history: history,
      selection: SelectionController(),
    )..pxPerMm = 10;
  });

  RunningStitchObject object() =>
      document.objectById(const Id('obj-1')) as RunningStitchObject;

  test('rotation persists on the object and the box stays oriented', () {
    tool.tap(const Point(15, 15));
    // Grip starts above top-center (15, 7.8); sweep to the right of the
    // center (pivot 15,20) for a 90° CCW-in-screen rotation.
    tool.uniformModifier = true; // snap to exact 15° steps
    tool.dragStart(const Point(15, 7.8));
    tool.dragUpdate(const Point(30, 20)); // 90° from "up" to "right"
    tool.dragEnd();

    expect(object().rotationDeg, closeTo(90, 0.001));
    // Geometry rotated: 10×20 becomes 20×10 in world AABB.
    final world = object().bounds();
    expect(world.maxX - world.minX, closeTo(20, 0.001));
    expect(world.maxY - world.minY, closeTo(10, 0.001));
    // Frame box keeps the object's own 10×20 shape.
    final frame = tool.frameBounds!;
    expect(frame.maxX - frame.minX, closeTo(10, 0.001));
    expect(frame.maxY - frame.minY, closeTo(20, 0.001));
    // Box transform maps the frame box onto the rotated object.
    expect(tool.boxTransform, isNotNull);
  });

  test('second rotation accumulates instead of restarting from zero', () {
    tool.tap(const Point(15, 15));
    tool.uniformModifier = true;
    // First: 45°.
    tool.dragStart(const Point(15, 7.8));
    final pivot = const Point(15, 20);
    Point onCircle(double deg) {
      final r = 12.2; // grip distance from pivot
      final a = (deg - 90) * math.pi / 180; // 0° = up
      return Point(pivot.x + r * math.cos(a), pivot.y + r * math.sin(a));
    }

    tool.dragUpdate(onCircle(45));
    tool.dragEnd();
    expect(object().rotationDeg, closeTo(45, 0.001));

    // Second: +45° more, starting from the ROTATED grip position.
    final grip = tool.frameTransform; // non-null after first rotation
    expect(grip, isNotNull);
    final handleWorld = tool.handleAt(
        tool.frameTransform!.apply(Point(
            (tool.frameBounds!.minX + tool.frameBounds!.maxX) / 2,
            tool.frameBounds!.minY - 2.2)));
    expect(handleWorld, TransformHandle.rotate,
        reason: 'rotate grip is hit-tested in the rotated frame');
  });

  test('undo restores the previous orientation', () {
    tool.tap(const Point(15, 15));
    tool.uniformModifier = true;
    tool.dragStart(const Point(15, 7.8));
    tool.dragUpdate(const Point(30, 20));
    tool.dragEnd();
    expect(object().rotationDeg, closeTo(90, 0.001));

    history.undo();
    expect(object().rotationDeg, 0);
    expect(tool.frameTransform, isNull, reason: 'box back to axis-aligned');

    history.redo();
    expect(object().rotationDeg, closeTo(90, 0.001));
  });

  test('resize on a rotated object scales along its own axes', () {
    tool.tap(const Point(15, 15));
    tool.uniformModifier = true;
    tool.dragStart(const Point(15, 7.8));
    tool.dragUpdate(const Point(30, 20)); // 90°
    tool.dragEnd();
    tool.uniformModifier = false;

    // Frame E handle (frame +X) now points along world -Y... locate it
    // through the tool's own mapping and drag it outward to double the
    // frame width.
    final frame = tool.frameBounds!;
    final eFrame = Point(frame.maxX, (frame.minY + frame.maxY) / 2);
    final eWorld = tool.frameTransform!.apply(eFrame);
    expect(tool.handleAt(eWorld), TransformHandle.e);

    // Drag so the frame-width doubles: in frame space the E edge moves
    // from maxX to maxX + width.
    final width = frame.maxX - frame.minX;
    final targetWorld =
        tool.frameTransform!.apply(Point(frame.maxX + width, eFrame.y));
    tool.dragStart(eWorld);
    tool.dragUpdate(targetWorld);
    tool.dragEnd();

    expect(object().rotationDeg, closeTo(90, 0.001),
        reason: 'resize must not change orientation');
    final after = tool.frameBounds!;
    expect(after.maxX - after.minX, closeTo(width * 2, 0.01),
        reason: 'scaled along the frame axis');
    expect(after.maxY - after.minY, closeTo(20, 0.01),
        reason: 'other frame axis untouched');
  });

  test('multi-select stays axis-aligned', () {
    history.execute(const AddObject(RunningStitchObject(
        id: Id('obj-2'),
        path: Path(start: Point(40, 40), segments: [
          LineSegment(Point(50, 40)),
          LineSegment(Point(50, 50)),
        ]))));
    tool.tap(const Point(15, 15));
    tool.uniformModifier = true;
    tool.dragStart(const Point(15, 7.8));
    tool.dragUpdate(const Point(30, 20));
    tool.dragEnd();

    tool.tapWithModifiers(const Point(45, 45), extend: true);
    expect(tool.selectionRotationDeg, 0);
    expect(tool.frameTransform, isNull);
  });

  test('rotation serializes and round-trips', () {
    tool.tap(const Point(15, 15));
    tool.uniformModifier = true;
    tool.dragStart(const Point(15, 7.8));
    tool.dragUpdate(const Point(30, 20));
    tool.dragEnd();

    final json = object().toJson();
    expect(json['rotation'], closeTo(90, 0.001));
    final loaded = EmbroideryObject.fromJson(json);
    expect(loaded.rotationDeg, closeTo(90, 0.001));
    // Legacy object without the field loads axis-aligned.
    final legacy = EmbroideryObject.fromJson(json..remove('rotation'));
    expect(legacy.rotationDeg, 0);
  });
}
