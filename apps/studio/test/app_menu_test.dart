import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/menu/app_menu.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

void main() {
  Future<StudioSession> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    final session = StudioSession();
    await tester.pumpWidget(StudioApp(session: session));
    return session;
  }

  testWidgets('in-app menu bar renders the full shared definition',
      (tester) async {
    await pumpApp(tester);
    // Previously mac-only items now exist in the in-app menus too.
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    for (final label in [
      'New Project…',
      'Open Recent',
      'Save As…',
      'Export DST…',
      'Document Setup…'
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    // Native-only menus stay out of the in-app bar.
    expect(find.text('Window'), findsNothing);
  });

  testWidgets('menu shortcuts work app-wide on non-mac platforms',
      (tester) async {
    final session = await pumpApp(tester);
    session.history.execute(const AddObject(RunningStitchObject(
      id: Id('o1'),
      path: g.Path(
          start: g.Point(0, 0), segments: [g.LineSegment(g.Point(10, 0))]),
    )));
    await tester.pump();
    expect(session.document.objects, hasLength(1));

    // Definition says ⌘Z; on non-mac surfaces it binds as Ctrl+Z.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    expect(session.document.objects, isEmpty);
  });

  testWidgets('plugin contributions appear in the rendered menus',
      (tester) async {
    menuContributions.add(MenuContribution(
      intoMenu: 'File',
      build: () => [
        AppMenuItem(
            command: 'plugin.hello', label: 'Plugin Item', action: () {}),
      ],
    ));
    menuContributions.add(MenuContribution(
      build: () => [
        AppMenu('Plugin Menu', [
          AppMenuItem(command: 'plugin.sub', label: 'Sub Item', action: () {}),
        ]),
      ],
    ));
    addTearDown(menuContributions.clear);

    await pumpApp(tester);
    expect(find.text('Plugin Menu'), findsOneWidget); // top-level, before Help
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    expect(find.text('Plugin Item'), findsOneWidget);
  });

  test('invokeMenuCommand runs enabled items by id, reports disabled', () {
    var ran = false;
    final menus = [
      AppMenu('File', [
        AppMenuItem(
            command: 'file.save', label: 'Save', action: () => ran = true),
        const AppMenuItem(command: 'file.props', label: 'Properties…'),
      ]),
    ];
    expect(invokeMenuCommand(menus, 'file.save'), isTrue);
    expect(ran, isTrue);
    expect(invokeMenuCommand(menus, 'file.props'), isFalse); // disabled
    expect(invokeMenuCommand(menus, 'nope'), isFalse); // unknown
  });

  test('shortcut bindings translate meta to control and skip disabled', () {
    final menus = [
      AppMenu('Edit', [
        AppMenuItem(
          command: 'edit.undo',
          label: 'Undo',
          shortcut: const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
          action: () {},
        ),
        const AppMenuItem(
          command: 'edit.cut',
          label: 'Cut',
          shortcut: SingleActivator(LogicalKeyboardKey.keyX, meta: true),
        ),
      ]),
    ];
    final bindings = menuShortcutBindings(menus);
    expect(bindings, hasLength(1));
    final activator = bindings.keys.single as SingleActivator;
    expect(activator.control, isTrue);
    expect(activator.meta, isFalse);
    expect(activator.trigger, LogicalKeyboardKey.keyZ);
  });
}
