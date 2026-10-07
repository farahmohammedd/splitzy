import 'package:flutter/material.dart';

import 'app_brand_colors.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Builds the Splitzy [ThemeData].
///
/// Light theme only; the brand palette has no dark variant yet.
abstract final class AppTheme {
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onDark,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.textPrimary,
    secondaryContainer: AppColors.secondary,
    onSecondaryContainer: AppColors.primaryDark,
    // Gold is always paired with dark text: white on gold is unreadable.
    tertiary: AppColors.moneyAccent,
    onTertiary: AppColors.textPrimary,
    tertiaryContainer: AppColors.moneyHighlight,
    onTertiaryContainer: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.onDark,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  static ThemeData get light {
    const textTheme = AppTextStyles.textTheme;
    const pillShape = StadiumBorder();
    const buttonSize = Size(double.infinity, AppSizes.buttonHeight);

    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: textTheme,
      extensions: const [AppBrandColors.light],
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Primary calls to action use the deeper emerald (see design refs).
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onDark,
          minimumSize: buttonSize,
          shape: pillShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          minimumSize: buttonSize,
          shape: pillShape,
          side: const BorderSide(color: AppColors.border),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIconColor: AppColors.textPrimary,
        suffixIconColor: AppColors.textPrimary,
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: fieldBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDark,
        linearTrackColor: AppColors.primaryLight,
        linearMinHeight: 8,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}
