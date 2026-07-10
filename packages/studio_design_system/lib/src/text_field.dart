import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Studio text input: recessed field chrome with input-group [prefix]
/// and [suffix] slots rendered inside the border.
///
/// Custom chrome over [EditableText] rather than a Material
/// [TextField]. Selection gestures and the copy/paste toolbar reuse
/// Flutter's public selection machinery
/// ([TextSelectionGestureDetectorBuilder],
/// [AdaptiveTextSelectionToolbar]) — "custom" means custom chrome, not
/// a reimplementation of text editing.
class StudioTextField extends StatefulWidget {
  const StudioTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hint,
    this.label,
    this.prefix,
    this.suffix,
    this.enabled = true,
    this.error = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.style,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  }) : assert(controller == null || initialValue == null,
            'Provide a controller or an initialValue, not both.');

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;

  /// Muted placeholder shown while the field is empty.
  final String? hint;

  /// Muted label rendered above the field.
  final String? label;

  /// Input-group slot inside the chrome, before the text.
  final Widget? prefix;

  /// Input-group slot inside the chrome, after the text.
  final Widget? suffix;

  final bool enabled;

  /// Draws the error border.
  final bool error;

  final bool autofocus;
  final TextAlign textAlign;
  final TextStyle? style;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<StudioTextField> createState() => _StudioTextFieldState();
}

class _StudioTextFieldState extends State<StudioTextField>
    implements TextSelectionGestureDetectorBuilderDelegate {
  @override
  final GlobalKey<EditableTextState> editableTextKey =
      GlobalKey<EditableTextState>();

  @override
  bool get forcePressEnabled => false;

  @override
  bool get selectionEnabled => widget.enabled;

  late final _gestureBuilder =
      TextSelectionGestureDetectorBuilder(delegate: this);

  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  var _hover = false;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownedController ??= TextEditingController(text: widget.initialValue));

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(StudioTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = _focusNode.hasFocus;
    final borderColor = widget.error
        ? AppTokens.error
        : focused
            ? AppTokens.primary
            : AppTokens.border;
    final textStyle = TextStyle(
      fontSize: 12.5,
      color: widget.enabled
          ? AppTokens.textPrimary
          : AppTokens.textMuted.withValues(alpha: 0.5),
    ).merge(widget.style);

    final editable = EditableText(
      key: editableTextKey,
      controller: _controller,
      focusNode: _focusNode,
      style: textStyle,
      cursorColor: AppTokens.primary,
      backgroundCursorColor: AppTokens.surfaceHigh,
      selectionColor: AppTokens.primary.withValues(alpha: 0.35),
      selectionControls: desktopTextSelectionControls,
      contextMenuBuilder: (context, state) =>
          AdaptiveTextSelectionToolbar.editableText(editableTextState: state),
      rendererIgnoresPointer: true,
      autofocus: widget.autofocus,
      readOnly: !widget.enabled,
      textAlign: widget.textAlign,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      keyboardAppearance: Brightness.dark,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );

    // Hint sits behind the (transparent-backed) editable text.
    final core = Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        if (widget.hint != null)
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? Text(widget.hint!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppTokens.textMuted, fontSize: 12))
                : const SizedBox.shrink(),
          ),
        _gestureBuilder.buildGestureDetector(
          behavior: HitTestBehavior.translucent,
          child: editable,
        ),
      ],
    );

    Widget field = MouseRegion(
      cursor:
          widget.enabled ? SystemMouseCursors.text : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        // Clicks on the chrome (padding, empty prefix/suffix gutters)
        // focus the field; the editable's own gesture detector and any
        // interactive prefix/suffix children win hit-testing first.
        onTap: () => _focusNode.requestFocus(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _hover && widget.enabled && !focused
                ? Color.alphaBlend(AppTokens.surfaceHigh.withValues(alpha: 0.4),
                    AppTokens.field)
                : AppTokens.field,
            border: Border.all(
              color: borderColor,
              width: focused || widget.error ? 1.2 : 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            if (widget.prefix != null)
              Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: widget.prefix),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: core,
              ),
            ),
            if (widget.suffix != null)
              Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: widget.suffix),
          ]),
        ),
      ),
    );

    if (!widget.enabled) {
      field = ExcludeFocus(child: IgnorePointer(child: field));
    }

    if (widget.label != null) {
      field = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(widget.label!,
                style: TextStyle(color: AppTokens.textMuted, fontSize: 12)),
          ),
          field,
        ],
      );
    }
    return field;
  }
}
