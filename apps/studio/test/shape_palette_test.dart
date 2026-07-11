import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_design_system/studio_design_system.dart';

void main() {
  testWidgets(
      'floating shape palette: appears with the Shape tool, picks '
      'shapes, drags by its grip, dismisses on tool switch', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    const palette = Key('shape-palette');
    expect(find.byKey(palette), findsNothing);

    // Activate the Shape tool: the palette appears.
    await tester.tap(find.byKey(const Key('tool-Shapes')));
    await tester.pump();
    expect(find.byKey(palette), findsOneWidget);

    // Pick a shape: palette stays; the chosen shape becomes active.
    await tester.tap(find.byKey(const Key('shape-star')));
    await tester.pump();
    expect(find.byKey(palette), findsOneWidget);
    expect(
      tester
          .widget<StudioIconButton>(find.byKey(const Key('shape-star')))
          .active,
      isTrue,
    );

    // Drag by the grip: the palette moves.
    final before = tester.getTopLeft(find.byKey(palette));
    await tester.drag(
        find.byKey(const Key('shape-palette-grip')), const Offset(60, 40));
    await tester.pump();
    final after = tester.getTopLeft(find.byKey(palette));
    expect(after.dx - before.dx, closeTo(60, 1));
    expect(after.dy - before.dy, closeTo(40, 1));

    // Drag back toward the original hotspot: the snap-candidate drop
    // zone lights up mid-drag, and releasing docks the palette exactly
    // back on the left-center hotspot.
    final grip = find.byKey(const Key('shape-palette-grip'));
    final gesture = await tester.startGesture(tester.getCenter(grip));
    await gesture.moveBy(const Offset(-40, -25));
    await tester.pump();
    expect(find.byKey(const Key('palette-snap-candidate')), findsOneWidget);
    await gesture.up();
    await tester.pump();
    expect(find.byKey(const Key('palette-snap-candidate')), findsNothing);
    expect(tester.getTopLeft(find.byKey(palette)), before);

    // Switching tools dismisses the palette.
    await tester.tap(find.byKey(const Key('tool-Move')));
    await tester.pump();
    expect(find.byKey(palette), findsNothing);
  });

  testWidgets('multi-tool groups get a floating palette too', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    await tester.pumpWidget(StudioApp(session: StudioSession()));

    // Activate the navigate group (Pan slot): its palette appears.
    await tester.tap(find.byKey(const Key('tool-View (Pan)')));
    await tester.pump();
    expect(find.byKey(const Key('palette-navigate')), findsOneWidget);

    // Pick Zoom inside the palette: stays open (same group), active.
    await tester.tap(find.byKey(const Key('palette-tool-Zoom')));
    await tester.pump();
    expect(find.byKey(const Key('palette-navigate')), findsOneWidget);
    expect(
      tester
          .widget<StudioIconButton>(find.byKey(const Key('palette-tool-Zoom')))
          .active,
      isTrue,
    );

    // Leaving the group dismisses the palette.
    await tester.tap(find.byKey(const Key('tool-Move')));
    await tester.pump();
    expect(find.byKey(const Key('palette-navigate')), findsNothing);
  });
}
