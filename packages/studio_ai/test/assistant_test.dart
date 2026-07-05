import 'package:studio_ai/studio_ai.dart';
import 'package:studio_commands/studio_commands.dart';
import 'package:test/test.dart';

final class _Noop extends Command {
  const _Noop(this.tag);
  final String tag;
}

void main() {
  test('first understanding hook wins; none → empty', () {
    final assistant = Assistant()
      ..register((input) => input.contains('a') ? const [_Noop('a')] : const [])
      ..register(
          (input) => input.contains('b') ? const [_Noop('b')] : const []);

    expect((assistant.propose('ab').single as _Noop).tag, 'a');
    expect((assistant.propose('b').single as _Noop).tag, 'b');
    expect(assistant.propose('zzz'), isEmpty);
  });
}
