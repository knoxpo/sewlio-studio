import 'package:flutter_test/flutter_test.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_events/studio_events.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  group('PenTool', () {
    test('taps build a path, double tap commits open', () {
      Path? created;
      final pen = PenTool(onCreate: (p) => created = p);
      pen.tap(const Point(0, 0));
      pen.tap(const Point(10, 0));
      pen.tap(const Point(10, 10));
      expect(pen.preview.single.toPolyline(), hasLength(3));

      pen.doubleTap(const Point(20, 10)); // places final point + finishes
      expect(created!.closed, isFalse);
      expect(created!.toPolyline(), [
        const Point(0, 0),
        const Point(10, 0),
        const Point(10, 10),
        const Point(20, 10)
      ]);
      expect(pen.preview, isEmpty); // state reset
    });

    test('clicking near the start closes the path', () {
      Path? created;
      final pen = PenTool(onCreate: (p) => created = p);
      pen.tap(const Point(0, 0));
      pen.tap(const Point(10, 0));
      pen.tap(const Point(10, 10));
      pen.tap(const Point(0.5, 0.5)); // within tolerance of start
      expect(created!.closed, isTrue);
    });
  });

  group('PencilTool', () {
    test('freehand trace simplifies to corners', () {
      Path? created;
      final pencil = PencilTool(onCreate: (p, {pressures}) => created = p);
      expect(pencil.dragStart(const Point(0, 0)), isTrue);
      for (var x = 0.5; x <= 10; x += 0.5) {
        pencil.dragUpdate(Point(x, 0));
      }
      for (var y = 0.5; y <= 10; y += 0.5) {
        pencil.dragUpdate(Point(10, y));
      }
      pencil.dragEnd();
      expect(created!.toPolyline(),
          [const Point(0, 0), const Point(10, 0), const Point(10, 10)]);
    });

    test('stylus pressure decimates with the trace, one per node', () {
      Path? created;
      List<double>? captured;
      final pencil = PencilTool(onCreate: (p, {pressures}) {
        created = p;
        captured = pressures;
      });
      pencil.pointerPressure = 0.2;
      pencil.dragStart(const Point(0, 0));
      for (var x = 0.5; x <= 10; x += 0.5) {
        pencil.pointerPressure = x < 5 ? 0.2 : 0.9;
        pencil.dragUpdate(Point(x, 0));
      }
      pencil.pointerPressure = 1.0;
      pencil.dragUpdate(const Point(10, 10));
      pencil.dragEnd();
      expect(captured, isNotNull);
      expect(captured!.length, created!.segments.length + 1);
      expect(captured!.first, 0.2);
      expect(captured!.last, 1.0);
    });

    test('uniform pressure yields no pressures (mouse/touch)', () {
      List<double>? captured = [];
      final pencil =
          PencilTool(onCreate: (p, {pressures}) => captured = pressures);
      pencil.dragStart(const Point(0, 0));
      pencil.dragUpdate(const Point(10, 0));
      pencil.dragUpdate(const Point(10, 10));
      pencil.dragEnd();
      expect(captured, isNull);
    });
  });

  group('ShapeTool', () {
    test('drag creates the configured shape', () {
      final created = <Path>[];
      final shape = ShapeTool(onCreate: created.add);

      for (final (kind, check) in [
        (ShapeKind.rectangle, (Path p) => p.closed && p.segments.length == 3),
        (
          ShapeKind.circle,
          (Path p) => p.segments.whereType<CubicSegment>().length == 4
        ),
        (ShapeKind.hexagon, (Path p) => p.toPolyline().length == 7),
        (ShapeKind.star, (Path p) => p.toPolyline().length == 11),
        (ShapeKind.spiral, (Path p) => !p.closed),
      ]) {
        shape.kind = kind;
        shape.dragStart(const Point(0, 0));
        shape.dragUpdate(const Point(20, 10));
        shape.dragEnd();
        expect(check(created.last), isTrue, reason: kind.name);
      }
      expect(created, hasLength(5));
    });

    test('polygon uses configurable sides', () {
      final created = <Path>[];
      final shape = ShapeTool(onCreate: created.add)
        ..kind = ShapeKind.polygon
        ..sides = 8;
      shape.dragStart(const Point(0, 0));
      shape.dragUpdate(const Point(10, 0));
      shape.dragEnd();
      expect(created.single.toPolyline().length, 9); // 8 vertices + close
    });

    test('square constrains aspect', () {
      final created = <Path>[];
      final shape = ShapeTool(onCreate: created.add)..kind = ShapeKind.square;
      shape.dragStart(const Point(0, 0));
      shape.dragUpdate(const Point(20, 5));
      shape.dragEnd();
      final b = created.single.bounds();
      expect(b.width, closeTo(b.height, 1e-9));
    });
  });

  group('MeasureTool', () {
    test('reports distance, never mutates', () {
      final measure = MeasureTool();
      expect(measure.dragStart(const Point(0, 0)), isTrue);
      measure.dragUpdate(const Point(3, 4));
      measure.dragEnd();
      expect(measure.status, contains('5.00 mm'));
      expect(measure.preview, hasLength(1));
      measure.cancel();
      expect(measure.preview, isEmpty);
    });
  });

  group('monoline font', () {
    test('text becomes stitchable stroke paths', () {
      final paths = textToPaths('HI 5', origin: const Point(0, 0), sizeMm: 12);
      // H = 3 strokes, I = 3 strokes, space = 0, 5 = 1 stroke.
      expect(paths, hasLength(7));
      // Cap height honored: H spans 12 mm above the baseline.
      final hBounds = paths.first.bounds();
      expect(hBounds.height, closeTo(12, 1e-9));
      // Advance moves right per character.
      expect(paths.last.bounds().minX, greaterThan(hBounds.maxX));
    });

    test('unknown characters are skipped, lowercase maps up', () {
      expect(textToPaths('a', origin: Point.zero),
          hasLength(textToPaths('A', origin: Point.zero).length));
      expect(textToPaths('~', origin: Point.zero), isEmpty);
    });
  });

  group('NodeTool', () {
    test('drag anchor commits undoable ReplaceObject', () {
      final document = Document(id: const Id('doc'));
      final bus = CommandBus(EventBus());
      final history = History(bus);
      registerDocumentHandlers(bus, document);
      const path = Path(
        start: Point(0, 0),
        segments: [LineSegment(Point(10, 0)), LineSegment(Point(10, 10))],
      );
      history.execute(
          const AddObject(RunningStitchObject(id: Id('o1'), path: path)));

      final selection = SelectionController();
      final node =
          NodeTool(document: document, history: history, selection: selection);

      node.tap(const Point(5, 5)); // selects the object
      expect(selection.selected, const Id('o1'));
      expect(node.markers, hasLength(3));

      expect(node.dragStart(const Point(10, 0)), isTrue); // grab mid anchor
      node.dragUpdate(const Point(12, 3));
      node.dragEnd();

      final moved = document.objectById(const Id('o1'))!;
      expect(moved.path.segments.first.end, const Point(12, 3));

      history.undo();
      expect(document.objectById(const Id('o1'))!.path.segments.first.end,
          const Point(10, 0));
    });
  });
}
