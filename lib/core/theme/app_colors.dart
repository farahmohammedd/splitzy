import 'package:flutter/painting.dart';

/// The Splitzy brand palette.
///
/// This is the only place brand hex values are defined. Widgets should read
/// colors from `Theme.of(context).colorScheme` or [AppBrandColors] rather than
/// referencing these constants directly.
abstract final class AppColors {
  static const Color primary = Color(0xFF00695C);
  static const Color primaryDark = Color(0xFF004D40);
  static const Color primaryLight = Color(0xFFA8D5BA);
  static const Color secondary = Color(0xFFCFE6C7);

  static const Color moneyAccent = Color(0xFFF4B942);
  static const Color moneyHighlight = Color(0xFFFFD166);

  static const Color background = Color(0xFFFFFDF5);
  static const Color surface = Color(0xFFFFFEFA);

  static const Color textPrimary = Color(0xFF172B27);
  static const Color textSecondary = Color(0xFF64736E);

  static const Color border = Color(0xFFDDE7E1);
  static const Color error = Color(0xFFD95C5C);
  static const Color success = Color(0xFF198754);

  /// Foreground for content on [primary], [primaryDark] and [error].
  static const Color onDark = Color(0xFFFFFFFF);
}

/// Colors owned by third-party brands, used only where their branding
/// guidelines require them (e.g. the Google "G" mark). Not part of the
/// Splitzy palette — never use these for app UI.
abstract final class ThirdPartyBrandColors {
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleRed = Color(0xFFEA4335);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleGreen = Color(0xFF34A853);
}
