import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:studio_tools/studio_tools.dart';

import 'font_io.dart';

/// Application font registry: the built-in monoline font plus every
/// parseable TrueType font installed on the system. Scan runs once,
/// lazily, off the UI thread; parsed fonts are cached.
///
/// Also registers fonts with Flutter's engine on demand ([ensurePreview])
/// so the font picker can render each family name in its own typeface;
/// notifies listeners when a preview face becomes available.
// ponytail: singleton app state — inject if fonts ever need per-project
// scoping.
class FontLibrary extends ChangeNotifier {
  FontLibrary._();

  static final instance = FontLibrary._();

  static const builtinFamily = 'Monoline';

  Future<Map<String, String>>? _scan;
  Map<String, String> _paths = const {};
  final _cache = <String, TextFont>{};
  final _previewReady = <String>{};
  final _previewLoading = <String>{};

  /// Family display names: built-in first, system fonts sorted.
  Future<List<String>> families() async {
    final system = await (_scan ??= scanSystemFontFamilies());
    _paths = system;
    return [builtinFamily, ...system.keys.toList()..sort()];
  }

  /// The already-loaded font for [family], or null if not yet cached.
  /// Synchronous — for UI that needs font capabilities during build; a
  /// null result means "trigger [load] and rebuild".
  TextFont? cached(String family) =>
      family == builtinFamily ? const MonolineTextFont() : _cache[family];

  /// Loads (and caches) the font for [family]; falls back to the
  /// built-in monoline font when the file can't be parsed.
  Future<TextFont> load(String family) async {
    if (family == builtinFamily) return const MonolineTextFont();
    final cached = _cache[family];
    if (cached != null) return cached;
    final path = (await (_scan ??= scanSystemFontFamilies()))[family];
    final font = path == null ? null : await loadFontFile(path);
    return _cache[family] = font ?? const MonolineTextFont();
  }

  /// Whether [family] is registered with Flutter and can be rendered by a
  /// `TextStyle(fontFamily: family)` (the built-in monoline is not — it is
  /// a stroke font with no glyph raster).
  bool isPreviewReady(String family) => _previewReady.contains(family);

  /// Registers [family]'s font file with Flutter's engine so its name can
  /// be previewed in its own typeface. Idempotent; notifies listeners when
  /// the face finishes loading. No-op for the built-in font, unknown
  /// families, or the web (no font bytes).
  void ensurePreview(String family) {
    if (family == builtinFamily ||
        _previewReady.contains(family) ||
        _previewLoading.contains(family)) {
      return;
    }
    final path = _paths[family];
    if (path == null) return;
    _previewLoading.add(family);
    () async {
      final bytes = await loadFontBytes(path);
      if (bytes != null) {
        try {
          await (FontLoader(family)
                ..addFont(Future.value(ByteData.sublistView(bytes))))
              .load();
          _previewReady.add(family);
          notifyListeners();
        } catch (_) {
          // Unparseable-by-engine face — leave it in the default UI font.
        }
      }
      _previewLoading.remove(family);
    }();
  }

  @visibleForTesting
  void registerPreviewForTest(String family) {
    _previewReady.add(family);
  }
}
