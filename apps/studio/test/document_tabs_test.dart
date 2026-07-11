import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_canvas/studio_canvas.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(const StudioApp());
    await tester.pump();
  }

  /// Drives the New Project page (already visible) to create [name].
  Future<void> createProject(WidgetTester tester, String name) async {
    await tester.enterText(find.byKey(const Key('new-project-name')), name);
    await tester.pump();
    await tester.tap(find.byKey(const Key('new-project-create')));
    await tester.pumpAndSettle();
  }

  /// Draws one pen path in the active editor (dirties the document).
  Future<void> drawPath(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('tool-Pen')));
    await tester.pump();
    final canvas = tester.getCenter(find.byType(CanvasView));
    await tester.tapAt(canvas);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tapAt(canvas + const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(canvas + const Offset(80, 0));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> openNewProjectPage(WidgetTester tester) async {
    await tester.tap(find.text('File'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Project…'));
    await tester.pumpAndSettle();
  }

  testWidgets('two tabs with independent dirty state; switching works',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('home-new-project')));
    await tester.pump();
    await createProject(tester, 'Alpha');
    await openNewProjectPage(tester);
    await createProject(tester, 'Beta');

    // Home tab + two document tabs; Beta is active.
    expect(find.byKey(const Key('home-tab')), findsOneWidget);
    expect(find.text('Alpha.swl'), findsOneWidget);
    expect(find.text('Beta.swl'), findsOneWidget);

    // Dirty Alpha only: its tab shows the star, Beta's stays clean.
    await tester.tap(find.text('Alpha.swl'));
    await tester.pumpAndSettle();
    await drawPath(tester);
    expect(find.text('Alpha.swl*'), findsOneWidget);
    expect(find.text('Beta.swl'), findsOneWidget);

    // Switching tabs switches the active document title.
    await tester.tap(find.text('Beta.swl'));
    await tester.pumpAndSettle();
    final title = tester.widget<Text>(find.byKey(const Key('doc-title')));
    expect(title.data, 'Beta.swl');
  });

  testWidgets('closing a clean tab removes it; last close returns Home',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('home-new-project')));
    await tester.pump();
    await createProject(tester, 'Solo');
    expect(find.text('Solo.swl'), findsOneWidget);

    await tester.tap(find.byKey(const Key('close-tab-0')));
    await tester.pumpAndSettle();

    // Back on Home; the app keeps running and shows no empty editor.
    expect(find.text('Solo.swl'), findsNothing);
    expect(find.byKey(const Key('home-new-project')), findsOneWidget);
    expect(find.byType(CanvasView), findsNothing);
  });

  testWidgets('closing a dirty tab prompts Save / Discard / Cancel',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const Key('home-new-project')));
    await tester.pump();
    await createProject(tester, 'Dirty');
    await drawPath(tester);
    expect(find.text('Dirty.swl*'), findsOneWidget);

    // Cancel keeps the tab open.
    await tester.tap(find.byKey(const Key('close-tab-0')));
    await tester.pumpAndSettle();
    expect(find.text('Unsaved Changes'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Dirty.swl*'), findsOneWidget);

    // Discard closes without saving and lands on Home.
    await tester.tap(find.byKey(const Key('close-tab-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Dirty.swl*'), findsNothing);
    expect(find.byKey(const Key('home-new-project')), findsOneWidget);
  });
}
