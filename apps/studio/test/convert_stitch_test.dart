import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';

Path _square(double o, double s) => Path(
      start: Point(o, o),
      segments: [
        LineSegment(Point(o + s, o)),
        LineSegment(Point(o + s, o + s)),
        LineSegment(Point(o, o + s)),
      ],
      closed: true,
    );

// A text object with two closed contours (outer + a hole), like an 'O'.
TextObject _glyphText() => TextObject(
      id: const Id('t1'),
      path: const Path(start: Point.zero),
      text: 'O',
      fontFamily: 'Arial',
      outlines: [_square(0, 10), _square(3, 4)],
    );

WorkspaceViewModel _vmWithText() {
  final vm = WorkspaceViewModel(session: StudioSession());
  vm.execute(AddObject(_glyphText(), parent: null));
  vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
  return vm;
}

void main() {
  test('convert to running: stitch objects on a new stitch layer, text kept',
      () {
    final vm = _vmWithText();
    vm.convertTextToStitches(const Id('t1'), StitchTarget.running);

    final doc = vm.session.document;
    // The design text stays; a stitch layer is created above it.
    expect(doc.objectById(const Id('t1')), isA<TextObject>(),
        reason: 'design text kept');
    expect(doc.firstStitchLayer, isNotNull, reason: 'stitch layer created');
    final running =
        doc.objects.values.whereType<RunningStitchObject>().toList();
    expect(running, hasLength(2), reason: 'one per contour');
    // Only the stitch-layer objects digitize.
    expect(doc.flattenVisibleStitchObjects(), hasLength(2));
  });

  test('convert to fill: single even-odd fill with the hole', () {
    final vm = _vmWithText();
    vm.convertTextToStitches(const Id('t1'), StitchTarget.fill);

    final fills = vm.session.document.objects.values.whereType<FillObject>();
    expect(fills, hasLength(1));
    expect(fills.first.holes, hasLength(1), reason: 'inner contour is a hole');
  });

  test('convert is one undo step; undo removes the stitch objects', () {
    final vm = _vmWithText();
    vm.convertTextToStitches(const Id('t1'), StitchTarget.satin);
    expect(vm.session.document.objects.values.whereType<SatinObject>(),
        hasLength(2));
    expect(vm.session.document.firstStitchLayer, isNotNull);

    vm.undo();
    // The design text was never removed; the stitch objects are gone.
    expect(vm.session.document.objectById(const Id('t1')), isA<TextObject>());
    expect(
        vm.session.document.objects.values.whereType<SatinObject>(), isEmpty);
  });
}
