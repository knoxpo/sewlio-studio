import 'package:studio_tools/studio_tools.dart';

import 'font_io.dart';

/// Application font registry: the built-in monoline font plus every
/// parseable TrueType font installed on the system. Scan runs once,
/// lazily, off the UI thread; parsed fonts are cached.
// ponytail: singleton app state — inject if fonts ever need per-project
// scoping.
final class FontLibrary {
  FontLibrary._();

  static final instance = FontLibrary._();

  static const builtinFamily = 'Monoline';

  Future<Map<String, String>>? _scan;
  final _cache = <String, TextFont>{};

  /// Family display names: built-in first, system fonts sorted.
  Future<List<String>> families() async {
    final system = await (_scan ??= scanSystemFontFamilies());
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
}
