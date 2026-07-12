import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/tool_options.dart';
import 'package:studio/src/tools/text/text_options.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

TextObject _text() {
  const font = MonolineTextFont();
  return TextObject(
    id: const Id('t1'),
    path: const Path(start: Point.zero),
    text: 'hi',
    fontFamily: font.family,
    sizeMm: 5,
    outlines: layoutText('hi', font, origin: Point.zero, sizeMm: 5),
  );
}

void main() {
  group('toggledStyle', () {
    const all = ['Regular', 'Bold', 'Italic', 'Bold Italic'];
    test('composes and removes flags Illustrator-style', () {
      expect(toggledStyle('Regular', 'Bold', all), 'Bold');
      expect(toggledStyle('Bold', 'Italic', all), 'Bold Italic');
      expect(toggledStyle('Bold Italic', 'Bold', all), 'Italic');
      expect(toggledStyle('Italic', 'Italic', all), 'Regular');
    });
    test('null when the family lacks the face', () {
      expect(toggledStyle('Regular', 'Bold', const ['Regular']), isNull);
      expect(toggledStyle('Bold', 'Italic', const ['Regular', 'Bold']),
          isNull);
    });
    test('accepts Oblique/Normal naming synonyms (Helvetica-style)', () {
      const helvetica = ['Regular', 'Bold', 'Oblique', 'Bold Oblique'];
      expect(toggledStyle('Regular', 'Italic', helvetica), 'Oblique');
      expect(toggledStyle('Bold', 'Italic', helvetica), 'Bold Oblique');
      expect(toggledStyle('Bold Oblique', 'Bold', helvetica), 'Oblique');
      expect(toggledStyle('Oblique', 'Italic', helvetica), 'Regular');
      expect(styleHasFlag('Bold Oblique', 'Italic'), isTrue);
      expect(styleHasFlag('Light Oblique', 'Italic'), isTrue);
      expect(styleHasFlag('Bold', 'Italic'), isFalse);
    });
  });

  testWidgets('underline toggle adds a decoration path, undoable',
      (tester) async {
    tester.view.physicalSize = const Size(1800, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.execute(AddObject(_text(), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    vm.selectTool(ToolKind.text);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolOptionsBar(tool: vm.tool, onChanged: vm.notify, model: vm),
      ),
    ));

    TextObject object() =>
        session.document.objectById(const Id('t1')) as TextObject;
    final before = object().outlines.length;

    await tester.tap(find.byIcon(TablerIcons.underline));
    await tester.pumpAndSettle();
    expect(object().outlines.length, before + 1,
        reason: 'underline emits one decoration path');
    expect(
        object().attrsAt(0).decorations!.has(TextDecorationLine.underline),
        isTrue);

    session.history.undo();
    expect(object().outlines.length, before);
  });

  testWidgets('justify button sets object alignment', (tester) async {
    tester.view.physicalSize = const Size(1800, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.execute(AddObject(_text(), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    vm.selectTool(ToolKind.text);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolOptionsBar(tool: vm.tool, onChanged: vm.notify, model: vm),
      ),
    ));

    await tester.tap(find.byIcon(TablerIcons.align_justified));
    await tester.pumpAndSettle();
    final object = session.document.objectById(const Id('t1')) as TextObject;
    expect(object.alignment, 'justify');
  });

  testWidgets('Bold is disabled for the monoline font (no Bold face)',
      (tester) async {
    tester.view.physicalSize = const Size(1800, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.execute(AddObject(_text(), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    vm.selectTool(ToolKind.text);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolOptionsBar(tool: vm.tool, onChanged: vm.notify, model: vm),
      ),
    ));

    await tester.tap(find.byIcon(TablerIcons.bold));
    await tester.pumpAndSettle();
    final object = session.document.objectById(const Id('t1')) as TextObject;
    expect(object.attrsAt(0).styleName, isNull,
        reason: 'no Bold face installed for Monoline — button inert');
  });
}
