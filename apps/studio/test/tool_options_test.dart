import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio/src/tool_options.dart';
import 'package:studio/src/workspace_view_model.dart';

void main() {
  testWidgets('options bar renders from the active tool contribution',
      (tester) async {
    final vm = WorkspaceViewModel(session: StudioSession());
    vm.selectTool(ToolKind.shape);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolOptionsBar(
            tool: vm.tool, onChanged: vm.notify, model: vm),
      ),
    ));
    // Shape bar names the current shape — content came from the
    // contribution's optionsBuilder, not a hardcoded switch.
    expect(find.text('Rectangle'), findsOneWidget);

    // A tool with no optionsBuilder still gets a bar (no reflow on
    // tool switch): its name plus its status hint.
    vm.selectTool(ToolKind.measure);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ToolOptionsBar(
            tool: vm.tool, onChanged: vm.notify, model: vm),
      ),
    ));
    expect(find.text('Measure'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('every tool contribution yields a visible options bar',
      (tester) async {
    final vm = WorkspaceViewModel(session: StudioSession());
    for (final kind in ToolKind.values) {
      vm.selectTool(kind);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ToolOptionsBar(
              tool: vm.tool, onChanged: vm.notify, model: vm),
        ),
      ));
      expect(find.byType(SingleChildScrollView), findsOneWidget,
          reason: 'no bar for $kind — canvas would reflow on switch');
    }
  });
}
