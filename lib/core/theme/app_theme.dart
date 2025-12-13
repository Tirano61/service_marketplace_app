import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTextStyles.textTheme,
      useMaterial3: true,
    );
  }
}
