import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';
import 'package:studio_embroidery/studio_embroidery.dart';
import 'package:studio_geometry/studio_geometry.dart' as g;

/// The thread colour an object renders with: explicit stroke colour,
/// else its fill, else the theme default the canvas uses.
Color threadColor(EmbroideryObject object) =>
    _parseHex(object.stroke.colorHex) ??
    _parseHex(object.stroke.fillHex) ??
    AppTokens.primary;

Color? _parseHex(String? hex) => hex == null
    ? null
    : Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

/// Swatch marking an object's thread colour (Stitches panel).
class ThreadSwatch extends StatelessWidget {
  const ThreadSwatch({super.key, required this.object, this.size = 12});

  final EmbroideryObject object;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Thread colour',
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: threadColor(object),
          border: Border.all(color: AppTokens.border),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

/// Miniature preview of one object's geometry (Layers panel): its
/// render contours scaled to fit, drawn in the thread colour. Text
/// objects preview their laid-out glyph outlines via [renderPaths].
class ObjectThumbnail extends StatelessWidget {
  const ObjectThumbnail({super.key, required this.object, this.size = 20});

  final EmbroideryObject object;
  final double size;

  @override
  Widget build(BuildContext context) =>
      NodeThumbnail(objects: [object], size: size);
}

/// Composite preview of any hierarchy node: every contained object
/// drawn together in its own thread colour (layers and groups get the
/// same treatment as objects). Empty containers show [emptyIcon].
class NodeThumbnail extends StatelessWidget {
  const NodeThumbnail({
    super.key,
    required this.objects,
    this.size = 20,
    this.emptyIcon,
  });

  final List<EmbroideryObject> objects;
  final double size;
  final IconData? emptyIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTokens.background,
        border: Border.all(color: AppTokens.border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: objects.isEmpty
          ? (emptyIcon == null
              ? null
              : Icon(emptyIcon, size: size * 0.6, color: AppTokens.textMuted))
          : CustomPaint(painter: _ThumbPainter(objects)),
    );
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.objects);

  final List<EmbroideryObject> objects;

  @override
  void paint(Canvas canvas, Size size) {
    var bounds = objects.first.bounds();
    for (final object in objects.skip(1)) {
      bounds = bounds.union(object.bounds());
    }
    if (bounds.width <= 0 && bounds.height <= 0) return;
    const inset = 3.0;
    final scale = _fitScale(bounds, size, inset);
    final dx = (size.width - bounds.width * scale) / 2 - bounds.minX * scale;
    final dy = (size.height - bounds.height * scale) / 2 - bounds.minY * scale;

    for (final object in objects) {
      final fillHex = object.stroke.fillHex;
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = threadColor(object);
      for (final contour in object.renderPaths) {
        final points = contour.toPolyline();
        if (points.isEmpty) continue;
        final path = Path()
          ..moveTo(points.first.x * scale + dx, points.first.y * scale + dy);
        for (final p in points.skip(1)) {
          path.lineTo(p.x * scale + dx, p.y * scale + dy);
        }
        if (fillHex != null) {
          canvas.drawPath(
            Path.from(path)..close(),
            Paint()..color = _parseHex(fillHex)!.withValues(alpha: 0.7),
          );
        }
        canvas.drawPath(path, stroke);
      }
    }
  }

  static double _fitScale(g.Bounds bounds, Size size, double inset) {
    final sx =
        (size.width - inset * 2) / (bounds.width <= 0 ? 1 : bounds.width);
    final sy =
        (size.height - inset * 2) / (bounds.height <= 0 ? 1 : bounds.height);
    return sx < sy ? sx : sy;
  }

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) =>
      !identical(oldDelegate.objects, objects) &&
      (oldDelegate.objects.length != objects.length ||
          !_sameObjects(oldDelegate.objects, objects));

  static bool _sameObjects(List<EmbroideryObject> a, List<EmbroideryObject> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
