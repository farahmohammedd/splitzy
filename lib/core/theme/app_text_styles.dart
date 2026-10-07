import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Splitzy typography.
///
/// Uses the platform default font family (no bundled fonts). The reference
/// designs' heavy, rounded wordmark is approximated with [FontWeight.w800].
abstract final class AppTextStyles {
  static const TextTheme textTheme = TextTheme(
    // Brand wordmark ("Splitzy") on the launch and splash screens.
    displaySmall: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      height: 1.1,
      color: AppColors.textPrimary,
    ),
    // Screen titles, e.g. "Welcome Back".
    headlineMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.25,
      height: 1.2,
      color: AppColors.textPrimary,
    ),
    // Section headings, e.g. "Split Expenses / Build Stronger Bonds".
    headlineSmall: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.25,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: AppColors.textPrimary,
    ),
    // Taglines and subtitles.
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w500,
      height: 1.35,
      color: AppColors.textSecondary,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.35,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: AppColors.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.textSecondary,
    ),
    // Button labels.
    labelLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.textSecondary,
    ),
  );
}
