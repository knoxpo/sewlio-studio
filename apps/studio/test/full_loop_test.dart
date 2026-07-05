import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_diagnostics/studio_diagnostics.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_export/studio_export.dart';
import 'package:studio_geometry/studio_geometry.dart';
import 'package:studio_import/studio_import.dart';
import 'package:studio_machine/studio_machine.dart';

/// MVP acceptance loop (MVP-S10-T5): import → edit → digitize →
/// compile → validate → export → save → reopen, headless.
void main() {
  test('import → edit → export → save → reopen produces stable output', () {
    final session = StudioSession();

    // Import: SVG square (96 px = 25.4 mm sides).
    const svg = '<svg><path d="M0 0 L96 0 L96 96 L0 96 Z"/></svg>';
    for (final path in importSvg(svg)) {
      session.history.execute(AddObject(RunningStitchObject(
          id: session.registry.get<IdGenerator>().next(), path: path)));
    }
    expect(session.document.objects, hasLength(1));

    // Edit: move it 10 mm right via the command path, then assistant
    // renames the document through the same path.
    final id = session.document.objects.single.id;
    session.history.execute(TransformObject(id, Transform2.translation(10, 0)));
    final proposals = session.assistant.propose('rename to Acceptance');
    proposals.forEach(session.history.execute);
    expect(session.document.name, 'Acceptance');

    // Digitize → compile → validate → export.
    final sequence = digitizeObjects(session.document.objects);
    expect(sequence.stitchCount, greaterThan(30)); // ~101.6 mm / 2.5 mm
    final program = compileToMachine(sequence);
    final sink = CollectingSink();
    expect(program.validate(MachineModel.generic, sink), isTrue,
        reason: sink.diagnostics.join('\n'));
    final dst = encodeDst(program);
    final exp = encodeExp(program, sink: sink);
    expect(sink.hasErrors, isFalse);
    expect(dst.length, greaterThan(512));
    expect(exp, isNotEmpty);

    // Save → reopen → identical project and identical machine bytes.
    final saved = encodeProject(session.document);
    final reopened = StudioSession(document: decodeProject(saved));
    expect(encodeProject(reopened.document), saved);
    final dst2 =
        encodeDst(compileToMachine(digitizeObjects(reopened.document.objects)));
    expect(dst2, dst);

    // Undo still works after the loop.
    session.history.undo(); // rename
    session.history.undo(); // transform
    expect(session.document.objects.single.path.start, const Point(0, 0));
  });
}
