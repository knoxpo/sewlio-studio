import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studio_design_system/studio_design_system.dart';

import 'tool_docs.dart';

/// Affinity-style Tool Learning Card: wraps a toolbox button and shows
/// a rich hover card (name, shortcut, description, quick-start hints,
/// Learn More) after a short delay. The card stays while the pointer
/// is over it and fades away otherwise. Content comes entirely from
/// [ToolDoc] metadata, so plugin tools get the same card for free.
class ToolCardHover extends StatefulWidget {
  const ToolCardHover({super.key, required this.doc, required this.child});

  final ToolDoc? doc;
  final Widget child;

  @override
  State<ToolCardHover> createState() => _ToolCardHoverState();
}

class _ToolCardHoverState extends State<ToolCardHover> {
  final _link = LayerLink();
  final _overlay = OverlayPortalController();
  Timer? _showTimer;
  Timer? _hideTimer;
  var _overCard = false;

  static const _showDelay = Duration(milliseconds: 700);
  static const _hideDelay = Duration(milliseconds: 200);

  @override
  void dispose() {
    _showTimer?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleShow() {
    _hideTimer?.cancel();
    _showTimer ??= Timer(_showDelay, () {
      _showTimer = null;
      if (mounted) _overlay.show();
    });
  }

  void _scheduleHide() {
    _showTimer?.cancel();
    _showTimer = null;
    _hideTimer?.cancel();
    _hideTimer = Timer(_hideDelay, () {
      if (mounted && !_overCard && _overlay.isShowing) _overlay.hide();
    });
  }

  void _hideNow() {
    _showTimer?.cancel();
    _showTimer = null;
    _overCard = false;
    if (_overlay.isShowing) _overlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    if (doc == null) return widget.child;
    return OverlayPortal(
      controller: _overlay,
      overlayChildBuilder: (context) => CompositedTransformFollower(
        link: _link,
        targetAnchor: Alignment.topRight,
        followerAnchor: Alignment.topLeft,
        offset: const Offset(10, -6),
        child: Align(
          alignment: Alignment.topLeft,
          child: MouseRegion(
            onEnter: (_) => _overCard = true,
            onExit: (_) {
              _overCard = false;
              _scheduleHide();
            },
            child: _ToolCard(doc: doc, onAction: _hideNow),
          ),
        ),
      ),
      child: CompositedTransformTarget(
        link: _link,
        child: MouseRegion(
          onEnter: (_) => _scheduleShow(),
          onExit: (_) => _scheduleHide(),
          // Selecting the tool dismisses the card immediately.
          child:
              Listener(onPointerDown: (_) => _hideNow(), child: widget.child),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.doc, required this.onAction});

  final ToolDoc doc;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(8 * (1 - t), 0), child: child),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: AppTokens.popoverSurface,
          border: Border.all(color: AppTokens.popoverBorder),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
                color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(doc.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              if (doc.shortcut != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTokens.field,
                    border: Border.all(color: AppTokens.border),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(doc.shortcut!,
                      style: TextStyle(
                          fontSize: 11, color: AppTokens.textPrimary)),
                ),
            ]),
            const SizedBox(height: 6),
            Text(doc.description,
                style: TextStyle(
                    fontSize: 12, height: 1.35, color: AppTokens.textMuted)),
            if (doc.quickStart.isNotEmpty || doc.modifiers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: AppTokens.border),
              ),
              for (final hint in [...doc.quickStart, ...doc.modifiers])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•  ',
                            style: TextStyle(
                                fontSize: 11.5, color: AppTokens.textMuted)),
                        Expanded(
                          child: Text(hint,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.3,
                                  color: AppTokens.textPrimary)),
                        ),
                      ]),
                ),
            ],
            const SizedBox(height: 8),
            Center(
              child: StudioButton(
                label: 'Learn More',
                onPressed: () {
                  onAction();
                  showToolDocumentation(context, doc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full documentation dialog, generated from the same [ToolDoc]
/// metadata as the hover card.
Future<void> showToolDocumentation(BuildContext context, ToolDoc doc) {
  Widget section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudioSectionLabel(title),
          ...children,
        ],
      );
  Widget bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('•  ', style: TextStyle(color: AppTokens.textMuted)),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ]),
      );
  return showStudioDialog<void>(
    context: context,
    title: doc.shortcut == null ? doc.name : '${doc.name}  [${doc.shortcut}]',
    width: 440,
    body: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(doc.description, style: const TextStyle(height: 1.4)),
        if (doc.quickStart.isNotEmpty)
          section(
              'Quick start', [for (final step in doc.quickStart) bullet(step)]),
        if (doc.modifiers.isNotEmpty)
          section('Modifier keys',
              [for (final modifier in doc.modifiers) bullet(modifier)]),
        if (doc.learnMore.isNotEmpty)
          section('Notes', [
            Text(doc.learnMore,
                style: TextStyle(height: 1.4, color: AppTokens.textPrimary)),
          ]),
      ],
    ),
  );
}
