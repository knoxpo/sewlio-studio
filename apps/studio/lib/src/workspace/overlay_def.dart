import 'package:flutter/widgets.dart';

import '../workspace_view_model.dart';

/// A canvas overlay contribution (ARCH-038): presentation only, layered
/// over the shared canvas in domain/simulation modes. Builders read
/// derived state from the view model and never mutate anything.
// TODO: real stitch overlays should move into CanvasView's paint
// pipeline (precedent: its `stitches:` parameter) once they paint
// actual geometry — Stack layers can't share the viewport transform
// cheaply.
final class OverlayDef {
  const OverlayDef({
    required this.id,
    required this.label,
    this.defaultVisible = true,
    required this.builder,
  });

  final String id;
  final String label;
  final bool defaultVisible;
  final Widget Function(BuildContext context, WorkspaceViewModel model) builder;
}
