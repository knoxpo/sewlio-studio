import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'button.dart';
import 'dialog.dart';
import 'text_field.dart';
import 'tokens.dart';

/// Sentinel hex for a transparent colour (alpha 00): "no fill" / "no
/// stroke". A first-class colour, distinct from null (unset/inherit).
/// Renderers treat this as absent; [StudioColorSwatch] shows the
/// "none" slash for it.
const String studioTransparent = '#00000000';

/// Whether [hex] is the transparent sentinel.
bool isTransparent(String? hex) => hex == studioTransparent;

/// Compact Affinity-style colour picker: hue wheel + inner HSV triangle,
/// an opacity slider, a first-class transparent swatch, and hex / RGB /
/// HSL / CMYK entry. Returns the chosen hex — `#rrggbb` when fully opaque,
/// `#rrggbbaa` when partly transparent, [studioTransparent] for the
/// transparent swatch — or null on cancel.
// ponytail: display-space RGB conversions (CMYK is naive, no profile) —
// good enough until a real colour-managed pipeline lands.
Future<String?> showStudioColorPicker({
  required BuildContext context,
  required String initialHex,
}) {
  // The body reports every change here so the footer's Select button
  // (a plain dialog action) can return the latest pick.
  var picked = initialHex;
  return showStudioDialog<String>(
    context: context,
    title: 'Pick Color',
    width: 264,
    body: StudioColorEditor(
      initialHex: initialHex,
      onChanged: (hex) => picked = hex,
    ),
    actions: [
      Builder(
        builder: (context) => StudioButton(
          label: 'Cancel',
          variant: StudioButtonVariant.ghost,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      Builder(
        builder: (context) => StudioButton(
          key: const Key('color-picker-select'),
          label: 'Select',
          variant: StudioButtonVariant.primary,
          onPressed: () => Navigator.pop(context, picked),
        ),
      ),
    ],
  );
}

/// Parse a `#rrggbb` or `#rrggbbaa` hex into an opaque colour and an
/// alpha byte (0–255). Returns null on malformed input.
(Color, int)? _parseHex(String text) {
  final h = text.replaceFirst('#', '').trim();
  if (h.length != 6 && h.length != 8) return null;
  final rgb = int.tryParse(h.substring(0, 6), radix: 16);
  if (rgb == null) return null;
  var alpha = 255;
  if (h.length == 8) {
    final a = int.tryParse(h.substring(6, 8), radix: 16);
    if (a == null) return null;
    alpha = a;
  }
  return (Color(0xFF000000 | rgb), alpha);
}

/// Format an opaque colour + alpha byte per the picker contract:
/// alpha 0 → [studioTransparent], alpha 255 → `#rrggbb`, else
/// `#rrggbbaa`.
String _formatHex(Color c, int alpha) {
  if (alpha <= 0) return studioTransparent;
  final rgb = (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0');
  if (alpha >= 255) return '#$rgb';
  return '#$rgb${alpha.toRadixString(16).padLeft(2, '0')}';
}

/// The reusable colour-editing surface: hue wheel + HSV triangle, opacity
/// slider, transparent swatch, hex/RGB entry. Used inside
/// [showStudioColorPicker]'s dialog and embedded directly in panels
/// (Fill/Stroke) for inline editing. Emits every change via [onChanged].
class StudioColorEditor extends StatefulWidget {
  const StudioColorEditor(
      {super.key, required this.initialHex, required this.onChanged});

  final String initialHex;
  final ValueChanged<String> onChanged;

  @override
  State<StudioColorEditor> createState() => _StudioColorEditorState();
}

class _StudioColorEditorState extends State<StudioColorEditor> {
  static const _wheelSize = Size.square(190);

  late HSVColor _hsv; // hue/sat/value; alpha tracked separately.
  int _alpha = 255; // 0–255.
  late final TextEditingController _hex;

  /// Opaque display colour for the current H/S/V.
  Color get _rgb => _hsv.toColor();

  @override
  void initState() {
    super.initState();
    final parsed = _parseHex(widget.initialHex) ?? (Colors.white, 255);
    _hsv = HSVColor.fromColor(parsed.$1);
    _alpha = parsed.$2;
    _hex = TextEditingController(text: _formatHex(_rgb, _alpha));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _emit() {
    final hex = _formatHex(_rgb, _alpha);
    _hex.text = hex;
    widget.onChanged(hex);
  }

  void _setHsv(HSVColor next) => setState(() {
        _hsv = next;
        _emit();
      });

  void _setAlpha(int a) => setState(() {
        _alpha = a.clamp(0, 255);
        _emit();
      });

  void _setChannel({int? r, int? g, int? b}) {
    final c = _rgb;
    _setHsv(HSVColor.fromColor(Color.fromARGB(
      255,
      (r ?? (c.r * 255).round()).clamp(0, 255),
      (g ?? (c.g * 255).round()).clamp(0, 255),
      (b ?? (c.b * 255).round()).clamp(0, 255),
    )));
  }

  void _pickTransparent() => setState(() {
        _alpha = 0;
        _emit();
      });

  // Route a pointer on the wheel box: outside the inner circle picks the
  // hue by angle; inside picks saturation/value from the triangle.
  void _dragWheel(Offset local) {
    final g = _WheelGeom(_wheelSize, _hsv.hue);
    final v = local - g.center;
    if (v.distance >= g.innerR) {
      final deg = (math.atan2(v.dy, v.dx) * 180 / math.pi) % 360;
      _setHsv(_hsv.withHue(deg < 0 ? deg + 360 : deg));
      return;
    }
    final (a, b, c) = g.barycentricClamped(local);
    final vv = (a + b).clamp(0.0, 1.0); // value
    final sv = (a + b) <= 0 ? 0.0 : (a / (a + b)).clamp(0.0, 1.0); // saturation
    _setHsv(_hsv.withSaturation(sv).withValue(vv));
    // c is the black weight; unused directly (value already encodes it).
    assert(c >= -0.001);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transparent swatch (red slash) + current-colour preview,
            // stacked top-left like Affinity's picker.
            Column(children: [
              _TransparentSwatch(onTap: _pickTransparent),
              const SizedBox(height: 6),
              _PreviewSwatch(color: _rgb, alpha: _alpha),
            ]),
            const SizedBox(width: 8),
            // Hue wheel + inner HSV triangle.
            GestureDetector(
              onPanDown: (d) => _dragWheel(d.localPosition),
              onPanUpdate: (d) => _dragWheel(d.localPosition),
              child: CustomPaint(
                size: _wheelSize,
                painter: _WheelPainter(_hsv),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Opacity slider.
        _OpacitySlider(
          color: _rgb,
          alpha: _alpha,
          onChanged: _setAlpha,
        ),
        const SizedBox(height: 12),
        StudioTextField(
          key: ValueKey('hex-${_hex.text}'),
          initialValue: _hex.text,
          label: 'Hex',
          onSubmitted: (text) {
            final parsed = _parseHex(text);
            if (parsed == null) return;
            setState(() {
              _hsv = HSVColor.fromColor(parsed.$1);
              _alpha = parsed.$2;
              _emit();
            });
          },
        ),
        const SizedBox(height: 8),
        Row(children: [
          _channelField('R', (_rgb.r * 255).round(), (v) => _setChannel(r: v)),
          const SizedBox(width: 8),
          _channelField('G', (_rgb.g * 255).round(), (v) => _setChannel(g: v)),
          const SizedBox(width: 8),
          _channelField('B', (_rgb.b * 255).round(), (v) => _setChannel(b: v)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _channelField('H', _hsl.hue.round(), (v) => _setHsl(h: v.toDouble())),
          const SizedBox(width: 8),
          _channelField(
              'S', (_hsl.saturation * 100).round(), (v) => _setHsl(s: v / 100)),
          const SizedBox(width: 8),
          _channelField(
              'L', (_hsl.lightness * 100).round(), (v) => _setHsl(l: v / 100)),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _channelField('C', _cmyk.$1, (v) => _setCmyk(c: v)),
          const SizedBox(width: 8),
          _channelField('M', _cmyk.$2, (v) => _setCmyk(m: v)),
          const SizedBox(width: 8),
          _channelField('Y', _cmyk.$3, (v) => _setCmyk(y: v)),
          const SizedBox(width: 8),
          _channelField('K', _cmyk.$4, (v) => _setCmyk(k: v)),
        ]),
      ],
    );
  }

  HSLColor get _hsl => HSLColor.fromColor(_rgb);

  /// Current colour as CMYK percentages (0–100).
  (int, int, int, int) get _cmyk {
    final r = _rgb.r, g = _rgb.g, b = _rgb.b;
    final k = 1 - math.max(r, math.max(g, b));
    if (k >= 1) return (0, 0, 0, 100);
    final c = (1 - r - k) / (1 - k);
    final m = (1 - g - k) / (1 - k);
    final y = (1 - b - k) / (1 - k);
    return (
      (c * 100).round(),
      (m * 100).round(),
      (y * 100).round(),
      (k * 100).round()
    );
  }

  void _setHsl({double? h, double? s, double? l}) {
    final cur = _hsl;
    _setHsv(HSVColor.fromColor(HSLColor.fromAHSL(
      1,
      (h ?? cur.hue).clamp(0, 360),
      (s ?? cur.saturation).clamp(0, 1),
      (l ?? cur.lightness).clamp(0, 1),
    ).toColor()));
  }

  void _setCmyk({int? c, int? m, int? y, int? k}) {
    final cur = _cmyk;
    final cc = (c ?? cur.$1).clamp(0, 100) / 100;
    final mm = (m ?? cur.$2).clamp(0, 100) / 100;
    final yy = (y ?? cur.$3).clamp(0, 100) / 100;
    final kk = (k ?? cur.$4).clamp(0, 100) / 100;
    _setHsv(HSVColor.fromColor(Color.fromARGB(
      255,
      (255 * (1 - cc) * (1 - kk)).round(),
      (255 * (1 - mm) * (1 - kk)).round(),
      (255 * (1 - yy) * (1 - kk)).round(),
    )));
  }

  Widget _channelField(String label, int value, void Function(int) onChanged) {
    return Expanded(
      child: StudioTextField(
        key: ValueKey('$label-$value'),
        initialValue: '$value',
        label: label,
        keyboardType: TextInputType.number,
        onSubmitted: (text) {
          final v = int.tryParse(text.trim());
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// Geometry of the hue wheel and its inscribed HSV triangle for a given
/// hue. Shared by the painter and the hit-testing so they never drift.
class _WheelGeom {
  _WheelGeom(this.size, this.hue);

  final Size size;
  final double hue;

  Offset get center => Offset(size.width / 2, size.height / 2);
  double get outerR => size.shortestSide / 2;
  double get ringThickness => size.shortestSide * 0.12;
  double get innerR => outerR - ringThickness;

  // Triangle circumscribed radius, a hair inside the ring.
  double get triR => innerR - 3;

  static double _rad(double deg) => deg * math.pi / 180;
  Offset _onCircle(double deg, double r) =>
      center + Offset(math.cos(_rad(deg)), math.sin(_rad(deg))) * r;

  /// Pure-hue vertex (S=1, V=1), pointing at the current hue.
  Offset get vHue => _onCircle(hue, triR);

  /// White vertex (S=0, V=1).
  Offset get vWhite => _onCircle(hue + 120, triR);

  /// Black vertex (V=0).
  Offset get vBlack => _onCircle(hue + 240, triR);

  /// Hue thumb sits centred in the ring band.
  Offset get hueThumb => _onCircle(hue, (outerR + innerR) / 2);

  /// Position of the current saturation/value inside the triangle.
  Offset svThumb(double sat, double val) {
    final a = sat * val; // hue weight
    final b = val * (1 - sat); // white weight
    final c = 1 - val; // black weight
    return vHue * a + vWhite * b + vBlack * c;
  }

  /// Barycentric weights (hue, white, black) of [p], clamped into the
  /// triangle. ponytail: negative weights are zeroed and renormalised —
  /// a cheap projection that keeps the thumb on the triangle without a
  /// full point-to-triangle clamp.
  (double, double, double) barycentricClamped(Offset p) {
    final a = vHue, b = vWhite, c = vBlack;
    final v0 = b - a, v1 = c - a, v2 = p - a;
    final d00 = v0.dx * v0.dx + v0.dy * v0.dy;
    final d01 = v0.dx * v1.dx + v0.dy * v1.dy;
    final d11 = v1.dx * v1.dx + v1.dy * v1.dy;
    final d20 = v2.dx * v0.dx + v2.dy * v0.dy;
    final d21 = v2.dx * v1.dx + v2.dy * v1.dy;
    final den = d00 * d11 - d01 * d01;
    if (den == 0) return (1, 0, 0);
    final wb = (d11 * d20 - d01 * d21) / den; // white
    final wc = (d00 * d21 - d01 * d20) / den; // black
    final wa = 1 - wb - wc; // hue
    var ha = wa < 0 ? 0.0 : wa;
    var hb = wb < 0 ? 0.0 : wb;
    var hc = wc < 0 ? 0.0 : wc;
    final sum = ha + hb + hc;
    if (sum == 0) return (1, 0, 0);
    return (ha / sum, hb / sum, hc / sum);
  }
}

/// Foot of the perpendicular from [p] onto the line through [a]–[b].
Offset _footOnLine(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 == 0) return a;
  final t = ((p - a).dx * ab.dx + (p - a).dy * ab.dy) / len2;
  return a + ab * t;
}

/// Paints the hue ring, the inscribed HSV triangle, and both thumbs.
class _WheelPainter extends CustomPainter {
  _WheelPainter(this.hsv);

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final g = _WheelGeom(size, hsv.hue);

    // Hue ring: a sweep gradient stroked as an annulus.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = g.ringThickness
      ..shader = ui.Gradient.sweep(
        g.center,
        [
          for (var h = 0; h <= 360; h += 60)
            HSVColor.fromAHSV(1, h % 360.0, 1, 1).toColor()
        ],
        [for (var h = 0; h <= 360; h += 60) h / 360],
      );
    final ringR = (g.outerR + g.innerR) / 2;
    canvas.drawCircle(g.center, ringR, ringPaint);

    // HSV triangle: base black + additive hue and white gradients so the
    // per-pixel colour equals hueWeight*hue + whiteWeight*white.
    final tri = Path()
      ..moveTo(g.vHue.dx, g.vHue.dy)
      ..lineTo(g.vWhite.dx, g.vWhite.dy)
      ..lineTo(g.vBlack.dx, g.vBlack.dy)
      ..close();
    canvas.save();
    canvas.clipPath(tri);
    canvas.drawPath(tri, Paint()..color = Colors.black);
    final hue = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    final bounds = tri.getBounds();
    // Hue gradient runs from edge (white–black) up to the hue vertex.
    final hueFoot = _footOnLine(g.vHue, g.vWhite, g.vBlack);
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.linear(
          hueFoot,
          g.vHue,
          [hue.withValues(alpha: 0), hue],
        ),
    );
    // White gradient runs from edge (hue–black) up to the white vertex.
    final whiteFoot = _footOnLine(g.vWhite, g.vHue, g.vBlack);
    canvas.drawRect(
      bounds,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = ui.Gradient.linear(
          whiteFoot,
          g.vWhite,
          [const Color(0x00FFFFFF), const Color(0xFFFFFFFF)],
        ),
    );
    canvas.restore();

    _drawThumb(canvas, g.hueThumb, 7);
    _drawThumb(canvas, g.svThumb(hsv.saturation, hsv.value), 6);
  }

  void _drawThumb(Canvas canvas, Offset c, double r) {
    canvas.drawCircle(c, r, Paint()..color = const Color(0x66000000));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_WheelPainter old) => old.hsv != hsv;
}

/// A small square that selects the transparent colour when tapped.
class _TransparentSwatch extends StatelessWidget {
  const _TransparentSwatch({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('color-picker-transparent'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppTokens.field,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTokens.border),
        ),
        child: CustomPaint(painter: _SlashPainter()),
      ),
    );
  }
}

/// Current-colour preview over a checkerboard so partial alpha reads.
class _PreviewSwatch extends StatelessWidget {
  const _PreviewSwatch({required this.color, required this.alpha});

  final Color color;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _CheckerPainter(),
        child: ColoredBox(color: color.withValues(alpha: alpha / 255)),
      ),
    );
  }
}

/// Horizontal opacity slider: checkerboard under a transparent→opaque
/// gradient of the current colour, a draggable thumb, and a percent
/// readout.
class _OpacitySlider extends StatelessWidget {
  const _OpacitySlider({
    required this.color,
    required this.alpha,
    required this.onChanged,
  });

  final Color color;
  final int alpha;
  final ValueChanged<int> onChanged;

  static const _width = 182.0;

  void _drag(Offset local) =>
      onChanged(((local.dx / _width).clamp(0.0, 1.0) * 255).round());

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      GestureDetector(
        onPanDown: (d) => _drag(d.localPosition),
        onPanUpdate: (d) => _drag(d.localPosition),
        child: SizedBox(
          width: _width,
          height: 16,
          child: Stack(clipBehavior: Clip.none, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomPaint(
                painter: _CheckerPainter(),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      color.withValues(alpha: 0),
                      color.withValues(alpha: 1),
                    ]),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            Positioned(
              left: (alpha / 255) * _width - 6,
              top: -1,
              child: Container(
                width: 12,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: const Color(0x88000000)),
                ),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      SizedBox(
        width: 34,
        child: Text(
          '${(alpha / 255 * 100).round()}%',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 11, color: AppTokens.textMuted),
        ),
      ),
    ]);
  }
}

/// Diagonal red slash marking the transparent/none swatch.
class _SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTokens.error
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(3, size.height - 3), Offset(size.width - 3, 3), paint);
  }

  @override
  bool shouldRepaint(_SlashPainter old) => false;
}

/// Grey checkerboard, the universal "transparency" backdrop.
class _CheckerPainter extends CustomPainter {
  static const _cell = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Paint()..color = const Color(0xFFBDBDBD);
    final dark = Paint()..color = const Color(0xFF8A8A8A);
    canvas.drawRect(Offset.zero & size, light);
    for (var y = 0.0; y < size.height; y += _cell) {
      for (var x = 0.0; x < size.width; x += _cell) {
        if (((x ~/ _cell) + (y ~/ _cell)).isEven) continue;
        canvas.drawRect(Rect.fromLTWH(x, y, _cell, _cell), dark);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerPainter old) => false;
}
