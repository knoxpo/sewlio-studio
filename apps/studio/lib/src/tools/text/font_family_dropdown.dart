import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import '../../font_library.dart';

/// The application's font-family picker: searchable, with each family
/// name previewed in its own typeface. One widget shared by the
/// Character panel and the text tool's options bar so the two surfaces
/// can never drift. A family missing from the scan (an unparseable
/// `.otf`, or the scan still running) is shown by name via [hint].
class FontFamilyDropdown extends StatefulWidget {
  const FontFamilyDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.width,
    this.mixed = false,
  });

  /// Current family name (may be unknown to the scan).
  final String value;
  final void Function(String family) onChanged;
  final double? width;

  /// Selection spans multiple families (panel's mixed state).
  final bool mixed;

  @override
  State<FontFamilyDropdown> createState() => _FontFamilyDropdownState();
}

class _FontFamilyDropdownState extends State<FontFamilyDropdown> {
  @override
  void initState() {
    super.initState();
    // Preview faces register asynchronously — rebuild as they land.
    FontLibrary.instance.addListener(_onFontsChanged);
  }

  @override
  void dispose() {
    FontLibrary.instance.removeListener(_onFontsChanged);
    super.dispose();
  }

  void _onFontsChanged() {
    if (mounted) setState(() {});
  }

  /// Font family to render a picker item's own label in: registers the
  /// face on first sight and returns it once ready (else null → default
  /// UI font until the async load completes and rebuilds).
  String? _previewFamily(String family) {
    if (family == FontLibrary.builtinFamily) return null;
    FontLibrary.instance.ensurePreview(family);
    return FontLibrary.instance.isPreviewReady(family) ? family : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: FontLibrary.instance.families(),
      builder: (context, snapshot) {
        final families = snapshot.data ?? const [FontLibrary.builtinFamily];
        final known = families.contains(widget.value);
        return StudioSearchableDropdown<String>(
          key: const Key('font-family-dropdown'),
          value: known && !widget.mixed ? widget.value : null,
          hint: widget.mixed ? 'Mixed' : (known ? null : widget.value),
          width: widget.width ?? double.infinity,
          items: [for (final f in families) (f, f)],
          itemFontFamily: _previewFamily,
          onChanged: widget.onChanged,
        );
      },
    );
  }
}
