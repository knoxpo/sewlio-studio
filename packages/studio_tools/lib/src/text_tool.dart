import 'package:studio_geometry/studio_geometry.dart';

import 'monoline_font.dart';
import 'tool.dart';

/// Tap to place text. The shell supplies the string via [onRequestText]
/// (dialog); glyphs come from the built-in monoline font and commit as
/// one path per stroke through [onCreate].
final class TextTool extends Tool {
  TextTool({required this.onRequestText, required this.onCreate});

  /// Asks the user for a string (returns null on cancel).
  final Future<String?> Function() onRequestText;
  final void Function(Path path) onCreate;

  double sizeMm = 10;

  @override
  void tap(Point world) {
    onRequestText().then((text) {
      if (text == null || text.trim().isEmpty) return;
      for (final path in textToPaths(text, origin: world, sizeMm: sizeMm)) {
        onCreate(path);
      }
    });
  }

  @override
  String? get status => 'Text: click on canvas to place text';
}
