/// Spacing scale used for padding, margins and gaps.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

/// Corner radii.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;

  /// Fully rounded ends for pill-shaped buttons.
  static const double pill = 999;
}

/// Fixed component and layout sizes.
abstract final class AppSizes {
  /// Height of primary and secondary buttons.
  static const double buttonHeight = 56;

  /// Maximum width of screen content on tablets, desktop and web.
  static const double maxContentWidth = 480;
}
