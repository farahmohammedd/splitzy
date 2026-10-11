import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brand colors that have no matching slot in Material's [ColorScheme].
///
/// Read with `context.brandColors` (or
/// `Theme.of(context).extension<AppBrandColors>()`).
@immutable
class AppBrandColors extends ThemeExtension<AppBrandColors> {
  const AppBrandColors({
    required this.primaryDark,
    required this.moneyAccent,
    required this.moneyHighlight,
    required this.success,
  });

  static const AppBrandColors light = AppBrandColors(
    primaryDark: AppColors.primaryDark,
    moneyAccent: AppColors.moneyAccent,
    moneyHighlight: AppColors.moneyHighlight,
    success: AppColors.success,
  );

  final Color primaryDark;
  final Color moneyAccent;
  final Color moneyHighlight;
  final Color success;

  @override
  AppBrandColors copyWith({
    Color? primaryDark,
    Color? moneyAccent,
    Color? moneyHighlight,
    Color? success,
  }) {
    return AppBrandColors(
      primaryDark: primaryDark ?? this.primaryDark,
      moneyAccent: moneyAccent ?? this.moneyAccent,
      moneyHighlight: moneyHighlight ?? this.moneyHighlight,
      success: success ?? this.success,
    );
  }

  @override
  AppBrandColors lerp(AppBrandColors? other, double t) {
    if (other == null) return this;
    return AppBrandColors(
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t) ?? primaryDark,
      moneyAccent: Color.lerp(moneyAccent, other.moneyAccent, t) ?? moneyAccent,
      moneyHighlight:
          Color.lerp(moneyHighlight, other.moneyHighlight, t) ?? moneyHighlight,
      success: Color.lerp(success, other.success, t) ?? success,
    );
  }
}

extension AppBrandColorsContext on BuildContext {
  /// The [AppBrandColors] of the current theme.
  ///
  /// Falls back to [AppBrandColors.light] if the theme does not register the
  /// extension (e.g. a widget test that pumps a bare [MaterialApp]).
  AppBrandColors get brandColors =>
      Theme.of(this).extension<AppBrandColors>() ?? AppBrandColors.light;
}
