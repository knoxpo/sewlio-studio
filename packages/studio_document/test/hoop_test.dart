import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_events/studio_events.dart';
import 'package:test/test.dart';

void main() {
  test('UpdateHoop round trips with undo', () {
    final doc = Document(id: const Id('doc'));
    final bus = CommandBus(EventBus());
    final history = History(bus);
    registerDocumentHandlers(bus, doc);

    expect(doc.hoop.widthMm, 100); // defaults

    history.execute(const UpdateHoop(HoopSettings(
      widthMm: 130,
      heightMm: 180,
      shape: HoopShape.oval,
      fabricColorHex: '#1b5e9e',
      texture: FabricTexture.weave,
    )));
    expect(doc.hoop.heightMm, 180);
    expect(doc.hoop.shape, HoopShape.oval);

    history.undo();
    expect(doc.hoop.widthMm, 100);
    expect(doc.hoop.shape, HoopShape.roundedRectangle);
    history.redo();
    expect(doc.hoop.texture, FabricTexture.weave);
  });

  test('hoop persists through .swl', () {
    final doc = Document(id: const Id('doc'))
      ..hoop = const HoopSettings(
          widthMm: 200,
          heightMm: 150,
          shape: HoopShape.rectangle,
          fabricColorHex: '#ffffff',
          texture: FabricTexture.aida);
    final decoded = decodeProject(encodeProject(doc));
    expect(decoded.hoop.widthMm, 200);
    expect(decoded.hoop.shape, HoopShape.rectangle);
    expect(decoded.hoop.texture, FabricTexture.aida);
    expect(decoded.hoop.fabricColorHex, '#ffffff');
  });
}
