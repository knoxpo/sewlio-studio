import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_canvas/studio_canvas.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

void main() {
  testWidgets(
      'stitches panel expands text into glyph rows; selection is '
      'view-only', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));

    // Commit "hi" as one text object.
    await tester.tap(find.byKey(const Key('tool-Text')));
    await tester.pump();
    await tester.tapAt(tester.getCenter(find.byType(CanvasView)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyH);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyI);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    // Layers model: exactly ONE editable text object.
    expect(session.document.objects, hasLength(1));
    final id = session.document.objects.keys.single;
    final revision = session.document.revision;

    // Expand the text row into per-glyph entries.
    await tester.tap(find.byKey(Key('glyphs-expand-${id.value}')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Glyph "h"'), findsOneWidget);
    expect(find.textContaining('Glyph "i"'), findsOneWidget);

    // Select a glyph: canvas gets a highlight, document untouched.
    await tester.tap(find.byKey(Key('glyph-${id.value}-0')));
    await tester.pump();
    CanvasView canvas() => tester.widget<CanvasView>(find.byType(CanvasView));
    expect(canvas().highlightStitches, isNotEmpty);
    expect(session.document.objects, hasLength(1));
    expect(session.document.objects.values.single, isA<TextObject>());
    expect(session.document.revision, revision); // no mutation

    // Tapping the highlighted glyph again clears the highlight.
    await tester.tap(find.byKey(Key('glyph-${id.value}-0')));
    await tester.pump();
    expect(canvas().highlightStitches, isEmpty);
  });

  test('glyph highlight is derived: invalidates on edit, restores on undo', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    const font = MonolineTextFont();
    final object = TextObject(
      id: const Id('t1'),
      path: Path(start: Point.zero),
      text: 'oo',
      fontFamily: font.family,
      outlines: layoutText('oo', font, origin: Point.zero),
    );
    vm.execute(AddObject(object, parent: null));
    final partsPerO = font.glyphPaths(0x6F, Point.zero, 10).length;

    // Highlight the SECOND 'o' — repeated chars stay distinguishable
    // by outline range.
    vm.setStitchHighlight(
        (id: object.id, start: partsPerO, end: 2 * partsPerO));
    expect(vm.highlightedStitchOps, isNotEmpty);

    // Editing the text to one 'o' shrinks the outlines: the stale
    // range degrades to empty instead of pointing at wrong geometry.
    vm.execute(ReplaceObject(TextObject(
      id: object.id,
      path: Path(start: Point.zero),
      text: 'o',
      fontFamily: font.family,
      outlines: layoutText('o', font, origin: Point.zero),
    )));
    expect(vm.highlightedStitchOps, isEmpty);

    // Undo restores the source text — the derived highlight follows.
    vm.undo();
    expect(vm.highlightedStitchOps, isNotEmpty);
  });
}
