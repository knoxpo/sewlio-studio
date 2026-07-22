import 'package:studio_commands/studio_commands.dart';
import 'package:studio_core/studio_core.dart';
import 'package:studio_document/studio_document.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_events/studio_events.dart';
import 'package:test/test.dart';

void main() {
  late Document doc;
  late History history;

  setUp(() {
    doc = Document(id: Id('d1'));
    final events = EventBus();
    final bus = CommandBus(events);
    registerDocumentHandlers(bus, doc);
    history = History(bus);
  });

  test('SetOpticalRules replaces the table and undoes exactly', () {
    expect(doc.opticalRules, isEmpty);
    history.execute(const SetOpticalRules([
      OpticalRule(leftPct: 100, rightPct: 100, chars: '.,'),
    ]));
    expect(doc.opticalRules.single.chars, '.,');

    history.execute(SetOpticalRules(OpticalRule.defaults));
    expect(doc.opticalRules.length, OpticalRule.defaults.length);

    history.undo();
    expect(doc.opticalRules.single.chars, '.,');
    history.undo();
    expect(doc.opticalRules, isEmpty);
    history.redo();
    expect(doc.opticalRules.single.chars, '.,');
  });

  test('optical rules persist through .swl and default-empty stays empty', () {
    history.execute(SetOpticalRules(OpticalRule.defaults));
    final restored = decodeProject(encodeProject(doc));
    expect(restored.opticalRules, OpticalRule.defaults);

    final blank = Document(id: Id('d2'));
    expect(decodeProject(encodeProject(blank)).opticalRules, isEmpty);
  });
}
