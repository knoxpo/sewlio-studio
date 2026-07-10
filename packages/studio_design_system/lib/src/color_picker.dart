import 'package:flutter/material.dart';

import 'button.dart';
import 'dialog.dart';
import 'text_field.dart';
import 'tokens.dart';

/// Compact desktop color picker: saturation/value square, hue slider,
/// hex and RGB entry. Returns the chosen `#rrggbb` hex, or null.
// ponytail: HSV only — HSL/CMYK entry waits for a real color-managed
// pipeline; values here are display-space RGB.
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
    body: _ColorPickerBody(
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

class _ColorPickerBody extends StatefulWidget {
  const _ColorPickerBody({required this.initialHex, required this.onChanged});

  final String initialHex;
  final ValueChanged<String> onChanged;

  @override
  State<_ColorPickerBody> createState() => _ColorPickerBodyState();
}

class _ColorPickerBodyState extends State<_ColorPickerBody> {
  static const _squareSize = Size(232, 140);
  static const _barWidth = 232.0;

  late HSVColor _hsv;
  late final TextEditingController _hex;

  Color get _color => _hsv.toColor();

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(_parse(widget.initialHex) ?? Colors.white);
    _hex = TextEditingController(text: _format(_hsv.toColor()));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  static Color? _parse(String text) {
    final hex = text.replaceFirst('#', '').trim();
    if (hex.length != 6) return null;
    final value = int.tryParse(hex, radix: 16);
    return value == null ? null : Color(0xFF000000 | value);
  }

  static String _format(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

  void _setHsv(HSVColor next) {
    setState(() {
      _hsv = next;
      _hex.text = _format(next.toColor());
    });
    widget.onChanged(_format(next.toColor()));
  }

  void _setChannel({int? r, int? g, int? b}) {
    final c = _color;
    _setHsv(HSVColor.fromColor(Color.fromARGB(
      255,
      (r ?? (c.r * 255).round()).clamp(0, 255),
      (g ?? (c.g * 255).round()).clamp(0, 255),
      (b ?? (c.b * 255).round()).clamp(0, 255),
    )));
  }

  void _dragSquare(Offset local) => _setHsv(_hsv
      .withSaturation(
        (local.dx / _squareSize.width).clamp(0, 1),
      )
      .withValue(1 - (local.dy / _squareSize.height).clamp(0, 1)));

  void _dragHue(Offset local) =>
      _setHsv(_hsv.withHue((local.dx / _barWidth).clamp(0, 1) * 360));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saturation (x) / value (y) square for the current hue.
        GestureDetector(
          onPanDown: (d) => _dragSquare(d.localPosition),
          onPanUpdate: (d) => _dragSquare(d.localPosition),
          child: SizedBox.fromSize(
            size: _squareSize,
            child: Stack(children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(colors: [
                    Colors.white,
                    HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor(),
                  ]),
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
              ),
              Positioned(
                left: _hsv.saturation * _squareSize.width - 6,
                top: (1 - _hsv.value) * _squareSize.height - 6,
                child: _thumb(),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 10),
        // Hue bar.
        GestureDetector(
          onPanDown: (d) => _dragHue(d.localPosition),
          onPanUpdate: (d) => _dragHue(d.localPosition),
          child: SizedBox(
            width: _barWidth,
            height: 14,
            child: Stack(children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  gradient: LinearGradient(colors: [
                    for (var h = 0; h <= 360; h += 60)
                      HSVColor.fromAHSV(1, h.toDouble() % 360, 1, 1).toColor(),
                  ]),
                ),
                child: const SizedBox.expand(),
              ),
              Positioned(
                left: _hsv.hue / 360 * _barWidth - 7,
                top: 0,
                child: _thumb(size: 14),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTokens.border),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StudioTextField(
              key: ValueKey('hex-${_hex.text}'),
              initialValue: _hex.text,
              label: 'Hex',
              onSubmitted: (text) {
                final color = _parse(text);
                if (color != null) _setHsv(HSVColor.fromColor(color));
              },
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          _channelField(
              'R', (_color.r * 255).round(), (v) => _setChannel(r: v)),
          const SizedBox(width: 8),
          _channelField(
              'G', (_color.g * 255).round(), (v) => _setChannel(g: v)),
          const SizedBox(width: 8),
          _channelField(
              'B', (_color.b * 255).round(), (v) => _setChannel(b: v)),
        ]),
      ],
    );
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

  Widget _thumb({double size = 12}) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 3)],
        ),
      );
}
