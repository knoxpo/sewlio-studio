/// Canvas viewport and design rendering.
///
/// Renders the document and forwards gestures out as world-space
/// callbacks — it never mutates the document (tools do, via commands).
library;

export 'src/canvas_view.dart';
export 'src/viewport.dart';
