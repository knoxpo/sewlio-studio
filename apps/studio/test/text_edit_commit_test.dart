import 'package:flutter_test/flutter_test.dart';
import 'package:studio/main.dart';
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
  test('entering and leaving text edit without changes is a no-op '
      '(no history entry, no dirty document)', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.execute(AddObject(_text(), parent: null));
    final revisionAfterAdd = session.document.revision;

    final tool = vm.tools[ToolKind.text]! as TextTool;
    tool.editExisting(
        session.document.objectById(const Id('t1')) as TextObject,
        const MonolineTextFont());
    tool.commit();

    expect(session.document.revision, revisionAfterAdd,
        reason: 'document untouched — reopening a file and double-'
            'clicking text must not mark it dirty');
    // Only the AddObject is in the undo stack — no phantom replace.
    session.history.undo();
    expect(session.document.objectById(const Id('t1')), isNull);
    expect(session.history.canUndo, isFalse,
        reason: 'no-change edit must not create an undo entry');
  });

  test('style runs survive a text-tool commit that keeps the text', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.execute(AddObject(_text(), parent: null));
    vm.selectRef(const DocumentNodeRef(DocumentNodeKind.object, Id('t1')));

    // Style the whole string with an underline run.
    vm.applyCharAttrs(const CharAttrs(
        decorations: TextDecorations(lines: {TextDecorationLine.underline})));
    TextObject object() =>
        session.document.objectById(const Id('t1')) as TextObject;
    expect(object().runs, isNotEmpty);

    // Re-edit and change only the size — a real commit.
    final tool = vm.tools[ToolKind.text]! as TextTool;
    tool.editExisting(object(), const MonolineTextFont());
    tool.sizeMm = 8;
    tool.commit();

    expect(object().sizeMm, 8);
    expect(object().runs, isNotEmpty,
        reason: 'commit must carry the runs — before this fix it '
            'rebuilt the object without them');
    expect(
        object().attrsAt(0).decorations!.has(TextDecorationLine.underline),
        isTrue);
  });

  test('styling applied while editing shows in the live preview', () {
    final session = StudioSession();
    final vm = WorkspaceViewModel(session: session);
    vm.execute(AddObject(_text(), parent: null));

    final tool = vm.tools[ToolKind.text]! as TextTool;
    tool.editExisting(
        session.document.objectById(const Id('t1')) as TextObject,
        const MonolineTextFont());
    final plainPreview = tool.previewFills.length;

    // Underline the whole string from the panel/toolbar while editing.
    tool.selectAll();
    vm.applyCharAttrs(const CharAttrs(
        decorations: TextDecorations(lines: {TextDecorationLine.underline})));

    expect(tool.previewFills.length, plainPreview + 1,
        reason: 'the in-place preview is run-aware — the decoration '
            'must appear before commit');
  });
}
