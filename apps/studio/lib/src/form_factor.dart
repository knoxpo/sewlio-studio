import 'package:flutter/foundation.dart';

/// Workspace layout breakpoints (platform-requirements §14).
enum FormFactor {
  /// ≥1200 px: permanent panels (current desktop layout).
  desktop,

  /// 900–1199 px: dock collapsible behind a toolbar toggle.
  tabletLandscape,

  /// <900 px: full-bleed canvas; toolbox and dock float as overlays.
  /// (The spec's phone tier is out of scope — tablets are the target.)
  tabletPortrait,
}

FormFactor formFactorFor(double width) => width >= 1200
    ? FormFactor.desktop
    : width >= 900
        ? FormFactor.tabletLandscape
        : FormFactor.tabletPortrait;

/// 48 dp touch targets apply on touch-first platforms, independent of
/// window width (a narrow desktop window keeps compact mouse targets).
bool get isTouchPlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android;
