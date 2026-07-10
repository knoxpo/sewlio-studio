import 'package:studio_geometry/studio_geometry.dart';

import 'tool.dart';

/// Hoop tool (the embroidery "artboard" tool): clicking the canvas
/// opens the hoop/document setup.
// ponytail: interactive hoop resize/reposition needs a hoop origin in
// the document schema (hoop is anchored at world 0,0 today) — this
// tool becomes a real manipulator when that lands (ADR needed).
final class HoopTool extends Tool {
  HoopTool({required this.onOpenSetup});

  final void Function() onOpenSetup;

  @override
  void tap(Point world) => onOpenSetup();

  @override
  String? get status => 'Hoop: click to edit hoop size, shape, and fabric';
}
