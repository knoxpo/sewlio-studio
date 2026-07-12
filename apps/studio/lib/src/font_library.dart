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

  Future<Map<String, Map<String, String>>>? _scan;
  Map<String, Map<String, String>> _paths = const {};
  final _cache = <String, TextFont>{};
  final _previewReady = <String>{};
  final _previewLoading = <String>{};

  /// Whether the system scan has landed ([stylesFor] is authoritative
  /// only after it has).
  bool get scanned => _paths.isNotEmpty;

  /// Family display names: built-in first, system fonts sorted.
  /// Notifies listeners the first time the scan lands so style-aware
  /// UI built before it can refresh.
  Future<List<String>> families() async {
    final first = !scanned;
    final system = await (_scan ??= scanSystemFontFamilies());
    _paths = system;
    if (first && scanned) notifyListeners();
    return [builtinFamily, ...system.keys.toList()..sort()];
  }

  static const _styleOrder = [
    'Regular', 'Normal', // synonyms first
    'Bold',
    'Italic', 'Oblique',
    'Bold Italic', 'Bold Oblique',
  ];

  /// Style names available for [family] (Regular/Bold/Italic/… faces
  /// grouped by the scan), common styles first. Synchronous — before
  /// the scan completes it reports the single default style.
  List<String> stylesFor(String family) {
    final styles = _paths[family]?.keys.toList();
    if (styles == null || styles.isEmpty) return const ['Regular'];
    // Common styles first, remaining variants (Black, Book, Light, …)
    // alphabetical.
    styles.sort((a, b) {
      final ia = _styleOrder.indexOf(a), ib = _styleOrder.indexOf(b);
      final ra = ia < 0 ? _styleOrder.length : ia;
      final rb = ib < 0 ? _styleOrder.length : ib;
      return ra != rb ? ra.compareTo(rb) : a.compareTo(b);
    });
    return styles;
  }

  /// The face path for ([family], [style]), falling back to Regular
  /// then any face of the family.
  String? _pathFor(String family, String style) {
    final styles = _paths[family];
    if (styles == null || styles.isEmpty) return null;
    return styles[style] ?? styles['Regular'] ?? styles.values.first;
  }

  /// The already-loaded face for [family] + [style], or null if that
  /// exact face is not yet cached. Synchronous — for UI that needs font
  /// capabilities during build; a null result means "trigger [load] and
  /// rebuild" (callers pick their own fallback face meanwhile).
  TextFont? cached(String family, {String style = 'Regular'}) =>
      family == builtinFamily
          ? const MonolineTextFont()
          : _cache['$family/$style'];

  /// Loads (and caches) the font face for [family] + [style]; falls
  /// back to the family's Regular face, then to the built-in monoline
  /// font when nothing can be parsed.
  Future<TextFont> load(String family, {String style = 'Regular'}) async {
    if (family == builtinFamily) return const MonolineTextFont();
    final key = '$family/$style';
    final cached = _cache[key];
    if (cached != null) return cached;
    _paths = await (_scan ??= scanSystemFontFamilies());
    final path = _pathFor(family, style);
    final font = path == null ? null : await loadFontFile(path);
    return _cache[key] = font ?? const MonolineTextFont();
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
    final path = _pathFor(family, 'Regular');
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
