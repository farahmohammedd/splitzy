import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_colors.dart';
import 'package:splitzy/core/theme/app_text_styles.dart';
import 'package:splitzy/core/theme/app_theme.dart';

void main() {
  group('AppTheme.light', () {
    final theme = AppTheme.light;
    final scheme = theme.colorScheme;

    test('maps the palette onto the ColorScheme', () {
      expect(scheme.brightness, Brightness.light);
      expect(scheme.primary, AppColors.primary);
      expect(scheme.onPrimary, AppColors.onDark);
      expect(scheme.primaryContainer, AppColors.primaryLight);
      expect(scheme.secondaryContainer, AppColors.secondary);
      expect(scheme.tertiary, AppColors.moneyAccent);
      expect(scheme.tertiaryContainer, AppColors.moneyHighlight);
      expect(scheme.surface, AppColors.surface);
      expect(scheme.onSurface, AppColors.textPrimary);
      expect(scheme.onSurfaceVariant, AppColors.textSecondary);
      expect(scheme.outline, AppColors.border);
      expect(scheme.error, AppColors.error);
    });

    test('pairs gold with dark text, never white', () {
      expect(scheme.onTertiary, AppColors.textPrimary);
      expect(scheme.onTertiaryContainer, AppColors.textPrimary);
    });

    test('fills primary buttons with the deep emerald', () {
      final style = theme.filledButtonTheme.style;

      expect(style?.backgroundColor?.resolve({}), AppColors.primaryDark);
      expect(style?.foregroundColor?.resolve({}), AppColors.onDark);
    });

    test('uses the cream background for scaffolds', () {
      expect(theme.scaffoldBackgroundColor, AppColors.background);
    });

    test('registers the brand colors extension', () {
      final brand = theme.extension<AppBrandColors>();

      expect(brand, isNotNull);
      expect(brand?.primaryDark, AppColors.primaryDark);
      expect(brand?.moneyAccent, AppColors.moneyAccent);
      expect(brand?.moneyHighlight, AppColors.moneyHighlight);
      expect(brand?.success, AppColors.success);
    });

    test('uses the platform default font with heavy display weights', () {
      // No custom family is set; ThemeData fills in the platform font
      // (e.g. Roboto on Android, San Francisco on iOS).
      expect(AppTextStyles.textTheme.displaySmall?.fontFamily, isNull);
      expect(theme.textTheme.displaySmall?.fontWeight, FontWeight.w800);
      expect(theme.textTheme.headlineMedium?.fontWeight, FontWeight.w800);
    });
  });

  group('AppBrandColors', () {
    const base = AppBrandColors.light;

    test('copyWith replaces only the given colors', () {
      final copy = base.copyWith(success: AppColors.error);

      expect(copy.success, AppColors.error);
      expect(copy.primaryDark, base.primaryDark);
      expect(copy.moneyAccent, base.moneyAccent);
      expect(copy.moneyHighlight, base.moneyHighlight);
    });

    test('lerp returns the endpoints at t = 0 and t = 1', () {
      final other = base.copyWith(primaryDark: AppColors.primary);

      expect(base.lerp(other, 0).primaryDark, base.primaryDark);
      expect(base.lerp(other, 1).primaryDark, AppColors.primary);
    });

    test('lerp with null returns itself', () {
      expect(base.lerp(null, 0.5), same(base));
    });
  });
}
