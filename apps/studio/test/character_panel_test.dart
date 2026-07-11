import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/panels/character_panel.dart';
import 'package:studio/src/workspace_view_model.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_tools/studio_tools.dart';

/// Pumps a CharacterPanel bound to [vm] inside a minimal app shell.
Future<void> _pumpPanel(WidgetTester tester, WorkspaceViewModel vm) async {
  // Tall viewport so the lazy ListView builds every section (the last
  // one, Typography, otherwise stays below the fold).
  tester.view.physicalSize = const Size(320, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(body: CharacterPanel(model: vm)),
  ));
  await tester.pump();
}

TextObject _text(String s,
    {double sizeMm = 5, List<StyleRun> runs = const []}) {
  const font = MonolineTextFont();
  return TextObject(
    id: const Id('t1'),
    path: Path(start: Point.zero),
    text: s,
    fontFamily: font.family,
    sizeMm: sizeMm,
    runs: runs,
    outlines: layoutText(s, font, origin: Point.zero, sizeMm: sizeMm),
  );
}

void main() {
  StudioNumberField field(WidgetTester tester, String key) =>
      tester.widget<StudioNumberField>(find.byKey(Key(key)));

  testWidgets('empty state when no text is selected', (tester) async {
    final vm = WorkspaceViewModel(session: StudioSession());
    await _pumpPanel(tester, vm);
    expect(find.byKey(const Key('character-empty')), findsOneWidget);
    expect(find.text('No text selected'), findsOneWidget);
  });

  testWidgets('shows the target font and size', (tester) async {
    final vm = WorkspaceViewModel(session: StudioSession());
    final obj = _text('hi', sizeMm: 7);
    vm.execute(AddObject(obj, parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    await _pumpPanel(tester, vm);

    expect(find.byKey(const Key('character-panel')), findsOneWidget);
    // Monoline is the built-in family; the family control renders it.
    expect(find.text(MonolineTextFont().family), findsWidgets);
    expect(field(tester, 'char-field-sizeMm').value, 7);
    expect(field(tester, 'char-field-sizeMm').mixed, isFalse);
  });

  testWidgets('editing the size field dispatches an undoable edit',
      (tester) async {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.execute(AddObject(_text('hi', sizeMm: 5), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    await _pumpPanel(tester, vm);

    final revision = vm.session.document.revision;
    await tester.enterText(
        find.descendant(
            of: find.byKey(const Key('char-field-sizeMm')),
            matching: find.byType(EditableText)),
        '9');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(vm.session.document.revision, isNot(revision));
    final obj = vm.session.document.objectById(const Id('t1')) as TextObject;
    // The whole-string range now resolves to the new size.
    expect(obj.attrsAt(0).sizeMm, 9);
  });

  testWidgets('mixed size across runs shows a mixed field', (tester) async {
    final vm = WorkspaceViewModel(session: StudioSession());
    // Two characters with different sizes → 'sizeMm' is mixed over the
    // whole-string range.
    vm.execute(AddObject(
        _text('hi', sizeMm: 5, runs: const [
          StyleRun(0, 1, CharAttrs(sizeMm: 5)),
          StyleRun(1, 1, CharAttrs(sizeMm: 8)),
        ]),
        parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    await _pumpPanel(tester, vm);

    expect(field(tester, 'char-field-sizeMm').mixed, isTrue);
  });

  testWidgets('unsupported OpenType feature button is disabled',
      (tester) async {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.execute(AddObject(_text('hi'), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    await _pumpPanel(tester, vm);

    // Typography section is collapsed by default — expand it.
    await tester.tap(find.text('TYPOGRAPHY'));
    await tester.pumpAndSettle();

    final liga =
        tester.widget<StudioButton>(find.byKey(const Key('char-otf-liga')));
    // Monoline exposes no features, so the toggle is honestly disabled.
    expect(liga.onPressed, isNull);
  });

  // Expands the Optical Alignment section (collapsed by default).
  Future<void> openOptical(WidgetTester tester) async {
    await tester.tap(find.text('OPTICAL ALIGNMENT'));
    await tester.pumpAndSettle();
  }

  WorkspaceViewModel textVm() {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.execute(AddObject(_text('hi'), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));
    return vm;
  }

  testWidgets('optical alignment table renders the default preset rows',
      (tester) async {
    final vm = textVm();
    await _pumpPanel(tester, vm);
    await openOptical(tester);

    // The seed table is shown when the document has no explicit rules.
    for (var i = 0; i < OpticalRule.defaults.length; i++) {
      expect(find.byKey(Key('char-optical-left-$i')), findsOneWidget);
    }
    expect(find.byKey(Key('char-optical-left-${OpticalRule.defaults.length}')),
        findsNothing);
  });

  testWidgets('editing a leftPct cell dispatches SetOpticalRules',
      (tester) async {
    final vm = textVm();
    await _pumpPanel(tester, vm);
    await openOptical(tester);

    expect(vm.session.document.opticalRules, isEmpty);
    await tester.enterText(
        find.descendant(
            of: find.byKey(const Key('char-optical-left-0')),
            matching: find.byType(EditableText)),
        '42');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // The edit persists the full table; row 0 now carries the new value.
    expect(vm.session.document.opticalRules, isNotEmpty);
    expect(vm.session.document.opticalRules.first.leftPct, 42);
  });

  testWidgets('Add appends an optical rule', (tester) async {
    final vm = textVm();
    await _pumpPanel(tester, vm);
    await openOptical(tester);

    await tester.tap(find.byKey(const Key('char-optical-add')));
    await tester.pumpAndSettle();

    expect(vm.session.document.opticalRules.length,
        OpticalRule.defaults.length + 1);
  });

  testWidgets('deleting an optical rule removes one row', (tester) async {
    final vm = textVm();
    await _pumpPanel(tester, vm);
    await openOptical(tester);

    await tester.tap(find.byKey(const Key('char-optical-del-0')));
    await tester.pumpAndSettle();

    expect(vm.session.document.opticalRules.length,
        OpticalRule.defaults.length - 1);
  });
}
