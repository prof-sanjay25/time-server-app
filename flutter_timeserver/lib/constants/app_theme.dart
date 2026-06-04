import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light, no-action-bar theme matching the original `AppTheme`.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primaryDark,
        secondary: AppColors.accent,
        surface: AppColors.white,
      ),
      primaryColor: AppColors.primary,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.blue : AppColors.greyLight,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.blue.withValues(alpha: 0.5)
              : AppColors.grey.withValues(alpha: 0.4),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.primaryDark,
        displayColor: AppColors.primaryDark,
      ),
    );
  }
}
