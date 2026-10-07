import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    test('matches the confirmed brand palette', () {
      const palette = {
        'primary': (AppColors.primary, Color(0xFF00695C)),
        'primaryDark': (AppColors.primaryDark, Color(0xFF004D40)),
        'primaryLight': (AppColors.primaryLight, Color(0xFFA8D5BA)),
        'secondary': (AppColors.secondary, Color(0xFFCFE6C7)),
        'moneyAccent': (AppColors.moneyAccent, Color(0xFFF4B942)),
        'moneyHighlight': (AppColors.moneyHighlight, Color(0xFFFFD166)),
        'background': (AppColors.background, Color(0xFFFFFDF5)),
        'surface': (AppColors.surface, Color(0xFFFFFEFA)),
        'textPrimary': (AppColors.textPrimary, Color(0xFF172B27)),
        'textSecondary': (AppColors.textSecondary, Color(0xFF64736E)),
        'border': (AppColors.border, Color(0xFFDDE7E1)),
        'error': (AppColors.error, Color(0xFFD95C5C)),
        'success': (AppColors.success, Color(0xFF198754)),
      };

      for (final MapEntry(key: name, value: (actual, expected))
          in palette.entries) {
        expect(actual, expected, reason: name);
      }
    });
  });
}
