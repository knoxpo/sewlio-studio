import 'dart:ui';

/// Stylus tap/drag state machine, driven by raw pointer events so
/// strokes start after a small slop with live pressure — bypassing the
/// gesture arena entirely (the arena's tap/scale competition adds
/// latency a drawing stylus can't afford).
///
/// Pure Dart: feed it [down]/[move]/[up]/[cancel] and it emits tap or
/// drag callbacks in screen coordinates. Double taps are not detected
/// here — the workspace view model already does its own detection on
/// plain taps (see `_isDoubleTap`).
final class StylusGestureHandler {
  StylusGestureHandler({
    this.onTap,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.slop = 6.0,
  });

  final void Function(Offset position)? onTap;
  final void Function(Offset position, double pressure)? onDragStart;
  final void Function(Offset position, double pressure)? onDragUpdate;
  final void Function()? onDragEnd;

  /// Movement (logical px) before a contact becomes a drag. Smaller
  /// than touch slop — a stylus is precise, and drawing should start
  /// near-immediately. ponytail: constant chosen by feel, tune on
  /// hardware if taps turn into micro-drags.
  final double slop;

  Offset? _downPosition;
  double _downPressure = 1.0;
  bool _dragging = false;

  /// Whether a stylus contact is currently being tracked.
  bool get isActive => _downPosition != null;

  void down(Offset position, double pressure) {
    _downPosition = position;
    _downPressure = pressure;
    _dragging = false;
  }

  void move(Offset position, double pressure) {
    final down = _downPosition;
    if (down == null) return;
    if (!_dragging) {
      if ((position - down).distance < slop) return;
      _dragging = true;
      // The stroke starts where the stylus touched, with the contact
      // pressure — not slop-distance late.
      onDragStart?.call(down, _downPressure);
    }
    onDragUpdate?.call(position, pressure);
  }

  void up(Offset position) {
    final down = _downPosition;
    _downPosition = null;
    if (down == null) return;
    if (_dragging) {
      _dragging = false;
      onDragEnd?.call();
    } else {
      onTap?.call(down);
    }
  }

  void cancel() {
    final wasDragging = _dragging;
    _downPosition = null;
    _dragging = false;
    if (wasDragging) onDragEnd?.call();
  }
}
