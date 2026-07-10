import 'package:flutter/material.dart';

import 'tokens.dart';

/// Desktop-style modal dialog (Affinity look): compact chrome, hairline
/// border, title bar with a close button, dense content, right-aligned
/// small action buttons. Use instead of AlertDialog everywhere.
///
/// [floating] makes it behave like an OS utility window (the About
/// panel): no dimmed barrier and draggable by its title bar.
// ponytail: in-process window, not a real NSWindow — Flutter
// multi-window + cross-engine document state isn't worth it yet.
Future<T?> showStudioDialog<T>({
  required BuildContext context,
  required String title,
  required Widget body,
  List<Widget> actions = const [],
  double width = 340,
  bool floating = false,

  /// Content inset. Pass [EdgeInsets.zero] for full-bleed bodies that
  /// manage their own layout (e.g. the New Project panes).
  EdgeInsetsGeometry contentPadding = const EdgeInsets.fromLTRB(16, 14, 16, 16),
}) {
  var dragOffset = Offset.zero;
  return showDialog<T>(
    context: context,
    barrierColor: floating ? Colors.transparent : const Color(0x66000000),
    builder: (context) => StatefulBuilder(
      builder: (context, setWindowState) {
        // Windows favors square corners; macOS/GTK round more.
        final isWindows = Theme.of(context).platform == TargetPlatform.windows;
        final radius = BorderRadius.circular(isWindows ? 4 : 8);
        // OS-tailored window shadows: macOS/GTK cast a large, soft,
        // low-opacity drop plus a faint contact shadow; Win11 uses a
        // tighter single shadow.
        final shadows = isWindows
            ? const [
                BoxShadow(
                    color: Color(0x47000000),
                    blurRadius: 22,
                    offset: Offset(0, 10)),
              ]
            : const [
                BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 50,
                    spreadRadius: -10,
                    offset: Offset(0, 25)),
                BoxShadow(
                    color: Color(0x2E000000),
                    blurRadius: 12,
                    offset: Offset(0, 2)),
              ];
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Transform.translate(
            offset: dragOffset,
            child: Container(
              width: width,
              // Children clip to the rounded corners; the hairline border
              // lives in foregroundDecoration so it paints ON TOP of
              // content — opaque bodies can't cut it at the corners.
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppTokens.popoverSurface,
                borderRadius: radius,
                boxShadow: shadows,
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: AppTokens.popoverBorder),
                borderRadius: radius,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title bar adapts to the host OS window chrome. Every
                  // dialog is draggable by its title bar (desktop
                  // convention); [floating] only removes the barrier dim.
                  Builder(builder: (context) {
                    return GestureDetector(
                      onPanUpdate: (details) =>
                          setWindowState(() => dragOffset += details.delta),
                      child: _DialogTitleBar(
                        title: title,
                        onClose: () => Navigator.pop(context),
                      ),
                    );
                  }),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: contentPadding,
                      child: DefaultTextStyle(
                        style: TextStyle(
                            fontSize: 12, color: AppTokens.textPrimary),
                        child: body,
                      ),
                    ),
                  ),
                  if (actions.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTokens.panel,
                        border:
                            Border(top: BorderSide(color: AppTokens.border)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          for (final (index, action) in actions.indexed) ...[
                            if (index > 0) const SizedBox(width: 8),
                            action,
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// OS-native dialog title bar:
///
/// - **macOS** — red traffic-light close on the left (x on hover),
///   centered title.
/// - **Windows** — title on the left, wide flat caption close button
///   on the right that turns red on hover (Win11 style).
/// - **Linux/other** — centered title, circular hover-highlight close
///   button on the right (GTK/Adwaita style).
class _DialogTitleBar extends StatefulWidget {
  const _DialogTitleBar({required this.title, required this.onClose});

  final String title;
  final VoidCallback onClose;

  @override
  State<_DialogTitleBar> createState() => _DialogTitleBarState();
}

class _DialogTitleBarState extends State<_DialogTitleBar> {
  var _hover = false;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final titleText = Text(
      widget.title,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTokens.textPrimary),
    );

    final Widget bar = switch (platform) {
      TargetPlatform.macOS => Row(children: [
          const SizedBox(width: 8),
          MouseRegion(
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: Tooltip(
              message: 'Close',
              waitDuration: const Duration(milliseconds: 600),
              child: GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5F57),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE0443E)),
                  ),
                  child: _hover
                      ? const Icon(Icons.close,
                          size: 9, color: Color(0xFF730B00))
                      : null,
                ),
              ),
            ),
          ),
          // Balance the traffic light so the title truly centers.
          Expanded(child: Center(child: titleText)),
          const SizedBox(width: 20),
        ]),
      TargetPlatform.windows => Row(children: [
          const SizedBox(width: 12),
          Expanded(child: titleText),
          _WindowsCloseButton(onClose: widget.onClose),
        ]),
      _ => Row(children: [
          const SizedBox(width: 34),
          Expanded(child: Center(child: titleText)),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Tooltip(
              message: 'Close',
              waitDuration: const Duration(milliseconds: 600),
              child: InkWell(
                onTap: widget.onClose,
                customBorder: const CircleBorder(),
                hoverColor: AppTokens.surfaceHigh,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child:
                      Icon(Icons.close, size: 14, color: AppTokens.textPrimary),
                ),
              ),
            ),
          ),
        ]),
    };

    return Container(
      height: 34,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTokens.border)),
      ),
      child: bar,
    );
  }
}

class _WindowsCloseButton extends StatefulWidget {
  const _WindowsCloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_WindowsCloseButton> createState() => _WindowsCloseButtonState();
}

class _WindowsCloseButtonState extends State<_WindowsCloseButton> {
  var _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          width: 44,
          height: 33,
          color: _hover ? const Color(0xFFC42B1C) : Colors.transparent,
          child: Icon(Icons.close,
              size: 14, color: _hover ? Colors.white : AppTokens.textPrimary),
        ),
      ),
    );
  }
}
